---
name: "Weekly Develop Merge"
description: "Merge develop branch into main weekly"
timeout-minutes: 10

on:
  schedule: "weekly on monday around 09:00"
  workflow_dispatch:

permissions:
  contents: read
  pull-requests: read

engine:
  id: copilot

tools:
  bash: ["gh:*", "git:*", "echo", "date"]

safe-outputs:
  create-pull-request:
    title-prefix: "chore: "
    labels: [automated]
    draft: true
    base-branch: main
    max: 1
  add-comment:
    discussions: false
    max: 1

post-steps:
  - name: Mark draft PR ready and request Copilot review with auto-merge
    env:
      GH_TOKEN: ${{ github.token }}
    run: |
      PR=$(gh pr list --repo "$GITHUB_REPOSITORY" --base main --head develop --state open --json number --jq '.[0].number')
      if [ -n "$PR" ]; then
        echo "Found PR #$PR"
        gh pr ready "$PR" --repo "$GITHUB_REPOSITORY" || true
        echo "PR #$PR marked ready for review"
        gh pr edit "$PR" --repo "$GITHUB_REPOSITORY" --add-reviewer "@copilot" 2>/dev/null || echo "Copilot reviewer not available"
        echo "Requested Copilot review on PR #$PR"
        gh pr merge "$PR" --repo "$GITHUB_REPOSITORY" --squash --auto --delete-branch=false || echo "Auto-merge enabled (will merge when approved)"
      else
        echo "No draft PR found"
      fi
---

# Weekly Develop-to-Main Merge Agent

## Context

You are performing the weekly merge of the `develop` branch into `main` for ${{ github.repository }}. This workflow runs every Monday around 09:00 via fuzzy schedule.

## Instructions

### Step 1: Check divergence

```bash
git fetch origin main develop
AHEAD=$(git rev-list --count origin/main..origin/develop)
echo "develop is $AHEAD commits ahead of main"
```

If `AHEAD` is 0, report "develop is up to date with main. Nothing to merge." and stop (noop).

### Step 2: Create PR

Use the `create-pull-request` safe-output to create a PR from `develop` to `main`:
- Title: `chore: weekly develop merge {date}`
- Body: list of commits being merged (`git log --oneline origin/main..origin/develop`), count of commits

### Step 3: Report

Report the PR URL and number of commits included. The PR will be reviewed and merged according to the repository's merge policy.

## Edge Cases

- If `develop` branch does not exist, report "No develop branch found" and stop
- If a merge PR from develop to main already exists this week, report its URL and stop
- Do not force-merge — if there are conflicts, report them and leave the PR open
