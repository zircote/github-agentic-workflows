# Frontmatter Schema Reference

gh-aw workflow files use YAML frontmatter delimited by `---` markers.

## Root Configuration

### `name`
- **Type:** string
- **Description:** Human-readable workflow name
- **Example:** `name: "Issue Triage Agent"`

### `description`
- **Type:** string
- **Description:** Brief description of workflow purpose

### `source`
- **Type:** string
- **Description:** URL or path to source workflow definition

### `tracker-id`
- **Type:** string
- **Description:** External tracker reference (e.g., Jira ticket)

### `labels`
- **Type:** list of strings
- **Description:** Labels applied to artifacts created by this workflow
- **Example:** `labels: [automated, triage]`

### `metadata`
- **Type:** mapping
- **Description:** Arbitrary key-value pairs for workflow metadata

### `strict`
- **Type:** boolean
- **Default:** `true`
- **Description:** When true, unknown keys cause compilation errors and all permissions must be explicit. Set to `false` when processing untrusted/external input (e.g., public repo issues from non-contributors).

### `lockdown`
- **Type:** boolean
- **Description:** Security filtering for public repositories. Auto-enables for public repos with custom tokens. When enabled, agents only process content from authenticated contributors.

## Triggers (`on:`)

### Event Triggers

```yaml
on:
  issues:
    types: [opened, reopened, edited, closed]
    reaction: eyes
  pull_request:
    types: [opened, synchronize, reopened]
    reaction: eyes
  issue_comment:
    types: [created]
    reaction: eyes
  discussion:
    types: [created, answered]
    reaction: eyes
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      param-name:
        description: "Parameter description"
        required: true
        type: string
```

**CRITICAL:** The trigger field for issues is `issues` (plural), NOT `issue`. This is the most common mistake.

**`reaction: eyes`** — Required for event-triggered workflows (issues, PRs, comments, discussions). Grants the compiler permissions for `pre_activation`.

### Schedule Triggers

```yaml
on:
  schedule: daily
  schedule: "weekly on monday"
  schedule: "0 9 * * 1-5"    # cron: 9 AM weekdays
```

Supports natural language (`daily`, `weekly on monday`) and standard cron expressions.

## Engine Configuration (`engine:`)

```yaml
engine:
  id: copilot          # copilot | claude | codex
  model: claude-sonnet  # Engine-specific model selection
  max-turns: 20        # Maximum agent interaction turns
  thinking: true       # Enable chain-of-thought (Claude)
```

### Engine Options

| Engine | ID | Strengths | Secret Required |
|--------|----|-----------|-----------------|
| Copilot | `copilot` | GitHub-native, default | None (uses GITHUB_TOKEN) |
| Claude | `claude` | Strong reasoning, analysis | `ANTHROPIC_API_KEY` |
| Codex | `codex` | Code generation | `OPENAI_API_KEY` |

### `timeout-minutes`
- **Type:** integer
- **Default:** 10
- **Description:** Maximum execution time. Use 5 for simple tasks, 10-15 for moderate, 30+ for complex code analysis.

## Permissions (`permissions:`)

```yaml
permissions:
  contents: read
  issues: read
  pull-requests: read
  discussions: read
  actions: read
  security-events: read
```

### Available Scopes

| Scope | Values | Purpose |
|-------|--------|---------|
| `contents` | `read`, `write` | Repository files, commits, branches |
| `issues` | `read`, `write` | Issues and issue comments |
| `pull-requests` | `read`, `write` | Pull requests and PR comments |
| `discussions` | `read`, `write` | Discussions |
| `actions` | `read`, `write` | Workflow runs, logs, dispatch |
| `security-events` | `read`, `write` | Code scanning alerts |
| `statuses` | `read`, `write` | Commit statuses |
| `checks` | `read`, `write` | Check runs and suites |
| `packages` | `read`, `write` | GitHub Packages |
| `deployments` | `read`, `write` | Deployments |
| `pages` | `read`, `write` | GitHub Pages |

### Shorthand

- `read-all` — expands to `read` on all permission scopes
- Always prefer explicit minimal scopes over shorthand

### Permission Derivation Rules

Permissions must cover:
1. Every tool's read requirements
2. Every safe-output's write requirements
3. The `actions: read` requirement if using `agentic-workflows:` tool

## Tools (`tools:`)

See `tools-reference.md` for the complete tools documentation. Summary:

```yaml
tools:
  github:
    toolsets: [issues, labels, pull_requests]
  bash: ["echo", "ls", "jq", "git:*"]
  edit:
  web-fetch:
  web-search:
  playwright:
    allowed_domains: ["defaults", "github"]
  agentic-workflows:
  cache-memory:
  repo-memory:
```

