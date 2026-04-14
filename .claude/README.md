# aw-author Tools

Daily intelligence reporting and contextual knowledge for the **GitHub Agentic Workflows (gh-aw)** ecosystem.

## What It Does

The `aw-author` plugin gives Claude persistent, up-to-date knowledge of the gh-aw space and the tools to refresh that knowledge daily. It covers:

- GitHub Agentic Workflows (`github/gh-aw`, `gh aw` CLI)
- GitHub Actions AI features and deprecations
- GitHub Copilot Workspace & Agent Mode
- GitHub Copilot CLI (agentic terminal coding)
- GitHub Models API
- GitHub MCP Server (`github/github-mcp-server`)
- Claude Code × GitHub integrations
- Agentic CI/CD patterns and community ecosystem

## Commands

### `/aw-report`
Runs a full intelligence sweep — 8+ web searches across the gh-aw landscape — and produces a dated Markdown report saved to `outputs/gh-aw-reports/YYYY-MM-DD.md`. Updates the persistent knowledge base and posts to GitHub Discussions (`project-news` category) for historical record.

Flags: `--deep` (extended queries), `--no-post` (skip Discussions), `--domains domain1,domain2` (filter domains)

**Use when**: You want today's news, a briefing before a meeting, or to populate the knowledge base.

### `/aw-status`
Reads the knowledge base and delivers a quick 300–400 word briefing on current versions, active deprecations, and recommended actions. No web searches needed.

Flags: `--domain domain` (focus on one domain), `--since YYYY-MM-DD` (filter by date)

**Use when**: You need a fast reminder of the current state without running a full report.

### `/aw-daily`
Fully autonomous daily pipeline: research → Discussion posting → gap analysis → implementation → PR to `develop` → review → merge. Designed for zero human intervention.

Flags: `--dry-run` (research + analysis only), `--skip-research` (start at gap analysis), `--skip-implementation` (no file edits), `--no-merge` (create PR without merging)

**Use when**: Scheduled daily (via gh-aw workflow) or invoked manually to update reference files from the latest ecosystem intelligence.

### `/aw-merge`
Weekly merge of `develop` into `main`. Creates a PR, waits for CI, squash merges, and resets `develop`.

Flags: `--dry-run` (show what would merge), `--no-reset` (skip develop reset after merge)

**Use when**: Weekly cadence to promote accumulated daily updates from `develop` to `main`.

## Skills

### `gh-aw-report`
The core intelligence skill. Directs Claude to:
1. Execute 8 targeted web searches across the gh-aw ecosystem
2. Synthesize findings into a structured report with 7 standard sections
3. Save the report to `outputs/gh-aw-reports/`
4. Update the knowledge base with stable, persistent facts

## Knowledge Base

`skills/gh-aw-report/knowledge-base.md` is a persistent, append-only log of stable facts about the gh-aw ecosystem — versions, deprecations, architecture notes, and breaking changes. Every Claude session with this plugin starts with this context loaded.

### `aw-daily`
The autonomous pipeline skill. Extends `gh-aw-report` with gap analysis against reference files, issue creation, implementation, and PR management. 9-phase pipeline targeting the `develop` branch.

## Scheduled Use

The primary daily pipeline runs via a gh-aw scheduled workflow (`.github/workflows/daily-intelligence.md`) with fuzzy scheduling (`daily around 07:00`). This runs on GitHub Actions using the Copilot engine.

The weekly `develop` → `main` merge runs via `.github/workflows/weekly-develop-merge.md` (`weekly on monday around 09:00`).

For local alternative execution, use `/aw-daily` or `/aw-merge` directly. Idempotency checks prevent duplicate work if the gh-aw workflow already ran.

## Reference Files

- `skills/gh-aw-report/references/gh-aw-architecture.md` — Stable system architecture facts
- `skills/gh-aw-report/references/search-queries.md` — Extended query library for deep dives
- `skills/gh-aw-report/knowledge-base.md` — Persistent cross-session knowledge store