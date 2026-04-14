---
name: aw-status
description: >
  Summarize the current state of the GitHub Agentic Workflows ecosystem from the
  persistent knowledge base. Provides a quick briefing without running new web
  searches. Use with: /aw-status [--domain domain] [--since YYYY-MM-DD]
tools:
  - Read
---

Read the knowledge base at `skills/gh-aw-report/knowledge-base.md`
and provide a concise status briefing covering:

## Flags

Parse the argument string for these optional flags:

- `--domain` — Focus the briefing on a specific domain: `gh-aw`, `actions`, `workspace`, `agent-mode`, `models`, `mcp-server`, `claude-code`, `community`
- `--since` — Only include knowledge base entries from this date forward

## Briefing Format

1. **Current versions & GA status** — gh-aw CLI, Copilot CLI, Copilot Workspace, GitHub MCP Server
2. **Active deprecations & breaking changes** — what needs migration now
3. **Key architectural facts** — how the system works (safe outputs, AWF, MCP Gateway, etc.)
4. **Last report date** — when the knowledge base was last updated
5. **Recommended immediate actions** — top 2–3 things a practitioner should do right now

Keep the briefing to 300–400 words. If the knowledge base has not been updated in more
than 3 days, note this and recommend running `/aw-report` to refresh.

Entries marked `[SUPERSEDED]` should be excluded from the briefing.
