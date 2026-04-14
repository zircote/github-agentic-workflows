---
name: aw-daily
description: |
  Fully autonomous daily pipeline for the aw-author plugin. Executes intelligence
  research (web search + GitHub activity queries), posts to Discussions, performs
  gap analysis against reference files, creates issues, implements changes on
  develop branch, creates PR, requests review, and auto-merges. Designed for
  unattended execution with zero human intervention. Triggers on: "aw-daily",
  "daily pipeline", "daily cycle", "autonomous update".
---

# Autonomous Daily Intelligence Pipeline

You are an autonomous operations agent. Execute all phases below in order. If any phase fails, follow the error mode specified. **Do not prompt the user for input at any point.** This pipeline is designed for fully unattended execution.

Parse the argument string for optional flags:
- `--dry-run` -- Research + gap analysis only, show diff, do not commit or PR
- `--skip-research` -- Start at Phase 4 using the latest report in `outputs/gh-aw-reports/`
- `--skip-implementation` -- Research + gap analysis + issues only, do not edit files or PR
- `--no-merge` -- Create PR but do not auto-merge to `develop`

---

## Phase 0: Pre-flight & Idempotency

1. Determine today's date: `date +%Y-%m-%d` -> store as `TODAY`
2. Verify `gh` CLI: `gh auth status`
3. Verify clean working tree: `git status --porcelain` must be empty
   - If dirty: **ABORT** -- "Working tree is dirty. Commit or stash before running /aw-daily."
4. Capture current branch: `git branch --show-current` -> store as `ORIGINAL_BRANCH`

**Ensure `develop` branch exists:**
```bash
if ! git ls-remote --exit-code origin develop >/dev/null 2>&1; then
  git checkout main
  git checkout -b develop
  git push -u origin develop
  git checkout "$ORIGINAL_BRANCH"
fi
git fetch origin develop
```

**Idempotency checks:**

5. Check if today's Discussion already exists:
```bash
EXISTING_DISCUSSION=$(gh api graphql -f query='{ repository(owner:"zircote", name:"github-agentic-workflows") { discussions(categoryId:"DIC_kwDORSXBr84C61Lr", first:5, orderBy:{field:CREATED_AT, direction:DESC}) { nodes { title url } } } }' -q ".data.repository.discussions.nodes[] | select(.title | contains(\"$TODAY\")) | .url")
```
If found and `--skip-research` not set: set `RESEARCH_DONE=true`, store URL as `DISCUSSION_URL`

6. Check if today's PR already exists:
```bash
EXISTING_PR=$(gh pr list --repo zircote/github-agentic-workflows --base develop --search "daily-intelligence-$TODAY" --state all --json number,url -q '.[0].url')
```
If found: report "Today's pipeline already completed. PR: $EXISTING_PR" and **exit successfully**.

---

## Phase 1: Research (Intelligence Sweep)

Skip if `RESEARCH_DONE=true` or `--skip-research` flag.

### 1a. Load context

1. Read `skills/gh-aw-report/knowledge-base.md` -- note the most recent entry date as `LAST_DATE`
2. Read `skills/gh-aw-report/references/gh-aw-architecture.md` for current known state
3. Read `skills/gh-aw-report/references/search-queries.md` for query library
4. Read `skills/aw-daily/references/tracked-repos.md` for GitHub activity query patterns

### 1b. Web searches

Execute the 8 primary sweep queries from the search query library:
1. gh-aw core: releases, updates, breaking changes
2. GitHub Actions AI features
3. GitHub Copilot Workspace updates
4. GitHub Copilot Agent Mode / CLI updates
5. GitHub Models API changes
6. GitHub MCP Server releases
7. Claude Code x GitHub integrations
8. Agentic CI/CD community patterns

For each query, extract: version numbers, release dates, feature descriptions, deprecation notices, breaking changes, source URLs.

### 1c. GitHub activity queries

Query tracked repositories for activity since `LAST_DATE`:

```bash
# github/gh-aw -- issues, PRs, discussions
gh search issues --repo github/gh-aw --created ">=$LAST_DATE" --sort created --json title,url,labels,createdAt --limit 20
gh search prs --repo github/gh-aw --created ">=$LAST_DATE" --sort created --json title,url,labels,state,createdAt --limit 20

# github/github-mcp-server -- releases
gh release list --repo github/github-mcp-server --limit 5 --json tagName,publishedAt,name

# github/gh-aw -- discussions
gh api graphql -f query='{ repository(owner:"github", name:"gh-aw") {
  discussions(first:10, orderBy:{field:CREATED_AT, direction:DESC}) {
    nodes { title url createdAt category { name } }
  }
}}'

# zircote/github-agentic-workflows -- own activity
gh search issues --repo zircote/github-agentic-workflows --created ">=$LAST_DATE" --sort created --json title,url,labels,createdAt --limit 10
```

