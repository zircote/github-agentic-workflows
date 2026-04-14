# gh-aw Architecture Reference

> Last updated: 2026-04-14. This file captures stable architectural facts about the
> GitHub Agentic Workflows system to reduce web searches on known-stable information.

## System Overview

GitHub Agentic Workflows (gh-aw) is GitHub's framework for "Continuous AI" — AI agents
that run as GitHub Actions jobs, performing reasoning-based repository maintenance tasks
that traditional deterministic CI cannot handle.

**Core repository**: `github/gh-aw`
**Docs site**: `github.github.com/gh-aw/`
**GitHub Next project page**: `githubnext.com/projects/agentic-workflows/`
**Technical preview launched**: February 13, 2026

## Workflow Authoring

- Workflows are written in **Markdown** (not YAML), stored in `.github/workflows/*.md`
- The `gh aw compile` command compiles Markdown to GitHub Actions YAML (`.lock.yml` files)
- Workflow prompt files (`.github/aw/*.md`) are resolved directly from the gh-aw repo by
  the agent — they are NOT managed by the CLI
- Two-file structure: a `.md` source and a `.lock.yml` compiled output

## gh aw CLI

- Default AI agent: GitHub Copilot CLI
- Supported alternative agents: Claude (Anthropic), Codex (OpenAI), custom agents
- Key commands:
  - `gh aw compile` — compile Markdown workflows to YAML
  - `gh aw run` — execute a workflow
  - `gh aw fix --write` — auto-migrate deprecated config fields
  - `gh aw upgrade` — upgrade workflows to latest patterns

## Dependencies System (Agent Package Manager / APM)

- As of early 2026, **`plugins:` frontmatter field is DEPRECATED**
- Replacement: **`dependencies:` field** backed by Microsoft APM (Agent Package Manager)
- Migration: run `gh aw fix --write` to auto-migrate existing `plugins:` fields

## Security Architecture

| Layer | Mechanism |
|-------|-----------|
| Default permissions | Read-only repository access |
| Write operations | "Safe Outputs" subsystem — separate permission-controlled jobs |
| Network egress | Agent Workflow Firewall (AWF) — restricts outbound connections |
| MCP access | MCP Gateway — centralized access management |
| Threat detection | Dedicated job checks for prompt injection, leaked credentials, malicious code |

### Safe Output Types (known)
- `remove-labels` — workflow can remove labels from issues/PRs
- Additional types are added incrementally via gh-aw releases

## Companion Projects

| Project | Purpose |
|---------|---------|
| `gh-aw-actions` | Shared library of custom GitHub Actions for gh-aw workflows |
| Agent Workflow Firewall (AWF) | Network egress control for agentic jobs |
| MCP Gateway | Centralized MCP server access management |
| `githubnext/agentics` | Sample pack of community gh-aw workflows |
| `githubnext/awesome-continuous-ai` | Curated list of Continuous AI tools and frameworks |

## GitHub MCP Server

- Official repo: `github/github-mcp-server`
- Deployment modes: Docker (`ghcr.io/github/github-mcp-server`), HTTP with OAuth, local
- **Deprecated**: npm `@modelcontextprotocol/server-github` (deprecated April 2025)
- Key tools: repository management, issue/PR automation, CI/CD workflow intelligence,
  code analysis, Copilot job status (`get_copilot_job_status`)
- Enterprise: HTTP mode with per-request OAuth token forwarding
- Insiders mode: opt-in experimental features via `/insiders` URL or config header
- Projects toolset: consolidated (reduces ~23,000 tokens/50% token usage)

## GitHub Copilot CLI (GA: February 25, 2026)

- Terminal-native agentic coding environment
- **Autopilot mode**: fully autonomous task execution
- **Plan mode**: shows plan before executing
- **Background delegation**: prefix with `&` to delegate to cloud coding agent
- **Specialized sub-agents**: Explore, Task, Code Review, Plan
- **Model support**: Claude Opus 4.6, Claude Sonnet 4.6, GPT-5.3-Codex, Gemini 3 Pro
- Available to all paid Copilot subscribers (Pro, Business, Enterprise)

## GitHub Copilot Workspace / Agent Mode

- Agent mode GA: VS Code (earlier) + JetBrains (March 2026)
- Copilot reads `CLAUDE.md`, `AGENTS.md`, `COPILOT.md`, and custom instruction files
- Agentic code review: gathers full project context → suggests changes → can spawn
  fix PR via coding agent automatically
- Assign GitHub issue to Copilot → autonomous background work → PR opened for review
- Waitlist removed for Pro/Business/Enterprise (early 2026)

## Continuous AI Paradigm

GitHub Next's framing: "Continuous AI" is the agentic evolution of CI.
- **NOT a replacement** for deterministic CI/CD
- **Augments** existing pipelines with reasoning-based automation
- Target use cases: issue triage, documentation updates, test generation, CI failure
  analysis, PR review, repository health reporting, accessibility scanning
