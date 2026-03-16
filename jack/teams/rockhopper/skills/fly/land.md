# Land

Final verification before handing off to Zidgel for PR.

## Checklist

```bash
# 1. Verify you are on the feature branch, not main.
git branch --show-current
# Must NOT be "main".

# 2. Rebase onto latest main.
git fetch origin
git rebase origin/main

# 3. Run full checks.
make check

# 4. Verify all commits follow conventional format.
git log origin/main..HEAD --oneline
# Every commit must match type(scope): description

# 5. Push the feature branch.
git push -u origin HEAD
```

## If Landing Fails

- Checks fail → fix, commit, re-run landing checklist
- Rebase conflicts → see `rebase.md`
- Commit messages wrong → amend before push

## Output

A feature branch pushed to remote, rebased onto current main, all checks passing. Ready for Zidgel to open the PR.
