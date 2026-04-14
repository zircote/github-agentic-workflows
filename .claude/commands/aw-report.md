---
name: aw-report
description: >
  Generate today's GitHub Agentic Workflows intelligence report. Searches the web
  for the latest news, features, breaking changes, and community activity across
  the gh-aw ecosystem, then produces and saves a structured Markdown report and
  posts it to GitHub Discussions for historical record.
  Use with: /aw-report [--deep] [--no-post] [--domains domain1,domain2]
tools:
  - WebSearch
  - WebFetch
  - Write
  - Bash
  - Read
---

Run the `gh-aw-report` skill to produce today's GitHub Agentic Workflows intelligence report.

## Flags

Parse the argument string for these optional flags:

- `--deep` — Run additional deep-dive queries from the extended query library beyond the 8 primary searches
- `--no-post` — Skip posting to GitHub Discussions (still saves report locally and updates knowledge base)
- `--domains` — Comma-separated list of domains to sweep. Valid: `gh-aw`, `actions`, `workspace`, `agent-mode`, `models`, `mcp-server`, `claude-code`, `community`

## Steps

1. Load the gh-aw-report skill by reading `skills/gh-aw-report/SKILL.md`.
2. Follow the skill's instructions exactly — perform all 8 required web searches (or filtered if `--domains` specified), synthesize findings, and produce the full structured report.
3. If `--deep` is passed, run additional deep-dive queries from `skills/gh-aw-report/references/search-queries.md`.
4. Save the report to `outputs/gh-aw-reports/YYYY-MM-DD.md` (today's date).
5. Update the knowledge base at `skills/gh-aw-report/knowledge-base.md`.
6. Unless `--no-post`, post the report to GitHub Discussions in the `Project News` category at `zircote/github-agentic-workflows` using the GraphQL API (see skill Phase 6).
7. Present the saved report link, discussion URL, and a 3-sentence summary of the most important findings.

Do not produce placeholder content. Every section must reflect real search results from today's run.
