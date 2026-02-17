# Example Workflows

Complete gh-aw workflow examples with annotated frontmatter and prose body.

---

## Example 1: Issue Triage Agent

**Pattern:** Direct Dispatch
**Trigger:** New issues opened
**Purpose:** Automatically classify and label incoming issues

````markdown
---
name: "Issue Triage"
description: "Classify and label new issues based on content analysis"
timeout-minutes: 5
strict: false

on:
  issues:
    types: [opened, reopened]
    reaction: eyes

permissions:
  issues: read
  contents: read

engine:
  id: copilot

tools:
  github:
    toolsets: [issues, labels]

safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement, documentation, question, good-first-issue]
    max: 3
  add-comment:
    max: 1
---

# Issue Triage Agent

## Context

You are triaging issues in ${{ github.repository }}.
This repository is a TypeScript project using Node.js.

## Instructions

1. Read the issue title and body carefully
2. Determine the primary category:
   - **bug**: Error reports, broken functionality, regressions
   - **feature**: New capability requests
   - **enhancement**: Improvements to existing features
   - **documentation**: Docs corrections, additions, or clarifications
   - **question**: Usage questions or seeking guidance
3. If the issue seems approachable for newcomers, also add `good-first-issue`
4. Post a brief comment explaining your classification

## Edge Cases

- If the body is empty, classify based on the title alone
- If the issue could be multiple categories, choose the primary and mention others in your comment
- If the issue appears to be spam, add no labels and do not comment

## Comment Format

### Triage: {category}

{1-2 sentence reasoning}

Labels applied: {list}
````

---

## Example 2: Daily Repository Status Report

**Pattern:** Scheduled Batch
**Trigger:** Daily schedule
**Purpose:** Generate a summary of repository activity as an issue

````markdown
---
name: "Daily Status Report"
description: "Create daily summary of repository activity"
timeout-minutes: 10

on:
  schedule: daily

permissions:
  issues: read
  pull-requests: read
  contents: read

engine:
  id: copilot

tools:
  github:
    toolsets: [issues, pull_requests, repos]

safe-outputs:
  create-issue:
    title-prefix: "[daily-report] "
    labels: [report, automated]
    close-older-issues: true
    expires: 7d
    max: 1
---

# Daily Repository Status Report

## Context

You are generating a daily status report for ${{ github.repository }}.

## Instructions

1. Gather activity from the last 24 hours:
   - New issues opened
   - Issues closed
   - Pull requests opened, merged, or closed
   - Notable commits to main branch
2. Create a summary issue with today's date in the title
3. Include counts, highlights, and any trends

## Report Format

### Daily Report: {date}

**Activity Summary**

| Metric | Count |
|--------|-------|
| Issues opened | {n} |
| Issues closed | {n} |
| PRs opened | {n} |
| PRs merged | {n} |

**Highlights**
- {Notable item 1}
- {Notable item 2}

**Trends**
{Any observations about patterns}
````

---

## Example 3: ChatOps Slash Commands

**Pattern:** ChatOps
**Trigger:** Issue comments with slash commands
**Purpose:** Provide on-demand actions via comment commands

````markdown
---
name: "ChatOps Handler"
description: "Process slash commands in issue and PR comments"
timeout-minutes: 10
strict: false

on:
  issue_comment:
    types: [created]
    reaction: eyes

permissions:
  issues: read
  pull-requests: read
  contents: read

engine:
  id: copilot

tools:
  github:
    toolsets: [issues, pull_requests, labels, repos]

safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement, priority-high, priority-low, planned, wontfix]
    max: 5
  add-comment:
    hide-older-comments: true
    max: 1
  create-issue:
    title-prefix: "[plan] "
    labels: [planned]
    max: 1
---

# ChatOps Command Handler

## Context

You are processing a comment on ${{ github.repository }}.
The comment was made by @${{ github.actor }}.

## Command Detection

Check the comment body for slash commands. If the comment does not start with `/`, ignore it entirely and take no action.

### Supported Commands

**`/triage`** — Classify the issue
1. Analyze the issue content
2. Add appropriate labels from the allowlist
3. Comment with your classification

