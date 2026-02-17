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
strict: false                        # ← Required to process external/untrusted input

on:
  issues:                            # ← NOTE: plural "issues", not "issue"
    types: [opened, reopened]        # ← Only trigger on new/reopened, not edits

permissions:
  issues: read                       # ← Read to analyze, labels via safe-outputs
  contents: read                     # ← Read codebase for context

tools:
  github:
    toolsets: [issues, labels]       # ← Minimal toolset

safe-outputs:
  add-labels:
    allowed:                         # ← Explicit allowlist prevents label sprawl
      - bug
      - feature
      - enhancement
      - documentation
      - question
      - help-wanted
      - good-first-issue
  add-comment: {}                    # ← No sub-field constraints in v0.45.0
---

# Issue Triage Agent

Analyze newly opened issues in ${{ github.repository }} and classify them.

## Classification Rules

Read the issue title and body. Assign exactly ONE primary label:

| Label | Criteria |
|-------|----------|
| `bug` | Reports broken behavior, errors, crashes, regressions |
| `feature` | Requests new functionality that doesn't exist |
| `enhancement` | Requests improvement to existing functionality |
| `documentation` | Reports doc issues, requests doc additions |
| `question` | Asks for help or clarification |
| `help-wanted` | Issue is well-defined and suitable for contributors |
| `good-first-issue` | Simple issue suitable for newcomers |

## Process

1. Read the issue title and body
2. Check the issue against the codebase for context
3. Determine the most appropriate label based on the classification rules
4. Add the label
5. Post a comment explaining the classification

## Comment Format

```
**Classification:** `{label}`
**Reasoning:** {1-2 sentence explanation}

{If bug: "Could you provide reproduction steps if not already included?"}
{If feature: "This has been tagged for review by maintainers."}
```

## Edge Cases

- If the issue body is empty → add `question` label, ask for details
- If the issue is clearly spam → add no label, do not comment
- If the author is in the `bots` list → skip entirely
- If multiple labels could apply → choose the primary one, mention alternatives in comment
````

---

## Example 2: Pull Request Reviewer

**Pattern:** Direct Dispatch with Conditional Execution
**Trigger:** New or updated pull requests
**Purpose:** Automated code review with structured feedback

````markdown
---
name: "PR Review Bot"
description: "Review pull requests for code quality, security, and style"
timeout-minutes: 15

on:
  pull_request:
    types: [opened, synchronize, ready_for_review]

engine:
  id: claude                         # ← Claude for strong reasoning on code
  max-turns: 20                      # ← Complex review may need many turns
  thinking: true                     # ← Enable chain-of-thought for better analysis

permissions:
  contents: read
  pull-requests: read                # ← Read PR details, writes via safe-outputs

tools:
  github:
    toolsets: [pull_requests, issues] # ← NOTE: pull_requests uses underscore
  bash: [grep, wc, find, diff]       # ← Array of allowed commands

safe-outputs:
  add-comment: {}                    # ← No sub-field constraints in v0.45.0
  add-labels:
    allowed: [needs-changes, approved, security-concern, performance-concern]
---

# Pull Request Reviewer

Review the pull request in ${{ github.repository }}.

## Skip Conditions

Do NOT review if:
- PR is a draft (not `ready_for_review`)
- PR author is in the `bots` list
- PR has fewer than 5 changed lines (trivial change)

## Review Process

### Phase 1: Overview
- Read the PR title, description, and linked issues
- List all changed files and categorize them (source, test, config, docs)
- Identify the intent of the change

### Phase 2: Code Quality
For each changed source file:
- Check error handling (are errors properly propagated or handled?)
- Check naming conventions (consistent with project style?)
- Check for TODO/FIXME/HACK comments without linked issues
- Check for magic numbers or hardcoded strings
- Check function length (flag functions > 50 lines)

### Phase 3: Security
- Check for secrets or credentials in the diff
- Check for SQL injection, XSS, or command injection patterns
- Check for unsafe deserialization
- Check dependency changes for known vulnerabilities

### Phase 4: Tests
- Verify new functionality has corresponding tests
- Check test names are descriptive
- Verify edge cases are covered

## Output

Post a single review comment with this structure:

```
## PR Review: {PR title}

### Summary
{1-2 sentence overview of the change}

### Findings

#### Critical (must fix)
{Numbered list of critical issues, or "None"}

#### Suggestions (consider)
{Numbered list of suggestions, or "None"}

### Verdict
{APPROVE / CHANGES REQUESTED / NEEDS DISCUSSION}
```

Add the appropriate label based on verdict.
````

---

## Example 3: Scheduled Status Report

**Pattern:** Recursive Scheduling with State
**Trigger:** Daily schedule
**Purpose:** Generate daily activity summaries as GitHub Discussions

