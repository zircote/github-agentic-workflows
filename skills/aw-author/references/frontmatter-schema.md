# Frontmatter Schema Reference

gh-aw workflow files use YAML frontmatter delimited by `---` markers. This reference covers every configuration key.

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
- **Description:** URL or path to the source workflow definition

### `tracker-id`
- **Type:** string
- **Description:** External tracker reference (e.g., Jira ticket)

### `labels`
- **Type:** list of strings
- **Description:** Labels applied to artifacts created by this workflow
- **Example:** `labels: [automated, triage]`

### `metadata`
- **Type:** mapping
- **Description:** Arbitrary key-value metadata attached to the workflow

### `strict`
- **Type:** boolean
- **Default:** `true`
- **Description:** Security mode that controls agent capabilities. When `true` (default), enables strict compilation mode: unknown keys cause errors, all permissions must be explicitly declared, write permissions are blocked (use safe-outputs instead), and network access is restricted to ecosystem aliases only. Set `strict: false` for workflows that must process external/untrusted input (e.g., issue triage on public repos) or that need custom network domains.

> **Note (v0.45.0):** The `lockdown` field shown in older documentation is **not valid**. Use `strict: true/false` instead. `strict: false` replaces the former `lockdown: false` behavior.

### `timeout-minutes`
- **Type:** integer
- **Default:** `10`
- **Description:** Maximum execution duration in minutes
- **Example:** `timeout-minutes: 30`

### `roles`
- **Type:** mapping
- **Description:** Named roles mapping to GitHub usernames or teams for @-mention routing
- **Example:**
  ```yaml
  roles:
    reviewer: "@octocat"
    team-lead: "@org/leads"
  ```

### `bots`
- **Type:** list of strings
- **Description:** Bot accounts that should be ignored or given special treatment
- **Example:** `bots: [dependabot, renovate]`

### `rate-limit`
- **Type:** mapping
- **Description:** Throttling configuration to prevent excessive API calls
- **Fields:**
  - `max-runs-per-hour`: integer
  - `max-runs-per-day`: integer
  - `cooldown-minutes`: integer

### `imports`
- **Type:** list of strings
- **Description:** Import other workflow fragments or shared configurations
- **Example:** `imports: [./shared/common-tools.yml]`

### `github-token`
- **Type:** string
- **Description:** Override the default GitHub token. Use `${{ secrets.CUSTOM_TOKEN }}` for custom PATs.

### `env`
- **Type:** mapping
- **Description:** Environment variables available to the workflow
- **Example:**
  ```yaml
  env:
    NODE_ENV: production
    LOG_LEVEL: debug
  ```

### `secrets`
- **Type:** list of strings
- **Description:** GitHub secrets required by this workflow. Compilation fails if secrets are not configured.
- **Example:** `secrets: [OPENAI_API_KEY, SLACK_WEBHOOK]`

### `runtimes`
- **Type:** mapping
- **Description:** Runtime environment configuration for execution
- **Fields:**
  - `node`: Node.js version
  - `python`: Python version
  - `go`: Go version

---

## Triggers (`on`)

The `on` block defines when the workflow executes. Supports GitHub events, schedules, and slash commands.

### Event Triggers

```yaml
on:
  issues:                                # ← NOTE: plural "issues", not "issue"
    types: [opened, reopened, labeled, assigned]
  pull_request:
    types: [opened, synchronize, ready_for_review]
  issue_comment:
    types: [created]
  discussion:
    types: [created, commented]
  push:
    branches: [main, develop]
  workflow_dispatch: {}
```

> **IMPORTANT (v0.45.0):** The trigger name is `issues` (plural), not `issue`. The compiler will reject `issue:` as an unknown trigger.

**Supported events:**
| Event | Types | Description |
|-------|-------|-------------|
| `issues` | opened, reopened, labeled, unlabeled, assigned, unassigned, closed, edited, deleted, transferred, milestoned | Issue lifecycle events |
| `pull_request` | opened, synchronize, ready_for_review, closed, reopened, labeled, review_requested | PR lifecycle events |
| `issue_comment` | created, edited, deleted | Comments on issues and PRs |
| `discussion` | created, commented, answered, labeled | GitHub Discussions events |
| `push` | — | Push to specified branches |
| `workflow_dispatch` | — | Manual trigger |

### Schedule Triggers

```yaml
on:
  schedule: daily                    # Natural language
  schedule: "0 */6 * * *"           # Cron syntax
  schedule:
    - cron: "0 9 * * 1-5"           # Weekdays at 9am UTC
    - cron: "0 13 * * 1-5"          # Weekdays at 1pm UTC
```