**`/plan`** — Create an implementation plan
1. Read the issue and related code
2. Create a new plan issue with implementation steps
3. Comment on the original issue linking to the plan

**`/priority high|low`** — Set priority
1. Parse the priority argument
2. Add `priority-high` or `priority-low` label

**`/close wontfix`** — Mark as won't fix
1. Add `wontfix` label
2. Comment explaining the decision

**`/help`** — Show available commands
1. Comment with a list of supported commands and their descriptions

## Edge Cases

- Unknown commands: Comment that the command is not recognized and show `/help`
- Missing arguments: Comment asking for the required argument
- Multiple commands in one comment: Process only the first command
````

---

## Example 4: PR Security Review

**Pattern:** Direct Dispatch
**Trigger:** New pull requests
**Purpose:** Automated security-focused code review

````markdown
---
name: "Security Review"
description: "Automated security analysis of pull request changes"
timeout-minutes: 15

on:
  pull_request:
    types: [opened, synchronize]
    reaction: eyes

permissions:
  pull-requests: read
  contents: read

engine:
  id: claude
  thinking: true

tools:
  github:
    toolsets: [pull_requests, repos, code_security]

safe-outputs:
  create-pull-request-review-comment:
    max: 20
    side: RIGHT
    footer: true
  submit-pull-request-review:
    max: 1
  add-labels:
    allowed: [security-review-passed, security-concern]
    max: 1
---

# Security Review Agent

## Context

You are reviewing PR #${{ github.event.pull_request.number }} in ${{ github.repository }}.

## Instructions

1. Get the list of changed files in this PR
2. For each changed file, analyze for security concerns:
   - SQL injection vulnerabilities
   - XSS vulnerabilities
   - Hardcoded secrets or credentials
   - Insecure API usage
   - Missing input validation
   - Unsafe deserialization
   - Path traversal risks
3. For each finding, leave an inline review comment on the specific line
4. After reviewing all files:
   - If no concerns found: Add `security-review-passed` label and approve
   - If concerns found: Add `security-concern` label and request changes

## Edge Cases

- If the PR only changes documentation or tests, note that and approve
- If files are too large to analyze fully, note which files were partially reviewed
- Binary files should be skipped
````

---

## Example 5: Cross-Repository Issue Sync

**Pattern:** Pipeline (with cross-repo)
**Trigger:** Issues labeled with `upstream`
**Purpose:** Create tracking issues in another repository

````markdown
---
name: "Upstream Issue Sync"
description: "Create tracking issues in upstream repo when labeled"
timeout-minutes: 5

on:
  issues:
    types: [labeled]
    reaction: eyes

permissions:
  issues: read

engine:
  id: copilot

tools:
  github:
    toolsets: [issues]

safe-outputs:
  create-issue:
    title-prefix: "[downstream] "
    labels: [tracked, downstream]
    target-repo: "org/upstream-repo"
    max: 1
  add-comment:
    max: 1
  add-labels:
    allowed: [synced]
    max: 1
---

# Upstream Issue Sync

## Context

You are syncing issues from ${{ github.repository }} to org/upstream-repo.

## Instructions

1. Check if the triggering label is `upstream`
2. If not, take no action
3. If yes:
   - Read the issue title and body
   - Create a tracking issue in org/upstream-repo with:
     - Title prefixed with `[downstream]`
     - Body referencing the original issue
     - Labels: `tracked`, `downstream`
   - Comment on the original issue with a link to the upstream issue
   - Add the `synced` label to the original issue

## Edge Cases

- If the issue already has the `synced` label, do not create a duplicate
- If the upstream repo is not accessible, comment with an error message
````

---

## Minimal Workflow Template

Starter template for new workflows:

````markdown
---
name: "Workflow Name"
description: "Brief description"
timeout-minutes: 10

on:
  issues:
    types: [opened]
    reaction: eyes

permissions:
  issues: read

engine:
  id: copilot

tools:
  github:
    toolsets: [issues]

safe-outputs:
  add-comment:
    max: 1
---

# Workflow Title

## Context

You are operating on ${{ github.repository }}.

## Instructions

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Edge Cases

- [Edge case 1]
- [Edge case 2]
````