````markdown
---
name: "Daily Status Report"
description: "Generate daily repository activity summary"
timeout-minutes: 10

on:
  schedule:
    - cron: "0 17 * * 1-5"          # ← Weekdays at 5pm UTC (end of day)

permissions:
  contents: read
  issues: read
  pull-requests: read
  discussions: read                  # ← Read only; writes go through safe-outputs

tools:
  github:
    toolsets: [issues, pull_requests, discussions]  # ← underscore in pull_requests
  cache-memory: null

safe-outputs:
  create-discussion:
    category: "Status Reports"
    labels: [report, daily-status]
  create-issue:                      # ← For follow-up action items
    title-prefix: "[action-item]"
    labels: [action-item]
---

# Daily Status Report

Generate a daily activity summary for ${{ github.repository }}.

## Data Collection

Gather the following for the last 24 hours:

1. **Issues:** New issues opened, issues closed, issues labeled
2. **Pull Requests:** PRs opened, PRs merged, PRs with failing checks
3. **Commits:** Commits to main branch, notable commit messages
4. **Discussions:** New discussions, answered discussions

## State Check

Read `last-report-date` from cache-memory.
If today's report already exists, skip this run.

## Report Format

Create a discussion post with this structure:

```
# Daily Status: {date}

## Activity Summary
- **Issues:** {X} opened, {Y} closed ({net} net change)
- **Pull Requests:** {X} opened, {Y} merged
- **Commits:** {X} commits to main
- **Discussions:** {X} new, {Y} answered

## Highlights
{Top 3 most significant changes, based on PR size and issue priority}

## Attention Needed
{PRs with failing checks, issues with P1/P2 labels, stale PRs > 7 days}

## Trends
{Compare with yesterday's numbers if available from cache-memory}
```

## Follow-Up

If any items in "Attention Needed" have been unresolved for > 3 days:
- Create an action-item issue for each
- Reference the original issue/PR in the action item

## State Update

Write `last-report-date: {today}` to cache-memory.
````

---

## Example 4: ChatOps Command Handler

**Pattern:** Conditional Execution via Slash Commands
**Trigger:** Issue comments containing commands
**Purpose:** Handle `/deploy`, `/rollback`, and `/status` commands

````markdown
---
name: "ChatOps Commander"
description: "Handle slash commands in issue comments"
timeout-minutes: 10

on:
  issue_comment:
    types: [created]

roles:
  deployers: "@org/deploy-team"      # ← Only these users can deploy
  admins: "@org/admins"

strict: false                          # ← Required for custom network domains and write perms

permissions:
  contents: read
  issues: read
  actions: read                      # ← Read in strict mode; action triggers via safe-outputs

tools:
  github:
    toolsets: [issues, actions]
  bash: [curl, jq]                   # ← Array of allowed commands

network:
  allowed:
    - defaults                       # ← GitHub API domains
    - "deploy.internal.example.com"  # ← Internal deployment API (requires strict: false)
  firewall: true                     # ← Enable firewall with allowed list

safe-outputs:
  add-comment: {}
  add-reaction:
    allowed: ["+1", "rocket", "eyes", "-1"]
  add-labels:
    allowed: [deploying, deployed, rollback, deploy-failed]
---

# ChatOps Command Handler

Listen for slash commands in issue comments on ${{ github.repository }}.

## Command Parsing

Read the comment body. If it starts with a `/` command, process it.
If it's not a recognized command, ignore the comment entirely.

## Commands

### `/deploy {environment}`
**Authorization:** Comment author must be in the `deployers` or `admins` role.

1. React with :eyes: to acknowledge
2. Validate the environment (staging, production)
3. Check that the latest CI checks on main are passing
4. Add `deploying` label
5. Trigger the deployment workflow via GitHub Actions API
6. Comment with deployment status
7. On success: remove `deploying`, add `deployed`, react with :rocket:
8. On failure: remove `deploying`, add `deploy-failed`, comment with error details

### `/rollback {environment}`
**Authorization:** `admins` role only.

1. React with :eyes: to acknowledge
2. Trigger rollback workflow
3. Comment with rollback status

### `/status`
**Authorization:** Any user.

1. React with :+1: to acknowledge
2. Check current deployment status for each environment
3. Comment with status table:
   ```
   | Environment | Version | Status | Deployed At |
   |-------------|---------|--------|-------------|
   | staging     | v1.2.3  | healthy| 2h ago      |
   | production  | v1.2.2  | healthy| 1d ago      |
   ```

## Error Handling

- Unknown command → ignore (do not comment)
- Unauthorized user → react with :-1:, comment "Insufficient permissions for this command"
- Invalid environment → comment "Unknown environment. Valid: staging, production"
- Deployment API unreachable → comment "Deployment service unavailable, please try again later"
````
