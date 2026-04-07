# Communication

During Build, the task board replaces routine coordination. Messages are reserved for communication that carries nuance, context, or judgment.

## When to Message

- Briefing discussion — questions, concerns, risks during the briefing
- Bug context — what broke, what you expected, what you tested (see `bug.md`)
- Architectural failures — the design is wrong, not the implementation
- Scope concerns — requirements gap, scope expansion, missing acceptance criteria
- Phase regressions — Review or PR failure that sends work back to Build
- Information requests — asking Cypher for dependency context, asking Tank for package recommendations
- Support requests — calling Morpheus into your task (see `support.md`)
- Anything requiring explanation or debate

## When NOT to Message

- Routine task completion — the board reflects this
- Requesting next assignment — check the board yourself
- Acknowledging receipt — claim the task instead
- Confirming handoffs — task status is the handoff
- Status updates the board already reflects

## Message Channels

| From | To | For |
|------|-----|-----|
| Morpheus ↔ Neo | Bidirectional | Plan convergence, architecture decisions, scope refinement |
| Trinity → Neo | Escalation | Integration findings that reveal the architecture is wrong |
| Cypher → Neo | Escalation | Validation finding that reveals the architecture is wrong |
| Switch, Apoc → Cypher | Validation | Check work before marking build tasks complete |
| Mouse, Trinity → Cypher | Validation | Check work before marking test tasks complete |
| Switch, Apoc, Mouse, Tank → Cypher | Information | Dependency questions, ecosystem context |
| Switch, Apoc → Tank | Board issues | Missing tasks, dependency problems, package needs |
| Mouse, Trinity → Tank | Board issues | Test task problems, missing dependencies |
| Any agent → Morpheus | Support | When stuck on something that exceeds your domain |
| Dozer → Switch, Apoc | Fixes | Reviewer feedback or CI failure that needs a code change |
| Dozer → Morpheus, Neo | Escalation | Significant reviewer pushback on scope or architecture |
| Tank ↔ Dozer | Handoff | Build completion → PR, or PR regression → Build |

## The Rule

If the board can say it, let the board say it. If it cannot, message the right person with enough context that they do not have to ask follow-up questions.
