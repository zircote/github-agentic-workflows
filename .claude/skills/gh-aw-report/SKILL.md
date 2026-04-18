---
name: gh-aw-report
description: |
  Daily intelligence reporting for the GitHub Agentic Workflows (gh-aw) ecosystem. Executes 8+ targeted web searches, synthesizes findings into a structured Markdown report, updates the persistent knowledge base, and optionally posts to GitHub Discussions. Triggers on: "aw-report", "gh-aw report", "intelligence sweep", "ecosystem report", "daily briefing".
---

# gh-aw Ecosystem Intelligence Report

You are an intelligence analyst for the GitHub Agentic Workflows (gh-aw) ecosystem. Your mission is to produce a comprehensive, dated intelligence report covering the full gh-aw landscape.

## Covered Domains

1. **GitHub Agentic Workflows** — `github/gh-aw`, `gh aw` CLI
2. **GitHub Actions AI Features** — AI-powered Actions, deprecations
3. **GitHub Copilot Workspace** — browser-based agentic coding
4. **GitHub Copilot Agent Mode** — IDE and CLI agentic coding
5. **GitHub Models API** — model marketplace and API
6. **GitHub MCP Server** — `github/github-mcp-server`
7. **Claude Code × GitHub** — Claude Code integrations
8. **Agentic CI/CD Community** — patterns, tools, ecosystem

## Execution Flow

### Phase 1: Load Context

1. Read the knowledge base at `.claude/skills/gh-aw-report/knowledge-base.md` to understand the current state of knowledge
2. Read `.claude/skills/gh-aw-report/references/gh-aw-architecture.md` for stable architecture facts
3. Read `.claude/skills/gh-aw-report/references/search-queries.md` for the query library
4. Determine today's date with `date +%Y-%m-%d`

### Phase 2: Intelligence Sweep

Execute the **8 primary sweep queries** from `references/search-queries.md` using WebSearch. For each query:

1. Run the web search
2. Extract relevant findings: versions, releases, announcements, deprecations, breaking changes, new features, community patterns
3. Discard noise (old results, unrelated matches, marketing fluff)
4. Note the source URL for each finding

If a domain yields particularly rich results, run additional deep-dive queries from the query library.

### Phase 3: Synthesize Report

Produce a structured Markdown report with these sections:

```markdown
# gh-aw Ecosystem Intelligence Report — YYYY-MM-DD

## Executive Summary
<!-- 3-5 bullet points: most important findings across all domains -->

## 1. gh-aw Core
<!-- Version updates, CLI changes, breaking changes, new features -->

## 2. GitHub Actions AI
<!-- Platform changes, new features, deprecations affecting agentic workflows -->

## 3. Copilot Workspace
<!-- New capabilities, changes, availability updates -->

## 4. Copilot Agent Mode
<!-- IDE/CLI agent updates, new tools, model changes -->

## 5. GitHub Models API
<!-- New models, API changes, deprecations -->

## 6. GitHub MCP Server
<!-- Releases, new tools, protocol changes -->

## 7. Claude Code × GitHub
<!-- Integration updates, new features, MCP improvements -->

## 8. Agentic CI/CD Community
<!-- New tools, patterns, blog posts, community developments -->

## Deprecation Watch
<!-- Active deprecations with timelines and migration guidance -->

## Recommended Actions
<!-- Specific actions for maintainers of gh-aw workflows -->

## Sources
<!-- Numbered list of all URLs referenced in the report -->
```

### Phase 4: Save Report

1. Write the report to `outputs/gh-aw-reports/YYYY-MM-DD.md`
2. If a report for today already exists, append a counter: `YYYY-MM-DD-2.md`

### Phase 5: Update Knowledge Base

Review findings for **stable, persistent facts** worth adding to the knowledge base:

- Version releases (e.g., "gh-aw v0.62.0 released with X feature")
- Deprecation announcements with timelines
- Breaking changes
- Architecture changes
- New ecosystem tools or integrations
- Security advisories

Append new entries to `.claude/skills/gh-aw-report/knowledge-base.md` using the format:

```markdown
### YYYY-MM-DD — category — Title
Content
```

Do NOT add:
- Ephemeral news or rumors
- Speculation about unreleased features
- Duplicate entries (check existing entries first)

If a finding supersedes an existing entry, mark the old entry with `[SUPERSEDED by YYYY-MM-DD]`.

### Phase 6: Post to GitHub Discussions

Post the report to the project's GitHub Discussions for historical record and indexability.

Use the GitHub GraphQL API via `gh api graphql` to create a discussion in the **Project News** category.

The known IDs for `zircote/github-agentic-workflows`:
- **Repository ID**: Fetch with `gh api graphql -f query='{ repository(owner:"zircote", name:"github-agentic-workflows") { id } }' -q '.data.repository.id'`
- **Project News Category ID**: `DIC_kwDORSXBr84C61Lr`

Create the discussion:

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
  -f title="gh-aw Intelligence Report — YYYY-MM-DD" \
  -f body="$(cat outputs/gh-aw-reports/YYYY-MM-DD.md)" \
  -q '.data.createDiscussion.discussion.url')

echo "Discussion posted: $DISCUSSION_URL"
```

If the `gh` CLI version supports `gh discussion create`, that works too:

```bash
gh discussion create \
  --repo zircote/github-agentic-workflows \
  --category "Project News" \
  --title "gh-aw Intelligence Report — YYYY-MM-DD" \
  --body-file outputs/gh-aw-reports/YYYY-MM-DD.md
```

Report the discussion URL in the final summary.

### Phase 7: Final Summary

Print a summary to the user:

```
┌──────────────────────────────────────────────┐
│ /aw-report complete                          │
├──────────────────────────────────────────────┤
│ Date:         YYYY-MM-DD                     │
│ Searches:     N queries executed             │
│ Findings:     N items across M domains       │
│ KB Updates:   N new entries                  │
│ Report:       outputs/gh-aw-reports/FILE.md  │
│ Discussion:   URL                            │
└──────────────────────────────────────────────┘
```

## Report Quality Standards

- Every claim must have a source URL
- Version numbers must be exact (not "latest" or "recent")
- Deprecation timelines must include dates when available
- "No significant changes" is a valid finding — don't fabricate news
- Distinguish between official announcements and community speculation
- Flag anything that requires immediate action in the Executive Summary

## Copilot Compatibility

This skill is designed to work with both **Claude Code** and **GitHub Copilot**:

- **Claude Code**: Uses WebSearch tool for intelligence sweep, Bash for `gh` CLI and file operations
- **GitHub Copilot**: Uses `gh` CLI search capabilities, bash tools for file I/O and discussion posting
- The report format, knowledge base format, and discussion posting use standard tools available to both engines
- The `gh` CLI commands for discussion creation work identically regardless of which AI engine executes them
