# Safe-Outputs Reference

Safe-outputs are the security-first mechanism for write operations in gh-aw. Agents run read-only and request actions via structured output, while separate permission-controlled jobs execute those requests.

## Architecture

```
Agent (read-only) → Structured Output → Validation → Execution Job (minimal permissions)
```

This separation enforces least privilege — the AI agent never receives write permissions. All write requests are validated against the safe-output specification before execution.

---

## Common Parameters

Most safe-output types support these cross-cutting parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | string/int | `"triggering"`, `"*"`, or specific item number (default: `"triggering"`) |
| `max` | integer | Maximum operations per run |
| `target-repo` | string | Cross-repo target in `"owner/repo"` format (default: current repo) |
| `allowed-repos` | list | Additional allowed repositories for cross-repo operations |
| `github-token` | string | Custom authentication token (default: App token) |
| `footer` | boolean/string | Attribution footer — `true`/`"always"`, `false`/`"none"`, `"if-body"` |

---

## Issues & Discussions

### `create-issue:`

```yaml
safe-outputs:
  create-issue:
    title-prefix: "[report] "
    labels: [automated, report]
    assignees: [username]
    expires: 7d
    group: daily-reports
    close-older-issues: true
    max: 3
    target-repo: "owner/other-repo"
    footer: true
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title-prefix` | string | — | Required prefix for issue titles |
| `labels` | list | — | Labels to apply automatically |
| `assignees` | list | — | Users to assign |
| `expires` | string/int/false | `7` | Auto-close timer: `2h`, `7d`, `2w`, `1m`, `1y`, integer (days), or `false` to disable |
| `group` | boolean/string | `false` | Group identifier for related issues; organize as sub-issues |
| `close-older-issues` | boolean | `false` | Close previous issues in same group |
| `max` | integer | `1` | Maximum issues per run |
| `target-repo` | string | current repo | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `footer` | boolean | `true` | Include AI-generated footer |
| `github-token` | string | — | Custom authentication token |

**Required permission:** `issues: write`

### `update-issue:`

```yaml
safe-outputs:
  update-issue:
    target: "triggering"
    status: true
    title: true
    body: true
    title-prefix: "[report]"
    max: 1
    target-repo: "owner/repo"
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target` | string/int | `"triggering"` | Target issue |
| `status` | boolean | — | Enable status updates |
| `title` | boolean | — | Enable title updates |
| `body` | boolean | — | Enable body updates |
| `title-prefix` | string | — | Restrict updates to issues matching prefix |
| `max` | integer | `1` | Maximum updates per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

**Operation values (body):** `append`, `prepend`, `replace`, `replace-island`

### `close-issue:`

```yaml
safe-outputs:
  close-issue:
    target: "triggering"
    required-labels: [automated]
    required-title-prefix: "[report]"
    state-reason: completed
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target` | string/int | `"triggering"` | Target issue |
| `required-labels` | list | — | Issue must have these labels to close |
| `required-title-prefix` | string | — | Issue title must start with this |
| `state-reason` | string | `completed` | `completed`, `not_planned`, or `duplicate` |
| `max` | integer | `1` | Maximum closes per run |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

### `link-sub-issue:`

```yaml
safe-outputs:
  link-sub-issue:
    parent-required-labels: [epic]
    parent-title-prefix: "[epic]"
    sub-required-labels: [task]
    sub-title-prefix: "[task]"
    max: 5
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `parent-required-labels` | list | — | Parent must have these labels |
| `parent-title-prefix` | string | — | Parent title filter |
| `sub-required-labels` | list | — | Sub-issue must have these labels |
| `sub-title-prefix` | string | — | Sub-issue title filter |
| `max` | integer | `1` | Maximum links per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

### `create-discussion:`

```yaml
safe-outputs:
  create-discussion:
    title-prefix: "[weekly] "
    category: "General"
    expires: 30d
    fallback-to-issue: true
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title-prefix` | string | — | Discussion title prefix |
| `category` | string | — | Category slug, name, or ID |
| `expires` | string/int/false | `7` | Auto-close timer |
| `fallback-to-issue` | boolean | `true` | Create issue if discussions are unavailable |
| `max` | integer | `1` | Maximum discussions per run |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

### `update-discussion:`

```yaml
safe-outputs:
  update-discussion:
    title: true
    body: true
    labels: true
    allowed-labels: [report, automated]
    target: "triggering"
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | boolean | — | Enable title updates |
| `body` | boolean | — | Enable body updates |
| `labels` | boolean | — | Enable label updates |
| `allowed-labels` | list | — | Restrict to specific labels |
| `target` | string/int | `"triggering"` | Target discussion |
| `max` | integer | `1` | Maximum updates per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

