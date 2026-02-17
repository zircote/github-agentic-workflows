# Validation Reference

This reference covers common errors, anti-patterns, and runtime failures in gh-aw workflow files, organized by when they occur.

---

## Phase 1: Compilation Errors

These errors are caught by `gh aw compile` before the workflow runs.

### YAML Syntax Errors
- **Indentation mismatch:** YAML requires consistent indentation (2 spaces recommended)
- **Missing quotes:** Strings with special characters (`:`, `#`, `{`) must be quoted
- **Invalid types:** e.g., `timeout-minutes: "ten"` (expects integer)

### Strict Mode Violations
When `strict: true` is set:
- **Unknown keys:** Any frontmatter key not in the schema causes an error
- **Undeclared permissions:** Every permission used must be explicitly declared
- **Missing required fields:** `on` trigger is always required

### Trigger Conflicts
- **Overlapping schedules:** Two workflows with the same cron expression compete for resources
- **Ambiguous event types:** Using both `issues` and `issue_comment` without clear separation can cause double-processing
- **Missing event types:** `on: issues: {}` without `types` defaults to all event types — often too broad

### Safe-Output Violations
- **Referencing undefined operations:** Using `create-pull-request` in prose when it's not in `safe-outputs`
- **Label not in allowlist:** Agent attempts to add a label not in `safe-outputs.add-labels.allowed`
- **Exceeding output limits:** Attempting to create more artifacts than the workflow design intends

---

## Phase 2: Structural Anti-Patterns

These won't cause compilation errors but lead to poor workflow behavior.

### Raw Context Injection
**Problem:** Dumping entire file contents or issue bodies into the agent context without summarization.
```markdown
# Bad
Read the entire codebase and analyze every file.

# Good
List files matching `src/**/*.go`. For each file, check only the exported function signatures.
```
**Impact:** Context window exhaustion, token waste, degraded reasoning quality.

### Hardcoded Secrets and Values
**Problem:** Embedding secrets, repo names, or branch names directly in markdown.
```markdown
# Bad
Push to the repository octocat/my-repo on branch main.

# Good
Push to ${{ github.repository }} on branch ${{ github.base_ref }}.
```
**Impact:** Workflow not portable, secrets potentially exposed in repository.

### Fixed Schedules Without State
**Problem:** Running a scheduled workflow without tracking what's been processed.
```markdown
# Bad — processes same files every day
Audit all Go files in the repository.

# Good — tracks progress
Read `audit-progress` from cache-memory. Skip packages audited in the last 7 days.
Select the next unaudited package.
```
**Impact:** Wasted compute, duplicate issues, no coverage guarantees.

### Unconstrained Output
**Problem:** No limits on how many artifacts the agent can create per run.
```yaml
# Bad
safe-outputs:
  create-issue: {}

# Good — use title-prefix and close-older-issues to constrain output
safe-outputs:
  create-issue:
    title-prefix: "[auto]"
    close-older-issues: true
```
**Impact:** Issue spam, notification fatigue, difficult rollback.

### Explicit MCP Tool Names in Prose Body
**Problem:** Referencing specific MCP tool function names (e.g., `get_issue`, `create_pull_request`) in the prose body. MCP tool names vary by server version and the agent may not recognize them. The gh-aw agent maps natural language instructions to available tools automatically.
```markdown
# Bad — hardcoded tool name that may not exist
Fetch the triggering issue using the github MCP server's `get_issue` tool.

# Good — natural language with template expressions
Read the details of issue #${{ github.event.issue.number }} in
${{ github.repository }}. Extract the title, body, and labels.
```
**Impact:** Agent calls a non-existent tool, gets `MCP error -32603: fetch failed`, and cannot recover. The workflow produces no output.

### Over-Permissioned Workflows
**Problem:** Requesting write permissions when only read is needed.
```yaml
# Bad — write permission for a read-only analysis
permissions:
  contents: write
  issues: write

# Good — minimal permissions
permissions:
  contents: read
  issues: read
```
**Impact:** Increased security surface, potential for unintended mutations.

