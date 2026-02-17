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
  - When users want real-world pattern inspiration
  - When exploring production workflow examples
  - When understanding orchestration patterns in practice
  - When learning from the 100+ production workflows in the Agent Factory
- **Content covers:** Orchestration patterns (TaskOps, Causal Chains, Direct Dispatch), production metrics (merge rates, attribution), anti-patterns learned from real deployments

---

## Usage Guidance

### When to Fetch External Resources

1. **User asks about latest features:** The embedded schema may lag behind the official spec. Fetch `llms-full.txt` to check.
2. **Edge case not covered locally:** If `frontmatter-schema.md` doesn't document a specific key or behavior, fetch the full spec.
3. **Real-world examples needed:** Fetch `agentic-workflows.txt` for production patterns from the Agent Factory (100+ workflows).
4. **Validation disputes:** When unsure if a configuration is valid, the full spec is the authoritative source.

### How to Cross-Reference

The embedded reference files in this plugin (`frontmatter-schema.md`, etc.) are derived from these external resources. When updating the embedded references:
1. Fetch `llms-full.txt` for the latest spec
2. Compare against the embedded schema
3. Update embedded references to match

### Fetching Example

Use WebFetch to retrieve these resources:
```
WebFetch: https://github.github.com/gh-aw/llms-full.txt
Prompt: "Extract the specification for the {specific_key} frontmatter field"
```

---

## Additional Resources

- **Source Repository:** https://github.com/github/gh-aw — Source code, issues, and development resources
- **GitHub CLI Documentation:** https://cli.github.com/manual/ — Reference for the underlying CLI tool
- **GitHub Actions Documentation:** https://docs.github.com/en/actions — Understanding the Actions runtime that gh-aw compiles to
