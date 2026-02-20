# Production Gotchas

Hard-won learnings from debugging gh-aw workflows in production. Each item was verified through real production failures and hours of debugging. Organized by category for quick reference.

---

## Expression Interpolation

### Code Block Interpolation Behavior

`${{ }}` expressions in the workflow markdown body **are** interpolated when they appear in plain text, but are **NOT** interpolated inside fenced code blocks (` ```bash `, ` ```yaml `, etc.).

**Symptom:** The agent receives the literal string `${{ github.event.issue.number }}` inside a code block. Bash cannot parse `${{`, and the command fails silently or produces unexpected results.

**Fix:** Declare environment variables in frontmatter `env:` (or in the prose as env var instructions), then reference them as `$VARIABLE_NAME` inside code blocks.

**Example — WRONG:**

````markdown
```bash
gh issue view ${{ github.event.issue.number }}
```
````

The agent receives the literal text `${{ github.event.issue.number }}` and bash fails.

**Example — CORRECT:**

Declare in prose (before code blocks):
```markdown
The issue number is available as `$ISSUE_NUMBER` (from `${{ github.event.issue.number }}`).
```

Or instruct the agent to read event context:
```markdown
Read the issue number from the event payload or the `event.json` file.
```

Then in code blocks, use shell variables:
````markdown
```bash
gh issue view "$ISSUE_NUMBER"
```
````

**Key principle:** Plain text expressions are interpolated at compile time. Fenced code block contents are passed to the agent verbatim.

---

## GitHub App & Token Conflicts

### tools.github.app Permission Inheritance

When using `tools.github.app` in frontmatter, the GitHub MCP server requests **ALL** workflow-level permissions for the App token — not just the ones the MCP tools need.

**Symptom:** HTTP 422 error: `"permissions requested are not granted to this app"`. The App token creation fails because the App installation doesn't have a permission that's declared in the workflow's `permissions:` block but isn't relevant to the MCP tools.

**Example:** Workflow has `packages: read` (for GHCR docker login in `steps:`), and `tools.github.app` is configured. The App token requests `packages:read`, but the GitHub App doesn't have the Packages permission installed. Result: 422 error on App token creation.

**Fix:** NEVER use `tools.github.app` unless the GitHub App has **ALL** permissions declared in the workflow's `permissions:` block. For read-only GitHub MCP access, omit `app:` entirely — `GITHUB_TOKEN` works fine for read operations.

**Decision tree:**
1. Does the agent need to **write** via MCP tools (not safe-outputs)? → Use `tools.github.app`
2. Does the agent only need to **read** via MCP tools? → Omit `app:`, use default `GITHUB_TOKEN`
3. Does the workflow have permissions the App doesn't have? → Remove `app:` or remove those permissions

### tools.github MCP Conflicts with gh CLI

When `tools.github` is configured in frontmatter, the GitHub MCP server takes ownership of the `GITHUB_TOKEN`. This prevents the `gh` CLI from authenticating in bash tool calls.

**Symptom:** Agent logs show `"Detected conflict with gh CLI authentication"` or `"missing tool"`. Bash commands using `gh` fail with authentication errors.

**Fix:** If the workflow **only** uses `gh` CLI via bash (not GitHub MCP tools), remove `tools.github` entirely from the frontmatter. The `gh` CLI authenticates directly with `GITHUB_TOKEN` and doesn't need the MCP server.

**Coexistence rule:** You can use `tools.github` AND `gh` CLI in the same workflow, but be aware that the MCP server may interfere with `gh` CLI auth. If you hit auth conflicts, choose one approach:
- MCP tools only (via `tools.github`) for structured API access
- `gh` CLI only (via `tools.bash: ["gh:*"]`) for shell-based access

---

## Safe-Output Gotchas

### add-comment Defaults to discussions:write

The `add-comment` safe-output silently requests `discussions:write` permission by default, even if the workflow never touches discussions.

