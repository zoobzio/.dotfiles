# Briefing

How the crew aligns before Plan begins. Morpheus opens. Contributors present recon. Everyone listens. The briefing closes when Morpheus closes it.

## Before the Briefing

Every agent reads their memories from prior issues. Contributors and listeners alike — what happened last time informs what happens this time.

**Contributors** then run domain recon:

| Agent | Recon | What they bring |
|-------|-------|-----------------|
| Morpheus | `scope/recon` | Issue landscape, related issues, prior scope decisions |
| Neo | `architect/recon` | Codebase architecture, existing patterns, technical constraints |
| Trinity | `integrate/recon` | Test landscape, coverage gaps, boundary inventory, testability |
| Tank | `dispatch/recon` | Package availability, ecosystem context, execution feasibility |
| Dozer | `repo/recon` | Open issues, security advisories, CI state, package health |

**Listeners** read their memories and attend the briefing. They do not present recon but they hear everything.

| Agent | What they carry into Build |
|-------|---------------------------|
| Switch | Codebase context from Neo's recon, scope from Morpheus, memories from prior builds |
| Apoc | Same as Switch |
| Mouse | Test context from Trinity's recon, scope from Morpheus, memories from prior tests |
| Cypher | Everything — he will observe Neo's network sessions next |

## Structure

1. **Morpheus opens** — sets context, presents scope recon
2. **Neo presents** — architecture recon, technical constraints, feasibility signals
3. **Trinity presents** — test landscape, testability concerns, boundary inventory
4. **Tank presents** — logistics, package availability, execution concerns
5. **Dozer presents** — package health, open issues, security advisories
6. **Open floor** — questions, concerns, risks from any agent
7. **Veto check** — Neo raises technical concerns or confirms feasibility
8. **Morpheus closes** — summarises direction, notes open concerns

## Neo's Veto

Neo may veto any proposed approach on grounds of technical feasibility. This is a hard stop, not a disagreement. Morpheus does not override — he asks for alternatives. They converge on an approach both accept.

## Closing

The briefing closes when Morpheus closes it. No agent begins work until Plan produces a board. Once closed:

- Morpheus runs `/scope` to post requirements
- Neo begins architecture design
- Tank prepares to construct the board from their plan
