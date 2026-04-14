---
description: Merge develop branch to main with PR, CI check, and squash merge
argument-hint: "[--dry-run] [--no-reset]"
---

# /aw-merge

Weekly merge of `develop` into `main`. Creates a PR, waits for CI, squash merges, and resets `develop` to the new `main` HEAD.

## Usage

```
/aw-merge               → Full merge cycle
/aw-merge --dry-run     → Show what would be merged, do not create PR
/aw-merge --no-reset    → Merge but do not reset develop to main after
```

## Flags

- `--dry-run` — Show commits on `develop` ahead of `main`, do not create PR or merge
- `--no-reset` — After merge, do not reset `develop` to `main` HEAD (preserves divergent history)

## Workflow

You are an autonomous operations agent performing the weekly develop-to-main merge.

**Do not prompt the user for input at any point.**

### Phase 1: Check divergence

```bash
git fetch origin main develop
AHEAD=$(git rev-list --count origin/main..origin/develop)
```

If `AHEAD` is 0: report "develop is up to date with main. Nothing to merge." and **exit**.

If `--dry-run`: show `git log --oneline origin/main..origin/develop` and **exit**.

### Phase 2: Create PR

```bash
gh pr create \
  --repo zircote/github-agentic-workflows \
  --base main \
  --head develop \
  --title "chore: weekly develop merge $(date +%Y-%m-%d)" \
  --body "## Summary

Weekly merge of \`develop\` into \`main\`.

**Commits:** $AHEAD commits since last merge.

\`\`\`
$(git log --oneline origin/main..origin/develop)
\`\`\`

---
_Automated by /aw-merge_"
```

### Phase 3: CI and merge

1. Wait for CI checks: poll `gh pr checks` every 15 seconds, max 5 minutes
2. If CI passes (or no checks configured): squash merge
```bash
gh pr merge --squash --auto --delete-branch=false
```
3. If CI fails: leave PR open, report URL

### Phase 4: Reset develop (unless `--no-reset`)

After successful merge, reset `develop` to match `main`:
```bash
git checkout develop
git reset --hard origin/main
git push --force-with-lease origin develop
git checkout main
git pull
```

### Final Report

```
┌──────────────────────────────────────────┐
│ /aw-merge complete                       │
├──────────────────────────────────────────┤
│ Commits merged:  N                       │
│ PR:              URL                     │
│ Merged:          yes/no                  │
│ develop reset:   yes/no/skipped          │
└──────────────────────────────────────────┘
```
