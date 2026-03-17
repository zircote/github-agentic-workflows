#!/usr/bin/env bash
# deploy-upgrade-workflow.sh
#
# Deploys a self-contained gh-aw auto-upgrade GitHub Actions workflow
# to all repos in an org that have gh-aw .md workflows.
#
# Usage:
#   ./scripts/deploy-upgrade-workflow.sh --org HMH-ProdOps --token ghp_xxx
#   ./scripts/deploy-upgrade-workflow.sh --org HMH-ProdOps --token ghp_xxx --dry-run
#   ./scripts/deploy-upgrade-workflow.sh --org HMH-ProdOps --token ghp_xxx --repos "ccab,observatory"
#
# Requirements: curl, python3, base64

set -euo pipefail

# --- Defaults ---
ORG=""
TOKEN=""
DRY_RUN=false
TARGET_REPOS="" # comma-separated subset, empty = all
WORKFLOW_PATH=".github/workflows/gh-aw-auto-upgrade.yml"
COMMIT_MSG="chore(ci): deploy gh-aw auto-upgrade workflow"

# --- Parse args ---
while [[ $# -gt 0 ]]; do
	case "$1" in
	--org)
		ORG="$2"
		shift 2
		;;
	--token)
		TOKEN="$2"
		shift 2
		;;
	--dry-run)
		DRY_RUN=true
		shift
		;;
	--repos)
		TARGET_REPOS="$2"
		shift 2
		;;
	*)
		echo "Unknown arg: $1"
		exit 1
		;;
	esac
done

if [[ -z "$ORG" || -z "$TOKEN" ]]; then
	echo "Usage: $0 --org ORG --token TOKEN [--dry-run] [--repos repo1,repo2]"
	exit 1
fi

AUTH="Authorization: token $TOKEN"

# --- Workflow content ---
# Self-contained YAML — no gh-aw compilation needed
WORKFLOW_CONTENT=$(
	cat <<'YAML'
# This workflow is deployed automatically. Do not edit manually.
# Source: github-agentic-workflows/scripts/deploy-upgrade-workflow.sh
name: gh-aw Auto Upgrade

on:
  schedule:
    - cron: '0 8 * * 1'  # Weekly Monday 8am UTC
  workflow_dispatch:
    inputs:
      force:
        description: 'Force upgrade even if already on latest version'
        type: boolean
        default: false

permissions:
  contents: write
  pull-requests: write
  actions: read

jobs:
  upgrade:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install gh-aw extension
        run: gh extension install github/gh-aw || true
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Record version before upgrade
        id: before
        run: |
          version=$(gh aw version 2>/dev/null | awk '{print $NF}' || echo "unknown")
          echo "version=$version" >> "$GITHUB_OUTPUT"
          echo "gh-aw version before: $version"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Upgrade gh-aw extension
        run: gh extension upgrade github/gh-aw --force
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Record version after upgrade
        id: after
        run: |
          version=$(gh aw version 2>/dev/null | awk '{print $NF}' || echo "unknown")
          echo "version=$version" >> "$GITHUB_OUTPUT"
          echo "gh-aw version after: $version"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Check if upgrade needed
        id: check
        run: |
          if [[ "${{ steps.before.outputs.version }}" == "${{ steps.after.outputs.version }}" && "${{ inputs.force }}" != "true" ]]; then
            echo "skip=true" >> "$GITHUB_OUTPUT"
            echo "Already on latest version (${{ steps.after.outputs.version }}). Skipping."
          else
            echo "skip=false" >> "$GITHUB_OUTPUT"
            echo "Upgrade needed: ${{ steps.before.outputs.version }} → ${{ steps.after.outputs.version }}"
          fi

      - name: Run gh-aw upgrade with PR creation
        if: steps.check.outputs.skip != 'true'
        run: gh aw upgrade --create-pull-request --verbose
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Auto-merge upgrade PR
        if: steps.check.outputs.skip != 'true'
        run: |
          # Find the PR created by gh aw upgrade
          PR_URL=$(gh pr list --state open --search "gh-aw upgrade" --json url --jq '.[0].url' 2>/dev/null || true)
          if [[ -z "$PR_URL" || "$PR_URL" == "null" ]]; then
            # Try alternate search — gh aw upgrade names its branch "aw/upgrade-*"
            PR_URL=$(gh pr list --state open --head "aw/upgrade" --json url --jq '.[0].url' 2>/dev/null || true)
          fi
          if [[ -n "$PR_URL" && "$PR_URL" != "null" ]]; then
            echo "Found upgrade PR: $PR_URL"
            gh pr merge "$PR_URL" --squash --auto --delete-branch || echo "Auto-merge requested (waiting for checks)"
          else
            echo "No upgrade PR found — gh aw upgrade may not have produced changes."
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
YAML
)

