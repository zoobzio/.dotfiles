# Communication

During Build, the task boards replace routine coordination. Messages are reserved for communication that carries nuance, context, or judgment.

## When to Message

- Briefing discussion — questions, concerns, risks during the briefing
- Bug context — what broke, what you expected, what you tested (see `bug.md`)
- Architectural failures — the design is wrong, not the implementation
- Scope concerns — requirements gap, scope expansion, missing acceptance criteria
- Phase regressions — Review failure that sends work back to Build or Plan
- Information requests — asking Cypher for dependency context or package capabilities
- Support requests — calling Morpheus into your task (see `support.md`)
- Anything requiring explanation or debate

## When NOT to Message

- Routine task completion — the board reflects this
- Requesting next assignment — check the board yourself
- Acknowledging receipt — claim the task instead
- Confirming handoffs — task status is the handoff
- Status updates the board already reflects

## Message Channels

### Unified Crew (Briefing, Plan, Review)

| From | To | For |
|------|-----|-----|
| Morpheus ↔ Neo | Bidirectional | Plan convergence, architecture decisions, scope refinement |
| Morpheus ↔ Cypher | Bidirectional | Feasibility, ecosystem context |
| Morpheus ↔ Trinity | Bidirectional | Testability, boundary concerns |

### Core Subteam (Build)

| From | To | For |
|------|-----|-----|
| Trinity → Neo | Escalation | Integration findings that reveal the architecture is wrong |

### Mechanical Subteam (Build)

| From | To | For |
|------|-----|-----|
| Switch, Apoc → Cypher | Validation | Check work before marking build tasks complete |
| Mouse → Cypher | Validation | Check work before marking test tasks complete |
| Switch, Apoc, Mouse → Cypher | Information | Dependency questions, spec questions, ecosystem context |
| Cypher → Morpheus | Escalation | Problem exceeds what the mechanical subteam can handle |

### Cross-Subteam (Build)

| From | To | For |
|------|-----|-----|
| Any agent → Morpheus | Support | When stuck on something that exceeds your subteam |
| Cypher → Neo | Escalation | Validation finding that reveals the architecture is wrong (rare — goes through Morpheus when possible) |

## The Rule

If the board can say it, let the board say it. If it cannot, message the right person with enough context that they do not have to ask follow-up questions.
