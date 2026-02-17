# Markdown Body Reference

The markdown body of a gh-aw workflow file is the agent's "intent layer" — natural language instructions that guide the AI engine's behavior. While frontmatter handles configuration, the body defines what the agent should actually do.

---

## Document Structure

### Heading Hierarchy

```markdown
# Workflow Title                  ← H1: Primary purpose/identity (one only)
## Context                        ← H2: Major sections
### Specific Area                 ← H3: Sub-sections within a phase
```

- **H1 (one only):** The workflow's name and primary purpose — the agent's "mission statement"
- **H2:** Major phases or sections of the workflow
- **H3+:** Detail breakdowns within sections

---

## Standard Sections

Most effective workflows follow this section pattern:

### 1. Context Section

Provide the agent with environmental awareness.

```markdown
## Context

You are operating on the ${{ github.repository }} repository.
This workflow runs when new issues are opened.
The repository uses TypeScript with Jest for testing.
The team follows conventional commits.
```

**Include:**
- Repository identity and language/stack
- What event triggered this run
- Team conventions and standards
- Any domain-specific knowledge the agent needs

### 2. Instructions Section

Step-by-step guidance for the agent's primary task.

```markdown
## Instructions

1. Read the issue title and body
2. Analyze the content to determine category:
   - Bug report → add `bug` label
   - Feature request → add `feature` label
   - Question → add `question` label
   - Documentation issue → add `documentation` label
3. If the issue references specific files, check if those files exist
4. Post a comment summarizing your classification and reasoning
```

**Guidelines:**
- Use numbered lists for sequential steps
- Use bullet lists for options/alternatives
- Be specific — "add the `bug` label" not "label appropriately"
- Reference safe-outputs by the exact labels/operations declared in frontmatter

### 3. Edge Cases Section

Handle unusual or error scenarios.

```markdown
## Edge Cases

- If the issue body is empty, classify based on title only and note the missing body in your comment
- If the issue appears to be spam (no meaningful content, just links), add the `spam` label and do not comment
- If the issue references multiple categories, choose the primary one and mention the secondary in the comment
- If the issue is written in a non-English language, still attempt classification and respond in English
```

**Common edge cases to address:**
- Empty or minimal input
- Malformed or unexpected content
- Multiple valid classifications
- Missing context or references
- Rate limit or timeout scenarios

### 4. Output Formatting Section

Define how results should be presented.

```markdown
## Output Format

When commenting, use this structure:

### Classification: {category}

**Reasoning:** {1-2 sentence explanation}

**Labels applied:** {list of labels}

{Any additional context or suggestions}
```

---

## Expression Syntax

gh-aw supports GitHub Actions expression syntax for dynamic values.

### Available Contexts

| Expression | Value |
|-----------|-------|
| `${{ github.repository }}` | `owner/repo` |
| `${{ github.repository_owner }}` | `owner` |
| `${{ github.event }}` | Full event payload (JSON) |
| `${{ github.event.issue.title }}` | Issue title |
| `${{ github.event.issue.body }}` | Issue body |
| `${{ github.event.issue.number }}` | Issue number |
| `${{ github.event.issue.user.login }}` | Issue author |
| `${{ github.event.pull_request.title }}` | PR title |
| `${{ github.event.pull_request.body }}` | PR body |
| `${{ github.event.comment.body }}` | Comment text |
| `${{ github.actor }}` | User who triggered the event |
| `${{ github.ref }}` | Branch/tag reference |
| `${{ github.sha }}` | Commit SHA |
| `${{ secrets.NAME }}` | Secret value |
| `${{ vars.NAME }}` | Variable value |

### Usage in Prose

```markdown
## Context

You are analyzing issue #${{ github.event.issue.number }} in ${{ github.repository }}.
The issue was created by @${{ github.event.issue.user.login }}.
```

### `event.json` Fallback

When `${{ github.event }}` is unavailable or incomplete, agents should check for an `event.json` file in the workspace root as a fallback source for event context.

---

## Writing Style Guidelines

### Be Imperative

Write instructions as commands, not descriptions.

**Good:** "Read the issue body and extract error messages."
**Bad:** "The agent should read the issue body and might want to extract error messages."

### Be Specific

Reference exact values from frontmatter.

**Good:** "Add one of these labels: `bug`, `feature`, `enhancement`, `documentation`."
**Bad:** "Add appropriate labels."

### Be Structured

Use consistent formatting for repeatable patterns.

**Good:**
```markdown
For each file changed in the PR:
1. Check if it has tests
2. If no tests exist, note it in the review
3. If tests exist, verify they cover the changed code paths
```

**Bad:** "Look at the files and check if there are tests and stuff."

### Align with Frontmatter

Every tool and safe-output referenced in the prose must exist in the frontmatter.

**If prose says:** "Search the codebase for related files"
**Frontmatter must have:** `tools: github: toolsets: [repos]` (or equivalent)

**If prose says:** "Add the `security` label"
**Frontmatter must have:** `safe-outputs: add-labels: allowed: [..., security]`

---

## Advanced Patterns

### Conditional Logic in Prose

```markdown
## Decision Tree

Based on your analysis:

**If the issue is a bug report:**
1. Add the `bug` label
2. Check if similar issues exist
3. Comment with classification and any related issues

**If the issue is a feature request:**
1. Add the `feature` label
2. Comment with classification and feasibility assessment

**If the issue is unclear:**
1. Add the `needs-info` label
2. Comment asking for clarification
```

### Multi-Phase Workflows

```markdown
## Phase 1: Analysis

Read and understand the issue content.

## Phase 2: Classification

Based on your analysis, determine the category.

## Phase 3: Action

Apply labels and post your comment.

## Phase 4: Verification

Confirm that your actions were applied correctly.
```

### Template Outputs

```markdown
## Comment Template

Use this exact format for your comment:

---
**Automated Triage Report**

| Field | Value |
|-------|-------|
| Category | {category} |
| Priority | {priority} |
| Confidence | {high/medium/low} |

**Summary:** {1-2 sentence description}

**Next steps:** {recommended action}
---
```

---

## Common Mistakes

1. **Referencing tools not in frontmatter** — if you tell the agent to use bash, `bash:` must be in `tools:`
2. **Referencing labels not in allowlist** — every label the prose mentions must be in `safe-outputs.add-labels.allowed`
3. **Missing context section** — agents perform poorly without repository and event context
4. **Vague instructions** — "handle it appropriately" gives no guidance
5. **No edge case handling** — agents get confused by unexpected input without guidance
6. **Inconsistent formatting** — use consistent heading levels and list styles throughout
