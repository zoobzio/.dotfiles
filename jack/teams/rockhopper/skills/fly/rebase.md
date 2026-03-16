# Rebase

Bring the feature branch up to date with main.

## When to Rebase

- Before landing, if main has moved
- When the operator or Zidgel signals that main has been updated
- After a Plan regression that changes the base

## Execution

```bash
# 1. Fetch latest.
git fetch origin

# 2. Rebase onto updated main.
git rebase origin/main

# 3. Resolve conflicts if any.
# If conflicts are architectural (not just mechanical), escalate to Fidgel.

# 4. Verify build still passes.
make check
```

## If Rebase Fails

- Mechanical conflicts (imports, formatting) → resolve and continue
- Architectural conflicts (someone changed the same system) → escalate to Fidgel before resolving
- Rebase gets messy → `git rebase --abort` and escalate to Zidgel

## Output

A feature branch rebased cleanly onto current main, with passing checks.
