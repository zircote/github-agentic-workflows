---
description: Author, validate, or improve GitHub Agentic Workflow (gh-aw) markdown files
argument-hint: "<mode: new|generate|validate|improve|debug> or topic query"
---

# /aw-author

Entry point for GitHub Agentic Workflow authoring assistance.

## Usage

```
/aw-author                    → Auto-detect mode or prompt for selection
/aw-author new                → Interactive guided workflow creation
/aw-author generate           → One-shot workflow generation from description
/aw-author validate           → Validate an existing workflow file
/aw-author improve            → Analyze and suggest improvements
/aw-author debug              → Debug a failing workflow
/aw-author <question>         → Answer questions about gh-aw
```

## Examples

```
/aw-author new
/aw-author generate an issue triage workflow for a public Go repo
/aw-author validate ./workflows/triage.md
/aw-author improve ./workflows/daily-report.md
/aw-author debug "workflow times out after 5 minutes"
/aw-author what engines are available?
/aw-author how do safe-outputs work?
/aw-author show me a ChatOps workflow example
```

## Workflow

Load the **aw-author** skill to handle the request. The skill will:

1. Parse the argument to determine the mode (new, generate, validate, improve, debug, or query)
2. If no argument provided, prompt the user to select a mode
3. Route to the appropriate workflow within the skill
4. Use progressive disclosure — load reference files only as needed

For deep workflow analysis (multi-file review, cross-workflow dependencies, security audit), delegate to the **aw-analyst** agent.
