# Safe-Outputs Reference

Safe-outputs are the security-first mechanism for write operations in gh-aw. Agents run read-only and request actions via structured output, while separate permission-controlled jobs execute those requests.

## Architecture

```
Agent (read-only) → Structured Output → Validation → Execution Job (minimal permissions)
```

This separation enforces least privilege — the AI agent never receives write permissions. All write requests are validated against the safe-output specification before execution.

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
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `title-prefix` | string | Required prefix for issue titles |
| `labels` | list | Labels to apply automatically |
| `assignees` | list | Users to assign |
| `expires` | string/int | Auto-close timer: `2h`, `7d`, `2w`, `1m`, `1y`, or integer (days). `false` to disable |
| `group` | string | Group identifier for related issues |
| `close-older-issues` | boolean | Close previous issues in same group |
| `max` | integer | Maximum issues per run (default: 1) |
| `target-repo` | string | Cross-repo target (default: current repo) |

**Required permission:** `issues: write`

### `update-issue:`

```yaml
safe-outputs:
  update-issue:
    target: "triggering"
    operation: append
    max: 1
    target-repo: "owner/repo"
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | string/int | `"triggering"`, `"*"`, or specific issue number |
| `operation` | string | `append` (default), `prepend`, `replace`, `replace-island` |
| `status` | string | Update issue status |
| `title` | string | Update title |
| `body` | string | Update body |
| `max` | integer | Maximum updates per run (default: 1) |

### `close-issue:`

```yaml
safe-outputs:
  close-issue:
    target: "triggering"
    required-labels: [automated]
    required-title-prefix: "[report]"
    max: 1
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | string/int | `"triggering"`, `"*"`, or specific number |
| `required-labels` | list | Issue must have these labels to close |
| `required-title-prefix` | string | Issue title must start with this |

### `link-sub-issue:`

```yaml
safe-outputs:
  link-sub-issue:
    parent-required-labels: [epic]
    sub-required-labels: [task]
    max: 5
```

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

### `update-discussion:` / `close-discussion:`

Similar parameters to issue equivalents with discussion-specific fields (`required-category`).

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
    max: 1
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `title-prefix` | string | Required prefix for PR titles |
| `labels` | list | Labels to apply |
| `reviewers` | list | Reviewers to request |
| `draft` | boolean | Create as draft PR |
| `expires` | string/int | Auto-close timer |
| `base-branch` | string | Target branch |
| `fallback-as-issue` | boolean | Create issue if PR fails |

**Required permissions:** `pull-requests: write`, `contents: write` (for branch creation)

### `update-pull-request:` / `close-pull-request:`

Similar to issue equivalents.

### `push-to-pull-request-branch:`

```yaml
safe-outputs:
  push-to-pull-request-branch:
    target: "triggering"
    title-prefix: "[fix]"
    labels: [automated]
    if-no-changes: "comment"
    max: 1
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `if-no-changes` | string | Action when no changes: `"comment"`, `"skip"` |

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

### `reply-to-pull-request-review-comment:`

```yaml
safe-outputs:
  reply-to-pull-request-review-comment:
    max: 10
    target: "triggering"
    footer: "if-body"
```

### `submit-pull-request-review:`

```yaml
safe-outputs:
  submit-pull-request-review:
    footer: true
    max: 1
```

### `resolve-pull-request-review-thread:`

```yaml
safe-outputs:
  resolve-pull-request-review-thread:
    max: 10
```

---

## Labels, Comments & Assignments

### `add-labels:`

```yaml
safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement, documentation, question]
    target: "triggering"
    max: 5
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `allowed` | list | **Allowlist of permitted labels** — agent can only apply these |
| `target` | string/int | Target issue/PR |
| `max` | integer | Maximum labels per run (default: 3) |

### `remove-labels:`

```yaml
safe-outputs:
  remove-labels:
    allowed: [needs-triage, stale]
    target: "triggering"
    max: 3
```

### `add-comment:`

```yaml
safe-outputs:
  add-comment:
    target: "triggering"
    hide-older-comments: true
    allowed-reasons: ["outdated"]
    discussion: false
    max: 1
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `hide-older-comments` | boolean | Minimize previous bot comments |
| `allowed-reasons` | list | Reasons for hiding (e.g., `outdated`) |
| `discussion` | boolean | Comment on discussion instead of issue/PR |

### `hide-comment:`

```yaml
safe-outputs:
  hide-comment:
    max: 5
```

### `add-reviewer:`

```yaml
safe-outputs:
  add-reviewer:
    reviewers: [user1, team/reviewers]
    target: "triggering"
    max: 3
```

### `assign-milestone:`

```yaml
safe-outputs:
  assign-milestone:
    allowed: ["v1.0", "v2.0", "backlog"]
    max: 1
```

### `assign-to-agent:` / `assign-to-user:` / `unassign-from-user:`

```yaml
safe-outputs:
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
    views: ["board", "table"]
    max: 1
```

**Note:** Projects v2 requires a custom token (not `GITHUB_TOKEN`).

### `update-project:`

```yaml
safe-outputs:
  update-project:
    project: "https://github.com/orgs/org/projects/1"
    github-token: ${{ secrets.PROJECT_TOKEN }}
    views: ["board"]
    max: 10
```

### `create-project-status-update:`

```yaml
safe-outputs:
  create-project-status-update:
    project: "https://github.com/orgs/org/projects/1"
    github-token: ${{ secrets.PROJECT_TOKEN }}
    status: "on_track"
    max: 1
```

### `update-release:`

```yaml
safe-outputs:
  update-release:
    max: 1
```

**Required permission:** `contents: write`

### `upload-asset:`

```yaml
safe-outputs:
  upload-asset:
    branch: main
    max-size: 1024
    allowed-exts: [".json", ".csv", ".md"]
    max: 10
```

---

## Security & Automation

### `create-code-scanning-alert:`

```yaml
safe-outputs:
  create-code-scanning-alert:
    max: 50
```

**Required permission:** `security-events: write`

### `autofix-code-scanning-alert:`

```yaml
safe-outputs:
  autofix-code-scanning-alert:
    max: 10
```

### `dispatch-workflow:`

```yaml
safe-outputs:
  dispatch-workflow:
    workflows: ["downstream-processor.yml", "notifier.yml"]
    max: 3
```

**Required permission:** `actions: write`. Same-repository only.

### `create-agent-session:`

```yaml
safe-outputs:
  create-agent-session:
    max: 1
```

---

## System Types (Auto-Enabled)

These are always available and don't need explicit declaration:

| Type | Purpose |
|------|---------|
| `noop:` | Completion messages when no actions are needed |
| `missing-tool:` | Report tools the agent needs but doesn't have |
| `missing-data:` | Report data gaps; can optionally create issues |

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
  messages:
    append-only-comments: true
```

## Cross-Repository Support

**Supported:** create-issue, update-issue, close-issue, add-comment, add-labels, remove-labels, all PR operations, discussions, release updates.

**Not supported:** push-to-pull-request-branch, dispatch-workflow, code-scanning, most project operations.

Use `target-repo: "owner/repo"` on supported types.
