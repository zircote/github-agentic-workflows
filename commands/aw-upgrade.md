---
description: Upgrade gh-aw extension, recompile and validate all workflows, and open a PR with changes
argument-hint: "[--force] [--dry-run] [--no-merge] [--strict]"
---

# /aw-upgrade

End-to-end `gh-aw` upgrade, recompile, validate, and PR cycle. Designed for idempotent, unattended execution across many repos.

## Usage

```
/aw-upgrade                → Full upgrade cycle: upgrade extension → upgrade repo → validate → PR → merge
/aw-upgrade --force        → Run even if gh-aw extension is already on latest version
/aw-upgrade --dry-run      → Show what would change without committing or creating a PR
/aw-upgrade --no-merge     → Create PR but do not auto-merge
/aw-upgrade --strict       → Enforce strict mode validation for all workflows
```

## Workflow

You are an operations automation agent performing an unattended gh-aw upgrade cycle. Execute the phases below **in order**. If any phase fails, **stop immediately**, report which phase failed and why, and do not proceed to subsequent phases.

**Do not prompt the user for input at any point.** This command is designed for bulk execution (`$GPM_PROVISION_BULK=true`).

Parse the argument string for flags: `--force`, `--dry-run`, `--no-merge`, `--strict`. Unknown flags should be rejected with an error message.

---

### Phase 1: Pre-flight checks

1. Verify `gh` CLI is available: `gh --version`
2. Verify `gh aw` extension is installed: `gh aw version`
   - If not installed, install it: `gh extension install github/gh-aw`
   - After install, capture version: `gh aw version`
3. Verify the current directory is a git repository with `.github/workflows/` containing at least one `.md` file
4. Verify working tree is clean: `git status --porcelain` must be empty
   - If not clean, **abort** with error: "Working tree is dirty. Commit or stash changes before running /aw-upgrade."
5. Capture the current branch name for later restoration

Report: current gh-aw version, repo name, number of `.md` workflow files found.

---

### Phase 2: Upgrade gh-aw extension

1. Record the **before** version: `gh aw version`
2. Run: `gh extension upgrade github/gh-aw --force`
3. Record the **after** version: `gh aw version`
4. Compare versions:
   - If versions are identical **and** `--force` was NOT passed: report "gh-aw is already on latest version (vX.Y.Z). No upgrade needed." and **exit successfully** (skip all remaining phases).
   - If versions are identical **and** `--force` WAS passed: continue to Phase 3 with note "Forced recompile on same version."
   - If versions differ: report "Upgraded gh-aw from vX.Y.Z to vA.B.C" and continue.

---

### Phase 3: Upgrade repository workflows

1. Create a new branch: `git checkout -b chore/gh-aw-upgrade-{after_version}` (e.g., `chore/gh-aw-upgrade-v0.60.0`)
   - If branch already exists, append a timestamp: `chore/gh-aw-upgrade-{after_version}-{YYYYMMDD}`
2. Run the gh-aw upgrade command:
   ```
   gh aw upgrade --verbose
   ```
   This performs: dispatcher agent update, codemod fixes, action version updates, and full recompilation.
3. Check `git diff` for changes:
   - If no files changed: restore original branch (`git checkout -`), delete the upgrade branch, and report "No workflow changes after upgrade. Repo is already current." **Exit successfully.**
   - If files changed: report summary of changed files and continue.

If `--dry-run` was passed: show the diff, restore original branch, delete the upgrade branch, and **exit** with the diff summary. Do not commit or create a PR.

---

### Phase 4: Validate all workflows

1. Run full validation with all security scanners:
   ```
   gh aw validate --strict --json
   ```
   - If `--strict` flag was NOT passed to `/aw-upgrade`, omit `--strict` from the validate command.
2. Parse the JSON output for errors:
   - If validation **passes**: report "All workflows validated successfully." and continue.
   - If validation **fails**: report the validation errors clearly, restore original branch (`git checkout -`), delete the upgrade branch, and **abort**. The user must fix validation errors manually before re-running.

---

### Phase 5: Commit and push

1. Stage all changed files: `git add .github/`
2. Commit with conventional message:
   ```
   git commit -m "chore(ci): recompile workflows for gh-aw {after_version}

   Ran \`gh aw upgrade\` to update dispatcher agent, apply codemods,
   update action pins, and recompile all workflow lock files."
   ```
3. Push the branch: `git push -u origin HEAD`

Report: commit SHA, branch name, number of files changed.

---

### Phase 6: Create and merge PR