Prioritize items labeled `breaking-change`, `deprecation`, `safe-output`, `engine`, `mcp`.

### 1d. Synthesize report

Combine web search findings and GitHub activity into the standard report structure:

```markdown
# gh-aw Ecosystem Intelligence Report -- {TODAY}

## Executive Summary
## 1. gh-aw Core
## 2. GitHub Actions AI
## 3. Copilot Workspace
## 4. Copilot Agent Mode
## 5. GitHub Models API
## 6. GitHub MCP Server
## 7. Claude Code x GitHub
## 8. Agentic CI/CD Community
## GitHub Activity Since {LAST_DATE}
## Deprecation Watch
## Recommended Actions
## Sources
```

Save to `outputs/gh-aw-reports/{TODAY}.md`. If file exists, append counter: `{TODAY}-2.md`.

**Error mode:** If zero results across all 8 web searches AND all GitHub queries return empty, **ABORT** -- "No intelligence data available. Check network and API access."

---

## Phase 2: Knowledge Base Update

1. Review findings for stable, persistent facts (version releases, deprecations, breaking changes, architecture changes)
2. Check existing entries in `skills/gh-aw-report/knowledge-base.md` for duplicates
3. Append new entries using the format:
```markdown
### YYYY-MM-DD -- category -- Title
Content
```
4. Mark superseded entries with `[SUPERSEDED by YYYY-MM-DD]`

Categories: `version`, `deprecation`, `breaking-change`, `architecture`, `ecosystem`, `security`, `feature`

**Error mode:** If write fails, log warning and continue. KB update is not blocking.

---

## Phase 3: Discussion Posting

Skip if `RESEARCH_DONE=true`.

Post the report to GitHub Discussions:

```bash
REPO_ID=$(gh api graphql -f query='{ repository(owner:"zircote", name:"github-agentic-workflows") { id } }' -q '.data.repository.id')

DISCUSSION_URL=$(gh api graphql -f query='
  mutation($repoId: ID!, $catId: ID!, $title: String!, $body: String!) {
    createDiscussion(input: {repositoryId: $repoId, categoryId: $catId, title: $title, body: $body}) {
      discussion { url }
    }
  }' \
  -f repoId="$REPO_ID" \
  -f catId="DIC_kwDORSXBr84C61Lr" \
  -f title="gh-aw Intelligence Report -- $TODAY" \
  -f body="$(cat outputs/gh-aw-reports/$TODAY.md)" \
  -q '.data.createDiscussion.discussion.url')
```

Store `DISCUSSION_URL` for the final summary.

**Error mode:** If GraphQL fails, log warning and continue. Discussion posting is historical, not blocking.

---

## Phase 4: Gap Analysis

Read `skills/aw-daily/references/gap-analysis-targets.md` to load the reference file inventory.

For each reference file in the inventory:

1. Read the file
2. Compare against today's research findings:
   - **Version numbers**: Check tracked version locations against release data
   - **Deprecated features**: Check if deprecated items are documented with warnings
   - **New features**: Check if new safe-outputs, tools, fields, patterns are covered
   - **Corrections**: Check if any findings contradict current content
3. Produce a structured gap entry for each discrepancy:

```
GAP-{NNN}: {type} | {file} | {section} | {description} | {source}
```

Where `type` is: `incorrect` (priority 1), `outdated` (priority 2), `missing` (priority 3).

Sort gaps by priority. Limit to **top 5 gaps** per run to keep changes reviewable.

If no gaps found: report "No actionable gaps identified. Reference files are current." and skip to Phase 9.

If `--dry-run`: report the gap list and **stop** (skip Phases 5-8).

---

## Phase 5: Issue Creation

For each gap (up to 5):

1. Check for existing open issue with matching title:
```bash
EXISTING=$(gh search issues "[aw-daily]" --repo zircote/github-agentic-workflows --state open --json title -q ".[].title" | grep -c "GAP-{NNN}")
```
2. If no existing issue, create one:
```bash
gh issue create \
  --repo zircote/github-agentic-workflows \
  --title "[aw-daily] GAP-{NNN}: {short description}" \
  --body "## Gap Details

**Type:** {incorrect|outdated|missing}
**File:** \`{path}\`
**Section:** {section heading}

## Current Content
{excerpt of current content}

## Expected Content
{what should change based on research}

## Source
{URL or GitHub activity reference}

## Intelligence Report
{link to today's Discussion}

---
_Automated by /aw-daily on {TODAY}_" \
  --label "automated,reference-update"
```

Store issue numbers for PR linking.

If `--skip-implementation`: report issue list and **stop** (skip Phases 6-8).