**Natural language shortcuts:** `daily`, `hourly`, `weekly`, `monthly`

### Slash Command Triggers

```yaml
on:
  issue_comment:
    types: [created]
# Then in the markdown body, define command parsing:
# Listen for /command-name in issue comments
```

Commands like `/plan`, `/review`, `/triage` are triggered via `issue_comment` events with command parsing in the prose body.

---

## Engine Block (`engine`)

Configures the AI engine that executes the workflow.

> **IMPORTANT (v0.45.0):** Available engine fields vary by engine ID. The `copilot` engine only accepts `id: copilot` -- no other fields (`model`, `max-turns`, `timeout-minutes`, `agent`, etc.) are supported for this engine. Other engines (e.g., `claude`) support additional configuration fields.

### Copilot Engine (minimal)

```yaml
engine:
  id: copilot                    # Only field accepted for copilot engine
```

### Claude Engine (full configuration)

```yaml
engine:
  id: claude                     # Engine identifier
  model: claude-sonnet-4-20250514     # Model to use
  max-turns: 20                  # Max conversation turns
  thinking: true                 # Enable chain-of-thought
  concurrency: 1                 # Parallel execution limit
  env:                           # Engine-specific env vars
    TEMPERATURE: "0.2"
  args:                          # Engine-specific arguments
    - "--verbose"
  error_patterns:                # Patterns that indicate failure
    - "FATAL:"
    - "Error:"
```

### Engine IDs

| ID | Provider | Notes |
|----|----------|-------|
| `copilot` | GitHub Copilot | Default engine, deep GitHub integration. Only `id` field is valid. |
| `claude` | Anthropic | Strong reasoning, long context. Supports full configuration. |
| `codex` | OpenAI Codex | Code-focused tasks |

### Key Fields

- **`id`** (required): Engine identifier
- **`model`**: Specific model version. Defaults vary by engine. **Not supported for `copilot` engine.**
- **`max-turns`**: Limits conversation depth to control cost and prevent loops. Default: `10`. **Not supported for `copilot` engine.**
- **`timeout-minutes`**: Engine-level timeout. **Not valid inside engine block per v0.45.0 compiler.** Use root-level `timeout-minutes` instead.
- **`concurrency`**: How many instances can run in parallel. Default: `1`
- **`thinking`**: Enable extended thinking/chain-of-thought. Default: `false`. **Not supported for `copilot` engine.**
- **`error_patterns`**: List of regex patterns that signal the engine encountered an error

---

## Permissions Block (`permissions`)

Declares the minimum GitHub permissions required. In strict mode, undeclared permissions cause compilation errors.

> **IMPORTANT (v0.45.0):** In strict mode (default), **write permissions are not allowed** for security reasons. The compiler will reject `contents: write`, `issues: write`, `pull-requests: write`, etc. with the error: "write permission is not allowed for security reasons. Use safe-outputs instead." All write operations must go through the `safe-outputs` block. Use `read` permissions here and define specific write actions in safe-outputs.

```yaml
permissions:
  contents: read          # Repository contents
  issues: read            # Issues (writes go through safe-outputs)
  pull-requests: read     # PRs (writes go through safe-outputs)
  discussions: read       # Discussions access
  actions: read           # Actions workflow access
  checks: read            # Check runs/suites
  packages: read          # GitHub Packages
  statuses: read          # Commit statuses
```

**Permission levels:** `none`, `read`, `write`

> **Note:** `write` is only accepted when `strict: false` is set at root level. In strict mode (default), only `none` and `read` are accepted. Use safe-outputs for all write operations.

**Scopes:**
| Scope | Description |
|-------|-------------|
| `contents` | Repository files, commits, branches |
| `issues` | Issues and issue comments |
| `pull-requests` | Pull requests and PR reviews |
| `discussions` | GitHub Discussions |
| `actions` | Workflow runs and artifacts |
| `checks` | Check runs and check suites |
| `packages` | GitHub Packages |
| `statuses` | Commit statuses |
| `deployments` | Deployment environments |
| `pages` | GitHub Pages |
| `security-events` | Security alerts |

> **Best practice:** Always use `read` permissions and define write operations in the `safe-outputs` block. This is enforced by the compiler in strict mode.

---

## Network Block (`network`)

Controls network access for sandboxed execution.

> **IMPORTANT (v0.45.0):** The `firewall` field does NOT accept the string values `strict`, `permissive`, or `disabled`. It accepts: `null`, `boolean` (`true`/`false`), the string `"disable"`, or an object with `allowed`/`blocked` arrays. Custom domains in the `allowed` list require `strict: false` at root level. In strict mode (default), only ecosystem aliases are permitted.

