# Orchestration Patterns

gh-aw workflows can be orchestrated in various patterns depending on complexity. Each pattern has different tradeoffs for coordination, traceability, and resource usage.

## 1. Direct Dispatch

**The simplest pattern.** A single workflow responds to a single event and performs a single task.

**Use when:** The task is self-contained, requires no coordination, and produces one type of output.

### Frontmatter Responsibility
- Define the trigger event
- Declare minimal permissions
- Constrain safe-outputs to one operation type

### Prose Responsibility
- Complete instruction set for the single task
- Edge case handling
- Output formatting

### Example: Issue Labeler
```yaml
on:
  issues:
    types: [opened]
permissions:
  issues: read
tools:
  github:
    toolsets: [issues, labels]
safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement]
  add-comment: {}
```

```markdown
# Label New Issues

Read the issue title and body. Classify as bug, feature, or enhancement.
Add the appropriate label. Comment with brief reasoning.
```

---

## 2. Multi-Phase / TaskOps

**Sequential multi-agent collaboration.** Multiple workflows operate in phases, each building on the previous phase's output.

**Use when:** The task is too complex for one agent, requires different capabilities per phase, or benefits from human review between phases.

### Phase Architecture

```
Phase 1: Discovery    -> Creates discussions/issues with analysis
Phase 2: Planning     -> Extracts tasks from Phase 1 output into actionable issues
Phase 3: Execution    -> Coding agents address individual issues, create PRs
Phase 4: Attribution  -> Causal chains track provenance from discussion -> issue -> PR
```

### Frontmatter Responsibility (per phase)
- Each phase is a separate workflow file
- Phase 2+ triggers on output of previous phase (e.g., `discussion.commented`, `issue.opened`)
- Permissions escalate per phase (discovery=read, execution=write)

### Prose Responsibility (per phase)
- Phase 1: Analysis and structured output generation
- Phase 2: Parsing previous output, decomposing into sub-tasks
- Phase 3: Implementation instructions referencing the originating issue
- Phase 4: Link attribution (referencing upstream discussions/issues)

### Example: Code Review Pipeline

**Phase 1 -- Analysis (discovery.md):**
```yaml
on:
  schedule:
    - cron: "0 2 * * *"
permissions:
  contents: read
  discussions: read
tools:
  github:
    toolsets: [issues, discussions]
  serena: null
safe-outputs:
  create-discussion:
    category: "Code Review"
```

**Phase 2 -- Task Extraction (plan-command.md):**
```yaml
on:
  issue_comment:
    types: [created]
  # Triggers on /plan command
permissions:
  issues: read
  discussions: read
safe-outputs:
  create-issue:
    title-prefix: "[refactor]"
    labels: [automated, refactor]
```

---

## 3. Causal Chains

**Explicit traceability through GitHub linking.** Every downstream artifact references its upstream source.

**Use when:** Auditability matters, you need to trace why a PR was created, or multiple teams need visibility into the automation pipeline.

### Chain Structure

```
Discussion #123 (analysis)
  -> Comment: /plan
    -> Issue #456 (task)
      -> PR #789 (implementation)
        -> References: "Fixes #456, originated from Discussion #123"
```

### Frontmatter Responsibility
- Each workflow declares which GitHub objects it reads from and writes to
- Safe-outputs include linking fields (labels, title-prefixes) for traceability

### Prose Responsibility
- Explicit instructions to include references: "In the PR body, include `Originated from Discussion #X`"
- Instructions to read upstream context: "Read the parent issue body for requirements"
- Attribution patterns: "When creating an issue from a discussion, reference the discussion number"

### Best Practices
- Use consistent title prefixes (`[refactor]`, `[perf]`, `[audit]`) for filtering
- Always close upstream issues when downstream work merges
- Include the full chain in PR descriptions for reviewers

---

## 4. Conditional Execution

**Dynamic routing based on event context.** A single workflow entry point routes to different behaviors based on conditions.

**Use when:** The same trigger event requires different handling depending on content, labels, or author.

### Frontmatter Responsibility
- Single trigger definition covering all cases
- Tools and permissions for all possible paths (union of requirements)
- Safe-outputs covering all possible output types

### Prose Responsibility
- Conditional logic: "If the issue has label X, do A. If label Y, do B."
- Fallback behavior: "If none of the above conditions match, add `needs-triage` label"
- Guard clauses: "If the author is a bot, skip processing entirely"

### Example
```markdown
# Issue Router

Read the incoming issue.

## Routing Rules

**If** the issue title starts with `[bug]` or has the `bug` label:
- Run the bug triage checklist
- Check for reproduction steps
- Assign severity label (critical, high, medium, low)

**If** the issue title starts with `[feature]` or has the `enhancement` label:
- Summarize the feature request
- Check for duplicates among open issues
- Add `feature-request` label

**If** the issue is from a first-time contributor:
- Welcome them with a friendly comment
- Add `first-contribution` label

**Otherwise:**
- Add `needs-triage` label
- Comment asking for clarification
```

---

## 5. Recursive Scheduling

**Self-perpetuating workflows with state.** A workflow runs on a schedule, maintains state across runs, and adjusts its behavior based on accumulated history.

**Use when:** Long-running improvement campaigns, iterative analysis, or progressive codebase audits that need to cover different areas over time.

### Frontmatter Responsibility
- Schedule trigger (cron or natural language)
- `cache-memory` or `repo-memory` tool enabled for state persistence
- Rate limiting to control resource usage

### Prose Responsibility
- State reading: "Check cache-memory for `last-processed` to determine where to resume"
- Coverage rotation: "Use a selection algorithm: 60% recent, 30% rotation, 10% revisit"
- Termination conditions: "If all items have been processed in the last 7 days, skip this run"
- State writing: "Update `last-processed` with the current batch"

### Example: Progressive Codebase Audit
```yaml
on:
  schedule:
    - cron: "0 9 * * 1-5"
tools:
  cache-memory: null
  github:
    toolsets: [issues]
safe-outputs:
  create-issue:
    title-prefix: "[audit]"
    close-older-issues: true
```

```markdown
# Daily Code Audit

## State Management
Read `audit-coverage` from cache-memory. This tracks which packages have been audited and when.

## Selection Algorithm
Choose the next package to audit:
- 60% chance: pick from packages modified in the last 7 days (prioritize recent changes)
- 30% chance: pick the package with the oldest audit date (ensure coverage rotation)
- 10% chance: re-audit a previously audited package (verify consistency)

## Audit Process
1. List all Go files in the selected package
2. Check for: missing error handling, unused exports, naming violations, missing tests
3. Create one issue with findings, or skip if no issues found

## State Update
Update `audit-coverage` with the package name and today's date.
```

---

## Choosing the Right Pattern

| Factor | Direct Dispatch | Multi-Phase | Causal Chains | Conditional | Recursive |
|--------|----------------|-------------|---------------|-------------|-----------|
| Complexity | Low | High | Medium | Medium | Medium |
| Traceability | Low | High | Very High | Low | Medium |
| Coordination | None | Multi-agent | Multi-agent | Single agent | Single agent |
| State | Stateless | Per-phase | Linked | Stateless | Stateful |
| Best for | Simple tasks | Complex pipelines | Auditable flows | Event routing | Long campaigns |
