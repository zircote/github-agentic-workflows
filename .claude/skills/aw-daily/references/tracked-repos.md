# Tracked Repositories

GitHub repositories queried for activity since the last intelligence report. Activity supplements web searches with precise, API-sourced data.

## Repository Inventory

| Repository | Query Types | Extract | Maps To |
|-----------|------------|---------|---------|
| `github/gh-aw` | Issues, PRs, Discussions, Releases | New features, breaking changes, bug reports, version bumps | frontmatter-schema.md, safe-outputs.md, tools-reference.md, production-gotchas.md, validation.md |
| `github/github-mcp-server` | Releases, Issues | Version changes, new tools, breaking changes | tools-reference.md, gh-aw-architecture.md, production-gotchas.md |
| `github/copilot-cli` | Releases (if public) | CLI updates, new agent modes, model changes | orchestration.md, gh-aw-architecture.md |
| `githubnext/agentics` | Commits, New files | New sample workflows, pattern changes | orchestration.md, examples.md |
| `zircote/github-agentic-workflows` | Issues, PRs, Discussions | Self-referential activity, community feedback | All reference files |

## Query Patterns

### Determine last report date

```bash
LAST_DATE=$(grep -oP '^\#\#\# \K\d{4}-\d{2}-\d{2}' .claude/skills/gh-aw-report/knowledge-base.md | tail -1)
# Fallback to 7 days ago if no entries
LAST_DATE=${LAST_DATE:-$(date -d '7 days ago' +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d)}
```

### Issues and PRs (gh search)

```bash
gh search issues --repo {owner/repo} --created ">=$LAST_DATE" --sort created --json title,url,labels,createdAt --limit 20
gh search prs --repo {owner/repo} --created ">=$LAST_DATE" --sort created --json title,url,labels,state,createdAt --limit 20
```

### Releases

```bash
gh release list --repo {owner/repo} --limit 5 --json tagName,publishedAt,name
```

### Discussions (GraphQL)

```bash
gh api graphql -f query='{ repository(owner:"{owner}", name:"{repo}") {
  discussions(first:10, orderBy:{field:CREATED_AT, direction:DESC}) {
    nodes { title url createdAt category { name } }
  }
}}'
```

## Label Filters

When querying `github/gh-aw`, prioritize items with these labels:
- `breaking-change` -- immediate reference file impact
- `deprecation` -- requires knowledge base + reference update
- `safe-output` -- maps to safe-outputs.md
- `engine` -- maps to orchestration.md engine section
- `mcp` -- maps to tools-reference.md MCP section

## Activity-to-Gap Mapping

| Activity Type | Gap Type | Priority |
|--------------|----------|----------|
| New release with version bump | `outdated` -- version number in architecture reference | High |
| Issue labeled `breaking-change` | `incorrect` -- reference may contradict new behavior | High |
| Issue labeled `deprecation` | `outdated` -- deprecated field/feature still documented without warning | High |
| New safe-output type in PR | `missing` -- not yet in safe-outputs.md | Medium |
| New tool or toolset in PR | `missing` -- not yet in tools-reference.md | Medium |
| New example workflow committed | `missing` -- pattern not in examples.md | Low |
| Discussion about gotcha/bug | `missing` -- not in production-gotchas.md | Medium |
