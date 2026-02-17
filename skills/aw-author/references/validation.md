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
- **Ambiguous event types:** Using both `issue` and `issue_comment` without clear separation can cause double-processing
- **Missing event types:** `on: issue: {}` without `types` defaults to all event types — often too broad

### Safe-Output Violations
- **Referencing undefined operations:** Using `create-pull-request` in prose when it's not in `safe-outputs`
- **Label not in allowlist:** Agent attempts to add a label not in `safe-outputs.add-labels.allowed`
- **Exceeding `max-per-run`:** Attempting to create more artifacts than allowed

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

# Good
safe-outputs:
  create-issue:
    max-per-run: 3
    title-prefix: "[auto]"
    close-older-issues: true
```
**Impact:** Issue spam, notification fatigue, difficult rollback.

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

### Missing Secrets
- **Symptom:** Engine fails to initialize, API calls return 401/403
- **Cause:** `secrets` list in frontmatter references secrets not configured in repository settings
- **Fix:** Add required secrets in Settings > Secrets and variables > Actions

### Network/Firewall Blocks
- **Symptom:** Agent cannot reach external APIs, web-fetch fails
- **Cause:** `network.firewall: strict` blocks domains not in the allowlist
- **Fix:** Add required domains to `network.allowed`

### Lockdown Mode Rejections
- **Symptom:** Agent skips issues from external contributors
- **Cause:** `lockdown: true` (default for public repos) prevents interaction with untrusted content
- **Fix:** Set `lockdown: false` for workflows that must process external input (e.g., issue triage)

### Token Permission Errors
- **Symptom:** 403 errors on GitHub API calls
- **Cause:** `permissions` block doesn't match what the workflow actually needs
- **Fix:** Elevate permissions (e.g., `issues: read` to `issues: write`) and recompile

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
- [ ] `safe-outputs` include `max-per-run` where applicable
- [ ] `tools` only include what's actually needed
- [ ] `secrets` are listed if the workflow uses external APIs
- [ ] `network.allowed` includes all required external domains
- [ ] `lockdown` setting matches the workflow's trust model

### Markdown Body
- [ ] H1 heading clearly states the workflow purpose
- [ ] Instructions use imperative voice
- [ ] Edge cases are explicitly handled
- [ ] Output format is defined
- [ ] No hardcoded values (use `${{ }}` templating)
- [ ] No raw context injection (targeted reads, not bulk)
- [ ] Failure modes are addressed ("if X fails, do Y")

### Integration
- [ ] Required secrets are configured in repository settings
- [ ] Labels referenced in `safe-outputs` exist in the repository
- [ ] `gh aw compile` succeeds without errors
- [ ] Lock file (`.lock.yml`) is reviewed before deployment
- [ ] Test run completed on a non-production branch