## Safe-Outputs (`safe-outputs:`)

See `safe-outputs.md` for the complete catalog. Summary:

```yaml
safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement]
  add-comment:
    hide-older-comments: true
  create-issue:
    title-prefix: "[report] "
    labels: [automated]
    close-older-issues: true
    max: 3
```

### Global Safe-Output Settings

```yaml
safe-outputs:
  github-token: ${{ secrets.CUSTOM_TOKEN }}
  app: ${{ secrets.GH_AW_APP_TOKEN }}
  max-patch-size: 5242880
  messages:
    append-only-comments: true
```

## Steps (`steps:`)

Pre-agent setup steps that run before the agentic workflow starts. These compile into GitHub Actions job steps that execute before the agent is invoked.

```yaml
steps:
  - name: Login to GitHub Container Registry
    run: echo "${{ github.token }}" | docker login ghcr.io -u "${{ github.actor }}" --password-stdin
```

### When Steps Are Required

**Container-based MCP servers pulling from ghcr.io require GHCR authentication.** Without a login step, container pulls fail silently at runtime. This is the most common cause of container-based workflow failures.

If your workflow uses `mcp-servers:` with a `container:` field referencing `ghcr.io`, you **must** include a GHCR login step:

```yaml
mcp-servers:
  my-server:
    container: ghcr.io/org/image:latest
    env:
      TOKEN: "${{ secrets.VALUE }}"

steps:
  - name: Login to GitHub Container Registry
    run: echo "${{ github.token }}" | docker login ghcr.io -u "${{ github.actor }}" --password-stdin
```

The `steps:` block is placed after `mcp-servers:` (or after `tools:` if no MCP servers) and before `safe-outputs:`.

---

## Network Configuration (`network:`)

```yaml
network:
  firewall:
    allowed:
      - "api.example.com"
      - "*.github.com"
```

- Omit for full sandbox (no external access)
- Use `network: true` for unrestricted (discouraged)
- Prefer explicit domain allowlists

### Ecosystem Identifiers vs Custom Domains

Ecosystem identifiers work in strict mode (`strict: true`, the default):
- `defaults` — standard GitHub/Actions infrastructure
- `github` — GitHub API and related domains
- `containers` — Docker Hub, GHCR (`ghcr.io`), Quay
- `node` — npm registries (needed for `npx`-based MCP servers)
- `python` — PyPI (needed for `uvx`-based MCP servers)

**Custom domains require `strict: false`.** Any domain not covered by an ecosystem identifier (e.g., `*.datadoghq.com`, `api.pagerduty.com`, `*.atlassian.net`) requires setting `strict: false` at the frontmatter root level, or the compiler rejects it.

```yaml
strict: false

network:
  firewall:
    allowed:
      - defaults
      - github
      - containers
      - node
      - python
      - "*.datadoghq.com"
      - "api.pagerduty.com"
```

## Imports (`imports:`)

```yaml
imports:
  - source: "org/repo/shared-tools.md"
    merge: tools
  - source: "./shared/base-config.md"
```

Import shared configuration fragments. Tool declarations merge from imported components.

## MCP Servers (`mcp-servers:`)

See `tools-reference.md` for custom MCP server configuration. Summary:

```yaml
mcp-servers:
  server-name:
    command: "npx"
    args: ["-y", "@org/package"]
    env:
      TOKEN: "${{ secrets.VALUE }}"
    allowed: ["tool_name"]
```

### Container-Based MCP Servers

```yaml
mcp-servers:
  server-name:
    container: "ghcr.io/org/image:tag"
    entrypointArgs:
      - "subcommand"
    env:
      API_KEY: "${{ secrets.VALUE }}"
      SSL_CERT_FILE: "/etc/ssl/certs/ca-certificates.crt"
    mounts:
      - "/etc/ssl/certs:/etc/ssl/certs:ro"
```

| Field | Type | Description |
|-------|------|-------------|
| `entrypointArgs` | list | Arguments passed to the container's ENTRYPOINT |
| `mounts` | list | Volume mounts in `"host:container:mode"` format |

**CA Certificate Warning:** Containers built from `FROM scratch` or distroless base images have no CA certificate bundle. Without CA certs, all TLS connections fail with "certificate verify failed". Mount the host's CA certs read-only and set `SSL_CERT_FILE` to point to them.

## Complete Example

```yaml
---
name: "Issue Triage Agent"
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
    allowed: [bug, feature, enhancement, documentation, question]
  add-comment: {}
---
```
