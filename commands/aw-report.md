---
description: Run a full gh-aw ecosystem intelligence sweep and produce a dated report
argument-hint: "[--deep] [--no-post] [--domains domain1,domain2]"
---

# /aw-report

Runs a full intelligence sweep across the GitHub Agentic Workflows ecosystem — 8+ web searches — and produces a dated Markdown report saved to `outputs/gh-aw-reports/YYYY-MM-DD.md`. Updates the persistent knowledge base and posts to GitHub Discussions.

## Usage

```
/aw-report                     → Full sweep, all domains, post to Discussions
/aw-report --deep              → Extended sweep with deep-dive queries
/aw-report --no-post           → Generate report without posting to Discussions
/aw-report --domains gh-aw,mcp → Only sweep specified domains
```

## Flags

- `--deep` — Run additional deep-dive queries from the extended query library beyond the 8 primary searches
- `--no-post` — Skip posting to GitHub Discussions (still saves report locally and updates knowledge base)
- `--domains` — Comma-separated list of domains to sweep. Valid domains: `gh-aw`, `actions`, `workspace`, `agent-mode`, `models`, `mcp-server`, `claude-code`, `community`

## Workflow

You are an intelligence analyst for the gh-aw ecosystem. Load the **gh-aw-report** skill to execute the full intelligence cycle:

1. Load context from the knowledge base and architecture reference
2. Execute the primary sweep (8 targeted web searches)
3. If `--deep` is passed, run additional deep-dive queries
4. If `--domains` is passed, filter to only the specified domains
5. Synthesize findings into a structured report
6. Save the report to `outputs/gh-aw-reports/YYYY-MM-DD.md`
7. Update the knowledge base with stable facts
8. Unless `--no-post`, post the report to GitHub Discussions in the `project-news` category at `zircote/github-agentic-workflows`
9. Print the final summary

## Examples

```
/aw-report
# → Full sweep, saves report, updates KB, posts to Discussions

/aw-report --deep
# → Extended sweep with deep-dive queries on rich domains

/aw-report --no-post --domains gh-aw,mcp-server
# → Only sweep gh-aw core and MCP server, skip Discussions post

/aw-report --deep --domains claude-code
# → Deep dive on Claude Code × GitHub integrations only
```
