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
- **Default:** `false`
- **Description:** When `true`, enables strict compilation mode. Unknown keys cause errors. All permissions must be explicitly declared.

### `lockdown`
- **Type:** boolean
- **Default:** `true` for public repos, `false` for private
- **Description:** Security mode that restricts agent capabilities. When enabled, agents cannot interact with content from untrusted contributors. Disable with `lockdown: false` only for workflows like issue triage that must process external input.

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
  issue:
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

**Supported events:**
| Event | Types | Description |
|-------|-------|-------------|
| `issue` | opened, reopened, labeled, unlabeled, assigned, unassigned, closed, edited, deleted, transferred, milestoned | Issue lifecycle events |
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

```yaml
engine:
  id: copilot                    # Engine identifier
  model: gpt-4o                  # Model to use
  version: "2024-01"             # Engine version
  agent: coding-agent            # Agent type/profile
  max-turns: 10                  # Max conversation turns
  timeout-minutes: 30            # Engine-specific timeout
  concurrency: 1                 # Parallel execution limit
  thinking: true                 # Enable chain-of-thought
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
| `copilot` | GitHub Copilot | Default engine, deep GitHub integration |
| `claude` | Anthropic | Strong reasoning, long context |
| `codex` | OpenAI Codex | Code-focused tasks |

### Key Fields

- **`id`** (required): Engine identifier
- **`model`**: Specific model version. Defaults vary by engine.
- **`max-turns`**: Limits conversation depth to control cost and prevent loops. Default: `10`
- **`timeout-minutes`**: Engine-level timeout (overrides root `timeout-minutes` for the engine). Default: inherits root.
- **`concurrency`**: How many instances can run in parallel. Default: `1`
- **`thinking`**: Enable extended thinking/chain-of-thought. Default: `false`
- **`error_patterns`**: List of regex patterns that signal the engine encountered an error

---

## Permissions Block (`permissions`)

Declares the minimum GitHub permissions required. In strict mode, undeclared permissions cause compilation errors.

```yaml
permissions:
  contents: read          # Repository contents
  issues: write           # Issues CRUD
  pull-requests: write    # PR CRUD
  discussions: read       # Discussions access
  actions: read           # Actions workflow access
  checks: write           # Check runs/suites
  packages: read          # GitHub Packages
  statuses: write         # Commit statuses
```

**Permission levels:** `none`, `read`, `write`

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

> **Best practice:** Always use minimum required permissions. Start with `read` and only elevate to `write` when the workflow must modify resources.

---

## Network Block (`network`)

Controls network access for sandboxed execution.

```yaml
network:
  allowed:
    - "api.github.com"
    - "api.openai.com"
    - "*.amazonaws.com"
  blocked:
    - "*.malicious.com"
  firewall: strict            # strict | permissive | disabled
```

- **`allowed`**: Allowlist of domains/patterns the agent can reach
- **`blocked`**: Denylist of domains/patterns (takes precedence over allowed)
- **`firewall`**: Firewall mode. `strict` blocks all except allowed. `permissive` allows all except blocked. `disabled` allows everything (not recommended).

---

## Tools Block (`tools`)

Declares which tools the agent can use. Tool allowlisting restricts agent capabilities to only what's needed.

```yaml
tools:
  github:
    toolsets: [issues, labels, pull-requests, discussions]
    lockdown: false          # Override global lockdown for this tool
  bash:
    enabled: true
    allowed-commands: [npm, node, python3, go, make]
  edit:
    enabled: true
    allowed-paths: ["src/**", "docs/**"]
  web-fetch:
    enabled: true
    allowed-domains: ["docs.github.com", "api.github.com"]
  web-search:
    enabled: true
  playwright:
    enabled: true
    headless: true
  cache-memory:
    enabled: true
    ttl: "24h"
  repo-memory:
    enabled: true
  mcp-servers:
    - name: serena
      url: "https://serena.example.com"
      auth: "${{ secrets.SERENA_TOKEN }}"
```

### GitHub Toolsets

| Toolset | Capabilities |
|---------|-------------|
| `issues` | List, read, create, update, close issues |
| `labels` | Add, remove, list labels |
| `pull-requests` | List, read, create, update, merge PRs |
| `discussions` | List, read, create, comment on discussions |
| `commits` | List, read commits |
| `branches` | List, create, delete branches |
| `releases` | List, create releases |
| `actions` | List, trigger workflow runs |

### Tool-Specific Options

- **`bash`**: `allowed-commands` restricts which CLI commands can be invoked
- **`edit`**: `allowed-paths` restricts file editing to specific glob patterns
- **`web-fetch`**: `allowed-domains` restricts HTTP requests to specific domains
- **`cache-memory`**: Persistent key-value store across runs. `ttl` sets default expiry.
- **`repo-memory`**: Read/write to a `.github/memory/` directory for cross-workflow state
- **`mcp-servers`**: Model Context Protocol server integrations

---

## Safe Outputs Block (`safe-outputs`)

Pre-approved GitHub write operations. The agent can perform these without additional approval. All other write operations are blocked.

```yaml
safe-outputs:
  create-issue:
    title-prefix: "[auto]"
    labels: [automated]
    close-older-issues: true
    max-per-run: 5
  add-comment:
    max-length: 5000
  add-labels:
    allowed: [bug, feature, enhancement, documentation, question, help-wanted, good-first-issue]
  remove-labels:
    allowed: [needs-triage]
  create-pull-request:
    title-prefix: "[auto]"
    base-branch: main
    draft: true
    labels: [automated]
    max-per-run: 1
  close-issue:
    require-comment: true
    allowed-reasons: [completed, not_planned, duplicate]
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
| `create-issue` | Create new issues | `title-prefix`, `labels`, `max-per-run`, `close-older-issues` |
| `add-comment` | Comment on issues/PRs | `max-length` |
| `add-labels` | Add labels | `allowed` (whitelist) |
| `remove-labels` | Remove labels | `allowed` (whitelist) |
| `create-pull-request` | Open PRs | `title-prefix`, `base-branch`, `draft`, `max-per-run` |
| `close-issue` | Close issues | `require-comment`, `allowed-reasons` |
| `update-issue` | Modify issue fields | `allowed-fields` |
| `lock-issue` | Lock issue threads | — |
| `create-discussion` | Create discussions | `category`, `labels` |
| `add-reaction` | React to content | `allowed` (whitelist) |

> **Key principle:** Safe outputs are the only way agents can modify GitHub state. Any operation not listed here is blocked. Keep allowlists tight.

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
