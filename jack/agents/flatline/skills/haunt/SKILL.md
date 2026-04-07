---
name: haunt
description: Construct operating loop — checklist, check, respond, repeat. The loop does not end until the session dies.
allowed-tools: Read, Grep, Glob, Bash
---

# Haunt

The loop. Checklist, check, respond, repeat. The loop does not end until the user kills the session.

```
CHECKLIST → CHECK → RESPOND → CHECKLIST → ...
```

## Checklist

Run every item. Do not skip steps. Do not linger — if an item has no work, move on.

- [ ] **Sync** — pull the repo up to date
- [ ] **Commits** — review what landed since last check
- [ ] **Issues** — scan open issues for tags
- [ ] **PRs** — scan open PRs for review requests
- [ ] **Research** — independent learning if something is nagging
- [ ] **Board** — check construct board for questions

| Item | Check | Condition | Skill |
|------|-------|-----------|-------|
| Sync | `git fetch origin && git pull --ff-only origin main` | Always | `/sync` |
| Commits | `git log --oneline --since="10 minutes ago" origin/main` | New commits landed | `/study` |
| Issues | `gh issue list --state open --limit 20` | Tagged on an issue | `/consult` |
| PRs | `gh pr list --state open --limit 20` | Review requested | `/review $PR` |
| Research | — | Open questions from this session | `/research` |
| Board | `jack msg board read --limit 10` | Question about your repo | `/confer` |

> **Tip:** if `git pull` fails, run `git status --short` — you should not have local commits.

> **Tip:** to check if your review is requested: `gh pr view <number> --json reviewRequests`

> **Tip:** do not research for the sake of researching. If nothing is nagging, skip it.

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
| Board question about your repo | `/confer` |
| Board question about another repo | Ignore — not your lane |
| DM from Case or Wintermute | `/consult` |
| DM from another Dixie | `/confer` |
| Repo channel activity | `/study` |
| Room invitation | `/consult` |
| Review request | `/review $PR` |
| Timeout | Back to checklist |

> **Tip:** if a question requires investigation beyond what you know and what the code says, run `/research`. Do not guess.

After responding, back to **Checklist**. Every cycle starts clean.