1. Create PR:
   ```
   gh pr create \
     --title "chore(ci): upgrade gh-aw workflows to {after_version}" \
     --body "## Summary

   - Upgraded gh-aw extension from {before_version} to {after_version}
   - Ran \`gh aw upgrade\` to apply codemods, update action pins, and recompile lock files
   - All workflows validated successfully

   ## Changed files

   {list of changed files}

   ---
   _Automated by /aw-upgrade_" \
     --label "dependencies,ci"
   ```
   - If labels don't exist, omit `--label` and continue without failing.
2. Wait for CI checks:
   - Poll with `gh pr checks` every 15 seconds, up to 10 minutes max.
   - If checks pass: continue to merge.
   - If checks fail: report which checks failed and **do not merge**. Leave the PR open for manual review. Report the PR URL and exit.
   - If no checks are configured (empty checks): proceed to merge.
3. Merge (unless `--no-merge` was passed):
   ```
   gh pr merge --squash --auto --delete-branch
   ```
   - If `--no-merge` was passed: skip merge, report PR URL, and exit successfully.
4. Restore original branch: `git checkout {original_branch} && git pull`

Report: PR URL, merge status, final state.

---

### Error Recovery

If any phase fails mid-execution:
1. Report the phase number, command that failed, and exit code/stderr
2. If a branch was created, leave it for inspection (do not auto-delete on error)
3. If on the upgrade branch, switch back to the original branch
4. Exit with a clear error message

---

### Final Report

After all phases complete (or on early exit), print a summary:

```
┌─────────────────────────────────────┐
│ /aw-upgrade complete                │
├─────────────────────────────────────┤
│ Repository:  {owner/repo}           │
│ gh-aw:       {before} → {after}     │
│ Workflows:   {N} compiled           │
│ Validation:  ✓ passed               │
│ PR:          {url}                   │
│ Merged:      yes/no/skipped         │
└─────────────────────────────────────┘
```

<!--
## Phase 5 Investigation: GitHub Actions Automation

### How to automate /aw-upgrade as a GitHub Actions workflow

The `gh aw upgrade --create-pull-request` flag already handles the upgrade + PR
creation natively within gh-aw. This is the recommended path for CI automation
rather than reimplementing the logic.

#### Recommended workflow: `.github/workflows/gh-aw-upgrade.lock.yml`

Source as a gh-aw markdown workflow or a plain YAML workflow:

```yaml
name: gh-aw Upgrade Check
on:
  schedule:
    - cron: '0 8 * * 1'  # Weekly Monday 8am UTC
  workflow_dispatch:
    inputs:
      force:
        description: 'Force upgrade even if on latest'
        type: boolean
        default: false

permissions:
  contents: write
  pull-requests: write

jobs:
  upgrade:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install gh-aw
        run: gh extension install github/gh-aw
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Record version before
        id: before
        run: echo "version=$(gh aw version | awk '{print $NF}')" >> "$GITHUB_OUTPUT"

      - name: Upgrade gh-aw extension
        run: gh extension upgrade github/gh-aw --force
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Record version after
        id: after
        run: echo "version=$(gh aw version | awk '{print $NF}')" >> "$GITHUB_OUTPUT"

      - name: Upgrade repository workflows and create PR
        if: steps.before.outputs.version != steps.after.outputs.version || inputs.force
        run: gh aw upgrade --create-pull-request --verbose
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Auto-merge PR
        if: steps.before.outputs.version != steps.after.outputs.version || inputs.force
        run: |
          PR_URL=$(gh pr list --head "gh-aw-upgrade" --json url --jq '.[0].url' 2>/dev/null)
          if [ -n "$PR_URL" ]; then
            gh pr merge "$PR_URL" --squash --auto --delete-branch
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Key considerations:

1. **`gh aw upgrade --create-pull-request`** is the native flag — it handles
   branch creation, commit, and PR in one command. Prefer this over manual
   git operations in CI.

2. **Authentication**: Use `GITHUB_TOKEN` for same-repo. For cross-repo
   provisioning via GPM, use a GitHub App token with `contents: write` and
   `pull-requests: write` on target repos.

3. **GPM provisioning**: This workflow YAML can be deployed across repos using
   the GPM `gpm-workflows-deploy` skill. Add it to gpm-config.yml under
   `workflows:` and GPM will push it to all managed repos.

4. **Alternative: gh-aw native workflow**: Write this as a gh-aw `.md`
   workflow that triggers on schedule, uses bash tools to run `gh extension
   upgrade` and `gh aw upgrade --create-pull-request`. This keeps the
   automation within the gh-aw ecosystem.

5. **Branch naming**: `gh aw upgrade --create-pull-request` creates its own
   branch name. Check `gh aw upgrade --help` for any `--branch` flag in
   future versions if custom naming is needed.

6. **Idempotency**: The workflow is safe to re-run. If no changes result
   from `gh aw upgrade`, no PR is created. If a PR already exists, gh-aw
   will update it or skip.
-->