### Strict mode (default) -- ecosystem aliases only

```yaml
network:
  allowed:
    - defaults                   # Standard GitHub API domains
    - python                     # PyPI and related
    - node                       # npm registry
    - containers                 # ghcr.io
  firewall: true                 # Enable firewall with allowed list
```

### Non-strict mode -- custom domains allowed

```yaml
strict: false                    # ← Required for custom domains

network:
  allowed:
    - "api.github.com"
    - "api.openai.com"
    - "*.amazonaws.com"
  blocked:
    - "*.malicious.com"
  firewall: true
```

### Firewall field values

| Value | Behavior |
|-------|----------|
| `true` | Enable firewall, enforce allowed/blocked lists |
| `false` | Disable firewall |
| `null` | Default behavior |
| `"disable"` | Explicitly disable firewall |
| `{ allowed: [], blocked: [], firewall: null }` | Object form with explicit lists |

**Ecosystem aliases** (usable in strict mode):
`defaults`, `python`, `node`, `containers`, and others defined by the gh-aw runtime.

- **`allowed`**: Allowlist of domains/patterns or ecosystem aliases the agent can reach
- **`blocked`**: Denylist of domains/patterns (takes precedence over allowed)
- **`firewall`**: See table above. Does **not** accept `"strict"` or `"permissive"`.

---

## Tools Block (`tools`)

Declares which tools the agent can use. Tool allowlisting restricts agent capabilities to only what's needed.

> **IMPORTANT (v0.45.0):** The `enabled: true/false` pattern is **not valid**. Tools do not use an `enabled` field. Each tool has its own accepted value types (see below). The `lockdown` field is also not valid inside tools -- use root-level `strict` instead.

```yaml
tools:
  github:
    toolsets: [issues, labels, pull_requests, discussions]  # ← underscores, not hyphens
  bash: [docker, git, npm, node]     # ← array of allowed commands, or true for all
  edit: null                          # ← accepts null or object (needs verification for sub-fields)
  web-fetch: null                     # ← accepts null or object (needs verification for sub-fields)
  web-search: null                    # ← accepts null or object
  playwright: null
  cache-memory: null
  repo-memory: null
  # MCP servers are top-level named tool entries (NOT under an "mcp-servers:" sub-key):
  nsip:
    container: "ghcr.io/zircote/nsip"
    args: ["mcp"]
  serena:
    command: node
    args: ["server.js", "--verbose"]
```

### GitHub Toolsets

> **IMPORTANT (v0.45.0):** Toolset names use **underscores**, not hyphens. `pull-requests` is invalid; use `pull_requests`.

**Valid toolset values:**

| Toolset | Capabilities |
|---------|-------------|
| `all` | All available toolsets |
| `default` | Default set of toolsets |
| `action-friendly` | Toolsets safe for GitHub Actions context |
| `context` | Context-related tools |
| `repos` | Repository operations |
| `issues` | List, read, create, update, close issues |
| `pull_requests` | List, read, create, update, merge PRs (**underscore, not hyphen**) |
| `actions` | Workflow runs and artifacts |
| `code_security` | Code security scanning tools |
| `dependabot` | Dependabot-related tools |
| `discussions` | List, read, create, comment on discussions |
| `experiments` | Experimental features |
| `gists` | Gist operations |
| `labels` | Add, remove, list labels |
| `notifications` | Notification management |
| `orgs` | Organization operations |
| `projects` | GitHub Projects |
| `search` | Code and issue search |
| `secret_protection` | Secret scanning tools |
| `security_advisories` | Security advisory tools |
| `stargazers` | Star/stargazer operations |
| `users` | User-related operations |

### Tool-Specific Options

- **`bash`**: Accepts `true` (all commands allowed), an array of command strings like `[docker, git]`, or `null`. Does **not** use `enabled` or `allowed-commands` as sub-fields.
- **`edit`**: Accepts `null` or an object. Does **not** support `enabled` or `allowed-paths`. Exact accepted sub-fields need verification -- mark as TODO if unsure.
- **`web-fetch`**: Accepts `null` or an object. Does **not** support `enabled` or `allowed-domains` as documented previously. Exact accepted sub-fields need verification.
- **`cache-memory`**: Persistent key-value store across runs.
- **`repo-memory`**: Read/write to a `.github/memory/` directory for cross-workflow state.
- **MCP Servers**: MCP servers are **not** configured under an `mcp-servers:` sub-key. They are **top-level named tool entries** under `tools:` with `container` and optional `args` fields, just like any other tool. Valid properties for an MCP tool entry: `allowed`, `allowed-domains`, `allowed_domains`, `args`, `command`, `container`, `description`, `entrypoint`, `entrypointArgs`, `env`. Use `gh aw mcp add` to register servers.

  > **CRITICAL:** For Docker-based MCP servers, always use the `container` field with the image reference. Do **NOT** use `command: docker` with `args: ["run", "--rm", "-i", "image", ...]`. The `command: docker` pattern causes the compiler to misparse the args — it will extract non-image tokens (like subcommands) as container image names in the `download_docker_images` step, causing pull failures at runtime. Use `container` for Docker images; reserve `command` for non-Docker executables (e.g., `command: node`).

  ```yaml
  tools:
    # Docker-based MCP server — use container field
    my-mcp-server:
      container: "ghcr.io/org/server"
      args: ["mcp"]
      env:
        API_KEY: "${{ secrets.MCP_KEY }}"

    # Non-Docker MCP server — command field is fine
    my-local-server:
      command: node
      args: ["server.js", "--verbose"]
  ```

