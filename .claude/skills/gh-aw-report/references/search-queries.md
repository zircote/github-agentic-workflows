# Search Query Library

Curated web search queries for the `gh-aw-report` skill. Organized by domain.

## Primary Sweep (8 queries — run by default)

### 1. gh-aw Core
```
"github agentic workflows" OR "gh-aw" OR "gh aw" release OR update OR changelog
```
**Targets**: gh-aw CLI releases, version bumps, breaking changes

### 2. GitHub Actions AI Features
```
"github actions" AI OR agentic OR copilot OR agent new feature OR update OR announcement
```
**Targets**: GitHub Actions platform changes affecting agentic workflows

### 3. GitHub Copilot Workspace
```
"github copilot workspace" OR "copilot workspace" update OR release OR feature
```
**Targets**: Copilot Workspace changes, new capabilities

### 4. GitHub Copilot Agent Mode
```
"github copilot" "agent mode" OR "agentic" OR "coding agent" update OR release
```
**Targets**: Copilot agent capabilities in VS Code, CLI, IDE extensions

### 5. GitHub Models API
```
"github models" API OR marketplace new model OR update OR deprecation
```
**Targets**: New models available, API changes, deprecations

### 6. GitHub MCP Server
```
"github-mcp-server" OR "github mcp server" release OR update OR feature
```
**Targets**: MCP server releases, new tools, breaking changes

### 7. Claude Code + GitHub
```
"claude code" github OR "mcp" OR "agentic" update OR integration OR release
```
**Targets**: Claude Code releases, GitHub integration improvements

### 8. Agentic CI/CD Community
```
"agentic ci" OR "agentic cd" OR "ai ci/cd" OR "llm github actions" pattern OR workflow OR best practice
```
**Targets**: Community patterns, blog posts, new tooling in the agentic CI/CD space

## Deep Dive Queries (run on request or for specific topics)

### gh-aw Deprecations
```
"gh-aw" OR "github agentic workflows" deprecated OR breaking OR migration
```

### MCP Protocol Updates
```
"model context protocol" OR "mcp" specification OR update OR "mcp server" new
```

### GitHub App Token Changes
```
"github app" token OR "installation token" OR "fine-grained" change OR update
```

### Safe-Outputs Changes
```
"gh-aw" "safe-outputs" OR "safe outputs" new OR change OR deprecation
```

### Engine Updates
```
"gh-aw" engine OR "copilot engine" OR "claude engine" OR "codex engine" update
```

### Security Advisories
```
"github actions" security advisory OR vulnerability OR CVE agentic OR workflow
```

### Competitor Landscape
```
"ai code review" OR "ai ci" OR "automated pr" tool OR platform launch OR release
```

## Query Construction Notes

- Use `OR` for term alternatives, quotes for exact phrases
- Append `site:github.blog` or `site:github.com` to narrow to official sources
- Append date range filters when available (e.g., `after:YYYY-MM-DD`)
- For GitHub Discussions/Issues: use `gh search issues` or `gh search discussions` via CLI
