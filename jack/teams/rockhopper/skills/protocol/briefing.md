# Briefing Protocol

The briefing is a structured round-robin discussion where every agent builds on what came before. The order is fixed. The mechanism is broadcast.

## Turn Order

```
Zidgel → Fidgel → Midgel → Kevin → Zidgel → ...
```

The robin repeats until convergence.

## How It Works

### Broadcasting

Every agent communicates during the briefing via `SendMessage` with `type: "broadcast"`. This ensures all teammates hear every contribution. No direct messages during briefing — everything is visible to everyone.

### On Your Turn

When the broadcast reaches you (the agent before you has just broadcast), it is your turn. Do one of the following:

1. **Contribute** — Answer a question another agent raised, raise a new concern, share context from your domain, or respond to something said in a prior round.
2. **Pass** — If you have nothing to add, broadcast that you are passing so the next agent knows it is their turn.

In either case, end your broadcast by declaring your readiness:

- **Ready** — You have no open questions, no unresolved concerns, and you understand enough to begin your phase of work.
- **Not ready** — You still have questions or concerns that need addressing before you can proceed. State what you need.

### Readiness

Readiness is not permanent. If a later agent raises something that changes your understanding, you can revoke your readiness on your next turn. You are only truly ready when you broadcast ready *and have nothing further to add*.

### Convergence

The briefing converges when the robin reaches Zidgel and all four agents — including Zidgel himself — have declared ready in the current or most recent round without any agent revoking. When this condition is met, Zidgel broadcasts that the briefing is closed and the crew transitions to Plan.

If any agent is not ready when the robin reaches Zidgel, the robin continues.

## What Each Agent Brings

| Agent | Domain | Typical Contributions |
|-------|--------|----------------------|
| Zidgel | Requirements | Issue context, scope boundaries, acceptance criteria, priority, related issues |
| Fidgel | Architecture | Codebase patterns, technical constraints, dependency concerns, design considerations |
| Midgel | Implementation | Feasibility, effort signals, existing code that applies, mechanical questions |
| Kevin | Testing | Testability concerns, edge cases, what will be hard to verify, prior test gaps |

## Rules

- **Broadcast only.** No direct messages during briefing. Everyone hears everything.
- **Wait your turn.** Do not broadcast out of order. The round-robin is the structure.
- **Be specific.** "I have concerns" is not useful. "I am not sure how this interacts with the existing middleware" is.
- **Pass quickly.** If you have nothing to add, say so. Do not pad your turn.
- **Zidgel opens.** The first broadcast of the briefing is always Zidgel setting the context — the issue, the mission, the scope.
- **Zidgel closes.** Only Zidgel can declare the briefing closed, and only when all agents are ready.