### `close-discussion:`

```yaml
safe-outputs:
  close-discussion:
    target: "triggering"
    required-category: "General"
    required-labels: [automated]
    required-title-prefix: "[weekly]"
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target` | string/int | `"triggering"` | Target discussion |
| `required-category` | string | — | Discussion must be in this category |
| `required-labels` | list | — | Discussion must have these labels |
| `required-title-prefix` | string | — | Title must start with this |
| `max` | integer | `1` | Maximum closes per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

**Resolution values (agent output):** `RESOLVED`, `DUPLICATE`, `OUTDATED`, `ANSWERED`

---

## Pull Requests

### `create-pull-request:`

```yaml
safe-outputs:
  create-pull-request:
    title-prefix: "[fix] "
    labels: [automated]
    reviewers: [username, team/name]
    draft: true
    expires: 7d
    base-branch: main
    fallback-as-issue: true
    protected-files: fallback-to-issue
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title-prefix` | string | — | Required prefix for PR titles |
| `labels` | list | — | Labels to apply |
| `reviewers` | list | — | Reviewers to request |
| `draft` | boolean | — | Create as draft PR |
| `expires` | string/int | — | Auto-close timer |
| `base-branch` | string | — | Target branch |
| `fallback-as-issue` | boolean | — | Create issue if PR fails |
| `protected-files` | string | — | `"fallback-to-issue"` — protect certain files from modification |
| `max` | integer | `1` | Maximum PRs per run |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

**Required permissions:** `pull-requests: write`, `contents: write` (for branch creation)

### `update-pull-request:`

```yaml
safe-outputs:
  update-pull-request:
    title: true
    body: true
    footer: true
    target: "triggering"
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | boolean | `true` | Enable title updates |
| `body` | boolean | `true` | Enable body updates |
| `footer` | boolean | `true` | Include AI footer |
| `target` | string/int | `"triggering"` | Target PR |
| `update-branch` | boolean | `false` | Sync PR branch with base branch before updating (calls `updateBranch` API) |
| `max` | integer | `1` | Maximum updates per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

**Operation values (body):** `append`, `prepend`, `replace`

### `close-pull-request:`

```yaml
safe-outputs:
  close-pull-request:
    target: "triggering"
    required-labels: [automated]
    required-title-prefix: "[fix]"
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target` | string/int | `"triggering"` | Target PR |
| `required-labels` | list | — | PR must have these labels to close |
| `required-title-prefix` | string | — | PR title must start with this |
| `max` | integer | `1` | Maximum closes per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

### `push-to-pull-request-branch:`

```yaml
safe-outputs:
  push-to-pull-request-branch:
    target: "triggering"
    title-prefix: "[fix]"
    labels: [automated]
    protected-files: fallback-to-issue
    if-no-changes: "warn"
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target` | string/int | `"triggering"` | Target PR |
| `title-prefix` | string | — | Require title prefix |
| `labels` | list | — | Require all labels present |
| `protected-files` | string | — | `"fallback-to-issue"` — protect certain files |
| `if-no-changes` | string | `"warn"` | Action when no changes: `"warn"` (default), `"error"`, `"ignore"` |
| `ignore-missing-branch-failure` | boolean | `false` | Treat missing/deleted target branches as skipped instead of failures |
| `commit-title-suffix` | string | — | Optional suffix to append to generated commit titles |
| `allowed-files` | list | — | Glob patterns forming a strict allowlist of files eligible for push |
| `excluded-files` | list | — | Glob patterns for files to exclude via git pathspecs (stripped before commit) |
| `patch-format` | string | `"am"` | Transport format: `"am"` (git format-patch) or `"bundle"` (git bundle, preserves merge topology) |
| `fallback-as-pull-request` | boolean | `true` | Create fallback PR when push fails due to diverged/non-fast-forward branch; set `false` to disable |
| `allow-workflows` | boolean | `false` | Add `workflows: write` to the App token (requires `safe-outputs.github-app`) |
| `github-token-for-extra-empty-commit` | string | — | Token for empty commit to trigger CI (PAT or `"app"`) |
| `max` | integer | `1` | Maximum pushes per run |
| `target-repo` | string | — | Cross-repo target (`"owner/repo"`) |
| `allowed-repos` | list | — | Additional allowed repositories |

**Required permissions:** `pull-requests: write`, `contents: write`

### `create-pull-request-review-comment:`

```yaml
safe-outputs:
  create-pull-request-review-comment:
    max: 10
    side: RIGHT
    target: "triggering"
    footer: true
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | `10` | Maximum comments per run |
| `side` | string | `RIGHT` | `LEFT` or `RIGHT` — which diff side |
| `target` | string/int | `"triggering"` | Target PR |
| `footer` | string | `"always"` | `"always"`, `"none"`, or `"if-body"` |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

