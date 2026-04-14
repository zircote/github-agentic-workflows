---
name: gh-aw-report
description: >
  Generates a comprehensive daily intelligence report on the GitHub Agentic Workflows
  (gh-aw) ecosystem. Use when asked to produce a gh-aw report, run a daily GitHub
  agentic workflows briefing, check what's new in GitHub agentic workflows, GitHub
  Actions AI updates, GitHub Copilot Workspace news, GitHub Models API changes,
  MCP GitHub integration updates, Claude Code GitHub integration status, or
  "what's trending in agentic CI/CD". Also triggers on: "gh-aw status",
  "agentic workflows digest", "agentic CI report", "GitHub AI ecosystem update".
---

# gh-aw-report: Daily GitHub Agentic Workflows Intelligence

Produce a comprehensive, dated intelligence report on the GitHub Agentic Workflows
ecosystem. This skill directs the agent to gather current information from the web,
synthesize it, and persist key findings to a knowledge base.

## Scope

The "GitHub Agentic Workflows" (gh-aw) space covers:

- **GitHub Agentic Workflows** — the `github/gh-aw` repository, `gh aw` CLI, compiled
  Markdown workflows, safe-outputs system, Agent Workflow Firewall (AWF), MCP Gateway
- **GitHub Actions** — new runner features, action deprecations, pricing changes,
  immutable actions, cache migrations, OIDC updates
- **GitHub Copilot Workspace** — agent mode, coding agent, agentic code review, IDE
  integrations (VS Code, JetBrains), Autopilot mode, sub-agents
- **GitHub Copilot CLI** — GA status, plan/autopilot modes, specialized agent delegation,
  model support (Claude Opus/Sonnet, GPT, Gemini), `& background` delegation
- **GitHub Models** — model catalog changes, API updates, rate limits, new model arrivals
- **GitHub MCP Server** — `github/github-mcp-server` releases, new tools, OAuth changes,
  Projects toolset, insiders mode, enterprise HTTP mode
- **Claude Code on GitHub** — `CLAUDE.md` support in Copilot, Claude as gh-aw agent,
  Claude Code MCP integrations, `steipete/claude-code-mcp`
- **Agentic CI/CD patterns** — "continuous AI" paradigm, community sample workflows
  (`githubnext/agentics`), community adoption, blog posts, conference talks
- **Security** — AWF network egress control, prompt injection detection, safe outputs,
  permission models, MCP Gateway

## Execution Steps

### Step 1 — Web Research (run ALL searches)

Execute the following searches. Do not skip any. Use today's date in queries where noted.

1. `site:github.blog/changelog github agentic workflows` — Official changelog entries
2. `"gh-aw" OR "github agentic workflows" new features breaking changes 2026` — Broad news
3. `github/gh-aw releases issues discussions 2026` — Repo-level activity
4. `github MCP server releases changelog 2026` — MCP server updates
5. `github copilot workspace agent mode updates 2026` — Copilot workspace news
6. `github copilot CLI agentic features 2026` — Copilot CLI news
7. `"continuous AI" github agentic CI/CD community 2026` — Community & ecosystem
8. `claude code github integration CLAUDE.md AGENTS.md 2026` — Claude-specific integration

For each search, extract: new features, version numbers, deprecations, breaking changes,
notable issues, community sentiment, and recommended actions.

### Step 2 — Read the knowledge base

Read `${CLAUDE_PLUGIN_ROOT}/skills/gh-aw-report/knowledge-base.md` to load prior context.
Cross-reference search findings with existing entries. Flag anything that contradicts or
supersedes prior knowledge.

### Step 3 — Compose the Report

Write a dated Markdown report. Today's date determines the filename.

**Report structure** (use exactly these section headers):

```
# GitHub Agentic Workflows — Intelligence Report: YYYY-MM-DD

## Executive Summary
3–5 sentences. What matters most today. Lead with the highest-signal finding.

## New Features & Releases
For each item: component name, version/date, what changed, impact assessment.
Subsections by product area: gh-aw CLI, GitHub Actions, Copilot Workspace,
Copilot CLI, GitHub Models, GitHub MCP Server.

## Breaking Changes & Deprecations
Explicit list. For each: what is deprecated/changed, effective date, migration path,
severity (High/Medium/Low). Empty section is fine — write "No new breaking changes
detected." rather than omitting.

## Trending Issues & Community Discussion
Top 3–5 items from GitHub Discussions, HN, DEV Community, Twitter/X, blog posts.
Include link, sentiment summary, and why it matters.

## Ecosystem Tool Updates
MCP integrations, Claude Code, third-party action runners, Agent Package Manager (APM),
`githubnext/awesome-continuous-ai`, community workflow packs.

## Notable PRs & Commits
From `github/gh-aw`, `github/github-mcp-server`, `github/copilot-cli` (if public).
Title, link if available, brief description of significance.

## Recommended Actions
Bulleted list of concrete next steps for a team building on gh-aw today.
Examples: "Upgrade to gh aw v0.X to get signed-commit support on new branches",
"Replace plugins: field with dependencies: field (use gh aw fix --write)", etc.

## Sources
All URLs consulted, as markdown links.
```

### Step 4 — Save the report

Save the complete report to:
```
outputs/gh-aw-reports/YYYY-MM-DD.md
```
(Replace YYYY-MM-DD with today's actual date.)

If the directory does not exist, create it with `mkdir -p`.

### Step 5 — Update the knowledge base

Append a dated entry to `${CLAUDE_PLUGIN_ROOT}/skills/gh-aw-report/knowledge-base.md`.
Each entry should capture only persistent, stable facts — API changes, confirmed
deprecations, version pinpoints, architecture decisions — not transient news.

Entry format:
```markdown
## [YYYY-MM-DD] Update
- **gh-aw CLI**: Current stable version X.Y.Z. Key facts: ...
- **Deprecations active**: plugins: field → dependencies:; npm @mcp/server-github deprecated
- **Breaking changes effective**: [list any with dates]
- **Architecture notes**: [any stable facts about how the system works]
```

### Step 6 — Post to GitHub Discussions

Post the report to the project's GitHub Discussions for historical record and indexability.

Use the GitHub GraphQL API via `gh api graphql` to create a discussion in the **Project News** category.

The known category ID for `zircote/github-agentic-workflows` Project News: `DIC_kwDORSXBr84C61Lr`

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

If `--no-post` flag was passed, skip this step.

### Step 7 — Present to user

Share the link to the saved report file and the discussion URL, then give a 3-sentence
verbal summary of the most important findings.

## Quality Standards

- Never produce placeholder or template content — every section must reflect actual
  search findings from today's run.
- If a search returns no relevant results for a section, write "No significant updates
  detected in this area." — do not invent content.
- Prefer primary sources (GitHub Changelog, GitHub Blog, official docs) over secondary.
- Date all version numbers and facts — "as of YYYY-MM-DD".
- Flag anything marked as "technical preview" or "beta" with a ⚠️ symbol.

## Reference Files

- `references/gh-aw-architecture.md` — stable facts about gh-aw system design
- `references/search-queries.md` — extended query library for edge-case coverage
- `knowledge-base.md` — persistent cross-session knowledge store
