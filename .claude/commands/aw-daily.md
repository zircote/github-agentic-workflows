---
name: aw-daily
description: >
  Fully autonomous daily pipeline: research, discussion posting, gap analysis,
  implementation, and PR to develop. Designed for unattended execution.
  Use with: /aw-daily [--dry-run] [--skip-research] [--skip-implementation] [--no-merge]
tools:
  - WebSearch
  - WebFetch
  - Write
  - Edit
  - Bash
  - Read
---

Run the `aw-daily` skill to execute the full daily intelligence and update pipeline.

## Flags

Parse the argument string for these optional flags:

- `--dry-run` — Research + gap analysis only, show diff, no commit/PR
- `--skip-research` — Start at gap analysis using latest report
- `--skip-implementation` — Research + gap analysis + issues, no file edits/PR
- `--no-merge` — Create PR but do not auto-merge

## Steps

1. Load the aw-daily skill by reading `skills/aw-daily/SKILL.md`.
2. Follow the skill's 9-phase instructions exactly.
3. Do not prompt the user for input at any point.
4. Report the final summary table when complete.

This command is designed for scheduled unattended execution.
