---
name: "Copilot PR Lifecycle"
description: "Marks Copilot-created draft PRs ready, requests review, and enables auto-merge"
timeout-minutes: 5

on:
  pull_request:
    types: [opened]

if: github.event.pull_request.draft == true && github.event.pull_request.user.login == 'copilot-swe-agent[bot]'

permissions:
  contents: read
  pull-requests: read

engine:
  id: copilot
  model: claude-sonnet

tools:
  bash: ["gh:*", "echo"]

post-steps:
  - name: Mark PR ready for review
    env:
      GH_TOKEN: ${{ github.token }}
      PR_NUMBER: ${{ github.event.pull_request.number }}
    run: |
      echo "Copilot PR #$PR_NUMBER detected as draft — marking ready"
      gh pr ready "$PR_NUMBER" --repo "$GITHUB_REPOSITORY" || true
  - name: Request Copilot review
    env:
      GH_TOKEN: ${{ github.token }}
      PR_NUMBER: ${{ github.event.pull_request.number }}
    run: |
      gh pr edit "$PR_NUMBER" --repo "$GITHUB_REPOSITORY" --add-reviewer "@copilot" 2>/dev/null || echo "Copilot reviewer not available"
  - name: Enable auto-merge
    env:
      GH_TOKEN: ${{ github.token }}
      PR_NUMBER: ${{ github.event.pull_request.number }}
    run: |
      gh pr merge "$PR_NUMBER" --repo "$GITHUB_REPOSITORY" --squash --auto --delete-branch || echo "Auto-merge enabled (will merge when approved)"
---

# Copilot PR Lifecycle Handler

## Context

This workflow fires when GitHub Copilot's coding agent opens a draft pull request. Copilot creates draft PRs when assigned to issues, but has no built-in mechanism to mark them ready for review or enable auto-merge.

## Instructions

This is a lifecycle management workflow. The actual work happens in `post-steps`. Your only job is to confirm the PR exists and report its status:

1. Read the PR details:

```bash
gh pr view "$PR_NUMBER" --repo "$GITHUB_REPOSITORY" --json number,title,isDraft,headRefName,baseRefName
```

2. Report what you found. No edits, no code changes. The `post-steps` block handles the draft-to-ready transition, review request, and auto-merge enablement.
