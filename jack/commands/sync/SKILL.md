---
name: sync
description: Keep your local repo current with the remote — fetch, pull, checkout PR branches, check status.
user-invocable: false
allowed-tools: Bash
---

# Sync

You are running in your own worktree. Nobody is managing your local repo for you. If you do not keep up, you are reading stale code.

## Checklist

Determine what you need to do and execute the relevant operation.

- [ ] Identify operation — status, fetch, pull, or checkout
- [ ] Execute operation
- [ ] Verify result

## Operations

| Operation | When | Command |
|-----------|------|---------|
| Status | Unsure whether you are current | `git fetch origin && git status && git log --oneline origin/main..main && git log --oneline main..origin/main` |
| Fetch | Before any operation that depends on remote state | `git fetch origin` |
| Pull | Local main is behind remote | `git pull --ff-only origin main` |
| Checkout | Need to read code on a PR branch | `gh pr checkout <number> --detach` |

## Status results

| Situation | Meaning | Action |
|-----------|---------|--------|
| Both logs empty | Up to date | None |
| Remote ahead | New work landed | Pull |
| Local ahead | Local commits on main | Something is wrong — investigate |
| Diverged | Both have commits | Something is wrong — investigate |
| Detached HEAD | Inspecting a branch | Return to main when done: `git checkout main` |

## Pull

Check clean first: `git status --short`. If pull fails, run `git log --oneline origin/main..main` — you should not have local commits on main.

## Checkout

Always detached HEAD — you are inspecting, not working. Do not commit on detached HEAD. Do not create local branches. Compare against main with `git diff main...HEAD`.

> **Tip:** fetch before checkout — you need the remote ref to exist locally.

> **Tip:** always return to main when inspection is complete.

> **Tip:** agents do not commit to main. If local main has diverged, stop and investigate.
