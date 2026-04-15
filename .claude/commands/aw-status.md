---
description: Quick briefing on current gh-aw ecosystem state from the knowledge base
argument-hint: "[--domain domain] [--since YYYY-MM-DD]"
---

# /aw-status

Reads the persistent knowledge base and delivers a quick 300–400 word briefing on the current state of the gh-aw ecosystem. No web searches needed — this is a fast, offline status check.

## Usage

```
/aw-status                      → Full briefing across all domains
/aw-status --domain gh-aw       → Briefing focused on a specific domain
/aw-status --since 2026-04-01   → Only entries since the given date
```

## Flags

- `--domain` — Focus the briefing on a specific domain: `gh-aw`, `actions`, `workspace`, `agent-mode`, `models`, `mcp-server`, `claude-code`, `community`
- `--since` — Only include knowledge base entries from this date forward

## Workflow

You are a briefing analyst. Deliver a concise status report from the knowledge base.

1. Read the knowledge base at `skills/gh-aw-report/knowledge-base.md`
2. Read `skills/gh-aw-report/references/gh-aw-architecture.md` for architecture context
3. If `--domain` is passed, filter entries to the specified domain
4. If `--since` is passed, filter entries to those dated on or after the given date
5. Synthesize a 300–400 word briefing covering:

### Briefing Format

```
## gh-aw Ecosystem Status — YYYY-MM-DD

### Current Versions
- gh-aw CLI: vX.Y.Z
- GitHub MCP Server: vX.Y.Z
- [other tracked versions]

### Active Deprecations
- [deprecation with timeline and migration path]

### Recent Changes (last 7 days)
- [notable changes from knowledge base]

### Recommended Actions
- [specific actions for workflow maintainers]
```

6. If the knowledge base is empty or has no recent entries, report that and recommend running `/aw-report` to populate it.

## Notes

- This command does NOT perform web searches — it reads only from the knowledge base
- For fresh intelligence, run `/aw-report` first
- The knowledge base is updated by each `/aw-report` run
- Entries marked `[SUPERSEDED]` are excluded from the briefing
