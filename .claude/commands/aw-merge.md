---
name: aw-merge
description: >
  Weekly develop-to-main merge with PR, CI check, and squash merge.
  Use with: /aw-merge [--dry-run] [--no-reset]
tools:
  - Bash
  - Read
---

Merge `develop` into `main` via PR.

1. Check if `develop` is ahead of `main`
2. If so, create a PR from `develop` to `main`
3. Wait for CI checks (max 5 minutes)
4. Squash merge
5. Unless `--no-reset`, reset `develop` to new `main` HEAD

If `develop` is not ahead of `main`, report "Nothing to merge" and exit.
If `--dry-run`, show what would be merged but take no action.