### `reply-to-pull-request-review-comment:`

```yaml
safe-outputs:
  reply-to-pull-request-review-comment:
    max: 10
    target: "triggering"
    footer: "if-body"
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | `10` | Maximum replies per run |
| `target` | string/int | `"triggering"` | Target PR |
| `footer` | boolean | `true` | Include attribution footer |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

### `submit-pull-request-review:`

```yaml
safe-outputs:
  submit-pull-request-review:
    footer: true
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | `1` | Maximum reviews per run |
| `target` | string/int | `"triggering"` | Target PR |
| `footer` | boolean | `true` | Include attribution footer |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

**Event values (agent output):** `APPROVE`, `REQUEST_CHANGES`, `COMMENT`

### `resolve-pull-request-review-thread:`

```yaml
safe-outputs:
  resolve-pull-request-review-thread:
    max: 10
    target: "triggering"
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | `10` | Maximum resolutions per run |
| `target` | string/int | `"triggering"` | Target PR |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

---

## Labels, Comments & Assignments

### `add-labels:`

```yaml
safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement, documentation, question]
    blocked: ["~*", "*[bot]"]
    target: "triggering"
    max: 5
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `allowed` | list | — | **Allowlist of permitted labels** — agent can only apply these |
| `blocked` | list | — | **Deny patterns** — glob format (e.g., `~*`, `*[bot]`) |
| `target` | string/int | `"triggering"` | Target issue/PR |
| `max` | integer | `3` | Maximum labels per run |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

### `remove-labels:`

```yaml
safe-outputs:
  remove-labels:
    allowed: [needs-triage, stale]
    blocked: ["protected-*"]
    target: "triggering"
    max: 3
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `allowed` | list | — | Restrict which labels can be removed |
| `blocked` | list | — | Deny removal patterns (glob format) |
| `target` | string/int | `"triggering"` | Target issue/PR |
| `max` | integer | `3` | Maximum removals per run |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

### `add-comment:`

```yaml
safe-outputs:
  add-comment:
    target: "triggering"
    hide-older-comments: true
    allowed-reasons: ["outdated"]
    discussion: false
    footer: true
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `target` | string/int | `"triggering"` | Target issue/PR/discussion |
| `hide-older-comments` | boolean | `false` | Minimize previous bot comments |
| `allowed-reasons` | list | — | Reasons for hiding (e.g., `outdated`) |
| `discussion` | boolean | `false` | Comment on discussion instead of issue/PR |
| `footer` | boolean | `true` | Include attribution footer |
| `max` | integer | `1` | Maximum comments per run |
| `target-repo` | string | — | Cross-repo target |
| `allowed-repos` | list | — | Additional allowed repositories |
| `github-token` | string | — | Custom authentication token |

**CRITICAL:** `add-comment` defaults to requesting `discussions:write` permission. Always add `discussions: false` unless discussions are explicitly needed, or the App token fails with HTTP 422.

### `hide-comment:`

```yaml
safe-outputs:
  hide-comment:
    max: 5
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | `5` | Maximum hides per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

**Valid reasons:** `spam`, `abuse`, `off_topic`, `outdated`, `resolved`

### `add-reviewer:`

```yaml
safe-outputs:
  add-reviewer:
    reviewers: [user1, team/reviewers]
    target: "triggering"
    max: 3
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `reviewers` | list | — | Restrict to specific users/teams |
| `target` | string/int | `"triggering"` | Target PR |
| `max` | integer | `3` | Maximum reviewers per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

### `assign-milestone:`

```yaml
safe-outputs:
  assign-milestone:
    allowed: ["v1.0", "v2.0", "backlog"]
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `allowed` | list | — | Restrict to milestone titles |
| `max` | integer | `1` | Maximum assignments per run |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

### `assign-to-agent:` / `assign-to-user:` / `unassign-from-user:`

```yaml
safe-outputs:
  assign-to-agent:
    max: 1
  assign-to-user:
    max: 1
  unassign-from-user:
    max: 1
