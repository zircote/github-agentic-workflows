# LLM-Optimized Reference Resources

External documentation resources from the official gh-aw documentation site, optimized for LLM consumption.

---

## Canonical URLs

### `llms.txt` — Documentation Index
- **URL:** https://github.github.com/gh-aw/llms.txt
- **Purpose:** Index of all available gh-aw documentation resources
- **When to use:** Starting point to discover what documentation exists

### `llms-full.txt` — Complete Specification
- **URL:** https://github.github.com/gh-aw/llms-full.txt
- **Purpose:** Full documentation for GitHub Agentic Workflows, auto-generated from official source materials
- **When to use:**
  - When the embedded schema in `frontmatter-schema.md` doesn't cover an edge case
  - When users ask about the latest spec changes
  - When validating against the authoritative source
- **Content covers:** Architecture, frontmatter specification, security model, tool definitions, compilation process, deployment patterns

### `llms-small.txt` — Abridged Documentation
- **URL:** https://github.github.com/gh-aw/llms-small.txt
- **Purpose:** Compact version with non-essential content removed
- **When to use:** Quick reference lookups, context-constrained environments

### `agentic-workflows.txt` — Blog Series & Production Patterns
- **URL:** https://github.github.com/gh-aw/_llms-txt/agentic-workflows.txt
- **Purpose:** Comprehensive blog series documenting workflow patterns, best practices, and real-world examples from Peli de Halleux's Agent Factory
- **When to use:**
  - When users need production-tested patterns
  - When looking for creative workflow ideas
  - When needing more than 100 annotated workflow examples
- **Content covers:** Pattern catalogs, security hardening, multi-agent orchestration, engine comparisons

---

## Reference Pages

### Tools Reference
- **URL:** https://github.github.com/gh-aw/reference/tools/
- **Purpose:** Complete tool configuration reference
- **When to use:** Verifying tool syntax, discovering new tool parameters

### Safe-Outputs Reference
- **URL:** https://github.github.com/gh-aw/reference/safe-outputs/
- **Purpose:** Complete safe-output types and constraint reference
- **When to use:** Configuring write operations, understanding constraint options

---

## Setup & Guides

### Creating Workflows
- **URL:** https://github.github.com/gh-aw/setup/creating-workflows/
- **Purpose:** Step-by-step guide for creating gh-aw workflows
- **When to use:** Helping users get started, understanding the creation flow

### Create Prompt
- **URL:** https://raw.githubusercontent.com/github/gh-aw/main/create.md
- **Purpose:** The official creation prompt used by coding agents to generate workflows
- **When to use:** Understanding the official authoring approach, generating workflows

---

## Source Repository

### Example Workflows
- **URL:** https://github.com/github/gh-aw/tree/main/.github/workflows
- **Purpose:** Working example workflows from the gh-aw repository itself
- **When to use:** Seeing production-quality workflow files, learning patterns by example

---

## Fetching Strategy

1. **Start with embedded references** — the files in this `references/` directory cover most use cases
2. **Fetch `llms-small.txt`** for quick lookups not covered by embedded references
3. **Fetch `llms-full.txt`** only when:
   - Embedded references are insufficient
   - User asks about a specific spec detail
   - Validating against the authoritative source
4. **Fetch `agentic-workflows.txt`** for production patterns and real-world examples
5. **Fetch specific reference pages** (tools, safe-outputs) for detailed configuration questions
