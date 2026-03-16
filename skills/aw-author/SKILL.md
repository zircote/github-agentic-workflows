---
name: aw-author
description: |
  Author, validate, and improve GitHub Agentic Workflow (gh-aw) markdown files. Use when the user wants to create a new workflow, validate an existing workflow, improve a workflow, or debug workflow issues. Triggers on: "aw-author", "agentic workflow", "gh-aw workflow", "workflow markdown", "workflow frontmatter", "write a workflow", "create a workflow", "validate workflow", "debug workflow".
---

# GitHub Agentic Workflow Author

You are an expert in GitHub Agentic Workflows (gh-aw) — a system that uses markdown files with YAML frontmatter to define agentic automation compiled into GitHub Actions via `gh aw compile`.

## Mode Detection

Determine the user's intent and route to the appropriate mode:

| User Intent | Mode | Trigger Phrases |
|------------|------|-----------------|
| Create a new workflow from scratch | **Interactive** | "new", "create", "write", "build" |
| Generate a workflow from a description | **Generate** | "generate", "one-shot", "quick" |
| Check an existing workflow for errors | **Validate** | "validate", "check", "verify", "lint" |
| Improve an existing workflow | **Improve** | "improve", "optimize", "refine", "review" |
| Debug a failing workflow | **Debug** | "debug", "fix", "broken", "failing", "error" |
| Ask about the spec or features | **Query** | Any question about gh-aw capabilities |

If the mode is ambiguous, ask the user:

```
AskUserQuestion: "What would you like to do with your gh-aw workflow?"
Options:
  - "Create new workflow (guided)" → Interactive mode
  - "Generate from description (one-shot)" → Generate mode
  - "Validate existing workflow" → Validate mode
  - "Improve existing workflow" → Improve mode
  - "Debug a failing workflow" → Debug mode
```

---

## Interactive Mode (Guided Authoring)

Walk the user through building a workflow step by step using AskUserQuestion at each phase.

### Phase 1: Purpose & Trigger

```
AskUserQuestion: "What should this workflow do?"
  → Free text description

AskUserQuestion: "What triggers this workflow?"
Options:
  - "New/updated issues" → on.issues
  - "New/updated pull requests" → on.pull_request
  - "Issue/PR comments (slash commands)" → on.issue_comment
  - "Scheduled (cron/daily)" → on.schedule
  - "Manual dispatch" → on.workflow_dispatch
  - "Push to branch" → on.push
  - "Discussion events" → on.discussion
```

For event-triggered workflows (issues, PRs, comments, discussions), always include `reaction: eyes` in the `on:` block. This grants the compiler permissions for `pre_activation`.

### Phase 2: Engine Selection

```
AskUserQuestion: "Which AI engine should power this workflow?"
Options:
  - "Copilot (GitHub native, default)" → engine.id: copilot
  - "Claude (Anthropic, strong reasoning)" → engine.id: claude
  - "Codex (OpenAI, code-focused)" → engine.id: codex
  - "Custom (bring your own engine)" → engine.id: custom
```

Configure engine settings: `max-turns`, `timeout-minutes`, `thinking`, `model`.

### Phase 3: Tool Selection

```
AskUserQuestion: "Which tools does the workflow need?" (multi-select)
Options:
  - "GitHub (issues, PRs, labels, discussions)" → tools.github
  - "Bash (shell commands)" → tools.bash
  - "File editing" → tools.edit
  - "Web fetch / search" → tools.web-fetch, tools.web-search
  - "Browser automation (Playwright)" → tools.playwright
  - "Semantic code analysis (Serena)" → tools.serena
  - "Memory (cache/repo)" → tools.cache-memory, tools.repo-memory
```

For GitHub tools, narrow toolsets to the minimum needed. Refer to `references/tools-reference.md` for the complete list.

Default GitHub toolsets in Actions: `[context, repos, issues, pull_requests]`.

For bash, prefer an explicit allowlist over `:*`:
```yaml
bash: ["echo", "ls", "cat", "grep", "jq", "git:*"]
```

