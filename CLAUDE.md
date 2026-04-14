# CLAUDE.md — aw-author Plugin

## Project

The **aw-author** Claude Code plugin (v1.3.0) at `zircote/github-agentic-workflows`. Provides skills, commands, and reference materials for GitHub Agentic Workflow (gh-aw) authoring, plus an autonomous daily intelligence pipeline.

## Commands

- `/aw-author` — Author, validate, improve, debug gh-aw workflow files
- `/aw-daily [--dry-run] [--skip-research] [--skip-implementation] [--no-merge]` — Autonomous daily pipeline: research → Discussion → gap analysis → implementation → PR to `develop`
- `/aw-merge [--dry-run] [--no-reset]` — Weekly develop→main merge
- `/aw-report [--deep] [--no-post] [--domains ...]` — Intelligence sweep + Discussion posting
- `/aw-status [--domain ...] [--since ...]` — Quick KB briefing
- `/aw-upgrade [--force] [--dry-run] [--no-merge] [--strict]` — gh-aw extension upgrade cycle

## Branching

- `main` — stable production
- `develop` — receives daily automated PRs
- `daily-intelligence-YYYY-MM-DD` — ephemeral feature branches

## Quality Gates

This project has no linter, type checker, or test suite. Quality gates are:

1. **`gh aw compile`** — all `.md` workflows in `.github/workflows/` must compile to `.lock.yml` with 0 errors
2. **`gh aw validate`** — all compiled workflows must validate with 0 errors
3. **Cross-reference consistency** — facts mentioned in one reference file must be consistent across all files that reference them

After editing any `.github/workflows/*.md` file, always recompile with `gh aw compile` and verify 0 errors.

## Key Files

| Path | Role |
|------|------|
| `skills/aw-author/references/` | 9 canonical reference files — the core deliverable |
| `skills/aw-daily/SKILL.md` | 9-phase autonomous pipeline |
| `skills/gh-aw-report/knowledge-base.md` | Persistent append-only KB |
| `.github/workflows/daily-intelligence.md` | Primary daily gh-aw workflow |
| `.github/workflows/weekly-develop-merge.md` | Weekly merge gh-aw workflow |
| `.claude-plugin/plugin.json` | Plugin manifest |

## Critical Conventions

- **`.lock.yml` files are generated** — never edit them directly
- **`add-comment` must include `discussions: false`** — known gotcha causing HTTP 422
- **`plugins:` is deprecated** — use `dependencies:`, run `gh aw fix --write`
- **Knowledge base is append-only** — mark old entries `[SUPERSEDED by YYYY-MM-DD]`
- **Use section headers as edit anchors** — not line numbers (they shift between runs)
- **PRs are created as drafts** — use `--draft` on `gh pr create`, mark ready with `gh pr ready` after changes are complete
- **Discussion category ID**: `DIC_kwDORSXBr84C61Lr` (Project News)

## gh-aw Compiler

```bash
gh aw compile .github/workflows/<name>.md   # Compile one workflow
gh aw validate .github/workflows/<name>.md  # Validate one workflow
gh aw compile                                # Compile all workflows
gh aw version                                # v0.68.1
```

## Spec Resources

- Full spec: `https://github.github.com/gh-aw/llms-full.txt`
- Abridged: `https://github.github.com/gh-aw/llms-small.txt`
- Patterns: `https://github.github.com/gh-aw/_llms-txt/agentic-workflows.txt`
