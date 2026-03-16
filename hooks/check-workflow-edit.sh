#!/usr/bin/env bash
# PostToolUse hook: remind to compile gh-aw workflows after .md edits
# and check for version drift between installed gh-aw and lock files.

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only fire for .github/workflows/*.md files
if ! echo "$FILE_PATH" | grep -qE '\.github/workflows/.*\.md$'; then
	exit 0
fi

CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
WF_ID=$(basename "$FILE_PATH" .md)
LOCK_FILE=".github/workflows/${WF_ID}.lock.yml"

# Resolve paths
if [[ -n "$CWD" ]]; then
	LOCK_PATH="${CWD}/${LOCK_FILE}"
	ACTIONS_LOCK="${CWD}/.github/aw/actions-lock.json"
else
	LOCK_PATH="$LOCK_FILE"
	ACTIONS_LOCK=".github/aw/actions-lock.json"
fi

# Get installed gh-aw version
INSTALLED=""
if command -v gh &>/dev/null && gh extension list 2>/dev/null | grep -q 'gh-aw'; then
	INSTALLED=$(gh aw version 2>&1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || true)
fi

# Get lock file compiler version
LOCK_VER=""
if [[ -f "$LOCK_PATH" ]]; then
	LOCK_VER=$(grep -oE 'compiler_version":"v[0-9]+\.[0-9]+\.[0-9]+"' "$LOCK_PATH" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || true)
fi

# Get actions-lock.json pinned version
PINNED=""
if [[ -f "$ACTIONS_LOCK" ]]; then
	PINNED=$(grep -oE '"github/gh-aw/actions/setup@v[0-9]+\.[0-9]+\.[0-9]+"' "$ACTIONS_LOCK" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || true)
fi

# Build reminder
MSG="[gh-aw] Workflow source modified: ${WF_ID}.md"
MSG+="\n  Run: gh aw compile ${WF_ID}"

if [[ -n "$INSTALLED" ]]; then
	MSG+="\n  Installed gh-aw: ${INSTALLED}"
fi

if [[ -n "$LOCK_VER" && -n "$INSTALLED" && "$LOCK_VER" != "$INSTALLED" ]]; then
	MSG+="\n  VERSION DRIFT: ${LOCK_FILE} compiled with ${LOCK_VER}, installed is ${INSTALLED}"
fi

if [[ -n "$PINNED" && -n "$INSTALLED" && "$PINNED" != "$INSTALLED" ]]; then
	MSG+="\n  VERSION DRIFT: actions-lock.json pins ${PINNED}, installed is ${INSTALLED}"
fi

if [[ ! -f "$LOCK_PATH" ]]; then
	MSG+="\n  WARNING: No lock file exists yet — compilation required before commit"
fi

echo -e "$MSG"
exit 0
