# Frontmatter Schema Reference

gh-aw workflow files use YAML frontmatter delimited by `---` markers. This is the complete field reference.

---

## Quick Index

| Field | Category | Anchor |
|-------|----------|--------|
| `add-comment` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#add-comment) |
| `add-labels` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#add-labels) |
| `add-reviewer` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#add-reviewer) |
| `agentic-workflows` | [Tools](#5-tools-tools) | [link](#agentic-workflows-tool) |
| `assign-milestone` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#assign-milestone) |
| `assign-to-agent` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#assign-to-agent) |
| `assign-to-user` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#assign-to-user) |
| `autofix-code-scanning-alert` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#autofix-code-scanning-alert) |
| `bash` | [Tools](#5-tools-tools) | [link](#bash-tool) |
| `cache` | [Container & Services](#11-container--services) | [link](#cache) |
| `cache-memory` | [Tools](#5-tools-tools) | [link](#cache-memory-tool) |
| `close-issue` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#close-issue) |
| `close-pull-request` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#close-pull-request) |
| `concurrency` | [Engine Configuration](#4-engine-configuration-engine) | [link](#concurrency) |
| `container` | [Container & Services](#11-container--services) | [link](#container) |
| `create-agent-session` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#create-agent-session) |
| `create-code-scanning-alert` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#create-code-scanning-alert) |
| `create-discussion` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#create-discussion) |
| `create-issue` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#create-issue) |
| `create-project` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#create-project) |
| `create-project-status-update` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#create-project-status-update) |
| `create-pull-request` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#create-pull-request) |
| `create-pull-request-review-comment` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#create-pull-request-review-comment) |
| `description` | [Workflow Identity](#1-workflow-identity) | [link](#description) |
| `dispatch-workflow` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#dispatch-workflow) |
| `edit` | [Tools](#5-tools-tools) | [link](#edit-tool) |
| `engine` | [Engine Configuration](#4-engine-configuration-engine) | [link](#engine) |
| `env` | [Environment & Secrets](#12-environment--secrets) | [link](#env) |
| `environment` | [Engine Configuration](#4-engine-configuration-engine) | [link](#environment) |
| `features` | [Environment & Secrets](#12-environment--secrets) | [link](#features) |
| `github` | [Tools](#5-tools-tools) | [link](#github-tool) |
| `hide-comment` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#hide-comment) |
| `if` | [Triggers](#2-triggers-on) | [link](#if) |
| `imports` | [Imports & Dependencies](#10-imports--dependencies) | [link](#imports) |
| `labels` | [Workflow Identity](#1-workflow-identity) | [link](#labels) |
| `link-sub-issue` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#link-sub-issue) |
| `lockdown` | [Workflow Identity](#1-workflow-identity) | [link](#lockdown) |
| `manual-approval` | [Triggers](#2-triggers-on) | [link](#manual-approval) |
| `mcp-servers` | [MCP Servers](#6-mcp-servers-mcp-servers) | [link](#mcp-servers) |
| `metadata` | [Workflow Identity](#1-workflow-identity) | [link](#metadata) |
| `name` | [Workflow Identity](#1-workflow-identity) | [link](#name) |
| `network` | [Network & Sandbox](#9-network--sandbox) | [link](#network) |
| `on` | [Triggers](#2-triggers-on) | [link](#on) |
| `permissions` | [Permissions](#3-permissions-permissions) | [link](#permissions) |
| `playwright` | [Tools](#5-tools-tools) | [link](#playwright-tool) |
| `plugins` | [Imports & Dependencies](#10-imports--dependencies) | [link](#plugins) |
| `post-steps` | [Steps & Post-Steps](#8-steps--post-steps) | [link](#post-steps) |
| `push-to-pull-request-branch` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#push-to-pull-request-branch) |
| `reaction` | [Triggers](#2-triggers-on) | [link](#reaction) |
| `remove-labels` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#remove-labels) |
| `repo-memory` | [Tools](#5-tools-tools) | [link](#repo-memory-tool) |
| `reply-to-pull-request-review-comment` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#reply-to-pull-request-review-comment) |
| `resolve-pull-request-review-thread` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#resolve-pull-request-review-thread) |
| `run-name` | [Engine Configuration](#4-engine-configuration-engine) | [link](#run-name) |
| `runs-on` | [Engine Configuration](#4-engine-configuration-engine) | [link](#runs-on) |
| `safe-outputs` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#safe-outputs-root) |
| `sandbox` | [Network & Sandbox](#9-network--sandbox) | [link](#sandbox) |
| `secrets` | [Environment & Secrets](#12-environment--secrets) | [link](#secrets) |
| `serena` | [Tools](#5-tools-tools) | [link](#serena-tool) |
| `services` | [Container & Services](#11-container--services) | [link](#services) |
| `skip-if-match` | [Triggers](#2-triggers-on) | [link](#skip-if-match) |
| `skip-if-no-match` | [Triggers](#2-triggers-on) | [link](#skip-if-no-match) |
| `source` | [Workflow Identity](#1-workflow-identity) | [link](#source) |
| `startup-timeout` | [Tools](#5-tools-tools) | [link](#startup-timeout) |
| `steps` | [Steps & Post-Steps](#8-steps--post-steps) | [link](#steps) |
| `stop-after` | [Triggers](#2-triggers-on) | [link](#stop-after) |
| `strict` | [Workflow Identity](#1-workflow-identity) | [link](#strict) |
| `submit-pull-request-review` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#submit-pull-request-review) |
| `timeout` | [Tools](#5-tools-tools) | [link](#timeout) |
| `timeout-minutes` | [Engine Configuration](#4-engine-configuration-engine) | [link](#timeout-minutes) |
| `tracker-id` | [Workflow Identity](#1-workflow-identity) | [link](#tracker-id) |
| `tools` | [Tools](#5-tools-tools) | [link](#tools-root) |
| `unassign-from-user` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#unassign-from-user) |
| `update-discussion` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#update-discussion) |
| `update-issue` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#update-issue) |
| `update-project` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#update-project) |
| `update-pull-request` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#update-pull-request) |
| `update-release` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#update-release) |
| `upload-asset` | [Safe Outputs](#7-safe-outputs-safe-outputs) | [link](#upload-asset) |
| `web-fetch` | [Tools](#5-tools-tools) | [link](#web-fetch-tool) |
| `web-search` | [Tools](#5-tools-tools) | [link](#web-search-tool) |

---

## 1. Workflow Identity

### `name`

- **Type:** string
- **Required:** no
- **Default:** filename without `.md` extension
- **Description:** Human-readable workflow name displayed in the GitHub Actions interface.

```yaml
name: "Issue Triage Agent"
```

### `description`

- **Type:** string
- **Required:** no
- **Default:** none
- **Description:** Brief description of the workflow purpose. Rendered as a comment in the compiled `.lock.yml`.

```yaml
description: "Classify and label new issues based on content analysis"
```

### `source`

- **Type:** string
- **Required:** no
- **Default:** none
- **Accepted Values:** `owner/repo/path@ref` format
- **Description:** Indicates where this workflow was sourced from.

```yaml
source: githubnext/agentics/workflows/ci-doctor.md@v1.0.0
```

### `tracker-id`

- **Type:** string
- **Required:** no
- **Default:** none
- **Accepted Values:** minimum 8 characters, alphanumeric with hyphens and underscores
- **Description:** Tags all assets created by the workflow (issues, discussions, comments, PRs) enabling search and retrieval.

```yaml
tracker-id: triage-bot-01
```

- **Gotchas:** Must be at least 8 characters. Shorter values fail compilation.

### `labels`

- **Type:** list of strings
- **Required:** no
- **Default:** none
- **Description:** Labels used to categorize and organize workflows. Used for filtering in `gh aw status`/`gh aw list`.

```yaml
labels: [automated, triage]
```

### `metadata`

- **Type:** mapping (key-value pairs)
- **Required:** no
- **Default:** none
- **Description:** Arbitrary key-value pairs for custom workflow metadata. Compatible with the custom agent spec.

```yaml
metadata:
  team: platform
  priority: high
```

- **Gotchas:** Key names limited to 64 characters; values limited to 1024 characters.

### `strict`

- **Type:** boolean
- **Required:** no
- **Default:** `true`
- **Description:** When true, unknown keys cause compilation errors and all permissions must be explicit. Set to `false` when using custom network domains or processing untrusted/external input.

```yaml
strict: false
```

- **Gotchas:** Custom network domains (anything not covered by ecosystem identifiers) **require** `strict: false` or the compiler rejects them. Ecosystem identifiers (`defaults`, `github`, `containers`, `node`, `python`) work in strict mode.
- **Cross-references:** See [Network](#network), `validation.md`

### `lockdown`

- **Type:** boolean
- **Required:** no
- **Default:** auto-enables for public repos with custom tokens
- **Description:** Security filtering for public repositories. When enabled, agents only process content from authenticated contributors.

```yaml
lockdown: true
```

- **Gotchas:** Defaults to enabled on public repos with custom tokens. Setting `lockdown: false` on a public repo is a security anti-pattern — external input becomes untrusted.

---

## 2. Triggers (`on:`)

### `on`

- **Type:** string | mapping
- **Required:** yes
- **Default:** none
- **Description:** Defines when the workflow triggers. Accepts event names, schedule formats, or slash command shorthands.

**Format 1 — Simple event string:**

```yaml
on: push
```

**Format 2 — Schedule shorthand:**

```yaml
on: daily
```

**Format 3 — Slash command shorthand:**

```yaml
on: /my-bot
```

Expands to `slash_command` + `workflow_dispatch`.

**Format 4 — Detailed mapping:**

```yaml
on:
  issues:
    types: [opened, reopened]
    reaction: eyes
  pull_request:
    types: [opened, synchronize]
    reaction: eyes
```

- **Gotchas:** The trigger field for issues is `issues` (plural), NOT `issue`. This is the #1 most common mistake.

### Event Types

All supported event triggers and their sub-fields:

#### `issues`

- **Type:** null | object
- **Sub-fields:** `types` (array), `names` (string | array — label filter), `lock-for-agent` (boolean), `reaction` (string)

```yaml
on:
  issues:
    types: [opened, reopened, edited, closed]
    names: ["needs-triage"]
    lock-for-agent: true
    reaction: eyes
```

#### `pull_request`

- **Type:** null | object
- **Sub-fields:** `types` (array — `created`, `updated`, `closed`), `branches` (array), `paths` (array), `reaction` (string)

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main]
    reaction: eyes
```

#### `issue_comment`

- **Type:** null | object
- **Sub-fields:** `types` (array), `lock-for-agent` (boolean), `reaction` (string)

```yaml
on:
  issue_comment:
    types: [created]
    lock-for-agent: true
    reaction: eyes
```

#### `discussion`

- **Type:** null | object
- **Sub-fields:** `types` (array — `created`, `answered`, etc.), `reaction` (string)

#### `discussion_comment`

- **Type:** null | object
- **Sub-fields:** `types` (array), `reaction` (string)

#### `push`

- **Type:** null | object
- **Sub-fields:** `branches` (array), `paths` (array), `tags` (array)

```yaml
on:
  push:
    branches: [main]
    paths: ["src/**"]
```

#### `schedule`

- **Type:** string | array of objects
- **Accepted Values:** Natural language shorthands, cron expressions
- **Shorthands:** `daily`, `daily around 14:00`, `weekly on monday`, `hourly`, `every 2h`
- **Cron:** `"0 9 * * 1-5"` (standard 5-field cron)

```yaml
on:
  schedule: "daily around 09:00"
```

```yaml
on:
  schedule: "0 9 * * 1"
```

- **Gotchas:** Fuzzy schedules distribute execution times to prevent load spikes. Minimum interval is 5 minutes.

#### `slash_command`

- **Type:** null | string | object
- **Formats:**
  - `null` — defaults to workflow filename without `.md`
  - string — custom command name (must not start with `/`)
  - object — `name` (string | array), `events` (`'*'` | array)

```yaml
on:
  slash_command:
    name: ["deploy", "rollback"]
    events: ["issue_comment", "pull_request_review_comment"]
```

#### `workflow_dispatch`

- **Type:** null | object
- **Sub-fields:** `inputs` (object — parameter definitions)

```yaml
on:
  workflow_dispatch:
    inputs:
      target:
        description: "Deployment target"
        required: true
        type: string
```

#### `workflow_run`

- **Type:** null | object

#### `release`

- **Type:** null | object
- **Sub-fields:** `types` (array — release event types)

#### `pull_request_review_comment`

- **Type:** null | object
- **Sub-fields:** `types` (array)

#### `pull_request_review`

- **Type:** null | object
- **Sub-fields:** `types` (array)

#### `pull_request_target`

- **Type:** null | object

#### Other Event Triggers

All of these accept `null` or an object with optional `types` (array):

`branch_protection_rule`, `check_run`, `check_suite`, `create`, `delete`, `deployment`, `deployment_status`, `fork`, `gollum` (wiki page changes), `label`, `merge_group`, `milestone`, `page_build`, `public`, `registry_package`, `repository_dispatch` (custom event types), `status`, `watch`

### Conditional Execution Fields

#### `reaction`

- **Type:** string | integer
- **Required:** yes for event-triggered workflows (issues, PRs, comments, discussions)
- **Default:** `eyes`
- **Accepted Values:** `+1`, `-1`, `laugh`, `confused`, `heart`, `hooray`, `rocket`, `eyes`, `none`

```yaml
on:
  issues:
    types: [opened]
    reaction: eyes
```

- **Gotchas:** YAML parses `+1` and `-1` without quotes as integers; they are auto-converted to strings at runtime. Required for `pre_activation` permission grants. Missing `reaction: eyes` is the second most common compilation error.
- **Cross-references:** `validation.md` — trigger errors

#### `stop-after`

- **Type:** string
- **Required:** no
- **Default:** none
- **Accepted Values:** Absolute dates or relative durations
- **Date formats:** `YYYY-MM-DD HH:MM:SS`, `June 1 2025`, `06/01/2025`
- **Relative formats:** `+25h`, `+3d`, `+1d12h30m`
- **Maximum values:** `12mo`, `52w`, `365d`, `8760h`

```yaml
stop-after: "+7d"
```

```yaml
stop-after: "2025-12-31"
```

- **Gotchas:** Minute unit `m` is NOT allowed; minimum granularity is hours (`h`).

#### `skip-if-match`

- **Type:** string | object
- **Required:** no
- **Default:** none
- **Description:** Skip the workflow run if the search query returns results.

**String format** (implies `max: 1`):

```yaml
skip-if-match: "repo:owner/repo is:issue label:daily-report is:open"
```

**Object format:**

```yaml
skip-if-match:
  query: "repo:owner/repo is:issue label:daily-report is:open"
  max: 3
```

#### `skip-if-no-match`

- **Type:** string | object
- **Required:** no
- **Default:** none
- **Description:** Skip the workflow run if the search query returns NO results.

**String format** (implies `min: 1`):

```yaml
skip-if-no-match: "repo:owner/repo is:issue label:needs-triage is:open"
```

**Object format:**

```yaml
skip-if-no-match:
  query: "repo:owner/repo is:issue label:needs-triage is:open"
  min: 5
```

#### `manual-approval`

- **Type:** string
- **Required:** no
- **Default:** none
- **Description:** Environment name requiring manual approval before the workflow proceeds.

```yaml
manual-approval: production
```

#### `if`

- **Type:** string (GitHub Actions expression)
- **Required:** no
- **Default:** none
- **Description:** Prevents workflow runs from starting entirely when the condition evaluates to false. Evaluated **before** any jobs run, saving compute.

```yaml
if: contains(github.event.issue.labels.*.name, 'needs-triage')
```

```yaml
if: github.event.action == 'labeled' && contains(github.event.issue.labels.*.name, 'status:assessed')
```

- **Gotchas:** Uses GitHub Actions expression syntax without the `${{ }}` wrapper.
- **Cross-references:** `production-gotchas.md` — `if` guard

---

## 3. Permissions (`permissions:`)

### `permissions`

- **Type:** string | mapping
- **Required:** no (but strongly recommended)
- **Default:** none

**Format 1 — Shorthand string:**

```yaml
permissions: read-all
```

**Format 2 — Granular mapping:**

```yaml
permissions:
  contents: read
  issues: read
  pull-requests: read
  actions: read
```

### Scopes

| Scope | Accepted Values | Purpose |
|-------|----------------|---------|
| `actions` | `read` | Workflow runs, logs, dispatch |
| `attestations` | `read` | Attestation verification |
| `checks` | `read` | Check runs and suites |
| `contents` | `read` | Repository files, commits, branches |
| `deployments` | `read` | Deployments |
| `discussions` | `read` | Discussions |
| `id-token` | `read` | OIDC token requests |
| `issues` | `read` | Issues and issue comments |
| `metadata` | `read` | Repository metadata |
| `models` | `read` | Copilot AI models access |
| `packages` | `read` | GitHub Packages |
| `pages` | `read` | GitHub Pages |
| `pull-requests` | `read` | Pull requests and PR comments |
| `security-events` | `read` | Code scanning alerts |
| `statuses` | `read` | Commit statuses |
| `all` | `read` | Shorthand for all scopes |

- **Gotchas:** The compiler **rejects** `write` values in `permissions:`. ALL write operations must go through `safe-outputs`, which use the App token internally. The `permissions:` block is strictly for `GITHUB_TOKEN` scoping and is read-only.
- **Cross-references:** `validation.md` — permission errors, `production-gotchas.md` — write permissions rejected

### Permission Derivation Checklist

Compute minimum required permissions by following these steps:

1. **Tools audit:** For each tool in `tools:`, add its required read permission:
   - `github:` → `contents: read` (minimum), plus scope per toolset
   - `agentic-workflows:` → `actions: read`
   - `edit:` → no additional permission
   - `bash:` → no additional permission
   - `web-fetch:` / `web-search:` → no additional permission
   - `playwright:` → no additional permission
   - `cache-memory:` / `repo-memory:` → no additional permission
2. **Safe-outputs audit:** Each safe-output type implies permissions that are granted via the App token automatically. No `write` permissions are needed in the `permissions:` block.
   - Exception: `push-to-pull-request-branch` and `update-release` require `contents: read` in `permissions:` (the write is handled by the App token)
3. **Toolset audit:** GitHub toolsets require matching read permissions:
   - `issues` toolset → `issues: read`
   - `pull_requests` toolset → `pull-requests: read`
   - `discussions` toolset → `discussions: read`
   - `actions` toolset → `actions: read`
   - `code_security` / `dependabot` / `secret_protection` / `security_advisories` → `security-events: read`
4. **Verify:** Run `gh aw compile` — the compiler checks for insufficient permissions.

---

## 4. Engine Configuration (`engine:`)

### `engine`

- **Type:** string | object
- **Required:** no
- **Default:** `copilot`

**Format 1 — Simple string:**

```yaml
engine: claude
```

**Format 2 — Object:**

```yaml
engine:
  id: copilot
  model: claude-sonnet
  max-turns: 20
  thinking: true
```

### Engine `id`

- **Type:** string
- **Required:** yes (in object format)
- **Accepted Values:** `copilot`, `claude`, `codex`, `custom`

| Engine | ID | Secret Required |
|--------|----|-----------------|
| Copilot | `copilot` | None (uses `GITHUB_TOKEN`) |
| Claude | `claude` | `ANTHROPIC_API_KEY` |
| Codex | `codex` | `OPENAI_API_KEY` |
| Custom | `custom` | Depends on implementation |

### Engine Sub-Fields

#### `model`

- **Type:** string
- **Required:** no
- **Default:** engine-specific default

#### `max-turns`

- **Type:** integer | string
- **Required:** no
- **Default:** engine-specific default
- **Description:** Maximum chat interaction turns.

#### `thinking`

- **Type:** boolean
- **Required:** no
- **Default:** false
- **Description:** Enable chain-of-thought reasoning. Primarily for Claude engine.

#### `version`

- **Type:** string
- **Required:** no
- **Description:** Action version override.

#### `user-agent`

- **Type:** string
- **Required:** no
- **Description:** Custom user agent string (Codex engine only).

#### `command`

- **Type:** string
- **Required:** no
- **Description:** Custom executable path (custom engine).

#### `args`

- **Type:** array of strings
- **Required:** no
- **Description:** Command-line arguments for the engine.

#### `agent`

- **Type:** string
- **Required:** no
- **Description:** Custom agent identifier (Copilot engine only).

#### `config`

- **Type:** string
- **Required:** no
- **Description:** Additional TOML configuration (Codex engine only).

#### `error_patterns`

- **Type:** array of objects
- **Required:** no
- **Description:** Custom error pattern matching for engine output.

```yaml
engine:
  id: custom
  error_patterns:
    - id: timeout
      pattern: "execution timed out after (\\d+)s"
      level_group: 0
      message_group: 1
      description: "Agent timeout"
```

- **Gotchas:** `level_group` and `message_group` use 1-based indexing; 0 means infer/entire match.

#### `steps`

- **Type:** array
- **Required:** no
- **Description:** Custom GitHub Actions steps for the engine setup (custom engine only).

#### `env`

- **Type:** mapping
- **Required:** no
- **Description:** Custom environment variables for the engine.

### `timeout-minutes`

- **Type:** integer
- **Required:** no
- **Default:** 20 (agentic workflows)
- **Description:** Maximum execution time in minutes.

```yaml
timeout-minutes: 30
```

### `concurrency`

- **Type:** string | object
- **Required:** no
- **Default:** `gh-aw-{engine-id}`

**Format 1 — String:**

```yaml
concurrency: "my-workflow-group"
```

**Format 2 — Object:**

```yaml
concurrency:
  group: "${{ github.workflow }}-${{ github.ref }}"
  cancel-in-progress: true
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `group` | string | — | Concurrency group name (supports expressions) |
| `cancel-in-progress` | boolean | `false` | Cancel in-progress runs when new run starts |

### `runs-on`

- **Type:** string | array of strings | object
- **Required:** no
- **Default:** `ubuntu-latest`

**Format 1 — String:**

```yaml
runs-on: ubuntu-latest
```

**Format 2 — Array (fallback labels):**

```yaml
runs-on: [ubuntu-latest, ubuntu-22.04]
```

**Format 3 — Object:**

```yaml
runs-on:
  group: my-runner-group
  labels: [self-hosted, linux]
```

### `run-name`

- **Type:** string
- **Required:** no
- **Default:** none
- **Description:** Custom run name in the GitHub Actions UI. Supports GitHub expressions.

```yaml
run-name: "Triage: ${{ github.event.issue.title }}"
```

### `environment`

- **Type:** string | object
- **Required:** no
- **Default:** none

**Format 1 — String:**

```yaml
environment: production
```

**Format 2 — Object:**

```yaml
environment:
  name: production
  url: "https://app.example.com"
```

---

## 5. Tools (`tools:`)

### `tools` (root) {#tools-root}

- **Type:** mapping
- **Required:** no
- **Default:** none
- **Description:** Declares which tools the agent can use. See `tools-reference.md` for complete details.

### GitHub Tool

#### `github`

- **Type:** null | boolean | string | object
- **Required:** no
- **Default:** enabled with default toolsets

**Format 1 — Enable with defaults:**

```yaml
tools:
  github:
```

**Format 2 — Object with configuration:**

```yaml
tools:
  github:
    toolsets: [issues, labels, pull_requests]
    mode: local
    read-only: true
    lockdown: true
    github-token: "${{ secrets.CUSTOM_PAT }}"
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `toolsets` | array | `[context, repos, issues, pull_requests, users]` | Toolset groups to enable |
| `mode` | string | `local` | `local` (Docker) or `remote` (hosted) |
| `read-only` | boolean | `false` | Restrict to read-only operations |
| `lockdown` | boolean | auto for public repos | Limit public repo content |
| `github-token` | string | `GITHUB_TOKEN` | Custom token expression |
| `allowed` | array | all | Allowed GitHub API functions |
| `version` | string | — | Server version override |
| `args` | array | — | Additional arguments |
| `mounts` | list | — | Volume mounts (local mode only) |

**Available toolsets:** `context`, `repos`, `issues`, `pull_requests`, `users`, `actions`, `code_security`, `discussions`, `labels`, `notifications`, `orgs`, `projects`, `gists`, `search`, `dependabot`, `experiments`, `secret_protection`, `security_advisories`, `stargazers`

**GitHub App sub-field:**

```yaml
tools:
  github:
    mode: remote
    app:
      app-id: ${{ vars.APP_ID }}
      private-key: ${{ secrets.APP_PRIVATE_KEY }}
      owner: "my-org"
      repositories: ["repo1", "repo2"]
```

| App sub-field | Type | Required | Description |
|---------------|------|----------|-------------|
| `app-id` | string | yes | GitHub App ID |
| `private-key` | string | yes | App private key |
| `owner` | string | no | Installation owner |
| `repositories` | array | no | `["*"]` for org-wide, list for specific repos, omit for current repo |

**Token precedence:** GitHub App → `github-token` → `GH_AW_GITHUB_MCP_SERVER_TOKEN` → `GH_AW_GITHUB_TOKEN` → `GITHUB_TOKEN`

- **Gotchas:**
  - When using `tools.github.app`, the MCP server requests **ALL** workflow-level permissions for the App token — not just MCP tool needs. If the App lacks a permission declared in `permissions:` (e.g., `packages: read`), token creation fails with HTTP 422. Only use `app:` when the App has **every** declared permission.
  - When `tools.github` is configured, the MCP server takes ownership of `GITHUB_TOKEN`, preventing `gh` CLI auth in bash. If only using `gh` CLI, remove `tools.github` entirely.
- **Cross-references:** `tools-reference.md`, `production-gotchas.md`

### Bash Tool

#### `bash`

- **Type:** null | boolean | array
- **Required:** no
- **Default:** default safe commands

**Format 1 — Default safe commands:**

```yaml
tools:
  bash:
```

**Format 2 — Disable:**

```yaml
tools:
  bash: false
```

**Format 3 — Explicit allowlist:**

```yaml
tools:
  bash: ["echo", "ls", "jq", "git:*"]
```

**Format 4 — Unrestricted:**

```yaml
tools:
  bash: [":*"]
```

**Default safe commands:** `echo`, `ls`, `pwd`, `cat`, `head`, `tail`, `grep`, `wc`, `sort`, `uniq`, `date`

**Wildcard patterns:** `git:*` (all git subcommands), `npm:*` (all npm), `:*` (unrestricted)

- **Gotchas:** `bash: [":*"]` without justification is a security anti-pattern. Use explicit allowlists.
- **Cross-references:** `tools-reference.md`

### Edit Tool

#### `edit`

- **Type:** null | object
- **Required:** no

```yaml
tools:
  edit:
```

Optional path restrictions:

```yaml
tools:
  edit:
    allowed-paths: ["src/", "docs/"]
```

### Web Fetch Tool

#### `web-fetch`

- **Type:** null | object
- **Required:** no

```yaml
tools:
  web-fetch:
```

### Web Search Tool

#### `web-search`

- **Type:** null | object
- **Required:** no

```yaml
tools:
  web-search:
```

### Playwright Tool

#### `playwright`

- **Type:** null | object
- **Required:** no

```yaml
tools:
  playwright:
    allowed_domains: ["defaults", "github", "*.custom.com"]
    version: "1.56.1"
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `allowed_domains` | array \| string | `["defaults"]` (localhost only) | Domain bundles or glob patterns |
| `version` | string | `1.56.1` | Container version |
| `args` | array | — | Additional arguments |

**Domain bundles:** `defaults` (localhost, 127.0.0.1), `github`, `node`, `python`

### Agentic Workflows Tool

#### `agentic-workflows`

- **Type:** boolean | null
- **Required:** no
- **Description:** Workflow introspection, log analysis, and debugging.

```yaml
tools:
  agentic-workflows:
```

- **Gotchas:** Requires `actions: read` permission. The `logs` and `audit` tools require writer/maintainer/admin repository role.
- **Cross-references:** Requires `permissions: actions: read`

### Cache Memory Tool

#### `cache-memory`

- **Type:** boolean | null | object | array
- **Required:** no

**Simple format:**

```yaml
tools:
  cache-memory:
```

**Object format:**

```yaml
tools:
  cache-memory:
    key: "triage-state"
    description: "Tracks triaged issues"
    retention-days: 30
    scope: workflow
    restore-only: false
    allowed-extensions: [".json", ".md", ".txt"]
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `key` | string | auto | Custom cache key |
| `description` | string | — | Cache description |
| `retention-days` | integer | — | 1-90 days |
| `restore-only` | boolean | `false` | Read-only access |
| `scope` | string | `workflow` | `workflow` or `repo` |
| `allowed-extensions` | array | `[".json", ".jsonl", ".txt", ".md", ".csv"]` | Allowed file types |

### Repo Memory Tool

#### `repo-memory`

- **Type:** boolean | null | object | array
- **Required:** no

**Simple format:**

```yaml
tools:
  repo-memory:
```

**Object format:**

```yaml
tools:
  repo-memory:
    branch-prefix: "memory"
    target-repo: "org/shared-memory"
    max-file-size: 10240
    max-file-count: 100
    create-orphan: true
    allowed-extensions: [".json", ".md"]
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `branch-prefix` | string | — | 4-32 chars, alphanumeric |
| `target-repo` | string | — | `owner/repo` format |
| `branch-name` | string | — | Custom branch name |
| `file-glob` | string \| array | — | Glob patterns |
| `max-file-size` | integer | 10240 | Max bytes per file |
| `max-file-count` | integer | 100 | Max files |
| `description` | string | — | Memory description |
| `create-orphan` | boolean | `true` | Create orphan branch |
| `allowed-extensions` | array | — | Allowed file types |

### Serena Tool

#### `serena`

- **Type:** null | array | object
- **Required:** no

**Format 1 — Language list:**

```yaml
tools:
  serena: ["go", "typescript"]
```

**Format 2 — Object:**

```yaml
tools:
  serena:
    version: "latest"
    mode: docker
    languages:
      go:
        version: "1.22"
        go-mod-file: "go.mod"
        gopls-version: "latest"
      typescript:
        version: "20"
      python:
        version: "3.12"
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `version` | string | — | MCP version |
| `mode` | string | `docker` | `docker` or `local` |
| `args` | array | — | Additional arguments |
| `languages` | mapping | — | Per-language configuration |

**Supported languages:** `go`, `typescript`, `python`, `java`, `rust`, `csharp`

### `timeout`

- **Type:** integer (seconds)
- **Required:** no
- **Default:** engine-specific
- **Description:** Tool-level timeout in seconds.

```yaml
tools:
  timeout: 120
```

### `startup-timeout`

- **Type:** integer (seconds)
- **Required:** no
- **Default:** 120
- **Description:** Maximum time for tool/MCP server startup.

```yaml
tools:
  startup-timeout: 180
```

---

## 6. MCP Servers (`mcp-servers:`)

### `mcp-servers`

- **Type:** mapping
- **Required:** no
- **Default:** none
- **Description:** Custom MCP server definitions. Each key is the server name.

### Execution Modes

**1. Process-based** (`command` + `args`):

```yaml
mcp-servers:
  slack:
    command: "npx"
    args: ["-y", "@slack/mcp-server"]
    env:
      SLACK_BOT_TOKEN: "${{ secrets.SLACK_BOT_TOKEN }}"
    allowed: ["send_message", "get_channel_history"]
```

**2. Container-based** (`container`):

```yaml
mcp-servers:
  datadog:
    container: "ghcr.io/org/datadog-mcp:latest"
    entrypointArgs:
      - "monitor"
    env:
      DD_API_KEY: "${{ secrets.DD_API_KEY }}"
      SSL_CERT_FILE: "/etc/ssl/certs/ca-certificates.crt"
    mounts:
      - "/etc/ssl/certs:/etc/ssl/certs:ro"
```

**3. HTTP-based** (`url`):

```yaml
mcp-servers:
  my-api:
    url: "https://mcp.example.com/v1"
    headers:
      Authorization: "Bearer ${{ secrets.API_KEY }}"
```

### Per-Server Fields

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Executable path (process-based) |
| `args` | array | Command arguments |
| `container` | string | Docker image reference (container-based) |
| `entrypointArgs` | array | Arguments passed to container ENTRYPOINT |
| `url` | string | HTTP endpoint (HTTP-based) |
| `headers` | mapping | HTTP headers for url-based servers |
| `registry` | string | MCP registry URI (informational only) |
| `env` | mapping | Environment variables |
| `mounts` | array | Volume mounts — `"host:container:mode"` format |
| `allowed` | array | Tool name restrictions |

- **Gotchas:**
  - **GHCR auth required:** Container images from `ghcr.io` require a GHCR login step in `steps:` or pulls fail silently at runtime.
  - **CA certs for minimal images:** Containers from `FROM scratch` or distroless base images have no CA bundle. Mount host certs: `mounts: ["/etc/ssl/certs:/etc/ssl/certs:ro"]` and set `SSL_CERT_FILE`.
  - **No double quotes in `entrypointArgs`:** `gh aw compile` does NOT escape `"` in entrypointArgs. Broken JSON results. Use `grep`/`sed` instead of `jq` expressions with quotes.
  - **MCP stdout constraint:** ANY stdout before the MCP handshake breaks initialization. Redirect all setup output to `/dev/null`.
  - **`npx` servers need `node` ecosystem:** Add `node` to `network.firewall.allowed` for npm registry access.
  - **`uvx` servers need `python` ecosystem:** Add `python` to `network.firewall.allowed` for PyPI access.
  - **`registry` field is informational** and does not affect execution.
  - **`gh aw mcp inspect/list` does NOT follow `imports:`** — check compiled `.lock.yml` instead.
- **Cross-references:** `tools-reference.md`, `production-gotchas.md`, [Steps](#steps), [Network](#network)

---

## 7. Safe Outputs (`safe-outputs:`)

### `safe-outputs` (root) {#safe-outputs-root}

- **Type:** mapping
- **Required:** no
- **Default:** none
- **Description:** Pre-approved write operations the agent can perform. ALL write operations must go through safe-outputs; `permissions:` does not grant writes.

### Global Settings

```yaml
safe-outputs:
  github-token: "${{ secrets.CUSTOM_TOKEN }}"
  app: "${{ secrets.GH_AW_APP_TOKEN }}"
  max-patch-size: 5242880
  allowed-domains: ["github.com"]
  allowed-github-references: ["org/repo"]
  messages:
    append-only-comments: true
```

| Setting | Type | Description |
|---------|------|-------------|
| `github-token` | string | Custom token for safe-output execution |
| `app` | string | App token expression |
| `max-patch-size` | integer | Max patch size in bytes |
| `allowed-domains` | array | Allowed domains for URL references |
| `allowed-github-references` | array | Allowed `owner/repo` references |
| `messages.append-only-comments` | boolean | Comment append behavior |

### Complete Safe-Output Types

#### `add-labels`

- **Type:** null | object

```yaml
safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement, documentation]
```

| Sub-field | Type | Description |
|-----------|------|-------------|
| `allowed` | array | Allowed label names |

- **Gotchas:** Labels without an allowlist let the agent apply anything — always use `allowed`.

#### `remove-labels`

- **Type:** null | object

```yaml
safe-outputs:
  remove-labels:
    allowed: [needs-triage]
```

#### `add-comment`

- **Type:** null | object

```yaml
safe-outputs:
  add-comment:
    discussions: false
    hide-older-comments: true
    max: 1
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `discussions` | boolean | `true` | Request `discussions:write` permission |
| `hide-older-comments` | boolean | `false` | Minimize previous bot comments |
| `max` | integer | — | Maximum comments |

- **Gotchas:** `add-comment` silently requests `discussions:write` by default. If the App lacks Discussions permission, token creation fails with HTTP 422. **Always add `discussions: false`** unless discussions are explicitly needed.
- **Cross-references:** `production-gotchas.md` — add-comment discussions:write default

#### `add-reviewer`

- **Type:** null | object

#### `assign-milestone`

- **Type:** null | object

#### `assign-to-agent`

- **Type:** null | object

#### `assign-to-user`

- **Type:** null | object

#### `unassign-from-user`

- **Type:** null | object

#### `hide-comment`

- **Type:** null | object

#### `close-issue`

- **Type:** null | object

#### `close-pull-request`

- **Type:** null | object

#### `create-issue`

- **Type:** null | object

```yaml
safe-outputs:
  create-issue:
    title-prefix: "[report] "
    labels: [automated, daily-report]
    allowed-labels: [automated, daily-report, bug]
    assignees: copilot
    max: 3
    target-repo: "org/other-repo"
    expires: "+7d"
    group: true
    close-older-issues: true
    footer: true
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `title-prefix` | string | — | Required prefix for issue titles |
| `labels` | array | — | Labels to apply |
| `allowed-labels` | array | — | Allowed label set |
| `assignees` | string \| array | — | Usernames (`copilot` for @copilot) |
| `max` | integer | 1 | Maximum issues to create |
| `target-repo` | string | — | `owner/repo` format |
| `allowed-repos` | array | — | Allowed target repos |
| `expires` | integer \| string \| boolean | — | Expiration (minimum 2h) |
| `group` | boolean | — | Enable sub-issue grouping |
| `close-older-issues` | boolean | — | Auto-close previous issues |
| `footer` | boolean | `true` | Append footer |

- **Gotchas:** Minimum expiration is 2 hours. Setting `expires` triggers maintenance workflow generation. No `title-prefix` means created items can't be tracked.

#### `create-pull-request`

- **Type:** null | object

- **Gotchas:** If the repo has standard `.yml`/`.yaml` files in `.github/workflows/`, the App token push will fail. Only `.lock.yml` files are exempt from the workflow push restriction.
- **Cross-references:** `production-gotchas.md` — .lock.yml exemption

#### `create-pull-request-review-comment`

- **Type:** null | object

#### `reply-to-pull-request-review-comment`

- **Type:** null | object

#### `resolve-pull-request-review-thread`

- **Type:** null | object

#### `submit-pull-request-review`

- **Type:** null | object

#### `push-to-pull-request-branch`

- **Type:** null | object

- **Cross-references:** Requires `permissions: contents: read`

#### `create-agent-session`

- **Type:** null | object

```yaml
safe-outputs:
  create-agent-session:
    base: main
    max: 1
    target-repo: "org/repo"
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `base` | string | — | Base branch |
| `max` | integer | 1 | Maximum sessions |
| `target-repo` | string | — | `owner/repo` format |
| `allowed-repos` | array | — | Allowed target repos |
| `github-token` | string | — | Custom token |

#### `create-discussion`

- **Type:** null | object

#### `update-discussion`

- **Type:** null | object

#### `update-issue`

- **Type:** null | object

#### `update-pull-request`

- **Type:** null | object

#### `update-project`

- **Type:** null | object

```yaml
safe-outputs:
  update-project:
    max: 10
    project: "https://github.com/orgs/my-org/projects/1"
    github-token: "${{ secrets.PROJECT_TOKEN }}"
    views:
      - name: "Sprint Board"
        layout: board
        filter: "status:in-progress"
        visible-fields: ["Title", "Status", "Priority"]
    field-definitions:
      - name: "Priority"
        data-type: SINGLE_SELECT
        options: ["P0", "P1", "P2", "P3"]
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | 10 | Max operations |
| `project` | string | **required** | Project URL |
| `github-token` | string | — | Custom token |
| `views` | array | — | View configurations |
| `field-definitions` | array | — | Custom field definitions |

**View object fields:** `name`, `layout` (`table`/`board`/`roadmap`), `filter`, `visible-fields`, `description`

**Field definition fields:** `name`, `data-type` (`DATE`/`NUMBER`/`SINGLE_SELECT`/etc.), `options` (for SINGLE_SELECT)

- **Gotchas:** Agent output must explicitly include the project field; config value is NOT used as fallback.

#### `create-project`

- **Type:** null | object

```yaml
safe-outputs:
  create-project:
    max: 1
    target-owner: "my-org"
    title-prefix: "Project"
    github-token: "${{ secrets.PROJECT_TOKEN }}"
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | 1 | Max create operations |
| `target-owner` | string | — | Org/user login |
| `title-prefix` | string | `Project` | Project title prefix |
| `github-token` | string | — | Custom token |
| `views` | array | — | Same structure as `update-project` |
| `field-definitions` | array | — | Same structure as `update-project` |

#### `create-project-status-update`

- **Type:** null | object

```yaml
safe-outputs:
  create-project-status-update:
    max: 1
    github-token: "${{ secrets.PROJECT_TOKEN }}"
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `max` | integer | 1 | Max status updates |
| `github-token` | string | — | Custom token |

#### `create-code-scanning-alert`

- **Type:** null | object

#### `autofix-code-scanning-alert`

- **Type:** null | object

#### `update-release`

- **Type:** null | object

- **Cross-references:** Requires `permissions: contents: read`

#### `upload-asset`

- **Type:** null | object

#### `dispatch-workflow`

- **Type:** null | object

#### `link-sub-issue`

- **Type:** null | object

**Important:** There is NO `merge-pull-request` safe-output. PR merging must use `post-steps` with a fresh App token. See [Post-Steps](#post-steps).

---

## 8. Steps & Post-Steps

### `steps`

- **Type:** object | array
- **Required:** conditional — required when using container-based MCP servers from `ghcr.io`
- **Default:** none
- **Description:** Pre-agent setup steps that compile into GitHub Actions job steps executing before the agent.

```yaml
steps:
  - name: Login to GitHub Container Registry
    run: echo "${{ github.token }}" | docker login ghcr.io -u "${{ github.actor }}" --password-stdin
```

Uses standard GitHub Actions step syntax: `name`, `run`, `uses`, `with`, `env`, `id`.

- **Gotchas:** Container-based MCP servers from `ghcr.io` **require** a GHCR login step. Without it, container pulls fail silently at runtime. This is the most common cause of container workflow failures.
- **Cross-references:** [MCP Servers](#6-mcp-servers-mcp-servers), `tools-reference.md`

### `post-steps`

- **Type:** object | array
- **Required:** no
- **Default:** none
- **Description:** Steps that run **after** AI agent execution completes.

```yaml
post-steps:
  - name: Generate merge token
    id: merge-token
    uses: actions/create-github-app-token@v2
    with:
      app-id: ${{ vars.APP_ID }}
      private-key: ${{ secrets.APP_KEY }}
      owner: org-name
      repositories: repo-name
  - name: Auto-merge PR
    env:
      GH_TOKEN: ${{ steps.merge-token.outputs.token }}
      PR_NUMBER: ${{ github.event.pull_request.number }}
    run: |
      gh pr merge "$PR_NUMBER" --repo "$GITHUB_REPOSITORY" --squash --auto
```

**Characteristics:**
- Runs in the agent job after the engine finishes
- Has access to full job context: `${{ github.event.* }}`, `${{ secrets.* }}`, `${{ vars.* }}`
- Can reference step outputs via `${{ steps.*.outputs.* }}`
- Uses standard GitHub Actions step syntax

**When post-steps are required:**
- **Merging PRs** — no `merge-pull-request` safe-output exists
- **Write operations not covered by safe-outputs** (branch deletion, release management beyond `update-release`)
- **Cleanup/finalization** after agent completion

- **Cross-references:** `production-gotchas.md` — post-steps feature

---

## 9. Network & Sandbox

### `network`

- **Type:** string | object
- **Required:** no
- **Default:** none (full sandbox, no external access)

**Format 1 — Defaults string:**

```yaml
network: defaults
```

**Format 2 — Object with firewall:**

```yaml
network:
  firewall:
    allowed:
      - defaults
      - github
      - containers
      - node
      - "*.datadoghq.com"
    blocked:
      - "*.internal.corp"
```

| Sub-field | Type | Description |
|-----------|------|-------------|
| `firewall.allowed` | array | Domains and ecosystem identifiers to allow |
| `firewall.blocked` | array | Domains to block (takes precedence over allowed) |

**Ecosystem identifiers** (work in `strict: true` mode):

| Identifier | Covers |
|------------|--------|
| `defaults` | Standard GitHub/Actions infrastructure, certificates, JSON schema, Ubuntu |
| `github` | GitHub API and related domains |
| `containers` | Docker Hub, GHCR (`ghcr.io`), Quay |
| `node` | npm registries (required for `npx`-based MCP servers) |
| `python` | PyPI (required for `uvx`-based MCP servers) |

- **Gotchas:**
  - Custom domains (anything not an ecosystem identifier) **require `strict: false`** at the frontmatter root. The compiler rejects custom domains in strict mode.
  - `*.example.com` matches subdomains AND the base domain.
  - `network: true` grants unrestricted external access — strongly discouraged.
  - Missing `node`/`python` ecosystems for `npx`/`uvx` MCP servers causes package install failures at runtime.
- **Cross-references:** [strict](#strict), `validation.md` — network & TLS checklist

### `sandbox`

- **Type:** object
- **Required:** no
- **Default:** AWF (Agent Workflow Firewall)

#### `sandbox.agent`

- **Type:** boolean | string | object
- **Accepted Values:** `false`, `awf`, `srt`

**Format 1 — Disable:**

```yaml
sandbox:
  agent: false
```

**Format 2 — String shorthand:**

```yaml
sandbox:
  agent: srt
```

**Format 3 — Object:**

```yaml
sandbox:
  agent:
    id: srt
    command: "/usr/local/bin/sandbox"
    args: ["--strict"]
    env:
      SANDBOX_MODE: "enforce"
    mounts:
      - "source:destination:mode"
    config:
      filesystem:
        denyRead: ["/etc/shadow"]
        allowWrite: ["/tmp", "/workspace"]
        denyWrite: ["/usr/bin"]
      ignoreViolations:
        "npm install": ["filesystem.write"]
      enableWeakerNestedSandbox: false
```

| Sub-field | Type | Description |
|-----------|------|-------------|
| `id` | string | `awf` or `srt` |
| `command` | string | Custom sandbox command |
| `args` | array | Sandbox arguments |
| `env` | mapping | Environment variables |
| `mounts` | array | Docker mount format |
| `config` | object | SRT-only configuration |

**SRT config sub-fields:**
- `filesystem.denyRead` — paths to deny reads
- `filesystem.allowWrite` — paths to allow writes
- `filesystem.denyWrite` — paths to deny writes
- `ignoreViolations` — command pattern → violation type mapping
- `enableWeakerNestedSandbox` — boolean

#### `sandbox.mcp`

- **Type:** object
- **Description:** MCP Gateway configuration. Always enabled; cannot be disabled.

```yaml
sandbox:
  mcp:
    container: "ghcr.io/org/mcp-gateway:latest"
    version: "1.0"
    entrypoint: "/gateway"
    args: ["--mode", "strict"]
    entrypointArgs: ["--config", "/etc/gateway.yaml"]
    mounts:
      - "/etc/ssl/certs:/etc/ssl/certs:ro"
    env:
      GATEWAY_MODE: "production"
    port: 8080
    api-key: "${{ secrets.GATEWAY_KEY }}"
    domain: "host.docker.internal"
```

| Sub-field | Type | Default | Description |
|-----------|------|---------|-------------|
| `container` | string | **required** | Container image |
| `version` | string | — | Container tag/version |
| `entrypoint` | string | — | Custom entrypoint |
| `args` | array | — | Docker run arguments |
| `entrypointArgs` | array | — | Container arguments |
| `mounts` | array | — | Docker mount format |
| `env` | mapping | — | Environment variables |
| `port` | integer | 8080 | HTTP server port |
| `api-key` | string | — | Supports `${{ secrets.* }}` |
| `domain` | string | `host.docker.internal` | Gateway domain |

- **Gotchas:** MCP Gateway is always enabled and cannot be disabled via sandbox config. Setting `sandbox.agent: false` disables the agent sandbox but keeps the MCP gateway.

---

## 10. Imports & Dependencies

### `imports`

- **Type:** array
- **Required:** no
- **Default:** none
- **Description:** Import shared configuration fragments. Tool declarations merge from imported components.

**Format 1 — String references:**

```yaml
imports:
  - "org/repo/shared-tools.md@v1"
  - "./shared/base-config.md"
```

**Format 2 — Object with inputs:**

```yaml
imports:
  - source: "org/repo/shared-tools.md@v1"
    merge: tools
  - source: "./shared/base-config.md"
```

- **Gotchas:** `gh aw mcp inspect/list` does NOT follow `imports:` directives. Check the compiled `.lock.yml` for fully resolved configuration.
- **Cross-references:** `production-gotchas.md` — MCP inspect limitation

### `plugins`

- **Type:** array | object
- **Required:** no
- **Default:** none

**Format 1 — Array of repo slugs:**

```yaml
plugins:
  - "org/plugin-repo"
```

**Format 2 — Object:**

```yaml
plugins:
  repos:
    - "org/plugin-repo"
  github-token: "${{ secrets.PLUGIN_TOKEN }}"
```

---

## 11. Container & Services

### `container`

- **Type:** string | object
- **Required:** no
- **Default:** none
- **Description:** Job-level container configuration.

**Format 1 — String (image only):**

```yaml
container: "ubuntu:22.04"
```

**Format 2 — Object:**

```yaml
container:
  image: "node:20"
  credentials:
    username: "${{ github.actor }}"
    password: "${{ secrets.DOCKER_PASSWORD }}"
  env:
    NODE_ENV: production
  ports:
    - "8080:8080"
  volumes:
    - "/data:/app/data"
  options: "--memory=4g"
```

| Sub-field | Type | Description |
|-----------|------|-------------|
| `image` | string | Docker image |
| `credentials` | object | `username` + `password` |
| `env` | mapping | Environment variables |
| `ports` | array | Exposed ports |
| `volumes` | array | Volume mounts |
| `options` | string | Docker options |

- **Gotchas:** `credentials.password` should use `${{ secrets.* }}` syntax.

### `services`

- **Type:** mapping
- **Required:** no
- **Default:** none
- **Description:** Service containers for the job.

```yaml
services:
  postgres:
    image: "postgres:15"
    env:
      POSTGRES_PASSWORD: test
    ports:
      - "5432:5432"
```

### `cache`

- **Type:** object | array
- **Required:** no
- **Default:** none

**Single cache:**

```yaml
cache:
  key: "deps-${{ hashFiles('package-lock.json') }}"
  path: "node_modules"
  restore-keys: "deps-"
```

**Multiple caches:**

```yaml
cache:
  - key: "npm-${{ hashFiles('package-lock.json') }}"
    path: "node_modules"
  - key: "build-${{ hashFiles('src/**') }}"
    path: ".build"
```

| Sub-field | Type | Description |
|-----------|------|-------------|
| `key` | string | **required** — Cache key |
| `path` | string \| array | File path(s) to cache |
| `restore-keys` | string \| array | Fallback keys |
| `upload-chunk-size` | integer | Bytes |
| `fail-on-cache-miss` | boolean | Fail if no cache hit |
| `lookup-only` | boolean | Check existence only |

---

## 12. Environment & Secrets

### `env`

- **Type:** mapping | string
- **Required:** no
- **Default:** none
- **Description:** Environment variables available to the workflow.

```yaml
env:
  ISSUE_NUMBER: "${{ github.event.issue.number }}"
  REPO_NAME: "${{ github.repository }}"
```

- **Gotchas:** `${{ }}` expressions in fenced code blocks are NOT interpolated — the agent receives literal text. Declare dynamic values as `env:` variables and reference them as `$VAR_NAME` in code blocks.
- **Cross-references:** `production-gotchas.md` — expression interpolation

### `secrets`

- **Type:** mapping
- **Required:** no
- **Default:** none

**String format:**

```yaml
secrets:
  API_KEY: "${{ secrets.MY_API_KEY }}"
```

**Object format:**

```yaml
secrets:
  API_KEY:
    value: "${{ secrets.MY_API_KEY }}"
    description: "API key for external service"
```

### `features`

- **Type:** mapping
- **Required:** no
- **Default:** none
- **Description:** Feature flags for experimental features.

```yaml
features:
  action-tag: "v2.0.0-beta"
```

| Sub-field | Type | Description |
|-----------|------|-------------|
| `action-tag` | string | Tag/SHA for actions/setup (testing only) |

---

## Common Patterns

### Triage Bot

```yaml
---
name: "Issue Triage"
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
    allowed: [bug, feature, enhancement, documentation, question]
  add-comment:
    discussions: false
---
```

### Scheduled Reporter

```yaml
---
name: "Daily Status Report"
on:
  schedule: "daily around 09:00"
permissions:
  issues: read
  pull-requests: read
  contents: read
engine:
  id: copilot
tools:
  github:
    toolsets: [issues, pull_requests, labels]
safe-outputs:
  create-issue:
    title-prefix: "[daily-report] "
    labels: [report, daily-status]
    close-older-issues: true
    max: 1
---
```

### PR Reviewer

```yaml
---
name: "PR Review Agent"
on:
  pull_request:
    types: [opened, synchronize]
    reaction: eyes
permissions:
  contents: read
  pull-requests: read
engine:
  id: claude
  model: claude-sonnet
  thinking: true
tools:
  github:
    toolsets: [repos, pull_requests, issues]
  bash: ["echo", "ls", "cat", "grep", "git:*"]
safe-outputs:
  add-comment:
    discussions: false
  add-labels:
    allowed: [needs-changes, approved, needs-review]
---
```

### Slash Command with MCP Server

```yaml
---
name: "Deploy Command"
strict: false
on: /deploy
permissions:
  contents: read
  actions: read
engine:
  id: copilot
network:
  firewall:
    allowed:
      - defaults
      - github
      - containers
      - node
      - "api.pagerduty.com"
tools:
  github:
    toolsets: [repos, actions]
  bash: ["echo", "ls", "gh:*"]
  agentic-workflows:
mcp-servers:
  pagerduty:
    command: "npx"
    args: ["-y", "@pagerduty/mcp-server"]
    env:
      PD_TOKEN: "${{ secrets.PAGERDUTY_TOKEN }}"
steps:
  - name: Login to GHCR
    run: echo "${{ github.token }}" | docker login ghcr.io -u "${{ github.actor }}" --password-stdin
safe-outputs:
  add-comment:
    discussions: false
---
```

---

## Compilation Gotchas

Consolidated list of every known compiler error and its fix:

| Error | Cause | Fix |
|-------|-------|-----|
| Unknown key in strict mode | Unrecognized frontmatter field | Remove the key or set `strict: false` |
| `issue` instead of `issues` | Wrong trigger name (singular) | Use `issues` (plural) |
| Missing `reaction` on event trigger | No `reaction: eyes` on issues/PRs/comments/discussions | Add `reaction: eyes` |
| Write permission rejected | `permissions:` block has `write` values | Change to `read` only; use safe-outputs for writes |
| Missing `actions: read` | `agentic-workflows:` tool without permission | Add `permissions: actions: read` |
| Custom domain in strict mode | Custom network domain without `strict: false` | Set `strict: false` at root |
| `tracker-id` too short | Value under 8 characters | Use 8+ alphanumeric characters |
| Invalid `stop-after` unit | Used minute (`m`) unit | Use hours (`h`) or larger |
| Circular imports | Import chain loops back | Break the circular reference |
| Insufficient permissions | Tool/output requires permission not declared | Add the missing read permission |
| HTTP 422 on App token | `tools.github.app` with mismatched permissions | Ensure App has all declared permissions, or remove `app:` |
| `gh` CLI auth conflict | `tools.github` and `gh` CLI both need `GITHUB_TOKEN` | Choose MCP tools OR `gh` CLI |
| Container pull failure (silent) | `ghcr.io` image without login step | Add GHCR login to `steps:` |
| TLS certificate verify failed | Minimal container without CA certs | Mount `/etc/ssl/certs` and set `SSL_CERT_FILE` |
| `add-comment` HTTP 422 | Default `discussions:write` without App permission | Add `discussions: false` |
| `.yml` blocks App push | Standard workflow file in `.github/workflows/` | Remove `.yml` files; use only `.lock.yml` |
| Broken JSON in lock file | Double quotes in `entrypointArgs` | Avoid `"` in MCP server command strings |
| MCP server no tools | Stdout before JSON-RPC handshake | Redirect setup output to `/dev/null` |
| `add-labels` without allowlist | No `allowed` constraint | Always specify `allowed: [...]` |
| `create-issue` without `title-prefix` | Untrackable issues | Add meaningful `title-prefix` |
| Missing `max` on safe-outputs | No rate limiting | Set explicit `max` values |
