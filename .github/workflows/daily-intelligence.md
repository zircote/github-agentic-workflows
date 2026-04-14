---
name: "Daily Intelligence Pipeline"
description: "Autonomous daily gh-aw ecosystem research, gap analysis, and reference file updates"
timeout-minutes: 30

on:
  schedule: "daily around 07:00"
  workflow_dispatch:

permissions:
  contents: read
  pull-requests: read
  discussions: read
  issues: read

engine:
  id: copilot
  model: claude-sonnet

tools:
  bash: ["gh:*", "git:*", "echo", "cat", "grep", "date", "mkdir", "jq", "wc", "sort", "diff"]
  edit:
    paths: ["skills/**", ".claude/skills/**"]
  web-search:
  web-fetch:
  cache-memory:
    key: "daily-intelligence"
    retention-days: 7
    scope: workflow

safe-outputs:
  create-discussion:
    title-prefix: "gh-aw Intelligence Report — "
    category: "Project News"
    max: 1
  create-issue:
    title-prefix: "[aw-daily] "
    labels: [automated, reference-update]
    close-older-issues: false
    max: 5
  create-pull-request:
    title-prefix: "docs(references): "
    labels: [automated, reference-update]
    draft: false
    base: develop
    max: 1
  push-to-pull-request-branch:
    target: "created"
    max: 10
  add-comment:
    discussions: false
    max: 3
  add-labels:
    allowed: [automated, reference-update, intelligence]
    max: 5
---

# Daily Intelligence Pipeline Agent

## Context

You are an autonomous operations agent running the daily intelligence and reference update pipeline for the `aw-author` plugin in ${{ github.repository }}. Today's date determines the report filename and idempotency signals.

This workflow runs daily around 07:00 via fuzzy schedule, or on-demand via workflow dispatch.

## Reference Files

The following files contain the skill logic and reference data:
- `skills/aw-daily/SKILL.md` — Full 9-phase pipeline logic
- `skills/aw-daily/references/gap-analysis-targets.md` — Reference file inventory for gap analysis
- `skills/aw-daily/references/tracked-repos.md` — GitHub repos to query for activity
- `skills/gh-aw-report/references/search-queries.md` — Web search query library
- `skills/gh-aw-report/knowledge-base.md` — Persistent knowledge base

## Instructions

Execute the following phases in order. If any phase fails, follow the specified error handling.

### Phase 0: Pre-flight

1. Determine today's date:

```bash
TODAY=$(date +%Y-%m-%d)
echo "Pipeline date: $TODAY"
```

2. Check idempotency — search for today's Discussion:

```bash
gh api graphql -f query='{ repository(owner:"zircote", name:"github-agentic-workflows") { discussions(categoryId:"DIC_kwDORSXBr84C61Lr", first:5, orderBy:{field:CREATED_AT, direction:DESC}) { nodes { title url } } } }' -q '.data.repository.discussions.nodes[].title'
```

If a Discussion titled "gh-aw Intelligence Report — {TODAY}" already exists, skip to Phase 4 (gap analysis). Set `RESEARCH_DONE=true`.

3. Check for existing PR — search for today's branch:

```bash
gh pr list --repo zircote/github-agentic-workflows --base develop --search "daily-intelligence-$TODAY" --state all --json number,url
```

If a PR already exists, report "Today's pipeline already completed" and stop.

4. Read `skills/gh-aw-report/knowledge-base.md` to determine the last report date (`LAST_DATE`). Look for the most recent `### YYYY-MM-DD` heading.

### Phase 1: Intelligence Sweep

Execute 8 web searches from the query library at `skills/gh-aw-report/references/search-queries.md`. For each search:
- Extract version numbers, release dates, feature descriptions, deprecation notices, breaking changes
- Note the source URL for every finding
- Discard results older than 14 days or clearly unrelated

Then query tracked GitHub repositories for activity since `LAST_DATE`:

```bash
gh search issues --repo github/gh-aw --created ">=$LAST_DATE" --sort created --json title,url,labels,createdAt --limit 20
```

```bash
gh release list --repo github/github-mcp-server --limit 5 --json tagName,publishedAt,name
```

```bash
gh api graphql -f query='{ repository(owner:"github", name:"gh-aw") { discussions(first:10, orderBy:{field:CREATED_AT, direction:DESC}) { nodes { title url createdAt category { name } } } } }'
```

Combine web search and GitHub activity into a structured intelligence report following the standard 8-section format. Save as `outputs/gh-aw-reports/{TODAY}.md`.

If zero results across ALL searches AND ALL GitHub queries, stop with a noop — "No intelligence data available."

### Phase 2: Knowledge Base Update

Review findings for stable, persistent facts. Append new entries to `skills/gh-aw-report/knowledge-base.md` using the format:

```
### YYYY-MM-DD — category — Title
Content
```

Do not add duplicates. Mark superseded entries with `[SUPERSEDED by YYYY-MM-DD]`.

### Phase 3: Discussion Posting

Create a Discussion in the Project News category with today's report content. Use the `create-discussion` safe-output. The title must follow the format: "gh-aw Intelligence Report — {TODAY}".

### Phase 4: Gap Analysis

Read `skills/aw-daily/references/gap-analysis-targets.md` for the reference file inventory. For each reference file:

1. Read the file
2. Compare against today's findings (or the latest report if research was skipped)
3. Identify gaps: `incorrect` (priority 1), `outdated` (priority 2), `missing` (priority 3)

Produce a gap list limited to the **top 5** most impactful gaps. Each gap entry:
- Gap ID (sequential)
- Type (incorrect/outdated/missing)
- Affected file and section
- Description of what needs to change
- Source reference

If no gaps found, report "Reference files are current" and stop.

### Phase 5: Issue Creation

For each identified gap, check if an open issue with matching `[aw-daily]` title prefix exists. If not, create one using the `create-issue` safe-output with:
- Title: `[aw-daily] GAP-{N}: {short description}`
- Body: gap details, current content excerpt, expected change, source URL
- Labels: `automated`, `reference-update`

### Phase 6: Implementation

Create a feature branch from `develop`:

```bash
git checkout develop
git pull origin develop
git checkout -b daily-intelligence-$TODAY
```

For each gap, edit the target reference file. Use section headers as anchors (not line numbers). Push changes to the feature branch using the `push-to-pull-request-branch` safe-output.

### Phase 7: PR Creation

Create a PR to `develop` using the `create-pull-request` safe-output:
- Title: `docs(references): daily intelligence update {TODAY}`
- Body: summary of gaps addressed, links to issues (using `Closes #NNN`), link to Discussion
- Base: `develop`
- Labels: `automated`, `reference-update`

### Phase 8: Summary

Report what was accomplished: searches run, findings count, gaps identified, issues created, files changed, PR URL. If any phase was skipped or failed, note it clearly.

## Edge Cases

- If `develop` branch does not exist, create it from `main` before branching
- If the Discussion already exists for today, skip research and start at gap analysis
- If a PR already exists for today, exit immediately (pipeline already ran)
- If all reference files are current (no gaps), exit after Discussion posting
- If `web-search` returns no results for a domain, report "No significant updates" — do not fabricate content
- If a file edit fails, revert that file and continue with remaining gaps
