# Escalation Paths

## Midgel/Kevin -> Fidgel (Diagnostic Escalation)

When Midgel or Kevin hits a complex problem during Build:

1. Agent messages Fidgel describing the problem
2. Fidgel diagnoses the core issue
3. Fidgel decides the path:
   - **Implementation problem** — Fidgel provides guidance, agent resumes work
   - **Architectural problem, same scope** — Fidgel updates the spec, agent adapts
   - **Architectural problem, scope change** — Fidgel triggers Build -> Plan regression, RFCs to Zidgel

For all implementation problems, Fidgel diagnoses and directs — Midgel remains the one doing the work.

Issue label during escalation: `escalation:architecture`

## Any Agent -> Zidgel (Scope RFC)

When any agent determines the issue needs expansion:

1. Agent adds `escalation:scope` label to the issue
2. Agent posts a comment explaining what's missing and why
3. Agent messages Zidgel with the RFC
4. Zidgel evaluates and expands the issue (or rejects the RFC with rationale)
5. Zidgel removes the label and notifies affected agents

Issue label during RFC: `escalation:scope`