# Base64 encode for GitHub API
ENCODED_CONTENT=$(echo "$WORKFLOW_CONTENT" | base64)

# --- Discover repos ---
echo "Discovering repos in $ORG..."

if [[ -n "$TARGET_REPOS" ]]; then
	IFS=',' read -ra REPOS <<<"$TARGET_REPOS"
else
	REPOS=()
	page=1
	while true; do
		response=$(curl -s -H "$AUTH" "https://api.github.com/orgs/$ORG/repos?per_page=100&page=$page&type=all")
		names=$(echo "$response" | python3 -c "
import sys, json
try:
    repos = json.load(sys.stdin)
    if isinstance(repos, list):
        for r in repos:
            if not r.get('archived', False) and not r.get('disabled', False):
                print(r['name'])
except: pass
" 2>/dev/null)
		[[ -z "$names" ]] && break
		while IFS= read -r name; do
			REPOS+=("$name")
		done <<<"$names"
		page=$((page + 1))
	done
fi

echo "Found ${#REPOS[@]} repos"

# --- Filter to repos with gh-aw workflows ---
GH_AW_REPOS=()
for repo in "${REPOS[@]}"; do
	md_count=$(curl -s -H "$AUTH" "https://api.github.com/repos/$ORG/$repo/contents/.github/workflows" 2>/dev/null | python3 -c "
import sys, json
try:
    items = json.load(sys.stdin)
    if isinstance(items, list):
        print(len([i for i in items if i['name'].endswith('.md')]))
    else:
        print(0)
except: print(0)
" 2>/dev/null)
	if [[ "$md_count" -gt 0 ]]; then
		GH_AW_REPOS+=("$repo")
		echo "  ✓ $repo ($md_count .md workflows)"
	else
		echo "  ✗ $repo (no gh-aw workflows, skipping)"
	fi
done

echo ""
echo "Deploying to ${#GH_AW_REPOS[@]} repos with gh-aw workflows"
echo "==========================================================="

# --- Deploy to each repo ---
deployed=0
skipped=0
failed=0

for repo in "${GH_AW_REPOS[@]}"; do
	echo ""
	echo "--- $ORG/$repo ---"

	# Check if file already exists (need SHA for update)
	existing=$(curl -s -H "$AUTH" "https://api.github.com/repos/$ORG/$repo/contents/$WORKFLOW_PATH" 2>/dev/null)
	existing_sha=$(echo "$existing" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('sha', ''))
except: print('')
" 2>/dev/null)

	# Check if content is identical (skip if unchanged)
	if [[ -n "$existing_sha" ]]; then
		existing_content=$(echo "$existing" | python3 -c "
import sys, json, base64
try:
    data = json.load(sys.stdin)
    print(base64.b64decode(data['content']).decode('utf-8'))
except: print('')
" 2>/dev/null)
		if [[ "$existing_content" == "$WORKFLOW_CONTENT" ]]; then
			echo "  SKIP: workflow already deployed and identical"
			skipped=$((skipped + 1))
			continue
		fi
		echo "  UPDATE: workflow exists but differs — updating"
	else
		echo "  CREATE: deploying new workflow"
	fi

	if [[ "$DRY_RUN" == "true" ]]; then
		echo "  DRY-RUN: would deploy $WORKFLOW_PATH"
		skipped=$((skipped + 1))
		continue
	fi

	# Build PUT payload using printf to avoid shell/python quoting issues
	clean_content=$(echo "$ENCODED_CONTENT" | tr -d '\n')
	if [[ -n "$existing_sha" ]]; then
		payload=$(printf '{"message":"%s","content":"%s","sha":"%s"}' "$COMMIT_MSG" "$clean_content" "$existing_sha")
	else
		payload=$(printf '{"message":"%s","content":"%s"}' "$COMMIT_MSG" "$clean_content")
	fi

	# Deploy via GitHub Contents API — try direct commit first
	response=$(curl -s -w "\n%{http_code}" -X PUT \
		-H "$AUTH" \
		-H "Accept: application/vnd.github+json" \
		-d "$payload" \
		"https://api.github.com/repos/$ORG/$repo/contents/$WORKFLOW_PATH" 2>/dev/null)

	http_code=$(echo "$response" | tail -1)
	body=$(echo "$response" | sed '$d')

	if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
		commit_sha=$(echo "$body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('commit',{}).get('sha','')[:7])" 2>/dev/null)
		echo "  ✓ Deployed ($http_code) — commit: $commit_sha"
		deployed=$((deployed + 1))
	elif [[ "$http_code" == "409" ]]; then
		# Branch protection — create via branch + PR
		echo "  Branch protected — creating PR instead"

		# Get default branch and its HEAD SHA
		default_branch=$(curl -s -H "$AUTH" "https://api.github.com/repos/$ORG/$repo" | python3 -c "import sys,json; print(json.load(sys.stdin).get('default_branch','main'))" 2>/dev/null)
		head_sha=$(curl -s -H "$AUTH" "https://api.github.com/repos/$ORG/$repo/git/ref/heads/$default_branch" | python3 -c "import sys,json; print(json.load(sys.stdin).get('object',{}).get('sha',''))" 2>/dev/null)

		if [[ -z "$head_sha" ]]; then
			echo "  ✗ FAILED: could not get HEAD SHA for $default_branch"
			failed=$((failed + 1))
			continue
		fi

		branch_name="chore/deploy-gh-aw-auto-upgrade"

		# Delete existing branch if present (from a prior run)
		curl -s -X DELETE -H "$AUTH" "https://api.github.com/repos/$ORG/$repo/git/refs/heads/$branch_name" >/dev/null 2>&1 || true

		# Create branch
		create_ref=$(curl -s -w "\n%{http_code}" -X POST \
			-H "$AUTH" \
			-H "Accept: application/vnd.github+json" \
			-d "{\"ref\":\"refs/heads/$branch_name\",\"sha\":\"$head_sha\"}" \
			"https://api.github.com/repos/$ORG/$repo/git/refs" 2>/dev/null)
		ref_code=$(echo "$create_ref" | tail -1)

		if [[ "$ref_code" != "201" ]]; then
			echo "  ✗ FAILED: could not create branch ($ref_code)"
			failed=$((failed + 1))
			continue
		fi

		# Check if file exists on the new branch (inherit from default)
		branch_existing=$(curl -s -H "$AUTH" "https://api.github.com/repos/$ORG/$repo/contents/$WORKFLOW_PATH?ref=$branch_name" 2>/dev/null)
		branch_sha=$(echo "$branch_existing" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('sha', ''))
except: print('')
" 2>/dev/null)

		# Build payload for branch commit
		clean_content=$(echo "$ENCODED_CONTENT" | tr -d '\n')
		if [[ -n "$branch_sha" ]]; then
			branch_payload=$(printf '{"message":"%s","content":"%s","sha":"%s","branch":"%s"}' "$COMMIT_MSG" "$clean_content" "$branch_sha" "$branch_name")
		else
			branch_payload=$(printf '{"message":"%s","content":"%s","branch":"%s"}' "$COMMIT_MSG" "$clean_content" "$branch_name")
		fi

		# Commit to branch
		commit_resp=$(curl -s -w "\n%{http_code}" -X PUT \
			-H "$AUTH" \
			-H "Accept: application/vnd.github+json" \
			-d "$branch_payload" \
			"https://api.github.com/repos/$ORG/$repo/contents/$WORKFLOW_PATH" 2>/dev/null)
		commit_code=$(echo "$commit_resp" | tail -1)

		if [[ "$commit_code" != "200" && "$commit_code" != "201" ]]; then
			commit_err=$(echo "$commit_resp" | sed '$d' | python3 -c "import sys,json; print(json.load(sys.stdin).get('message','unknown'))" 2>/dev/null)
			echo "  ✗ FAILED: could not commit to branch ($commit_code): $commit_err"
			# Clean up branch
			curl -s -X DELETE -H "$AUTH" "https://api.github.com/repos/$ORG/$repo/git/refs/heads/$branch_name" >/dev/null 2>&1 || true
			failed=$((failed + 1))
			continue
		fi

		# Create PR
		pr_body_text="## Summary\\n\\n- Deploys \`gh-aw-auto-upgrade.yml\` workflow\\n- Runs weekly on Monday 8am UTC + manual dispatch\\n- Installs gh-aw, upgrades extension, runs \`gh aw upgrade --create-pull-request\`\\n- Auto-merges the resulting upgrade PR\\n\\n---\\n_Deployed by deploy-upgrade-workflow.sh_"
		pr_payload=$(printf '{"title":"chore(ci): deploy gh-aw auto-upgrade workflow","body":"%s","head":"%s","base":"%s"}' "$pr_body_text" "$branch_name" "$default_branch")
		pr_resp=$(curl -s -w "\n%{http_code}" -X POST \
			-H "$AUTH" \
			-H "Accept: application/vnd.github+json" \
			-d "$pr_payload" \
			"https://api.github.com/repos/$ORG/$repo/pulls" 2>/dev/null)
		pr_code=$(echo "$pr_resp" | tail -1)
		pr_body_resp=$(echo "$pr_resp" | sed '$d')

		if [[ "$pr_code" == "201" ]]; then
			pr_url=$(echo "$pr_body_resp" | python3 -c "import sys,json; print(json.load(sys.stdin).get('html_url',''))" 2>/dev/null)
			pr_number=$(echo "$pr_body_resp" | python3 -c "import sys,json; print(json.load(sys.stdin).get('number',''))" 2>/dev/null)
			echo "  ✓ PR created: $pr_url"

			# Try to merge the PR immediately
			merge_resp=$(curl -s -w "\n%{http_code}" -X PUT \
				-H "$AUTH" \
				-H "Accept: application/vnd.github+json" \
				-d '{"merge_method":"squash"}' \
				"https://api.github.com/repos/$ORG/$repo/pulls/$pr_number/merge" 2>/dev/null)
			merge_code=$(echo "$merge_resp" | tail -1)

			if [[ "$merge_code" == "200" ]]; then
				echo "  ✓ PR merged (squash)"
				# Clean up branch
				curl -s -X DELETE -H "$AUTH" "https://api.github.com/repos/$ORG/$repo/git/refs/heads/$branch_name" >/dev/null 2>&1 || true
			else
				echo "  ℹ PR open — needs review/CI before merge"
			fi
			deployed=$((deployed + 1))
		else
			pr_err=$(echo "$pr_body_resp" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message','unknown'))" 2>/dev/null)
			echo "  ✗ FAILED: could not create PR ($pr_code): $pr_err"
			# Clean up branch
			curl -s -X DELETE -H "$AUTH" "https://api.github.com/repos/$ORG/$repo/git/refs/heads/$branch_name" >/dev/null 2>&1 || true
			failed=$((failed + 1))
		fi
	else
		error_msg=$(echo "$body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message','unknown'))" 2>/dev/null)
		echo "  ✗ FAILED ($http_code): $error_msg"
		failed=$((failed + 1))
	fi
done

# --- Summary ---
echo ""
echo "==========================================================="
echo "Deployment Summary"
echo "==========================================================="
echo "  Organization:  $ORG"
echo "  Total repos:   ${#REPOS[@]}"
echo "  With gh-aw:    ${#GH_AW_REPOS[@]}"
echo "  Deployed:      $deployed"
echo "  Skipped:       $skipped (identical or dry-run)"
echo "  Failed:        $failed"
echo "==========================================================="

[[ "$failed" -gt 0 ]] && exit 1
exit 0
