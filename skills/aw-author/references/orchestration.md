# Orchestration Patterns

gh-aw workflows can be orchestrated in various patterns depending on complexity. Each pattern has different tradeoffs for coordination, traceability, and resource usage.

---

## 1. Direct Dispatch

**The simplest pattern.** A single workflow responds to a single event and performs a single task.

**Use when:** The task is self-contained, requires no coordination, and produces one type of output.

### Characteristics
- One trigger → one agent → one output type
- Minimal frontmatter complexity
- Easy to debug and maintain

### Frontmatter Responsibility
- Define the trigger event
- Declare minimal permissions
- Constrain safe-outputs to one operation type

### Example: Issue Labeler

```yaml
on:
  issues:
    types: [opened]
    reaction: eyes
permissions:
  issues: read
tools:
  github:
    toolsets: [issues, labels]
safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement, documentation]
```

---

## 2. Fan-Out (Event-Driven Pipeline)

**Multiple workflows triggered by the same event.** Each handles a different aspect independently.

**Use when:** An event requires multiple independent analyses or actions (e.g., new issue needs triage, assignment, and notification).

### Characteristics
- Same trigger → multiple independent workflows
- No coordination needed between workflows
- Each workflow has its own permissions and safe-outputs
- Workflows run in parallel

### Design Guidelines
- Each workflow should have a single responsibility
- Avoid overlapping safe-outputs (label conflicts)
- Use distinct `title-prefix` values per workflow
- Keep permissions isolated per workflow

### Example: New Issue Fan-Out

**Workflow 1: Triage**
```yaml
on:
  issues:
    types: [opened]
    reaction: eyes
safe-outputs:
  add-labels:
    allowed: [bug, feature, enhancement]
```

**Workflow 2: Assignment**
```yaml
on:
  issues:
    types: [opened]
    reaction: eyes
safe-outputs:
  assign-to-user:
    max: 1
```

**Workflow 3: Welcome**
```yaml
on:
  issues:
    types: [opened]
    reaction: eyes
safe-outputs:
  add-comment:
    max: 1
```

---

## 3. Pipeline (Sequential Dispatch)

**One workflow triggers another.** Results from the first inform the second.

**Use when:** Tasks have dependencies — e.g., analyze first, then act based on analysis.

### Characteristics
- Workflow A completes → dispatches Workflow B
- Pass context via issue comments, labels, or cache-memory
- Clear ordering and dependency chain

### Implementation

```yaml
# Workflow A: Analyzer
safe-outputs:
  add-labels:
    allowed: [needs-fix, needs-review, ok]
  dispatch-workflow:
    workflows: ["auto-fixer.yml"]
    max: 1
```

```yaml
# Workflow B: Auto-Fixer (dispatched)
on:
  workflow_dispatch:
```

### Context Passing Methods
1. **Labels:** Workflow A adds labels → Workflow B reads them
2. **Comments:** Workflow A posts analysis → Workflow B reads comments
3. **Cache memory:** Workflow A writes to cache → Workflow B reads from cache
4. **Issue body:** Workflow A updates issue body → Workflow B parses it

---

## 4. ChatOps (Command-Driven)

**Slash commands in issue/PR comments trigger workflows.** Users type `/command` to invoke.

**Use when:** Human-in-the-loop workflows where users request specific actions.

### Characteristics
- Triggered by `issue_comment` with command parsing
- Human initiates, agent executes
- Great for on-demand tasks: `/triage`, `/plan`, `/security`, `/review`

### Implementation

```yaml
on:
  issue_comment:
    types: [created]
    reaction: eyes
```

### Prose Body for Command Parsing

```markdown
## Command Detection

Check the triggering comment for slash commands:
- `/triage` — Classify and label this issue
- `/plan` — Create an implementation plan
- `/security` — Run security analysis
- `/help` — Show available commands

If the comment doesn't start with a recognized command, ignore it.
```

### Multi-Command Pattern

```yaml
on:
  issue_comment:
    types: [created]
    reaction: eyes
permissions:
  issues: read
  contents: read
tools:
  github:
    toolsets: [issues, labels, repos]
safe-outputs:
  add-labels:
    allowed: [bug, feature, security, planned]
  add-comment:
    hide-older-comments: true
  create-issue:
    title-prefix: "[plan] "
    labels: [planned]
```

---

## 5. Event Chain (Reactive Cascade)

**Workflows react to outputs from other workflows.** Labels or issues created by one workflow trigger another.

**Use when:** Complex multi-stage processing where each stage's output is another's input.

### Characteristics
- Loosely coupled — workflows only share events
- Emergent behavior from simple rules
- Harder to debug (trace across workflows)

### Example

**Workflow 1:** New issue → adds `needs-triage` label
**Workflow 2:** `needs-triage` label added → performs triage → adds `bug` or `feature`
**Workflow 3:** `bug` label added → assigns to bug-fix team

### Design Considerations
- Use unique label prefixes to avoid infinite loops
- Document the chain in a README or architecture diagram
- Monitor for circular triggers
- Set `max` limits to prevent runaway cascades

---

## 6. Scheduled Batch Processing

**Cron-triggered workflows that process accumulated items.**

**Use when:** Periodic reporting, batch cleanup, trend analysis.

### Characteristics
- Time-based trigger, not event-based
- Processes multiple items per run
- Often creates summary issues or reports

### Implementation

```yaml
on:
  schedule: daily

permissions:
  issues: read
  contents: read

safe-outputs:
  create-issue:
    title-prefix: "[daily-report] "
    labels: [report, automated]
    close-older-issues: true
    max: 1
```

### Best Practices
- Use `close-older-issues: true` to prevent report accumulation
- Set meaningful `title-prefix` for searchability
- Use `expires` for auto-cleanup
- Consider `cache-memory` for tracking trends across runs

---

## 7. Meta-Agent (Agent Monitoring Agents)

**A workflow that monitors other workflows' outputs and health.**

**Use when:** You need oversight, quality control, or coordination across multiple agentic workflows.

### Characteristics
- Requires `agentic-workflows:` tool and `actions: read` permission
- Can read logs and audit trails from other workflows
- Can dispatch corrective actions

### Implementation

```yaml
permissions:
  actions: read
  issues: read

tools:
  agentic-workflows:
  github:
    toolsets: [issues, actions]

safe-outputs:
  create-issue:
    title-prefix: "[meta-review] "
    labels: [meta, review]
  dispatch-workflow:
    workflows: ["corrective-action.yml"]
```

---

## Choosing a Pattern

| Scenario | Recommended Pattern |
|----------|-------------------|
| Single-purpose automation | Direct Dispatch |
| Event needs multiple independent actions | Fan-Out |
| Multi-step with dependencies | Pipeline |
| Human-initiated actions | ChatOps |
| Complex multi-stage processing | Event Chain |
| Periodic reporting or cleanup | Scheduled Batch |
| Oversight and coordination | Meta-Agent |

### Complexity vs. Capability Tradeoff

```
Direct Dispatch → Fan-Out → Pipeline → Event Chain → Meta-Agent
(simple)                                              (complex)
```

Start with the simplest pattern that meets requirements. Refactor to more complex patterns only when needed.