**Symptom:** HTTP 422 error when the safe-output execution job tries to create the App token — the App doesn't have Discussions permission.

**Fix:** Explicitly set `discussions: false` under `add-comment:` in safe-outputs:

```yaml
safe-outputs:
  add-comment:
    discussions: false
    max: 1
```

### No merge-pull-request Safe Output

gh-aw has **NO** safe-output for merging pull requests. The complete list of valid safe-outputs is:

- `add-comment`
- `add-labels`
- `add-reviewer`
- `assign-milestone`
- `assign-to-agent`
- `assign-to-user`
- `autofix-code-scanning-alert`
- `close-issue`
- `close-pull-request`
- `create-agent-session`
- `create-code-scanning-alert`
- `create-discussion`
- `create-issue`
- `create-project`
- `create-project-status-update`
- `create-pull-request`
- `create-pull-request-review-comment`
- `dispatch-workflow`
- `hide-comment`
- `link-sub-issue`
- `push-to-pull-request-branch`
- `remove-labels`
- `reply-to-pull-request-review-comment`
- `resolve-pull-request-review-thread`
- `submit-pull-request-review`
- `unassign-from-user`
- `update-discussion`
- `update-issue`
- `update-project`
- `update-pull-request`
- `update-release`
- `upload-asset`

**If you need to merge a PR**, use `post-steps` with a fresh App token:

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

---

## Permissions & Compilation

### Write Permissions Not Allowed in Frontmatter

The gh-aw compiler rejects write permissions in the `permissions:` block. For example, `permissions: issues: write` fails compilation.

**Reason:** ALL write operations must go through safe-outputs, which use the App token internally. The workflow `permissions:` block is strictly for `GITHUB_TOKEN` scoping and is read-only.

**Fix:** Declare only `read` permissions in frontmatter. Use safe-outputs for all write operations.

**WRONG:**
```yaml
permissions:
  issues: write
  pull-requests: write
```

**CORRECT:**
```yaml
permissions:
  issues: read
  pull-requests: read

safe-outputs:
  add-labels:
    allowed: [bug, feature]
  add-comment:
    discussions: false
```

---

## Workflow Files & Push Restrictions

### .lock.yml Files Exempt from Workflow Push Restriction

Standard `.yml`/`.yaml` files in `.github/workflows/` block GitHub App token branch pushes. The error is:

> "refusing to allow a GitHub App to create or update workflow without `workflows` permission"

This happens because GitHub treats any `.yml`/`.yaml` file in `.github/workflows/` as a workflow definition and requires the `workflows` permission scope for modifications — a scope that GitHub Apps cannot have.

**Key insight:** gh-aw compiled `.lock.yml` files are **EXEMPT** from this restriction. The `.lock.yml` extension is specifically excluded from GitHub's workflow file detection.

**Rule:** NEVER add standard GitHub Actions `.yml`/`.yaml` workflow files alongside gh-aw workflows if using App tokens for safe-outputs (e.g., `create-pull-request`). The App token push will fail because the `.yml` file triggers the workflow push restriction.

**If you need standard GH Actions functionality:**
- Move the logic into a gh-aw workflow as a `post-steps` block
- Or use a completely separate repository for standard workflows
- Or ensure the PR branch never contains `.yml`/`.yaml` files in `.github/workflows/`

---

## Frontmatter Features

### `if` Guard (Conditional Execution)

The frontmatter-level `if:` field prevents workflow runs from starting entirely. This is evaluated **before** any jobs run, saving compute compared to job-level conditionals.

```yaml
if: contains(github.event.issue.labels.*.name, 'status:assessed') && contains(github.event.issue.labels.*.name, 'source:jira')
```

**Use for:** Scoping event-triggered workflows to specific label combinations, issue states, or other event conditions that should prevent the agent from running at all.

### post-steps Feature

`post-steps:` is a valid frontmatter field for defining custom workflow steps that run **after** AI execution completes.

