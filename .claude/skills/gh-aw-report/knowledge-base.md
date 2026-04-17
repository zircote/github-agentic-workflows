# gh-aw Knowledge Base

> Persistent cross-session facts about the GitHub Agentic Workflows ecosystem.
> Updated by each run of the gh-aw-report skill. Entries are dated and append-only.
> Do not remove entries — mark superseded information with `[SUPERSEDED by YYYY-MM-DD]`.

---

## [2026-04-17] Daily Intelligence Update

### GitHub MCP Server v1.0.0 — GA Release (2026-04-16)
- **First stable major release**: GitHub MCP Server reached v1.0.0 on April 16, 2026
- **`set_issue_fields` tool**: Sets/updates/deletes org-level custom field values on issues; feature-flagged under `issues_granular` toolset
- **MCP Apps feature flag**: `remote_mcp_ui_apps` — MCP Apps UI graduated from insiders-only to a proper feature flag for broader rollout
- **`HeaderAllowedFeatureFlags`**: HTTP mode now validates `X-MCP-Features` header flags via enforcement in v1.0.0
- **modelcontextprotocol/go-sdk v1.5.0** used in v1.0.0
- Source: https://github.com/github/github-mcp-server/releases/tag/v1.0.0

### GitHub MCP Server v0.33.0 additions (2026-04-14)
- **`resolve_review_thread` tool**: Resolves PR review threads
- **`list_commits` new params**: `path`, `since`, `until`
- **Granular OSS toolsets**: `pull_request_granular` and `issues_granular` toolsets now open-source
- **Configurable server name/title** via translation strings
- Source: https://github.com/github/github-mcp-server/releases/tag/v0.33.0

---

## [2026-04-14] Bootstrap Entry — Initial Research

### gh-aw CLI
- **Technical preview launched**: February 13, 2026
- **Core repo**: `github/gh-aw` (github.com/github/gh-aw)
- **Docs**: github.github.com/gh-aw/
- **GitHub Next page**: githubnext.com/projects/agentic-workflows/
- **Default agent**: GitHub Copilot CLI
- **Alternative agents**: Claude (Anthropic), Codex (OpenAI)
- **Key CLI commands**: `gh aw compile`, `gh aw run`, `gh aw fix --write`, `gh aw upgrade`
- **Issue #10193**: Intermittent Daily News workflow failures (~40% success rate, flagged Feb 2026)
- **MCP updates tracked in gh-aw**: Issue #20042 tracks GitHub MCP Server v0.31.0→v0.32.0 and MCP Gateway v0.1.8→v0.1.9

### Breaking Changes / Deprecations ACTIVE as of 2026-04-14
| Item | Status | Migration | Date |
|------|--------|-----------|------|
| `plugins:` frontmatter field | **DEPRECATED** | Use `dependencies:` field; run `gh aw fix --write` | Early 2026 |
| npm `@modelcontextprotocol/server-github` | **DEPRECATED** | Use Docker or HTTP GitHub MCP Server | April 2025 |
| actions/cache v1-v2 | **REMOVED** | Use v3 or v4 | March 2025 |
| Workflow prompt files managed by CLI | **CHANGED** | Files now resolved from gh-aw repo directly | 2026 |

### GitHub Actions (as of 2026-04-14)
- Immutable Actions in general use for hosted runners
- Self-hosted runners must allow `pkg.actions.githubusercontent.com`
- Pricing backlash/changes tracked at samexpert.com (check for current state)

### GitHub MCP Server (as of 2026-04-14)
- **Official repo**: `github/github-mcp-server`
- **Container**: `ghcr.io/github/github-mcp-server`
- ~~npm `@modelcontextprotocol/server-github`~~ DEPRECATED April 2025
- **Insiders mode**: opt-in via `/insiders` URL or config header for experimental features
- **HTTP mode**: enterprise deployment with per-request OAuth token support
- **Projects toolset**: consolidated — saves ~23,000 tokens (~50% reduction)
- **New tools**: `get_copilot_job_status`, `assign_copilot_to_issue`, `create_pull_request_with_copilot`
- **`base_ref` parameter**: added to Copilot PR tools for stacked PRs / feature branches
- **Changelog entry**: 2026-01-28 — New Projects tools, OAuth scope filtering

### GitHub Copilot CLI (as of 2026-04-14)
- **GA date**: February 25, 2026 (after ~5 months of public preview from September 2025)
- **Available to**: All paid Copilot subscribers (Pro, Business, Enterprise)
- **Modes**: Plan mode (shows plan first), Autopilot mode (fully autonomous)
- **Background delegation**: prefix prompt with `&` to send to cloud coding agent
- **Sub-agents**: Explore (codebase analysis), Task (build/test), Code Review, Plan
- **Models**: Claude Opus 4.6, Claude Sonnet 4.6, GPT-5.3-Codex, Gemini 3 Pro
- **January 2026 changelog**: Enhanced agents, context management, new install methods

### GitHub Copilot Workspace / Agent Mode (as of 2026-04-14)
- **JetBrains GA**: March 11, 2026 (VS Code was earlier)
- **Waitlist removed**: Pro, Business, Enterprise — early 2026
- **Agentic code review GA**: March 2026 — full context → suggestions → auto-spawn fix PR
- **Issue assignment**: Assign GitHub issue to Copilot → autonomous PR creation
- **Instruction files read**: `CLAUDE.md`, `AGENTS.md`, `COPILOT.md`, custom instruction files, workspace and global scope
- **Custom agents GA** (+ plan agent, sub-agents): GA; **agent hooks**: preview; **auto-approve MCP**: supported
- **April 2026 changelog**: Copilot in Visual Studio — March update (released 2026-04-02)

### Claude Code / Anthropic GitHub Integration (as of 2026-04-14)
- GitHub MCP Server installation guide for Claude: `github/github-mcp-server/docs/installation-guides/install-claude.md`
- Claude Code connects to GitHub MCP Server via `claude mcp add-json github` (HTTP) or Docker
- `steipete/claude-code-mcp`: Claude Code as a one-shot MCP server ("agent in your agent")
- Copilot natively reads `CLAUDE.md` instruction files in agentic workflows
- Claude can serve as the AI agent in gh-aw workflows (alternative to Copilot CLI)

### Community / Ecosystem (as of 2026-04-14)
- `githubnext/awesome-continuous-ai`: Curated list of Continuous AI actions and frameworks
- `githubnext/agentics`: Sample pack of gh-aw workflows (community starter kit)
- `0GiS0/github-agentic-workflows`: Community implementation with Daily Status Report bot
- HN thread on gh-aw preview: news.ycombinator.com/item?id=46934107
- GitHub blog post: "Continuous AI in practice: What developers can automate today"
- InfoQ coverage: "GitHub Agentic Workflows Unleash AI-Driven Repository Automation" (Feb 2026)
- April 2026: GitHub integrates AI for accessibility issue management and feedback triage

### Architecture Notes (stable)
- gh-aw is NOT a replacement for deterministic CI/CD — it augments it ("Continuous AI")
- Workflows run in isolated containers with read-only repo access by default
- AWF (Agent Workflow Firewall) restricts network egress
- Safe Outputs subsystem handles write operations in separate permission-controlled jobs
- Threat detection job runs per-workflow: prompt injection, credential leaks, malicious code

---
<!-- Append new entries above this line, newest first -->
