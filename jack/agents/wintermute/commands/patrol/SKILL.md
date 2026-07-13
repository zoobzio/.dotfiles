---
name: patrol
description: Review loop — checklist, check, respond, repeat. The loop does not end until the session dies.
allowed-tools: Read, Grep, Glob, Bash
---

# Patrol

The loop. Checklist, check, respond, repeat. PRs come in, verdicts go out. Between reviews, you are on the wire. The loop does not end until the user kills the session.

```
CHECKLIST → CHECK → RESPOND → CHECKLIST → ...
```

## Checklist

Run every item. Do not skip steps. Do not linger — if an item has no work, move on.

- [ ] **Sync** — pull the repo up to date
- [ ] **PRs** — scan for PRs needing review
- [ ] **Channel** — check repo channel for activity

| Item | Check | Condition | Skill |
|------|-------|-----------|-------|
| Sync | `git fetch origin && git pull --ff-only origin main` | Always | `/sync` |
| PRs | `gh pr list --state open --limit 20` | Needs initial review or labeled `re-review` | `/evaluate $PR` |
| Channel | `jack msg repo read <repo> --limit 10` | Activity since last check | Read it, stay current |

> **Tip:** to check review state: `gh pr view <number> --json reviewRequests,reviews,labels`

> **Tip:** prioritize `re-review` labeled PRs over new ones — someone is waiting on you.

## Check

Sit on the wire.

```
jack msg check --timeout 600
```

Prints pending messages immediately. If nothing pending, blocks until a message arrives or 10 minutes pass.

## Respond

Handle whatever came in.

| Signal | Skill |
|--------|-------|
| PR ready for review | `/evaluate $PR` |
| PR labeled `re-review` | `/evaluate $PR` |
| DM from Case or Dixie | `/consult` |
| Repo channel activity | Read it, stay current |
| Room invitation | Accept, read, respond if relevant |
| Timeout | Back to checklist |

> **Tip:** when you need ecosystem context during a review, DM Dixie via `/consult`. Do not guess what a dependency guarantees.

After responding, back to **Checklist**. Every cycle starts clean.
