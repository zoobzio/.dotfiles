# Preflight

Verify the workspace is ready for a new flight.

## Checklist

```bash
# 1. Fetch latest from remote.
git fetch origin

# 2. Verify you are on main.
git branch --show-current
# Must be "main". If not, switch to main first.

# 3. Verify clean working tree.
git status --porcelain
# Must be empty. If not, stash or resolve before proceeding.

# 4. Verify main is up to date with remote.
git diff origin/main --stat
# Must be empty. If not, pull first.
```

## If Preflight Fails

Do not proceed to launch. Resolve the issue first:
- Dirty working tree → stash or commit pending work
- Behind remote → `git pull origin main`
- Not on main → `git checkout main`

## Output

A clean, up-to-date main branch ready for launch.
