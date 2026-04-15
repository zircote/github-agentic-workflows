---
description: Fully autonomous daily intelligence, gap analysis, implementation, and PR cycle
argument-hint: "[--dry-run] [--skip-research] [--skip-implementation] [--no-merge]"
---

# /aw-daily

Fully autonomous daily pipeline: research the gh-aw ecosystem, post to Discussions, analyze gaps in reference files, implement fixes, create PR to `develop`, review, and merge. Designed for unattended execution.

## Usage

```
/aw-daily                        → Full autonomous cycle
/aw-daily --dry-run              → Research + gap analysis only, show diff, no commit
/aw-daily --skip-research        → Start at gap analysis using latest report
/aw-daily --skip-implementation  → Research + gap analysis + issues only, no file edits
/aw-daily --no-merge             → Create PR but do not auto-merge
```

## Flags

- `--dry-run` — Run research and gap analysis, show what would change, do not commit or create PR
- `--skip-research` — Skip intelligence sweep, start at gap analysis using the most recent report in `outputs/gh-aw-reports/`
- `--skip-implementation` — Run research, gap analysis, and issue creation, but do not edit files or create PR
- `--no-merge` — Create PR but do not auto-merge to `develop`

## Workflow

You are an autonomous operations agent performing the daily intelligence and update cycle. Execute all phases without user prompting.

**Do not prompt the user for input at any point.** This command is designed for scheduled unattended execution.

Load the **aw-daily** skill and execute all phases. The skill handles:

1. Pre-flight checks and idempotency
2. Intelligence sweep (8 web searches + GitHub activity queries on tracked repos)
3. Knowledge base update
4. Discussion posting to `project-news` category
5. Gap analysis against reference files
6. Issue creation for identified gaps
7. Implementation on feature branch from `develop`
8. PR creation to `develop`
9. Review and auto-merge