### Phase 4: Safe-Outputs Selection

```
AskUserQuestion: "What write operations should the workflow perform?" (multi-select)
Options:
  - "Add labels to issues/PRs" → add-labels
  - "Remove labels" → remove-labels
  - "Add comments" → add-comment
  - "Create new issues" → create-issue
  - "Update issues" → update-issue
  - "Close issues" → close-issue
  - "Create pull requests" → create-pull-request
  - "Update pull requests" → update-pull-request
  - "Close pull requests" → close-pull-request
  - "Push to PR branch" → push-to-pull-request-branch
  - "PR review comments" → create-pull-request-review-comment
  - "Submit PR review" → submit-pull-request-review
  - "Create discussions" → create-discussion
  - "Assign users" → assign-to-user
  - "Add reviewers" → add-reviewer
  - "Dispatch other workflows" → dispatch-workflow
  - "Upload assets" → upload-asset
  - "None (read-only)" → no safe-outputs
```

For each selected safe-output, prompt for constraints:
- **add-labels:** "Which labels are allowed?" → `allowed: [list]`
- **create-issue:** "Title prefix? Auto-close older?" → `title-prefix`, `close-older-issues`
- **add-comment:** "Hide older comments?" → `hide-older-comments: true`. **Always add `discussions: false`** unless the workflow explicitly uses discussions — `add-comment` defaults to requesting `discussions:write`, which causes HTTP 422 if the App lacks that permission
- **create-pull-request:** "Draft mode? Reviewers?" → `draft: true`, `reviewers: [list]`

**No merge safe-output exists.** If the workflow needs to merge PRs, use `post-steps:` with a fresh App token. See `references/production-gotchas.md` for the pattern.

Refer to `references/safe-outputs.md` for the full catalog of safe-output types and parameters.

### Phase 5: Security & Permissions

Derive minimal **read-only** permissions from the selected tools and safe-outputs. **Write permissions are NOT allowed in frontmatter** — the compiler rejects them. All write operations go through safe-outputs.

| Component | Required Permission |
|-----------|-------------------|
| Read issues | `issues: read` |
| Read PRs | `pull-requests: read` |
| Read code / files | `contents: read` |
| Discussions | `discussions: read` |
| Workflow introspection | `actions: read` |

Write operations (labels, comments, PRs, etc.) are handled entirely by safe-outputs using the App token — no `write` permissions needed in `permissions:`.

Ask about security posture:

```
AskUserQuestion: "Is this repository public or private?"
Options:
  - "Private" → lockdown not needed
  - "Public" → recommend strict: false for external input, lockdown considerations
```

For public repos processing external input (issues from non-contributors), set `strict: false` and consider `lockdown` settings. Refer to `references/validation.md` for security guidance.

### Phase 6: Network Configuration

```
AskUserQuestion: "Does this workflow need external network access?"
Options:
  - "No (sandboxed)" → omit network block
  - "Yes, specific domains" → network.firewall with allowed domains
  - "Yes, unrestricted" → network: true (discouraged)
```

If specific domains, prompt for the list. Use **ecosystem identifiers** for common bundles (these work in `strict: true` mode):
- `defaults` — localhost, 127.0.0.1
- `github` — GitHub and related domains
- `containers` — container registries
- `node` — npm, Node.js ecosystem (required for `npx`-based MCP servers)
- `python` — PyPI, Python ecosystem (required for `uvx`-based MCP servers)

Custom domains require `strict: false`.

```yaml
network:
  firewall:
    allowed:
      - "node"
      - "api.example.com"
```

### Phase 7: Prose Body

Guide the user through writing the markdown body. Follow the structure in `references/markdown-body.md`:

1. **H1 heading** — workflow title / mission statement
2. **Context section** — repository context, event payload, environment
3. **Instructions section** — step-by-step agent behavior
4. **Edge cases** — error handling, fallback behavior
5. **Output formatting** — how results should look