```

---

## Projects, Releases & Assets

### `create-project:`

```yaml
safe-outputs:
  create-project:
    github-token: ${{ secrets.PROJECT_TOKEN }}
    target-owner: "my-org"
    title-prefix: "[sprint] "
    views:
      - name: "Board"
        layout: board
      - name: "Table"
        layout: table
        filter: "is:open"
        visible-fields: [Title, Status]
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `github-token` | string | — | **Required** — custom token (default `GITHUB_TOKEN` insufficient) |
| `target-owner` | string | — | Default target owner |
| `title-prefix` | string | — | Default title prefix |
| `views` | list | — | Auto-create views (`name`, `layout`: `table`/`board`/`roadmap`, optional `filter`, `visible-fields`) |
| `max` | integer | `1` | Maximum projects per run |

**Note:** Projects v2 requires a custom token (not `GITHUB_TOKEN`).

### `update-project:`

```yaml
safe-outputs:
  update-project:
    project: "https://github.com/orgs/org/projects/1"
    github-token: ${{ secrets.PROJECT_TOKEN }}
    views: ["board"]
    create_if_missing: false
    max: 10
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `project` | string | — | **Required** — target project URL |
| `github-token` | string | — | **Required** — custom token |
| `views` | list | — | Auto-create views |
| `create_if_missing` | boolean | `false` | Create project if it doesn't exist |
| `max` | integer | `10` | Maximum updates per run |

**Supported field types:** `TEXT`, `DATE`, `NUMBER`, `ITERATION`, `SINGLE_SELECT`

### `create-project-status-update:`

```yaml
safe-outputs:
  create-project-status-update:
    project: "https://github.com/orgs/org/projects/1"
    github-token: ${{ secrets.PROJECT_TOKEN }}
    max: 1
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `project` | string | — | **Required** — target project URL |
| `github-token` | string | — | **Required** — custom token |
| `max` | integer | `1` | Maximum updates per run |

**Status values (agent output):** `ON_TRACK`, `AT_RISK`, `OFF_TRACK`, `COMPLETE`, `INACTIVE` (default: `ON_TRACK`)

### `update-release:`

```yaml
safe-outputs:
  update-release:
    max: 1
    target-repo: "owner/repo"
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | `1` | Maximum updates per run (max: 10) |
| `target-repo` | string | — | Cross-repo target |
| `github-token` | string | — | Custom authentication token |

**Operation values:** `replace`, `append`, `prepend`

**Required permission:** `contents: write`

### `upload-asset:`

```yaml
safe-outputs:
  upload-asset:
    branch: "assets/${{ github.workflow }}"
    max-size: 10240
    allowed-exts: [".png", ".jpg", ".jpeg"]
    max: 10
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `branch` | string | `assets/${{ github.workflow }}` | Orphaned git branch for uploads |
| `max-size` | integer | `10240` | Maximum file size in KB |
| `allowed-exts` | list | `[".png", ".jpg", ".jpeg"]` | Allowed file extensions |
| `max` | integer | `10` | Maximum uploads per run |
| `github-token` | string | — | Custom authentication token |

---

## Security & Automation

### `create-code-scanning-alert:`

```yaml
safe-outputs:
  create-code-scanning-alert:
    max: 50
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | unlimited | Maximum alerts per run |
| `github-token` | string | — | Custom authentication token |

**Severity values:** `error`, `warning`, `info`, `note`

**Required permission:** `security-events: write`

### `autofix-code-scanning-alert:`

```yaml
safe-outputs:
  autofix-code-scanning-alert:
    max: 10
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | `10` | Maximum autofixes per run |
| `github-token` | string | — | Custom authentication token |

### `dispatch-workflow:`

```yaml
safe-outputs:
  dispatch-workflow:
    workflows: ["downstream-processor.yml", "notifier.yml"]
    max: 3
```

**Shorthand syntax:**

```yaml
safe-outputs:
  dispatch-workflow: [workflow1, workflow2]
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `workflows` | list | — | **Required** — workflow names (without `.md`) |
| `max` | integer | `1` | Maximum dispatches per run (maximum: 50) |

**Required permission:** `actions: write`. Same-repository only.

### `call-workflow:`

```yaml
safe-outputs:
  call-workflow:
    max: 1
```

Calls reusable workflows via compile-time fan-out. Same-repo only.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | `1` | Maximum calls per run |

### `create-agent-session:`

```yaml
safe-outputs:
  create-agent-session:
    max: 1
