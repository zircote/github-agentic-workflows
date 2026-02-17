# Markdown Body Reference

The markdown body of a gh-aw workflow file is the agent's "intent layer" — natural language instructions that guide the AI engine's behavior. While frontmatter handles configuration, the body defines what the agent should actually do.

## Document Structure

### Heading Hierarchy

```markdown
# Workflow Title                  <- H1: Primary purpose/identity
## Context                        <- H2: Major sections
### Specific Area                 <- H3: Sub-sections within a phase
```

- **H1 (one only):** The workflow's name and primary purpose. This is the agent's "mission statement."
- **H2:** Major phases or sections of the workflow
- **H3+:** Detail breakdowns within sections

### Standard Sections

Most effective workflows follow this section pattern:

#### Context Section
```markdown
## Context

You are operating on the ${{ github.repository }} repository.
This workflow runs when new issues are opened.
The repository is a Go project using standard library conventions.
```
Sets the stage: what repo, what event triggered this, relevant constraints.

#### Steps Section
```markdown
## Steps

1. Read the issue title and body
2. Analyze the content against the codebase
3. Determine the appropriate label
4. Add the label and post an explanatory comment
```
Ordered instructions the agent should follow. Use numbered lists for sequential steps, bullets for unordered tasks.

#### Rules Section
```markdown
## Rules

- Never modify code directly; only create issues or comments
- Skip issues created by bots (check the `bots` list)
- If unsure about a label, use `needs-triage` instead of guessing
- Maximum 3 labels per issue
```
Hard constraints and guardrails. These are non-negotiable behavioral boundaries.

#### Output Format Section
```markdown
## Output Format

When commenting on an issue, use this structure:

**Label:** `{label}`
**Confidence:** {high|medium|low}
**Reasoning:** {brief explanation}
```
Defines the structure of any text the agent produces.

---

## Templating Syntax

### Variable Substitution

Use `${{ }}` for GitHub context variables:

```markdown
Analyze the repository ${{ github.repository }}.
The issue was opened by ${{ github.actor }}.
Check the branch ${{ github.head_ref }}.
```

**Available contexts:**
| Context | Fields | Description |
|---------|--------|-------------|
| `github` | `repository`, `actor`, `event_name`, `sha`, `ref`, `head_ref`, `base_ref`, `run_id` | GitHub event context |
| `secrets` | Any configured secret name | Repository secrets |
| `env` | Any configured env var | Environment variables |
| `inputs` | Workflow dispatch inputs | Manual trigger inputs |

### Conditional Blocks

```markdown
{{#if github.event.issue.labels}}
The issue already has labels: {{github.event.issue.labels}}.
Only add labels that aren't already present.
{{/if}}

{{#if env.VERBOSE}}
Include detailed reasoning in your comment.
{{/if}}
```

### Runtime Imports

```markdown
{{#runtime-import ./shared/code-review-rules.md}}
```

Imports content from another file at runtime, enabling shared instruction sets across workflows.

---

## Writing Effective Instructions

### Be Specific, Not Vague

**Bad:**
```markdown
Look at the issue and handle it appropriately.
```

**Good:**
```markdown
Read the issue title and body. Classify it as one of: bug, feature, question, documentation.
If it's a bug, check for reproduction steps. If missing, comment asking for them.
If it's a feature, add the `enhancement` label and summarize the request in a comment.
```

### Use Imperative Voice

Write instructions as commands:
- "Analyze the pull request diff" (not "The agent should analyze...")
- "Create an issue with the findings" (not "An issue could be created...")
- "Skip files matching `*.test.*`" (not "Test files might be skipped")

### Define Edge Cases

```markdown
## Edge Cases

- If the issue body is empty, comment asking for more details and add `needs-info` label
- If the issue is written in a language other than English, still attempt classification but add `needs-translation` label
- If the repository has no labels configured, create the required labels first
```

### Reference Frontmatter Constraints

```markdown
Use only the labels listed in `safe-outputs.add-labels.allowed`.
Respect the `rate-limit` settings — do not process more than `max-runs-per-hour` issues.
```

The prose body should be aware of and reference the frontmatter constraints it operates under.

---

## Common Patterns

### Codebase Analysis Pattern
```markdown
## Analysis

1. List all files matching `src/**/*.go`
2. For each file, check if it follows the naming convention: `snake_case.go`
3. Collect violations into a summary
4. Create a single issue listing all violations, grouped by directory
```

### Multi-Step Review Pattern
```markdown
## Review Process

### Phase 1: Structural Check
Verify the PR has:
- [ ] Description with context
- [ ] Tests for new functionality
- [ ] No unrelated changes

### Phase 2: Code Quality
For each changed file:
- Check for error handling patterns
- Verify naming conventions
- Look for potential performance issues

### Phase 3: Report
Post a review comment summarizing findings from both phases.
```

### Stateful Workflow Pattern
```markdown
## State Management

Check cache-memory for `last-run-modules` key.
If present, exclude those modules from this run to ensure coverage rotation.
After processing, update `last-run-modules` with the current batch.
```

---

## Anti-Patterns to Avoid

1. **Wall of text without structure:** Break instructions into clear sections with headings
2. **Ambiguous pronouns:** Say "the issue" not "it" when multiple objects are in context
3. **Missing failure modes:** Always specify what to do when something unexpected happens
4. **Hardcoded values:** Use `${{ }}` variables instead of hardcoding repo names, branch names, etc.
5. **No output specification:** Always define what the agent should produce (comment, issue, PR, label)