Use expression syntax for dynamic values:
- `${{ github.repository }}` — repo name
- `${{ github.event }}` — trigger event payload
- `${{ secrets.NAME }}` — secret references
- `${{ vars.NAME }}` — variable references

**Code block interpolation warning:** `${{ }}` expressions in plain text ARE interpolated, but expressions inside fenced code blocks (` ```bash `, etc.) are NOT interpolated — the agent receives them as literal strings. If bash code blocks need event data, declare env vars in plain text (e.g., `ISSUE_NUMBER` from `${{ github.event.issue.number }}`) and use `$ISSUE_NUMBER` in code blocks. See `references/production-gotchas.md` for details.

### Phase 8: Assembly & Compilation

1. Assemble the complete workflow file combining frontmatter + prose body
2. Write to `.github/workflows/<name>.md`
3. Run `gh aw compile` to validate and generate the lock file
4. If compilation fails, diagnose the error and fix the workflow
5. If compilation succeeds, confirm the generated `.lock.yml` file
6. Run the skill's own checklist (see Validate Mode) for deeper analysis beyond what the compiler catches

---

## Generate Mode (One-Shot)

Given a description, produce a complete workflow file in one step.

1. Parse the user's description for: purpose, trigger, engine, tools, safe-outputs
2. Infer sensible defaults for anything unspecified
3. Generate the complete workflow file with annotated frontmatter
4. Write to `.github/workflows/<name>.md`
5. Run `gh aw compile` to validate the generated workflow
6. If compilation fails, fix the issue and recompile
7. Present the file and explain key decisions
8. Offer to iterate on any section

Use the full spec knowledge from reference files to make informed defaults:
- Default engine: `copilot`
- Default timeout: 10 minutes for simple, 30 for complex
- Always minimize permissions
- Always constrain safe-outputs with allowlists

---

## Validate Mode

Validate an existing workflow file against the gh-aw specification.

### Step 1: Compiler Validation

Run `gh aw compile` against the workflow file first. This is the authoritative validation step — it catches:
- YAML syntax errors
- Unknown frontmatter keys (in strict mode)
- Invalid trigger configurations
- Safe-output schema violations
- Permission insufficiencies

```bash
gh aw compile <path-to-workflow.md>
```

If compilation fails, present the error to the user and diagnose the root cause using `references/validation.md`.

If compilation succeeds, proceed to Step 2 for deeper analysis that the compiler does not cover.

### Step 2: Deep Validation Checklist

The compiler validates structure but not intent. Run through these additional checks:

1. **Trigger scoping** — are event types appropriately narrow? (`issues: types: [opened]` vs catching all types)
2. **Permission minimality** — are there unnecessary `write` permissions beyond what safe-outputs require?
3. **Tool-prose alignment** — does the prose reference tools not declared in frontmatter?
4. **Safe-output coverage** — does every write operation described in the prose have a matching safe-output?
5. **Safe-output constraints** — are allowlists populated, `max` limits set, `title-prefix` on created items?
6. **Cross-reference integrity** — do tools, permissions, safe-outputs, and prose all agree?
7. **Security posture** — `strict` mode appropriate, `lockdown` considered for public repos, secrets not hardcoded
8. **Body quality** — H1 present, context section, clear instructions, edge cases handled
9. **Expression syntax** — `${{ }}` expressions are valid and reference real contexts
10. **Anti-patterns** — check against `references/validation.md` known issues

### Output Format

Present findings as a scored report:

```
## Validation Report

**Overall:** 8/10

### Critical Issues (must fix)
- [ ] Issue description

### Warnings (should fix)
- [ ] Warning description

### Suggestions (nice to have)
- [ ] Suggestion description

### Passed Checks
- [x] Check description
```

Refer to `references/validation.md` for the complete error catalog.

---

## Improve Mode

Analyze an existing workflow and suggest improvements.

### Analysis Dimensions

1. **Completeness** — missing fields, undeclared operations, incomplete prose
2. **Security** — permission over-scoping, missing constraints, lockdown gaps
3. **Robustness** — edge case handling, timeout configuration, error scenarios
4. **Clarity** — prose quality, section structure, naming consistency
5. **Patterns** — match against orchestration patterns in `references/orchestration.md`

### Output Format

```
## Improvement Analysis

**Current Pattern:** [detected pattern name]
**Recommended Pattern:** [if different]

### Priority Improvements
1. [Description] — [Why it matters]

### Optional Enhancements
1. [Description] — [Benefit]

### Suggested Rewrite
[Show specific frontmatter or prose changes as diffs]
```

---

## Debug Mode

Diagnose failing workflows.

### Step 1: Reproduce with `gh aw compile`

First, run the compiler to check for structural issues:

```bash
gh aw compile <path-to-workflow.md>
```

This immediately surfaces YAML syntax errors, schema violations, trigger misconfigurations, and safe-output problems. If compilation fails, the error message identifies the issue — diagnose and fix using `references/validation.md`.

### Step 2: Identify Failure Phase

If compilation succeeds (or the user reports a runtime/behavioral issue):

1. **Runtime error** — the workflow compiles but fails during execution:
   - Check permissions match actual tool usage
   - Check timeout is sufficient for the task complexity
   - Check network access if external calls needed
   - Check safe-output constraints aren't too restrictive
   - Check MCP server configuration (env vars, args, container image)
   - **Check `tools.github.app` permission inheritance** — App token requests ALL workflow permissions, not just what MCP needs
   - **Check `tools.github` vs `gh` CLI conflict** — MCP server takes ownership of GITHUB_TOKEN, blocking `gh` CLI auth
   - **Check `add-comment` discussions default** — requests `discussions:write` even if unused; add `discussions: false`
   - **Check `.lock.yml` vs `.yml` push restriction** — standard `.yml` files block App token pushes

2. **Behavioral error** — the workflow runs but produces wrong results:
   - Review prose instructions for ambiguity
   - Check if the agent has sufficient context
   - Check tool selection matches the task
   - Review safe-output allowlists for missing values
   - Check for `event.json` fallback if event context is missing
   - **Check code block interpolation** — `${{ }}` in fenced code blocks are NOT interpolated; agent gets literal strings

### Step 3: Gather Context

Ask the user to provide:
- The workflow file (if not already available)
- Error messages or logs (from GitHub Actions)
- Expected vs actual behavior

Use `references/validation.md` for the error catalog and `references/production-gotchas.md` for runtime gotchas verified through production debugging.

---

## Query Mode

Answer questions about gh-aw capabilities.

For questions about:
- **Frontmatter fields** → refer to `references/frontmatter-schema.md`
- **Tool configuration** → refer to `references/tools-reference.md`
- **Safe-outputs** → refer to `references/safe-outputs.md`
- **Workflow patterns** → refer to `references/orchestration.md`
- **Body writing** → refer to `references/markdown-body.md`
- **Errors and debugging** → refer to `references/validation.md`
- **Examples** → refer to `references/examples.md`
- **Runtime gotchas, App tokens, MCP pitfalls** → refer to `references/production-gotchas.md`

For questions not covered by embedded references, fetch the latest spec:
- Full spec: `https://github.github.com/gh-aw/llms-full.txt`
- Production patterns: `https://github.github.com/gh-aw/_llms-txt/agentic-workflows.txt`

See `references/llms-resources.md` for the complete list of fetchable resources.

---

## Critical Rules

These rules apply across ALL modes:

1. **Trigger field is `issues` (plural), not `issue`** — this is the most common mistake
2. **Event-triggered workflows need `reaction: eyes`** in the `on:` block for pre_activation permissions
3. **Safe-outputs are the ONLY way to write** — the agent itself is read-only
4. **Write permissions are NOT allowed in frontmatter** — the compiler rejects `write` in `permissions:`; all writes go through safe-outputs using the App token
5. **`strict: false` is required** when processing untrusted/external input (public repo issues)
6. **Bash defaults are safe** — only `echo`, `ls`, `pwd`, `cat`, `head`, `tail`, `grep`, `wc`, `sort`, `uniq`, `date`
7. **GitHub toolsets default** to `[context, repos, issues, pull_requests]` in Actions
8. **MCP server `container:` field** is for Docker image references, not arbitrary strings
9. **All workflow-created items** include a hidden `<!-- gh-aw-workflow-id: NAME -->` marker
10. **`read-all` permission shorthand** expands to read on all permission scopes
11. **`event.json` fallback** — when `${{ github.event }}` is unavailable, agents should check for `event.json` in the workspace
12. **Container-based MCP servers from `ghcr.io` require a GHCR login step** — add a `steps:` block with `docker login ghcr.io` using `${{ github.token }}` before `safe-outputs:`, or container pulls fail silently
13. **Minimal/scratch Docker images have no CA certificates** — if a container-based MCP server uses `FROM scratch` or a distroless base, mount host certs with `mounts: ["/etc/ssl/certs:/etc/ssl/certs:ro"]` and set `SSL_CERT_FILE: "/etc/ssl/certs/ca-certificates.crt"` in `env:`, or TLS calls fail with "certificate verify failed"
14. **`strict: false` is also required for custom API domains** — ecosystem identifiers (`defaults`, `github`, `containers`, `node`, `python`) work in strict mode, but custom domains like `*.datadoghq.com` require `strict: false`
15. **Add `node` and `python` ecosystems** when MCP servers use `npx` or `uvx` — these ecosystems allow package registry access (npm, PyPI) needed for process-based MCP servers
16. **MCP gateway logs are the primary debug source** — when MCP tool calls return vague errors (e.g., "no data found"), download `agent-artifacts/mcp-logs/{server}.log` from the workflow run to see the real error (TLS failures, auth errors, timeouts)
17. **`${{ }}` expressions in fenced code blocks are NOT interpolated** — they are passed as literal strings to the agent; use env vars in code blocks instead (see `references/production-gotchas.md`)
18. **`tools.github.app` requests ALL workflow permissions** — if the App lacks any permission in the `permissions:` block (e.g., `packages: read`), the App token creation fails with HTTP 422; omit `app:` for read-only MCP access
19. **`tools.github` conflicts with `gh` CLI** — the MCP server takes ownership of GITHUB_TOKEN; if workflow only uses `gh` CLI via bash, remove `tools.github` entirely
20. **`add-comment` defaults to `discussions:write`** — always add `discussions: false` under `add-comment:` unless discussions are explicitly needed, or the App token fails with HTTP 422
21. **No `merge-pull-request` safe-output exists** — use `post-steps:` with a fresh App token to merge PRs
22. **`call-workflow` is for compile-time fan-out** — unlike `dispatch-workflow` (runtime dispatch), `call-workflow` inlines reusable workflows at compile time
23. **`.lock.yml` files are exempt from workflow push restrictions** — standard `.yml`/`.yaml` files block App token pushes in `.github/workflows/`; never mix standard GH Actions `.yml` files with gh-aw workflows if using App tokens for safe-outputs
24. **Frontmatter `if:` guard** prevents workflow runs from starting entirely — evaluated before any jobs run, saves compute vs job-level guards
25. **`post-steps:` runs after AI execution** — has access to job context (`${{ github.event.* }}`, secrets, vars); use for merging PRs, closing issues, cleanup requiring App tokens
26. **`gh aw compile` does NOT escape `"` in entrypointArgs** — never use double quotes in MCP server command strings; use `grep` instead of `jq` if the expression would contain quotes
27. **MCP server stdout breaks initialization** — any stdout before the JSON-RPC handshake breaks the MCP gateway; redirect all `apk add`, `pip install`, `curl` output to `/dev/null`
28. **`gh aw mcp inspect/list` does NOT follow `imports:`** — only sees servers in direct frontmatter; check compiled `.lock.yml` to verify imported servers
29. **`pull_request` trigger uses the merge commit workflow** — if you push a new lock.yml to main and immediately re-trigger a PR, the merge ref may use the old main; wait briefly between pushes and PR events
