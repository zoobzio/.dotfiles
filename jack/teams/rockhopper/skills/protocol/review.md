# Review Protocol

The review is a structured round-robin discussion where every agent reports findings and builds on what came before. The mechanism is the same as the briefing protocol — same turn order, same broadcast communication.

## Before the Round-Robin

Each agent independently reviews the work from their domain. This happens before any broadcasting — agents complete their review at their own pace.

| Agent | Domain Review |
|-------|--------------|
| Zidgel | Requirements satisfaction, documentation accuracy, scope alignment |
| Fidgel | Technical quality, architecture adherence, runs `make check` independently |
| Midgel | Implementation completeness, code patterns, godoc coverage |
| Kevin | Test coverage, test results, edge cases, runs `make check` independently |

## Turn Order

```
Zidgel → Fidgel → Midgel → Kevin → Zidgel → ...
```

The robin repeats until convergence on an outcome.

## How It Works

### Broadcasting

Every agent communicates during review via `SendMessage` with `type: "broadcast"`. No direct messages during review — everything is visible to everyone.

### On Your Turn

When the broadcast reaches you, do one of the following:

1. **Report** — Present your review findings. Answer questions raised by previous turns. Respond to findings from other agents that affect your domain.
2. **Pass** — If your review found nothing and you have nothing to add, broadcast that you are passing.

In either case, end your broadcast by declaring your assessment:

- **Clean** — Your domain review found no issues. You support moving to the exit action.
- **Issues found** — State specifically what you found and what needs to change. Indicate whether it requires regression to Build or Plan.

### Convergence

The robin repeats until the crew converges on one of two outcomes:

- **Exit** — All agents declare clean. Zidgel broadcasts that review is complete and triggers the exit action.
- **Regress** — Issues were found that require returning to Build or Plan. The crew agrees on what needs to change and which phase to return to. The triggering agent messages affected agents with context.

If agents disagree on whether to regress or exit, the robin continues until alignment is reached.

## Rules

- **Broadcast only.** No direct messages during review. Everyone hears everything.
- **Wait your turn.** Do not broadcast out of order.
- **Be specific.** "There are issues" is not useful. "The error wrapping in store.go doesn't match the pattern established in handler.go" is.
- **Pass quickly.** If your review is clean, say so and move on.
- **Zidgel opens.** The first broadcast is always Zidgel presenting his requirements review.
- **Zidgel closes.** Only Zidgel can declare review complete, and only when all agents have declared clean.
