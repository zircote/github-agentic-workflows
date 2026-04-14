# Agent Instructions — aw-author Plugin

This file is read by all agentic runtimes (GitHub Copilot, Claude Code, Codex, and gh-aw workflows) when operating in this repository.

## What This Repository Is

The **aw-author** plugin (v1.3.0) for Claude Code. It provides skills, commands, and reference materials for authoring GitHub Agentic Workflow (gh-aw) markdown files, plus an autonomous daily pipeline that keeps the reference materials current.

**Repository**: `zircote/github-agentic-workflows`
**Owner**: Robert Allen (`zircote`)

## Key Directories

- `skills/aw-author/references/` — 9 canonical reference files (frontmatter schema, safe-outputs, tools, gotchas, patterns, examples, validation, body guide, URLs). These are the primary deliverable of this project.
- `skills/aw-daily/` — Autonomous daily pipeline skill that researches the gh-aw ecosystem, identifies gaps in reference files, and creates PRs to fix them.
- `skills/gh-aw-report/` — Intelligence reporting skill with knowledge base and search queries.
- `.github/workflows/` — Two gh-aw workflows: `daily-intelligence.md` (daily research + updates) and `weekly-develop-merge.md` (weekly develop→main merge).
- `outputs/gh-aw-reports/` — Dated intelligence reports.

## Branching

- `main` — stable
- `develop` — receives daily automated PRs from the intelligence pipeline
- Feature branches: `daily-intelligence-YYYY-MM-DD` (ephemeral, deleted after merge)

## Rules for All Agents

1. **Never edit `.lock.yml` files.** They are compiled output from `gh aw compile`.
2. **Reference files are large (200–2100 lines).** Use section headers as anchors for edits, not line numbers.
3. **Knowledge base (`skills/gh-aw-report/knowledge-base.md`) is append-only.** Never delete entries. Mark outdated facts with `[SUPERSEDED by YYYY-MM-DD]`.
4. **All `add-comment` safe-outputs must include `discussions: false`.** This is a known gh-aw gotcha that causes HTTP 422 errors.
5. **The `plugins:` frontmatter field is deprecated.** Use `dependencies:` instead. Run `gh aw fix --write` to migrate.
6. **Discussion posts go to the "Project News" category** (ID: `DIC_kwDORSXBr84C61Lr`).
7. **The daily pipeline is idempotent.** It checks for existing Discussions, PRs, and issues before creating new ones. Re-running on the same day is safe.
8. **When editing reference files, verify the change compiles.** Run `gh aw compile` after modifying any `.md` file in `.github/workflows/`.
9. **PRs are created as drafts.** Open with `--draft` or `draft: true` in safe-outputs, then mark ready with `gh pr ready` after all changes are pushed and verified.

## gh-aw Spec Essentials

- Workflows are `.md` files with YAML frontmatter in `.github/workflows/`
- Compiled to `.lock.yml` via `gh aw compile`
- `permissions:` block is **read-only** — write permissions are rejected by the compiler
- All write operations go through `safe-outputs:` using App tokens
- Event-triggered workflows need `reaction: eyes` in the `on:` block
- `${{ }}` expressions inside fenced code blocks are NOT interpolated — use env vars
- Trigger is `issues` (plural), not `issue`

## Available Commands

| Command | Purpose |
|---------|---------|
| `/aw-author` | Author, validate, improve, or debug gh-aw workflows |
| `/aw-daily` | Autonomous daily pipeline (research → gaps → fix → PR) |
| `/aw-merge` | Weekly develop→main merge |
| `/aw-report` | Intelligence sweep + Discussion posting |
| `/aw-status` | Quick briefing from knowledge base |
| `/aw-upgrade` | Upgrade gh-aw extension + recompile + PR |
