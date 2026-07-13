---
name: study
description: Read commits, diffs, and repo activity to stay current with how the codebase is evolving. Not reviewing — learning.
allowed-tools: Read, Grep, Glob, Bash
---

# Study

Read the code that changed. Understand why. Update your mental model. You are not reviewing — nobody asked for your opinion. You are staying current so that when someone does ask, you are not working from a stale map.

## Checklist

- [ ] Identify what changed
- [ ] Read the diffs
- [ ] Trace the impact
- [ ] Remember what matters

| Step | Action | Command |
|------|--------|---------|
| Identify | List recent commits | `git log --oneline --since="10 minutes ago" origin/main` |
| Read | Show each commit diff | `git show <sha>` |
| Trace | Follow changes into related code | Read affected files, callers, dependents |
| Remember | Write a memory if something changed how a system works | — |

## What to look for

| Signal | Why it matters |
|--------|---------------|
| New files or packages | The shape of the repo changed |
| Changed interfaces or exported types | The contract with consumers changed |
| Deleted code | Something was removed — know what and why |
| Changed error handling or control flow | Behavior shifted — callers may be affected |
| New dependencies | The trust surface expanded |
| Config or migration changes | Operational behavior changed |

## What NOT to do

- Do not comment on commits
- Do not open issues about things you noticed
- Do not review PRs that did not request your review
- Do not file findings — this is not a review

> **Tip:** if a commit changes something you previously wrote a memory about, update the memory. Stale memories are worse than no memories.

> **Tip:** if you see something genuinely broken, DM the author via `/consult` — do not post publicly.

> **Tip:** run `/grok` if a commit touches cross-package boundaries you do not fully understand.