**Error mode:** If issue creation fails for one gap, log warning and continue with remaining gaps.

---

## Phase 6: Implementation

1. Switch to develop and create feature branch:
```bash
git checkout develop
git pull origin develop
git checkout -b daily-intelligence-{TODAY}
```

2. For each gap, ordered by priority:
   - Read the target file
   - Locate the section using header text as anchor (NOT line numbers)
   - Apply the edit:
     - **Version updates**: Find exact old string, replace with new
     - **New sections**: Insert after the appropriate parent section
     - **Deprecation notices**: Insert after the feature heading
     - **New table rows**: Append to the table body
     - **Corrections**: Replace incorrect content
   - If an edit fails, revert that file: `git checkout -- {file}` and continue

3. Check if `.claude/` mirror exists for any edited file. If so, apply the same change there.

4. Verify changes make sense: `git diff --stat` should show only the expected files.

5. Stage and commit:
```bash
git add skills/ .claude/skills/
git commit -m "docs(references): daily intelligence update {TODAY}

{bullet per gap addressed}

Closes {#issue1}, {#issue2}, ...

Automated by /aw-daily"
```

6. Push:
```bash
git push -u origin daily-intelligence-{TODAY}
```

If `--dry-run`: show the diff but do not commit or push.

**Error mode:** If commit fails, leave branch for manual inspection. Switch back to `ORIGINAL_BRANCH`.

---

## Phase 7: PR Creation

```bash
gh pr create \
  --draft \
  --repo zircote/github-agentic-workflows \
  --base develop \
  --head daily-intelligence-{TODAY} \
  --title "docs(references): daily intelligence update {TODAY}" \
  --body "## Summary

Automated reference file updates from daily intelligence sweep.

## Gaps Addressed

{list with issue links using 'Closes #NNN' syntax}

## Intelligence Report

{DISCUSSION_URL}

## Changes

{git diff --stat output}

---
_Automated by /aw-daily_"
```

Store the PR URL and number.

**Mark PR ready** after all changes are pushed:
```bash
gh pr ready {PR_NUMBER}
```

**Error mode:** If PR creation fails, report error. Leave branch for manual inspection. Switch back to `ORIGINAL_BRANCH`.

---

## Phase 8: Review & Merge

1. **Request review** (try Copilot, fall back to self-review):
```bash
gh pr edit {PR_NUMBER} --add-reviewer "@copilot" 2>/dev/null || echo "Copilot review unavailable, proceeding with self-review"
```

2. **Wait for CI** (if configured):
```bash
# Poll checks every 15 seconds, max 5 minutes
for i in $(seq 1 20); do
  STATUS=$(gh pr checks {PR_NUMBER} --json bucket -q '.[].bucket' 2>/dev/null | sort -u)
  if echo "$STATUS" | grep -q "fail"; then
    echo "CI failed. Leaving PR open for manual review."
    break
  fi
  if echo "$STATUS" | grep -qv "pending"; then
    echo "CI passed."
    break
  fi
  sleep 15
done
```

3. **Merge** (unless `--no-merge` or CI failed):
```bash
gh pr merge {PR_NUMBER} --squash --auto --delete-branch
```

4. **Restore original branch**:
```bash
git checkout "$ORIGINAL_BRANCH"
git pull origin "$ORIGINAL_BRANCH" 2>/dev/null || true
```

**Error mode:** If merge fails or CI fails, leave PR open. Report PR URL for manual action.

---

## Phase 9: Final Summary

```
+--------------------------------------------------+
| /aw-daily complete                               |
+--------------------------------------------------+
| Date:          {TODAY}                           |
| Searches:      N web + M GitHub activity queries |
| Findings:      N items across M domains          |
| KB Updates:    N new entries                     |
| Discussion:    {DISCUSSION_URL}                  |
| Gaps Found:    N (P incorrect, Q outdated, R new)|
| Issues:        N created, M skipped (existing)   |
| Files Changed: N                                 |
| PR:            {PR_URL}                          |
| Review:        copilot / self                    |
| Merged:        yes / no / skipped                |
+--------------------------------------------------+
```

---

## Error Recovery

If any phase fails mid-execution:
1. Report the phase number, what failed, and why
2. If on a feature branch, switch back to `ORIGINAL_BRANCH`
3. Do NOT delete the feature branch on failure -- leave for inspection
4. Report what succeeded and what needs manual attention

**Re-run guidance:**
- If Phases 1-3 succeeded but 4+ failed: re-run with `--skip-research`
- If Phases 1-5 succeeded but 6+ failed: re-run with `--skip-research` (idempotency prevents duplicate issues)
- Same-day re-runs are safe -- idempotency checks prevent all duplicate work