**Characteristics:**
- Runs in the agent job after the Codex/Claude/Copilot agent finishes
- Has access to full job context: `${{ github.event.* }}`, `${{ secrets.* }}`, `${{ vars.* }}`
- Can reference step outputs from earlier steps via `${{ steps.*.outputs.* }}`
- Compiles into GitHub Actions job steps that execute sequentially after the agent step

**Use cases:**
- Merging PRs (no safe-output exists for this — see above)
- Closing issues with custom logic
- Cleanup operations
- Anything requiring write access via a fresh App token

```yaml
post-steps:
  - name: Generate token
    id: app-token
    uses: actions/create-github-app-token@v2
    with:
      app-id: ${{ vars.APP_ID }}
      private-key: ${{ secrets.APP_KEY }}
  - name: Cleanup
    env:
      GH_TOKEN: ${{ steps.app-token.outputs.token }}
    run: |
      echo "Post-agent cleanup"
```

---

## MCP Server Constraints

### JSON Escaping in entrypointArgs

`gh aw compile` does **NOT** escape double quotes (`"`) in `entrypointArgs` values for MCP servers. If a command string contains double quotes, the compiled JSON will be malformed.

**Symptom:** Compilation succeeds but the MCP server fails to start at runtime because the Docker CMD array has broken JSON.

**Fix:** NEVER use double quotes in command strings passed to MCP server configs. Use alternative approaches:
- Use `grep` instead of `jq` if the jq expression would contain quotes
- Use single-quoted strings where the shell allows it
- Use `sed` or `awk` with patterns that avoid quotes

**WRONG:**
```yaml
mcp-servers:
  my-server:
    container: ghcr.io/org/image:latest
    entrypointArgs:
      - "jq '.data[\"key\"]' input.json"
```

**CORRECT:**
```yaml
mcp-servers:
  my-server:
    container: ghcr.io/org/image:latest
    entrypointArgs:
      - "grep key input.json"
```

### MCP Server Stdout Constraint

The MCP gateway reads server stdout as JSON-RPC. **ANY** stdout output before the MCP handshake breaks server initialization.

**Symptom:** MCP server silently fails to initialize. The agent gets no tools from that server. No obvious error in the workflow logs — check `agent-artifacts/mcp-logs/{server}.log`.

**Common causes:**
- `apk add` or `apt-get install` printing progress to stdout
- `pip install` or `npm install` printing to stdout
- `curl` printing download progress
- Python `print()` statements in server startup code
- Shell scripts echoing status messages

**Fix:** Redirect ALL installation/setup output to `/dev/null`:

```yaml
entrypointArgs:
  - "sh"
  - "-c"
  - "apk add --no-cache curl >/dev/null 2>&1 && exec my-server"
```

### `gh aw mcp inspect/list` Limitation

The `gh aw mcp inspect` and `gh aw mcp list` commands do **NOT** follow `imports:` directives. They only see MCP servers declared in the direct frontmatter of the workflow file being inspected.

**Fix:** To verify imported MCP servers, check the compiled `.lock.yml` file instead, which contains the fully resolved configuration.

---

## Trigger Behavior

### pull_request Trigger and Workflow File Resolution

The `pull_request` trigger uses the workflow definition from the **merge commit** (base branch + PR branch merged together). This means:

1. If you push a new `.lock.yml` to `main` and immediately reopen/re-trigger a PR, the merge ref may still use the **old** version of `main`
2. GitHub needs a moment to update the merge ref after pushes to the base branch

**Symptom:** A PR re-run uses an outdated workflow definition even though you just pushed the correct one to `main`.

**Fix:** Wait a few seconds between pushing to `main` and triggering `pull_request` events. If testing workflow changes, close and reopen the PR (or push a new commit to the PR branch) to force a merge ref rebuild.

**Related:** For `push` triggers, the workflow is always from the pushed commit. For `workflow_dispatch`, it's from the branch selected in the UI.