---

## Safe Outputs Block (`safe-outputs`)

Pre-approved GitHub write operations. The agent can perform these without additional approval. All other write operations are blocked. In strict mode (default), this is the **only** way to perform writes -- permissions block must use `read` level.

> **IMPORTANT (v0.45.0):** Several fields from older documentation are **not valid**:
> - `max-length` under `add-comment` -- not a valid field
> - `max-per-run` under `create-issue` and `create-pull-request` -- not a valid field
> - `require-comment` under `close-issue` -- not a valid field
> - `allowed-reasons` under `close-issue` -- not a valid field

```yaml
safe-outputs:
  create-issue:
    title-prefix: "[auto]"
    labels: [automated]
    close-older-issues: true
  add-comment: {}
  add-labels:
    allowed: [bug, feature, enhancement, documentation, question, help-wanted, good-first-issue]
  remove-labels:
    allowed: [needs-triage]
  create-pull-request:
    title-prefix: "[auto]"
    base-branch: main
    draft: true
    labels: [automated]
    allow-empty: false
    allowed-labels: [automated]
    allowed-repos: []
    auto-merge: false
    expires: null
    fallback-as-issue: false
    footer: null
    github-token: null
  close-issue: {}
  update-issue:
    allowed-fields: [title, body, assignees, milestone]
  lock-issue: {}
  create-discussion:
    category: "General"
    labels: [automated]
  add-reaction:
    allowed: ["+1", "rocket", "eyes"]
```

### Operation Types

| Operation | Description | Key Constraints |
|-----------|-------------|-----------------|
| `create-issue` | Create new issues | `title-prefix`, `labels`, `close-older-issues` |
| `add-comment` | Comment on issues/PRs | No sub-field constraints in v0.45.0 |
| `add-labels` | Add labels | `allowed` (whitelist) |
| `remove-labels` | Remove labels | `allowed` (whitelist) |
| `create-pull-request` | Open PRs | `title-prefix`, `base-branch`, `draft`, `labels`, `allow-empty`, `allowed-labels`, `allowed-repos`, `auto-merge`, `expires`, `fallback-as-issue`, `footer`, `github-token` |
| `close-issue` | Close issues | No sub-field constraints in v0.45.0 |
| `update-issue` | Modify issue fields | `allowed-fields` |
| `lock-issue` | Lock issue threads | — |
| `create-discussion` | Create discussions | `category`, `labels` |
| `add-reaction` | React to content | `allowed` (whitelist) |

> **Key principle:** Safe outputs are the only way agents can modify GitHub state in strict mode. Any operation not listed here is blocked. Keep allowlists tight.

---

## Safe Inputs Block (`safe-inputs`)

Define inline tool capabilities the agent can use for processing (not GitHub operations).

```yaml
safe-inputs:
  parse-json:
    description: "Parse JSON from issue body"
    schema:
      type: object
      properties:
        field: { type: string }
  extract-urls:
    description: "Extract URLs from text"
```

Safe inputs define structured data extraction and transformation tools available to the agent during execution.

---

## Sandbox Block (`sandbox`)

Controls the execution sandbox environment.

> **Note (v0.45.0):** The sandbox block structure below needs verification against the current compiler. Fields and accepted values may have changed. Use with caution and test with `gh aw compile --check`.

```yaml
sandbox:
  enabled: true
  filesystem:
    read-only: ["/etc", "/usr"]
    writable: ["/tmp", "/workspace"]
  resources:
    memory: "2Gi"
    cpu: "1"
    disk: "10Gi"
  env-isolation: true
```

- **`filesystem`**: Control read/write access to paths
- **`resources`**: Resource limits for the sandbox
- **`env-isolation`**: When `true`, the sandbox gets a clean environment without host env vars
