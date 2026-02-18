# Validation Reference

Common errors, anti-patterns, and runtime failures in gh-aw workflow files, organized by when they occur.

---

## Phase 1: Compilation Errors

Caught by `gh aw compile` before the workflow runs.

### YAML Syntax Errors
- **Indentation mismatch:** YAML requires consistent indentation (2 spaces recommended)
- **Missing quotes:** Strings with special characters (`:`, `#`, `{`) must be quoted
- **Invalid types:** e.g., `timeout-minutes: "ten"` (expects integer)
- **Duplicate keys:** YAML silently uses the last value for duplicate keys

### Strict Mode Violations

When `strict: true` (default):
- **Unknown keys:** Any frontmatter key not in the schema causes an error
- **Undeclared permissions:** Every permission used must be explicitly declared
- **Missing required fields:** `on` trigger is always required

### Trigger Errors
- **`issue` instead of `issues`:** Must be plural — this is the #1 most common mistake
- **Missing `reaction: eyes`:** Required for event-triggered workflows (issues, PRs, comments, discussions) to grant pre_activation permissions
- **Overlapping schedules:** Two workflows with the same cron expression compete for resources
- **Ambiguous event types:** Using both `issues` and `issue_comment` without clear separation causes double-processing
- **Missing `types` field:** `on: issues: {}` without `types` defaults to all event types — usually too broad

### Safe-Output Violations
- **Referencing undefined operations:** Using `create-pull-request` in prose when it's not in `safe-outputs`
- **Missing required fields:** Some safe-outputs require specific parameters
- **Invalid constraint values:** Labels not as list, max not as integer

### Permission Errors
- **Insufficient permissions:** Safe-outputs require matching write permissions
- **Missing `actions: read`:** Required when using `agentic-workflows:` tool
- **Missing `contents: write`:** Required for `push-to-pull-request-branch` and `update-release`

---

## Phase 2: Runtime Errors

Occur during GitHub Actions execution.

### Tool Errors
- **Toolset not available:** Requesting a toolset that doesn't exist or isn't permitted
- **Bash command blocked:** Attempting a command not in the allowlist
- **Network blocked:** External URL access when no `network` configuration
- **MCP server connection failed:** Server not available, wrong args, missing env vars
- **Container pull failed (silent):** Container-based MCP servers from `ghcr.io` fail silently if no GHCR login step is present. Add a `steps:` block with `docker login ghcr.io` using `${{ github.token }}`

### Permission Errors
- **Token insufficient:** `GITHUB_TOKEN` lacks required scope
- **GitHub App scope mismatch:** App installed but missing repository access
- **Cross-repo access denied:** `target-repo` specified but token lacks access

### Timeout Errors
- **Agent timeout:** Exceeded `timeout-minutes` — increase limit or simplify task
- **MCP server timeout:** External service didn't respond in time
- **Compilation timeout:** Usually indicates circular imports

### Safe-Output Constraint Violations
- **Label not in allowlist:** Agent attempted to add a label not in `safe-outputs.add-labels.allowed`
- **Max operations exceeded:** More outputs requested than `max` allows
- **Title prefix mismatch:** Created item doesn't start with required `title-prefix`
- **Target mismatch:** `target: "triggering"` used but no triggering event context

---

## Phase 3: Behavioral Issues

The workflow runs but produces incorrect or unexpected results.

### Prompt Quality Issues
- **Vague instructions:** "Handle the issue appropriately" — too ambiguous
- **Missing context:** Agent doesn't know the repo's language, conventions, or purpose
- **Conflicting instructions:** Two sections give contradictory guidance
- **Missing edge cases:** No instruction for when labels don't match, or issue is spam

### Safe-Output Mismatches
- **Prose describes writes not in safe-outputs:** Agent tries but can't execute
- **Safe-outputs declared but never used:** Unnecessary permissions granted
- **Allowlist too restrictive:** Agent needs labels that aren't in the allowed list
- **Allowlist too permissive:** Agent applies irrelevant labels

### Context Issues
- **Missing `${{ github.event }}` handling:** Agent doesn't process event payload
- **No `event.json` fallback:** When event context is unavailable, agents should check for `event.json` in the workspace
- **Stale cache data:** `cache-memory` contains outdated information

---

## Anti-Pattern Catalog

### Security Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|-------------|-------------|-----|
| `permissions: write-all` | Violates least privilege | Declare minimal explicit scopes |
| `bash: [":*"]` without justification | Unrestricted shell access | Use explicit command allowlist |
| Hardcoded secrets in frontmatter | Secrets exposed in repo | Use `${{ secrets.NAME }}` |
| `lockdown: false` on public repo | External input untrusted | Enable lockdown or use `strict: false` |
| Missing `max` on safe-outputs | No rate limiting | Set explicit `max` limits |
| `network: true` | Unrestricted external access | Use `network.firewall.allowed` list |

### Design Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|-------------|-------------|-----|
| One workflow does everything | Hard to maintain/debug | Split into focused workflows |
| Labels without allowlist | Agent can apply anything | Use `allowed: [list]` |
| No `title-prefix` on created items | Can't search/track | Add meaningful prefix |
| No `close-older-issues` on reports | Issue accumulation | Enable auto-cleanup |
| Overlapping triggers | Double-processing | Use distinct event types |
| `container:` with non-Docker value | Compilation error | Use valid Docker image reference |
| `container: ghcr.io/…` without GHCR login step | Silent runtime failure | Add `steps:` with `docker login ghcr.io` |

### Prose Anti-Patterns

| Anti-Pattern | Why It's Bad | Fix |
|-------------|-------------|-----|
| No H1 heading | Agent lacks mission | Add clear H1 title |
| No Context section | Agent lacks environment info | Add repository/event context |
| "Be helpful" instructions | Too vague | Give specific, actionable steps |
| No edge case handling | Agent confused by unusual input | Enumerate edge cases |
| Referencing tools not in frontmatter | Tool unavailable | Align tools block with prose |

---

## Debugging Checklist

When a workflow fails, check in this order:

### 1. Compilation
- [ ] Valid YAML syntax (2-space indentation, quoted special chars)
- [ ] `on` trigger present with correct event name (`issues` not `issue`)
- [ ] `reaction: eyes` on event triggers
- [ ] All frontmatter keys are valid for the schema
- [ ] `strict: false` if processing external input

### 2. Permissions
- [ ] Every tool has matching read permission
- [ ] Every safe-output has matching write permission
- [ ] `actions: read` if using `agentic-workflows:` tool
- [ ] `contents: write` if pushing to branches or managing releases
- [ ] Custom token if using Projects v2

### 3. Tools
- [ ] GitHub toolsets include what the prose needs
- [ ] Bash allowlist covers required commands
- [ ] MCP servers have correct env vars and args
- [ ] Network config allows required external domains
- [ ] Container-based MCP servers from `ghcr.io` have a GHCR login step in `steps:`

### 4. Safe-Outputs
- [ ] Every write operation in prose has a matching safe-output
- [ ] Allowlists include all values the agent might need
- [ ] `max` limits are sufficient but not excessive
- [ ] `target` specification matches the workflow's trigger

### 5. Prose
- [ ] H1 heading with clear purpose
- [ ] Context section with repo and event info
- [ ] Specific, actionable instructions
- [ ] Edge cases handled
- [ ] Output format matches safe-output types

### 6. Runtime
- [ ] Timeout sufficient for task complexity
- [ ] Engine configured correctly (API key secret present)
- [ ] No circular imports
- [ ] No conflicting workflows on same trigger