### Vague Instructions
**Problem:** Ambiguous natural language that gives the agent too much discretion.
```markdown
# Bad
Look at the code and fix any problems you find.

# Good
For each function longer than 50 lines, check if it can be split into smaller functions.
Create an issue for each function that exceeds the threshold, with a suggested decomposition.
```
**Impact:** Unpredictable behavior, inconsistent outputs, difficult debugging.

---

## Phase 3: Runtime Failures

These occur during workflow execution in GitHub Actions.

### Docker Image Pull Failure from `command: docker` Pattern
- **Symptom:** `Download container images` step fails with `pull access denied for mcp, repository does not exist`
- **Cause:** MCP tool defined with `command: docker` and `args: ["run", "--rm", "-i", "ghcr.io/org/image", "mcp"]`. The compiler cannot correctly parse Docker image references from raw `docker run` args — it extracts non-image tokens (e.g., `mcp`) as container names and misses the actual image.
- **Fix:** Use the `container` field for Docker-based MCP servers:
  ```yaml
  # WRONG — causes image pull failure
  my-server:
    command: docker
    args: ["run", "--rm", "-i", "ghcr.io/org/image", "mcp"]

  # CORRECT — compiler properly resolves the image
  my-server:
    container: "ghcr.io/org/image"
    args: ["mcp"]
  ```
- **Rule:** Reserve `command` for non-Docker executables (e.g., `command: node`). Always use `container` for Docker images.

### Missing Secrets
- **Symptom:** Engine fails to initialize, API calls return 401/403
- **Cause:** `secrets` list in frontmatter references secrets not configured in repository settings
- **Fix:** Add required secrets in Settings > Secrets and variables > Actions

### Network/Firewall Blocks
- **Symptom:** Agent cannot reach external APIs, web-fetch fails
- **Cause:** `network.firewall: true` blocks domains not in the allowlist
- **Fix:** Add required domains to `network.allowed`. Custom domains require `strict: false` at root level.

### GitHub MCP Server Fetch Failure from Custom Network Domains
- **Symptom:** GitHub MCP tool calls fail with `MCP error -32603: fetch failed`, even though `api.github.com` is in the allowed list
- **Cause:** Listing raw domains (e.g., `"api.github.com"`) instead of using the `defaults` ecosystem alias. The GitHub MCP server communicates through internal Docker proxy endpoints and network paths that raw domain strings don't cover. The `defaults` alias includes all required GitHub API infrastructure.
- **Fix:** Always include the `defaults` ecosystem alias in `network.allowed`. Add custom domains only for non-GitHub services:
  ```yaml
  network:
    allowed:
      - defaults              # ← REQUIRED for GitHub MCP server
      - containers            # ← for ghcr.io / Docker images
      - "custom-api.example.com"  # ← only for non-GitHub services
    firewall: true
  ```
- **Rule:** Never rely on raw `api.github.com` to cover GitHub MCP server networking. Always use `defaults`.

### Agent Cannot Read Issue/PR Data (Bash Allowlist)
- **Symptom:** Agent reports `missing_data` — cannot access issue content via MCP, CLI, or event.json
- **Cause:** The `bash` tool allowlist is too restrictive. If the GitHub MCP server fails, the agent's fallback is to read `event.json` with `cat`/`jq`. When those commands aren't allowed, all data access paths are blocked.
- **Fix:** Always include `cat` and `jq` in the bash allowlist for workflows that process GitHub event data:
  ```yaml
  tools:
    bash: [docker, git, cat, jq]  # cat/jq needed for event.json fallback
  ```
- **Rule:** For any workflow triggered by GitHub events (issues, PRs, comments), ensure bash allows `cat` and `jq` as fallback data access methods.

### Strict Mode Rejections
- **Symptom:** Agent skips issues from external contributors, or write permissions rejected
- **Cause:** `strict: true` (default) prevents interaction with untrusted content and blocks write permissions
- **Fix:** Set `strict: false` for workflows that must process external input (e.g., issue triage). Use safe-outputs for all write operations.

