# Tools Reference

Complete reference for all tool types available in gh-aw workflow frontmatter.

---

## Edit Tool (`edit:`)

```yaml
tools:
  edit:
```

Enables file editing in the GitHub Actions workspace. No parameters.

### Path Restrictions

```yaml
tools:
  edit:
    allowed-paths: ["src/", "docs/"]
```

Restrict editing to specific directories.

---

## Bash Tool (`bash:`)

```yaml
tools:
  bash:                              # Default safe commands only
  bash: []                           # Disable all commands
  bash: ["echo", "ls", "git status"] # Specific commands only
  bash: [":*"]                       # All commands (unrestricted)
```

### Default Safe Commands

When `bash:` is declared without a list, only these commands are available:
`echo`, `ls`, `pwd`, `cat`, `head`, `tail`, `grep`, `wc`, `sort`, `uniq`, `date`

### Wildcard Patterns

- `git:*` — all git subcommands (`git status`, `git log`, `git diff`, etc.)
- `npm:*` — all npm subcommands
- `:*` — unrestricted access to all commands (use with caution)

### Recommended Allowlists

**Read-only analysis:**
```yaml
bash: ["echo", "ls", "cat", "grep", "jq", "wc", "sort"]
```

**Code analysis with git:**
```yaml
bash: ["echo", "ls", "cat", "grep", "jq", "git:*"]
```

**Build and test:**
```yaml
bash: ["echo", "ls", "cat", "npm:*", "git:*", "make"]
```

---

## Web Tools

### Web Fetch (`web-fetch:`)

```yaml
tools:
  web-fetch:
```

Retrieve content from URLs. No parameters required.

### Web Search (`web-search:`)

```yaml
tools:
  web-search:
```

Search the web. Engine-dependent; may require third-party MCP servers depending on engine selection.

---

## GitHub Tools (`github:`)

```yaml
tools:
  github:                                      # Default toolsets
  github:
    toolsets: [repos, issues, pull_requests]   # Specific toolset groups
    mode: remote                               # "local" (Docker) or "remote" (hosted)
    read-only: true                            # Restrict to read operations
    lockdown: true                             # Force security filtering
    github-token: "${{ secrets.CUSTOM_PAT }}"  # Custom token
```

### Toolsets — Complete List

| Toolset | Purpose |
|---------|---------|
| `context` | Repository and event context |
| `repos` | Code, commits, branches, files |
| `issues` | Issue read/analysis |
| `pull_requests` | PR read/analysis |
| `users` | User profile information |
| `actions` | Workflow runs, logs |
| `code_security` | Security advisories, scanning |
| `discussions` | Discussion content |
| `labels` | Label definitions |
| `notifications` | Notification management |
| `orgs` | Organization information |
| `projects` | GitHub Projects v2 |
| `gists` | Gist management |
| `search` | GitHub search API |
| `dependabot` | Dependabot alerts |
| `experiments` | Experimental features |
| `secret_protection` | Secret scanning |
| `security_advisories` | Security advisory management |
| `stargazers` | Star information |

### Default Toolsets

- **General:** `[context, repos, issues, pull_requests, users]`
- **GitHub Actions:** `[context, repos, issues, pull_requests]` (token limitations)

### Common Combinations

```yaml
# Issue management
toolsets: [issues, labels]

# PR review
toolsets: [repos, issues, pull_requests, labels]

# Full repository analysis
toolsets: [repos, issues, pull_requests, discussions, labels, actions]

# Security focused
toolsets: [repos, code_security, dependabot, secret_protection, security_advisories]
```

### GitHub App Authentication

```yaml
tools:
  github:
    mode: remote
    toolsets: [repos, issues, pull_requests]
    app:
      app-id: ${{ vars.APP_ID }}
      private-key: ${{ secrets.APP_PRIVATE_KEY }}
      owner: "my-org"
      repositories: ["repo1", "repo2"]
```

**Repository scoping:**
- `["*"]` — org-wide access
- `["repo1", "repo2"]` — specific repos
- Omit field — current repo only

**Token precedence:** GitHub App → `github-token` → `GH_AW_GITHUB_MCP_SERVER_TOKEN` → `GH_AW_GITHUB_TOKEN` → `GITHUB_TOKEN`

---

## Playwright Tool (`playwright:`)

```yaml
tools:
  playwright:
    allowed_domains: ["defaults", "github", "*.custom.com"]
    version: "1.56.1"
```

Containerized browser automation for web interaction.

### Domain Bundles

| Bundle | Domains |
|--------|---------|
| `defaults` | `localhost`, `127.0.0.1` |
| `github` | GitHub and related domains |
| `node` | npm, Node.js ecosystem |
| `python` | PyPI, Python ecosystem |

