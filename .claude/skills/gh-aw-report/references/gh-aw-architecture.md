# gh-aw Architecture Reference

Stable architectural facts about the GitHub Agentic Workflows ecosystem. Used by the `gh-aw-report` skill to contextualize intelligence findings.

## Core Components

### gh-aw CLI Extension
- **Repository**: `github/gh-aw`
- **Install**: `gh extension install github/gh-aw`
- **Purpose**: Compile markdown workflow definitions into GitHub Actions `.lock.yml` files
- **Key commands**: `gh aw compile`, `gh aw validate`, `gh aw upgrade`, `gh aw mcp inspect`, `gh aw mcp list`

### Workflow File Structure
- **Source**: `.github/workflows/<name>.md` — markdown with YAML frontmatter
- **Compiled**: `.github/workflows/<name>.lock.yml` — generated Actions workflow (never edit directly)
- **Frontmatter**: trigger config, engine, tools, permissions, safe-outputs, network
- **Body**: Prose instructions for the AI agent (H1 heading, context, instructions, edge cases)

### Engines
- `copilot` — GitHub-native (default), powered by GitHub Models
- `claude` — Anthropic Claude, strong reasoning
- `codex` — OpenAI, code-focused
- `custom` — bring your own engine via MCP or API

### Safe-Outputs System
- All write operations go through safe-outputs using GitHub App tokens
- The AI agent itself is read-only; safe-outputs are the only write path
- Each safe-output type has configurable constraints (allowlists, max limits, title prefixes)
- Write permissions in `permissions:` block are rejected by the compiler

### MCP Server Integration
- gh-aw supports MCP (Model Context Protocol) servers as tools
- Container-based servers use `container:` field with Docker image references
- Process-based servers use `command:` with `npx` or `uvx`
- MCP gateway logs at `agent-artifacts/mcp-logs/{server}.log`

### Dependencies System (Agent Package Manager)

- **`plugins:` field:** DEPRECATED as of early 2026
- **`dependencies:` field:** Current replacement, backed by Microsoft APM (Agent Package Manager)
- **Migration:** Run `gh aw fix --write` to auto-migrate existing `plugins:` references
- APM is the package registry for gh-aw workflow plugin dependencies
- Dependencies are resolved at compile time via `gh aw compile`

## Related GitHub Products

### GitHub Copilot Workspace
- Browser-based agentic coding environment
- Plan → Implement → Review → PR cycle
- Uses Copilot engine for code generation
- Natively reads `CLAUDE.md`, `AGENTS.md`, `COPILOT.md`, and custom instruction files
- Workspace-scoped and global-scoped instruction files are both respected

### GitHub Copilot Agent Mode (VS Code / CLI)
- Agentic coding in IDE with tool use
- `@workspace` agent for codebase-wide tasks
- CLI: `gh copilot` for terminal-based agentic coding

### GitHub Copilot CLI (GA: February 25, 2026)

- Terminal-native agentic coding environment and default agent runtime for gh-aw
- **Autopilot mode:** Fully autonomous task execution without approval prompts
- **Plan mode:** Displays step-by-step plan before execution for review
- **Background delegation:** Prefix prompt with `&` to delegate to cloud coding agent
- **Specialized sub-agents:** Explore, Task, Code Review, Plan
- **Model support:** Claude Opus 4.6, Claude Sonnet 4.6, GPT-5.3-Codex, Gemini 3 Pro
- Available to all paid Copilot subscribers (Pro, Business, Enterprise)

### GitHub Models API
- Model serving platform at `https://models.github.com`
- Hosts multiple LLM providers (OpenAI, Anthropic, Meta, etc.)
- Used by gh-aw engines for inference

### GitHub MCP Server
- **Repository**: `github/github-mcp-server`
- **Current stable version:** v1.0.0 (released 2026-04-16) — first stable major release
- Provides GitHub API tools via MCP protocol
- Used by Claude Code, Copilot, and other MCP-compatible clients
- **Projects toolset:** Consolidated `projects_list`, `projects_get`, `projects_write` tools (~50% token reduction, ~23,000 tokens saved)
- **Copilot tools:** `get_copilot_job_status`, `assign_copilot_to_issue`, `create_pull_request_with_copilot` (in default `copilot` toolset)
- **`base_ref` parameter:** On Copilot PR tools for stacked PR / feature branch workflows
- **`resolve_review_thread` tool:** Resolve PR review threads (added v0.33.0)
- **`set_issue_fields` tool:** Set/update/delete org-level custom field values on issues (in `issues_granular` toolset, added v1.0.0)
- **Granular toolsets:** `pull_request_granular` and `issues_granular` — OSS toolsets for fine-grained PR/issue operations (added v0.33.0)
- **`list_commits` enhancements:** Added `path`, `since`, and `until` parameters (added v0.33.0)
- **Insiders mode:** Opt-in experimental features via `/insiders` URL or config header (still active for early experiments)
- **MCP Apps:** UI rendering support for select tools; graduated from insiders to feature flag `remote_mcp_ui_apps` (v1.0.0)
- **HTTP mode:** Enterprise deployment with per-request OAuth token forwarding; `X-MCP-Features` header validated via `HeaderAllowedFeatureFlags` (v1.0.0)
- **MCP Gateway:** Centralized access management for MCP servers (v0.1.9 as of 2026-04-14)

### Claude Code
- Anthropic's CLI agentic coding tool
- Integrates with GitHub via MCP servers
- Can run gh-aw workflows locally for testing

## Ecosystem Integrations

### CI/CD Patterns
- gh-aw workflows compile to standard GitHub Actions
- Can coexist with traditional `.yml` Actions workflows (with caveats around App token pushes)
- `dispatch-workflow` safe-output enables runtime workflow chaining
- `call-workflow` enables compile-time fan-out (inlined reusable workflows)

### Security Model
- `strict: true` (default) — restricts network, enforces ecosystem identifiers
- `strict: false` — required for custom domains and untrusted input
- `lockdown` settings for public repositories
- Network firewall with ecosystem identifiers: `defaults`, `github`, `containers`, `node`, `python`
