#!/usr/bin/env bash
# Stop hook: check for uncompiled gh-aw workflow changes before Claude finishes.
# Blocks if any .github/workflows/*.md files have been modified but their
# corresponding .lock.yml files are stale or missing.

set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [[ -z "$CWD" ]]; then
	exit 0
fi

cd "$CWD"

# Check if this repo has any gh-aw workflow .md files
WORKFLOW_DIR=".github/workflows"
if [[ ! -d "$WORKFLOW_DIR" ]]; then
	exit 0
fi

# Find .md workflow files (skip if none exist)
MD_FILES=$(find "$WORKFLOW_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null || true)
if [[ -z "$MD_FILES" ]]; then
	exit 0
fi

# Check for modified .md files whose .lock.yml is older or missing
STALE=()
MISSING=()

while IFS= read -r md; do
	wf_id=$(basename "$md" .md)
	lock="${WORKFLOW_DIR}/${wf_id}.lock.yml"

	if [[ ! -f "$lock" ]]; then
		MISSING+=("$wf_id")
	elif [[ "$md" -nt "$lock" ]]; then
		STALE+=("$wf_id")
	fi
done <<<"$MD_FILES"

# Also check version drift
INSTALLED=""
if command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -q 'gh-aw'; then
	INSTALLED=$(gh aw version 2>&1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || true)
fi

DRIFT=()
if [[ -n "$INSTALLED" ]]; then
	while IFS= read -r md; do
		wf_id=$(basename "$md" .md)
		lock="${WORKFLOW_DIR}/${wf_id}.lock.yml"
		if [[ -f "$lock" ]]; then
			lock_ver=$(grep -oE 'compiler_version":"v[0-9]+\.[0-9]+\.[0-9]+"' "$lock" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || true)
			if [[ -n "$lock_ver" && "$lock_ver" != "$INSTALLED" ]]; then
				DRIFT+=("${wf_id} (${lock_ver})")
			fi
		fi
	done <<<"$MD_FILES"
fi

# If nothing to report, exit clean
if [[ ${#STALE[@]} -eq 0 && ${#MISSING[@]} -eq 0 && ${#DRIFT[@]} -eq 0 ]]; then
	exit 0
fi

# Build report
MSG="[gh-aw] Uncompiled workflow changes detected:"

if [[ ${#MISSING[@]} -gt 0 ]]; then
	MSG+="\n  MISSING lock files (never compiled):"
	for wf in "${MISSING[@]}"; do
		MSG+="\n    - ${wf}.md (run: gh aw compile ${wf})"
	done
fi

if [[ ${#STALE[@]} -gt 0 ]]; then
	MSG+="\n  STALE lock files (.md newer than .lock.yml):"
	for wf in "${STALE[@]}"; do
		MSG+="\n    - ${wf}.md (run: gh aw compile ${wf})"
	done
fi

if [[ ${#DRIFT[@]} -gt 0 ]]; then
	MSG+="\n  VERSION DRIFT (compiled with older gh-aw, installed: ${INSTALLED}):"
	for wf in "${DRIFT[@]}"; do
		MSG+="\n    - ${wf}"
	done
fi

# Output the report — Claude will see this and can act on it
echo -e "$MSG"

# Return structured decision to keep Claude working
cat <<'EOF'
{"decision": "block", "reason": "gh-aw workflow .md files have uncompiled changes or version drift. Run `gh aw compile <workflow-id>` for each stale workflow and stage the resulting .lock.yml files before finishing."}
EOF

exit 0