Custom domains use glob patterns: `*.example.com`

### Version

Defaults to `1.56.1`. Use `"latest"` for newest version.

### Requirements

Requires Docker with appropriate security flags for GitHub Actions compatibility.

---

## Built-in MCP Tools

### Agentic Workflows (`agentic-workflows:`)

```yaml
permissions:
  actions: read
tools:
  agentic-workflows:
```

Workflow introspection, log analysis, and debugging. **Requires `actions: read` permission.** The `logs` and `audit` tools require writer/maintainer/admin repository role.

### Cache Memory (`cache-memory:`)

```yaml
tools:
  cache-memory:
```

Persistent memory across workflow runs. Useful for tracking trends, historical data, and maintaining context between executions.

### Repo Memory (`repo-memory:`)

```yaml
tools:
  repo-memory:
```

Repository-scoped memory for maintaining context specific to a repository across executions.

---

## Custom MCP Servers (`mcp-servers:`)

```yaml
mcp-servers:
  server-name:
    command: "npx"
    args: ["-y", "@org/package"]
    env:
      TOKEN: "${{ secrets.VALUE }}"
    allowed: ["tool_name"]
```

### Configuration Options

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Executable path (process-based) |
| `args` | list | Command arguments |
| `container` | string | Docker image reference (alternative to command) |
| `entrypointArgs` | list | Arguments passed to container ENTRYPOINT |
| `url` | string | HTTP endpoint (alternative to command) |
| `headers` | mapping | HTTP headers for url-based servers |
| `registry` | string | MCP registry URI (informational only, does not affect execution) |
| `env` | mapping | Environment variables |
| `mounts` | list | Volume mounts in `"host:container:mode"` format |
| `allowed` | list | Tool name restrictions |

### Execution Modes

1. **Process-based:** `command` + `args` — runs as subprocess
2. **Container-based:** `container` — runs in Docker
3. **HTTP-based:** `url` + optional `headers` — connects to endpoint

**IMPORTANT:** The `container` field must be a valid Docker image reference. Do not use it for arbitrary strings.

### Example: Slack Integration

```yaml
mcp-servers:
  slack:
    command: "npx"
    args: ["-y", "@slack/mcp-server"]
    env:
      SLACK_BOT_TOKEN: "${{ secrets.SLACK_BOT_TOKEN }}"
    allowed: ["send_message", "get_channel_history"]
```

### Container Authentication (GHCR)

**CRITICAL:** When using `container:` with images hosted on GitHub Container Registry (`ghcr.io`), you **must** add a GHCR login step in the `steps:` block. Without this, container pulls fail silently at runtime.

```yaml
mcp-servers:
  datadog:
    container: ghcr.io/org/datadog-mcp:latest
    env:
      DD_API_KEY: "${{ secrets.DD_API_KEY }}"

steps:
  - name: Login to GitHub Container Registry
    run: echo "${{ github.token }}" | docker login ghcr.io -u "${{ github.actor }}" --password-stdin
```

This applies to **all** container-based MCP servers pulling from `ghcr.io`, regardless of whether the image is public or private. The `github.token` is automatically available and has sufficient scope for package reads.

### CA Certificates for Minimal Images

Containers built from `FROM scratch` or distroless base images have **no CA certificate bundle**. Any TLS connection (HTTPS API calls) will fail with "certificate verify failed". The MCP tool may return a misleading error (e.g., "no data found") instead of the real TLS error — check `agent-artifacts/mcp-logs/{server}.log` for the actual failure.

**Fix:** Mount the host runner's CA certs and set `SSL_CERT_FILE`:

```yaml
mcp-servers:
  my-server:
    container: ghcr.io/org/image:latest
    env:
      SSL_CERT_FILE: "/etc/ssl/certs/ca-certificates.crt"
    mounts:
      - "/etc/ssl/certs:/etc/ssl/certs:ro"
```

### Package Registry Access for Process-Based Servers

Process-based MCP servers using `npx` or `uvx` need package registry access at runtime:
- **`npx` servers** — add `node` to `network.firewall.allowed` (covers npm registries)
- **`uvx` servers** — add `python` to `network.firewall.allowed` (covers PyPI)

These ecosystem identifiers work in strict mode and do not require `strict: false`.

### Key Constraints

- Tool declarations merge from imported components
- GitHub App tokens auto-revoke after workflow completion
- Lockdown mode auto-enables for public repos with custom tokens
- The `registry` field is informational and doesn't affect execution
- Container-based MCP servers from `ghcr.io` require a GHCR login step (see above)
