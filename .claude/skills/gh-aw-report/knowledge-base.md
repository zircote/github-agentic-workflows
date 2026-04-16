# gh-aw Knowledge Base

> Persistent cross-session facts about the GitHub Agentic Workflows ecosystem.
> Updated by each run of the gh-aw-report skill. Entries are dated and append-only.
> Do not remove entries — mark superseded information with ~~strikethrough~~ and a note.

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
- **Models**: Claude Opus 4.6, Claude Sonnet 4.6, GPT-5.3-Codex, ~~Gemini 3 Pro~~ [SUPERSEDED by 2026-04-15 — deprecated 2026-03-26]
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

## [2026-04-15] Daily Intelligence Update

### 2026-04-15 -- version -- gh-aw CLI v0.68.3
Released 2026-04-14. Model-not-supported detection, shared import `checkout`/`env` fields, TBT metric, OTEL token breakdowns, 5 push_signed_commits.cjs fixes.

### 2026-04-15 -- version -- GitHub MCP Server v0.33.0/v0.33.1
Released 2026-04-14. Granular PRs/issues toolsets, resolve review threads tool, `list_commits` `path`/`since`/`until` params, configurable server name.

### 2026-04-15 -- deprecation -- Gemini 3 Pro deprecated
Deprecated 2026-03-26 across all GitHub Copilot experiences. Use Gemini 3 Ultra.

### 2026-04-15 -- feature -- Agent HQ and model selection
Agent HQ: multi-vendor agents on GitHub. Model selection for Claude/Codex on github.com (2026-04-14).

### 2026-04-15 -- feature -- Copilot data residency + FedRAMP
US/EU data residency (2026-04-13). FedRAMP Moderate for US gov. `copilot --remote` public preview.

### 2026-04-15 -- ecosystem -- GitHub Actions April changes
Workflow reruns capped at 50 (2026-04-10). OIDC for Dependabot/code scanning. Code scanning→Issues linking. Async SBOM exports.

---

## [2026-04-16] Daily Intelligence Update

### 2026-04-16 -- feature -- gh-aw v0.68.3 New Frontmatter Fields
- **`pre-steps:`** — Runs custom steps at job start, **before checkout**. Use for token minting or pre-checkout setup. Outputs accessible via `${{ steps.<id>.outputs.<name> }}` for use in `checkout.github-token` to avoid masked-value cross-job boundary issues. Same security restrictions as `steps:`.
- **`run-install-scripts:`** — Boolean (default: `false`). Allows npm pre/post install scripts. Default adds `--ignore-scripts` to all npm install commands (supply chain protection). Setting `true` disables globally; per-runtime scope via `runtimes.node.run-install-scripts`. Compile-time warning (strict mode: error).
- **`on.stale-check:`** — Boolean nested under `on:`, default `true`. When `false`, disables the frontmatter hash check in the activation job. Required for cross-repo org ruleset deployments.
- Source: PR #26607 in github/gh-aw ("Sync github-agentic-workflows.md with v0.68.3")

### 2026-04-16 -- security -- gh-aw Security Fixes
- **Steganographic injection**: PR #26596 strips markdown link title text to close injection channel
- **XPIA @mentions**: PR #26589 sanitizes @mentions in `create_issue` body
- **cache-memory sanitization**: PR #26587 adds pre-agent working-tree sanitization (neutralizes planted executables/disallowed files)
- **Lock file integrity schema v4**: PR #26594 extends integrity check to detect post-compilation YAML tampering

### 2026-04-16 -- version -- GitHub MCP Server v0.33.0/v0.33.1
- **v0.33.0** (2026-04-14): Granular PRs/issues toolsets, `resolve_review_thread` tool, `list_commits` path/since/until params, configurable server name/title via translation strings, OSS HTTP logging adapter
- **v0.33.1** (2026-04-14): Hotfix release

### 2026-04-16 -- feature -- Claude Code Remote Tasks
- **Remote Tasks** (launched March 20, 2026): Define GitHub repo + prompt + schedule → Claude runs autonomously on Anthropic cloud infrastructure. Supports cron scheduling.
- **Remote Sessions**: Start task, close laptop, session continues on Anthropic infrastructure
- **Open-sourced**: Agent layer at `anthropics/claude-code`
- **v2.1.76** (March 14, 2026): Enhanced MCP elicitation support, improved tool discovery

### 2026-04-16 -- feature -- Copilot Cloud Agent Per-Org Control
- **Copilot cloud agent per-org control** (April 15, 2026): Can now be enabled for selected organizations via AI Controls page → "Agent" → "Copilot Cloud Agent"
- **REST API version 2026-03-10**: Available with breaking changes to the REST API

---
<!-- Append new entries above this line, newest first -->
