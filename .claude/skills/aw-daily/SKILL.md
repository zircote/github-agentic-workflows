---
name: aw-daily
description: >
  Fully autonomous daily pipeline for the aw-author plugin. Executes intelligence
  research (web search + GitHub activity queries), posts to Discussions, performs
  gap analysis against reference files, creates issues, implements changes on
  develop branch, creates PR, requests review, and auto-merges.
---

Load and follow the instructions in `skills/aw-daily/SKILL.md` exactly.

This is the Claude Code mirror of the main skill. The full 9-phase pipeline
(Pre-flight → Research → KB Update → Discussion → Gap Analysis → Issues →
Implementation → PR → Review & Merge) is defined in the main skill file.

Parse flags from arguments: `--dry-run`, `--skip-research`, `--skip-implementation`, `--no-merge`.
