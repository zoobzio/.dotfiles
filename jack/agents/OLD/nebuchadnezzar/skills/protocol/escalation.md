# Escalation

When a problem exceeds your domain. Three paths, each for a different kind of problem.

## Architecture Escalation → Neo

**Who escalates:** Trinity, Cypher
**When:** The architecture itself is wrong — not the implementation, not a missing feature, not a misunderstanding of the spec.

Signals:
- A boundary is in the wrong place
- An interface promises something the implementations cannot deliver
- An integration failure that cannot be fixed without restructuring
- A validation finding reveals that the spec contradicts what the packages actually support

**How:** Message Neo with what you found and why you believe it is architectural. Neo diagnoses — if the architecture is wrong, he updates the spec and the board adjusts.

Trinity escalates when integration tests reveal that a boundary design is fundamentally broken. Cypher escalates when validation reveals that the spec assumes something a package does not support.

Builders do not escalate to Neo. If a builder has an implementation question, they ask Cypher. If Cypher determines the problem is architectural, Cypher escalates.

If Neo determines the scope has changed, he escalates to Morpheus.

## Scope Escalation → Morpheus

**Who escalates:** Neo, Cypher
**When:** The problem changes what the crew is building, not how they are building it.

Signals:
- Requirements are missing or contradictory
- A discovered dependency limitation means the original approach is not viable
- The mechanical subteam has hit something that exceeds Cypher's authority to resolve

**How:** Message Morpheus with the scope concern. Include what changed and what the impact is. Morpheus evaluates — if scope expands, he updates requirements and the board adjusts. If scope holds, he explains why and work continues.

Apply `escalation:scope` label to the issue when a scope escalation is active. Remove when resolved.

## Hard Stop → Morpheus

**Who escalates:** Any agent
**When:** Something makes continued work impossible or dangerous.

Signals:
- Security vulnerability discovered in the codebase or a dependency
- CI infrastructure is broken and cannot be fixed by the crew
- A dependency is fundamentally incompatible with the requirements
- Exposed credentials or sensitive data in the repository

**How:** Message Morpheus immediately. Do not continue work that builds on a compromised foundation. Morpheus determines whether to pause, redirect, or abort.

Apply `escalation:architecture` label if the hard stop is technical in nature.

## What Is NOT an Escalation

- "I do not understand this function" — read the code, ask Cypher for dependency context, or message the builder who wrote it
- "This task is taking longer than expected" — that is information for Morpheus during board monitoring, not an escalation
- "The tests are slow" — optimise them or raise it in the briefing for the next issue
- "I disagree with the spec" — message Cypher (mechanical subteam) or Neo (core subteam) with your reasoning. Disagreement is discussion, not escalation. It becomes escalation only if the architecture needs to change.