### Token Permission Errors
- **Symptom:** 403 errors on GitHub API calls
- **Cause:** `permissions` block doesn't match what the workflow actually needs
- **Fix:** Ensure needed permissions are declared. In strict mode, use `read` permissions and safe-outputs for writes. In non-strict mode (`strict: false`), `write` permissions are accepted.

### Pre-Activation Bad Credentials from Missing `reaction` Field
- **Symptom:** `pre_activation` job succeeds but `check_membership` reports `Bad credentials`. All subsequent jobs are skipped (activation → agent → safe_outputs).
- **Cause:** Without a `reaction:` field in the `on:` block, the compiler generates the `pre_activation` job with **no permissions block**. The `GITHUB_TOKEN` defaults to `Metadata: read` only, which is insufficient for `check_membership.cjs` to query repository collaborator permissions.
- **Fix:** Add `reaction: eyes` to the `on:` block for event-triggered workflows. This tells the compiler to grant `issues: write, pull-requests: write, discussions: write` to `pre_activation`, enabling the membership check. Also use `permissions: read-all` instead of listing individual `read` permissions.
  ```yaml
  on:
    issues:
      types: [opened]
    reaction: eyes              # ← triggers pre_activation permissions

  permissions: read-all         # ← broad read, writes via safe-outputs
  ```
- **Rule:** Every event-triggered workflow should include `reaction:` in the `on:` block.

### Engine Timeout
- **Symptom:** Workflow killed mid-execution
- **Cause:** `timeout-minutes` too low for the task, or agent stuck in a loop
- **Fix:** Increase timeout, add `max-turns` to prevent loops, simplify instructions

### Context Window Exhaustion
- **Symptom:** Agent produces truncated or incoherent output late in execution
- **Cause:** Too much content loaded into context (large files, many issues)
- **Fix:** Use targeted queries instead of bulk reads, summarize before processing

### Rate Limiting
- **Symptom:** 429 errors from GitHub API
- **Cause:** No `rate-limit` configured, or too many workflow runs triggered in quick succession
- **Fix:** Add `rate-limit` to frontmatter, stagger scheduled workflows

---

## Pre-Deployment Checklist

### Frontmatter
- [ ] `on` trigger is defined and specific (not catching all event types)
- [ ] `permissions` follow least-privilege principle
- [ ] `timeout-minutes` is reasonable for the task (5-30 min typical)
- [ ] `safe-outputs` constrain every write operation
- [ ] `safe-outputs` include appropriate constraints (title-prefix, allowed lists, etc.)
- [ ] `tools` only include what's actually needed
- [ ] Docker-based MCP tools use `container` field (NOT `command: docker` with args)
- [ ] `secrets` are listed if the workflow uses external APIs
- [ ] `network.allowed` includes `defaults` alias (required for GitHub MCP server)
- [ ] `network.allowed` includes `containers` alias if using Docker-based MCP tools
- [ ] Custom domains in `network.allowed` only used for non-GitHub services (need `strict: false`)
- [ ] `bash` allowlist includes `cat` and `jq` for event-triggered workflows (event.json fallback)
- [ ] Event-triggered workflows include `reaction:` in `on:` block (required for pre_activation permissions)
- [ ] `permissions: read-all` preferred over listing individual read permissions
- [ ] `strict` setting matches the workflow's trust model

### Markdown Body
- [ ] H1 heading clearly states the workflow purpose
- [ ] Instructions use imperative voice
- [ ] Edge cases are explicitly handled
- [ ] Output format is defined
- [ ] No hardcoded values (use `${{ }}` templating)
- [ ] No explicit MCP tool names (use natural language; agent maps to available tools)
- [ ] No raw context injection (targeted reads, not bulk)
- [ ] Failure modes are addressed ("if X fails, do Y")

### Integration
- [ ] Required secrets are configured in repository settings
- [ ] Labels referenced in `safe-outputs` exist in the repository
- [ ] `gh aw compile` succeeds without errors
- [ ] Lock file (`.lock.yml`) is reviewed before deployment
- [ ] Test run completed on a non-production branch
