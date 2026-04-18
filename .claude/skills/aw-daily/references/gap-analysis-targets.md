# Gap Analysis Targets

Reference files subject to automated gap analysis. Maps research domains and GitHub activity to specific file sections.

## Reference File Inventory

| File | Path | Primary Domains | Key Sections to Watch |
|------|------|----------------|----------------------|
| Frontmatter Schema | `skills/aw-author/references/frontmatter-schema.md` | gh-aw | New fields, deprecated fields, type changes, trigger updates |
| Safe-Outputs | `skills/aw-author/references/safe-outputs.md` | gh-aw | New safe-output types, parameter changes, constraint options |
| Tools Reference | `skills/aw-author/references/tools-reference.md` | gh-aw, mcp-server | New tools, toolset changes, deprecations |
| Production Gotchas | `skills/aw-author/references/production-gotchas.md` | gh-aw, actions | New gotchas, resolved gotchas, workaround updates |
| Orchestration | `skills/aw-author/references/orchestration.md` | gh-aw, community | New patterns, engine model updates |
| Examples | `skills/aw-author/references/examples.md` | gh-aw | Examples using deprecated patterns, missing new patterns |
| Validation | `skills/aw-author/references/validation.md` | gh-aw | New error types, resolved issues, checklist gaps |
| Markdown Body | `skills/aw-author/references/markdown-body.md` | gh-aw | Expression context changes, instruction file updates |
| LLMs Resources | `skills/aw-author/references/llms-resources.md` | gh-aw | URL changes, new fetchable resources |
| Architecture | `.claude/skills/gh-aw-report/references/gh-aw-architecture.md` | all | Version numbers, component additions/removals |
| Search Queries | `.claude/skills/gh-aw-report/references/search-queries.md` | all | Query effectiveness, new search terms needed |

## Gap Types

| Type | Priority | Description | Example |
|------|----------|-------------|---------|
| `incorrect` | 1 (highest) | Reference contradicts confirmed information | Reference says field X is required but it was made optional |
| `outdated` | 2 | Correct info but version/date/status is stale | Architecture says MCP Gateway v0.1.8 but v0.1.9 is released |
| `missing` | 3 | New feature/tool/pattern not covered | New safe-output type not in safe-outputs.md |

## Version Tracking Locations

Specific locations in reference files where version numbers appear. Check these against release data:

| Version | File | Section/Anchor |
|---------|------|---------------|
| gh-aw CLI version | `gh-aw-architecture.md` | "gh-aw CLI Extension" section |
| MCP Gateway version | `gh-aw-architecture.md` | "MCP Gateway" line |
| GitHub MCP Server version | `gh-aw-architecture.md` | "GitHub MCP Server" section |
| Copilot CLI GA date | `gh-aw-architecture.md` | "GitHub Copilot CLI" heading |
| Engine model list | `orchestration.md` | "Engine Model Selection" table |
| Engine model list | `frontmatter-schema.md` | "Available Models" sub-section |

## Edit Strategy

When implementing gap fixes, use these anchoring strategies:

- **Version updates**: Search for the exact old version string, replace with new
- **New sections**: Find the parent heading, insert after the last item in that section
- **Deprecated features**: Add deprecation notice after the feature's heading
- **New table rows**: Find the table, append before the closing empty line
- **Corrections**: Find the exact incorrect text, replace with correct text

Always use section headers as anchors, not line numbers (line numbers shift between runs).
