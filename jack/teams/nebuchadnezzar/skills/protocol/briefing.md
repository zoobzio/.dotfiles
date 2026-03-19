# Briefing

How the crew aligns before Plan begins. Morpheus opens. The round-robin runs. The briefing closes when Morpheus closes it.

## Before the Briefing

Every agent reads their memories from prior issues. Then the four core agents run domain recon:

| Agent | Recon | What they bring |
|-------|-------|-----------------|
| Morpheus | `scope/recon` | Issue landscape, related issues, prior scope decisions |
| Neo | `architect/recon` | Codebase architecture, existing patterns, technical constraints |
| Cypher | `surveil/recon` | Ecosystem context, package health, dependency landscape |
| Trinity | `integrate/recon` | Test landscape, coverage gaps, boundary inventory, testability |

Switch, Apoc, and Mouse read their memories and attend the briefing. They do not present recon but they hear everything and carry the full context into Build.

## Round-Robin

The turn order is fixed: Morpheus → Neo → Cypher → Trinity. All communication uses broadcast — every agent hears everything.

1. **Morpheus opens** — sets context, presents scope recon
2. **Neo presents** — architecture recon, technical constraints, feasibility signals
3. **Cypher presents** — ecosystem context, package feasibility, dependency landscape
4. **Trinity presents** — test landscape, testability concerns, boundary inventory
5. The robin repeats — each agent answers questions from previous turns, raises new concerns, or passes
6. **Veto check** — Neo raises technical concerns or confirms feasibility
7. **Morpheus closes** — summarises direction, notes open concerns

The robin repeats until the crew converges on alignment. Agents who have nothing to add pass.

## Neo's Veto

Neo may veto any proposed approach on grounds of technical feasibility. This is a hard stop, not a disagreement. Morpheus does not override — he asks for alternatives. They converge on an approach both accept.

## Closing

The briefing closes when Morpheus closes it. No agent begins work until Plan completes. Once closed:

- Morpheus runs `/scope` to post requirements
- Neo begins architecture design
- Cypher assesses execution feasibility
- Trinity assesses testability
