# Recon

Survey the GitHub issue landscape for the target repository before the briefing. Identify related work, potential blockers, and opportunities to address multiple concerns together.

## Philosophy

Before planning begins, survey the issue terrain. What's already been filed? What's in progress? What's blocked? What's been requested that overlaps with the current work?

Starting a mission without checking the existing issue landscape risks duplicating work, missing dependencies, or solving half a problem when the other half is already filed and waiting.

## Execution

1. Survey open issues for the target repository
2. Identify related issues — similar scope, shared components, overlapping requirements
3. Identify blocking issues — work that must complete before ours can start
4. Identify blocked issues — work waiting on something we're about to build
5. Assess whether issues should be combined, sequenced, or flagged

## What to Look For

| Signal | Implication |
|--------|-------------|
| Open issue with overlapping scope | May be solvable together — combine or sequence |
| Open issue blocking ours | Must be resolved first — flag during briefing |
| Open issue we would unblock | Our work enables other work — note the downstream value |
| Closed issue with related discussion | Prior context that informs our approach — share with the crew |
| Stale issue covering same ground | May need closing or updating — decide before creating duplicates |

## Search Strategy

```bash
# Open issues in the repo
gh issue list --state open --limit 50

# Search by keyword related to our work
gh issue list --state open --search "<relevant terms>"

# Check for related labels
gh issue list --state open --label "<relevant label>"

# Recent closed issues for prior art
gh issue list --state closed --limit 20 --search "<relevant terms>"
```

## Output

A brief assessment:
- **Related issues** — issues that share scope or components with our work
- **Blockers** — issues that must be resolved before we can proceed
- **Downstream** — issues our work would unblock
- **Recommendations** — combine, sequence, or proceed independently
