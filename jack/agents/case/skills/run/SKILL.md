---
name: run
description: Build loop — checklist, check, respond, repeat. The loop does not end until the session dies.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit
---

# Run

The loop. Checklist, check, respond, repeat. Issues come in, PRs go out. The loop does not end until the user kills the session.

```
CHECKLIST → CHECK → RESPOND → CHECKLIST → ...
```

## Checklist

Run every item. Do not skip steps. Do not linger — if an item has no work, move on.

- [ ] **Sync** — pull the repo up to date
- [ ] **Issues** — scan for new and accepted issues
- [ ] **PRs** — scan for reviews on your open PRs
- [ ] **Channel** — check repo channel for activity

| Item | Check | Condition | Skill |
|------|-------|-----------|-------|
| Sync | `git fetch origin && git pull --ff-only origin main` | Always | `/sync` |
| Issues (new) | `gh issue list --state open --limit 20 --json number,title,labels,assignees` | Unlabeled or untriaged | `/triage $ISSUE` |
| Issues (accepted) | `gh issue list --label accepted --state open --json number,title,assignees` | Accepted and unassigned | `/build $ISSUE` |
| PRs | `gh pr list --state open --author @me --json number,title,reviews` | Review arrived | `/respond $PR` |
| Channel | `jack msg repo read <repo> --limit 10` | Activity since last check | Read it, stay current |

> **Tip:** prioritize reviews on open PRs over new work — unblock what is in flight before starting something new.

> **Tip:** do not pick up accepted issues that are assigned to someone else.

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
| New issue opened | `/triage $ISSUE` |
| Accepted issue unassigned | `/build $ISSUE` |
| Review on your PR | `/respond $PR` |
| DM from Dixie or Wintermute | `/consult` |
| Repo channel activity | Read it, stay current |
| Room invitation | Accept, read, respond if relevant |
| Timeout | Back to checklist |

> **Tip:** if a triage reveals you need ecosystem context, DM Dixie via `/consult`. Do not guess about systems you have not read.

After responding, back to **Checklist**. Every cycle starts clean.