```

Creates Copilot coding agent sessions.

---

## System Types (Auto-Enabled)

These are always available and don't need explicit declaration:

### `noop:`

Completion messages when no actions are needed. Agent uses this when analysis concludes no GitHub action (issue, comment, PR, label, etc.) is required.

- Set to `false` to disable
- Enabled by default

### `missing-tool:`

Report tools the agent needs but doesn't have access to.

- Set to `false` to disable
- Enabled by default

### `missing-data:`

Report data gaps that prevent the agent from achieving its goals.

```yaml
safe-outputs:
  missing-data:
    create-issue: true
    title-prefix: "[missing data]"
    labels: [data-gap]
    max: 3
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `create-issue` | boolean | `false` | Generate issues for missing data |
| `title-prefix` | string | `[missing data]` | Title prefix for generated issues |
| `labels` | list | — | Labels for generated issues |
| `max` | integer | unlimited | Maximum reports per run |
| `github-token` | string | — | Custom authentication token |

---

## Target Specification

```yaml
target: "triggering"    # The issue/PR/discussion that triggered the workflow
target: "*"             # Any item; agent specifies number in output
target: 123             # Specific item number
```

## Operation Modes

The `operation` field on update types:

| Mode | Behavior |
|------|----------|
| `append` | Add to end with separator (default) |
| `prepend` | Add to start with separator |
| `replace` | Complete replacement |
| `replace-island` | Update HTML-comment-delimited section only |

## Footer Configuration

The `footer` field controls attribution on comments:

| Value | Behavior |
|-------|----------|
| `true` / `"always"` | Always include footer |
| `false` / `"none"` | Never include |
| `"if-body"` | Only when body text is present |

## Item Tracking

All workflow-created items include a hidden marker:
```html
<!-- gh-aw-workflow-id: WORKFLOW_NAME -->
```

Search for workflow-created items:
```
repo:owner/repo "gh-aw-workflow-id: daily-status" in:body
```

## Required Permissions by Category

| Category | Primary Permission | Secondary |
|----------|--------------------|-----------|
| Issue operations | `issues: write` | — |
| PR operations | `pull-requests: write` | `contents: write` (branch push) |
| Discussions | `discussions: write` | — |
| Projects v2 | Custom token required | `GH_AW_PROJECT_GITHUB_TOKEN` |
| Releases | `contents: write` | — |
| Code scanning | `security-events: write` | — |
| Workflow dispatch | `actions: write` | Same-repo only |

## Global Configuration

```yaml
safe-outputs:
  github-token: ${{ secrets.CUSTOM_TOKEN }}
  app: ${{ secrets.GH_AW_APP_TOKEN }}
  max-patch-size: 5242880
  report-failure-as-issue: true
  failure-issue-repo: "owner/ops-repo"
  group-reports: true
  environment: production
  allowed-domains: ["github.com", "*.internal.com"]
  allowed-github-references: ["owner/repo"]
  max-bot-mentions: 3
  concurrency-group: "my-safe-outputs"
  messages:
    append-only-comments: true
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `github-token` | string | Custom token for all safe-output operations |
| `app` | string | App token for all safe-output operations |
| `max-patch-size` | integer | Maximum patch size in bytes (default: 5242880) |
| `report-failure-as-issue` | boolean | Create issues when safe-output execution fails |
| `failure-issue-repo` | string | Repository for failure issue reporting |
| `group-reports` | boolean | Group failure reports together |
| `environment` | string | Environment protection for safe-outputs job |
| `allowed-domains` | list | Restrict domains in sanitized text |
| `allowed-github-references` | list | Restrict GitHub references in sanitized text |
| `max-bot-mentions` | integer | Maximum bot mentions per operation |
| `concurrency-group` | string | Controls safe-outputs job concurrency |
| `messages` | object | Custom workflow messages |

## Cross-Repository Support

**Supported:** create-issue, update-issue, close-issue, add-comment, add-labels, remove-labels, all PR operations, discussions, release updates.

**Not supported:** push-to-pull-request-branch, dispatch-workflow, call-workflow, code-scanning, most project operations.

Use `target-repo: "owner/repo"` on supported types. Use `allowed-repos` to permit additional repositories.

**Wildcard `target-repo`:** The value `target-repo: "*"` is supported at the handler level to permit operations against any repository the App token can access. Use with caution — this grants cross-repo write capability without allowlist restrictions.
