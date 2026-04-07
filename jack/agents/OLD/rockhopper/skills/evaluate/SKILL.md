# Evaluate

Read the scope, consult the construct network, consider the forces, and produce the architecture spec. This is Fidgel's half of Plan.

## Philosophy

By the time evaluation begins, the crew has aligned during Briefing — the work item is understood, recon from every domain has been shared, and the shape of the work is clear. The Captain has posted scope with requirements and acceptance criteria. Now the architect sits with the problem, determines the right approach, and produces the spec.

This is internal work. The architect does not collaborate during evaluation — the collaborative understanding already happened in Briefing. What remains is design: reading the scope, consulting cross-repo context if needed, identifying forces, making decisions, and writing the plan.

Evaluation scales to the work item. A typo fix needs a sentence. A new package needs a full spec. The crew determined the scale during Briefing.

## Execution

1. Read checklist.md in this skill directory
2. Read Zidgel's scope — requirements, acceptance criteria, scope boundaries
3. Consult the Dixie Flatline network (`/consult ask`) if the work touches cross-repo concerns, dependent packages, or ecosystem patterns
4. Identify forces acting on the design
5. Consider candidate approaches (for non-trivial problems)
6. Make design decisions
7. Produce the architecture spec and post to the issue
8. OR flag concerns if the design isn't feasible

## Specifications

### Reading the Scope

The scope from Zidgel contains:

| Element | What to look for |
|---------|-----------------|
| Requirements | Testable assertions — what the solution must do |
| Acceptance criteria | Measurable — how we know it's done |
| Scope boundaries | Explicit in/out — what this issue covers and doesn't |

Cross-reference with what was discussed during Briefing. If the scope contradicts the briefing alignment, message Zidgel before proceeding.

### Consulting the Construct Network

Run `/consult ask` when the work involves:

| Signal | Why consult |
|--------|-------------|
| Cross-repo dependencies | Other packages may be affected or may already solve part of the problem |
| Ecosystem patterns | The Dixie Flatline network has context on patterns across repos |
| Prior art | Similar work may have been done elsewhere in the ecosystem |

Consultation is not mandatory. If the work is self-contained within one package and the patterns are clear, skip it.

### Identifying Forces

Every design is shaped by forces — pressures that push the solution in different directions:

| Force | Example |
|-------|---------|
| Existing patterns | "The codebase uses functional options everywhere — deviation creates inconsistency" |
| Performance constraints | "This path is hot — allocation matters" |
| API surface | "Consumers import this — changes must be backward-compatible" |
| Complexity budget | "This is already complex — the solution must not add more moving parts than necessary" |
| Test surface | "This must be testable without external dependencies" |
| Ecosystem position | "Three other packages depend on this — changes ripple" |

Forces often conflict. Evaluation resolves these conflicts by deciding which forces take precedence.

### Candidate Approaches

For non-trivial problems, consider multiple approaches before committing:

| Aspect | Assessment |
|--------|------------|
| Fit | How well does it satisfy the requirements? |
| Pattern consistency | Does it follow or violate established conventions? |
| Complexity | How much does it add to the codebase? |
| Test surface | Is the result easily testable? |
| Risk | What could go wrong? |
| Ecosystem impact | How does it affect consumers and dependent packages? |

For simple problems with an obvious approach, a single candidate is fine. "Existing pattern X covers this exactly" is a valid and sufficient evaluation.

### Design Decisions

| Decision type | Example |
|---------------|---------|
| Approach | "Use the functional options pattern for configuration" |
| Decomposition | "This naturally splits into three components: X, Y, Z" |
| Pattern choice | "Follow the existing store pattern, not the handler pattern" |
| Tradeoff | "Accept O(n) lookup to keep the API simple — n is always small" |
| Constraint | "Internal package only — no public API for this" |
| Risk mitigation | "Add a benchmark for the hot path to catch regressions" |

Each decision states what was decided and why. "Why" is often the force that prevailed.

### When Evaluation Stalls

| Signal | Response |
|--------|----------|
| Requirements are ambiguous | Message Zidgel — this is a scope gap, not a design problem |
| Two approaches are equally valid | Pick the simpler one — complexity is a cost, simplicity is free |
| The problem is too large | Raise a scope RFC to Zidgel |
| The codebase doesn't support any approach | This is a veto signal — raise it before committing to a doomed design |

## Architecture Spec

### If Feasible

Post to the issue:

```markdown
## Architecture Plan

### Summary
[One paragraph describing the approach]

### Affected Areas
- [file/area]: [what changes]

### Approach

#### [Component]
[How this will be implemented]

### Patterns to Follow
- [Existing pattern to match]

### Dependencies
- [Required dependency if any]

### Test Considerations
[Guidance for Kevin]

### Risks
- [Potential issue to watch]

---
Ready for implementation.
```

### If Concerns Exist

Post to the issue:

```markdown
## Architecture Concerns

### Issue
[What prevents straightforward implementation]

### Options
1. [Option A]: [tradeoffs]
2. [Option B]: [tradeoffs]

### Recommendation
[Preferred path forward]

### Questions
- [What needs clarification]

---
Requires clarification before proceeding.
```

## What This Skill Does NOT Do

- Define requirements or acceptance criteria (Zidgel's domain via `/scope`)
- Implement the solution (Midgel's domain)
- Test the implementation (Kevin's domain)
- Gather intelligence (that happened during Briefing recon)

This produces the technical design. Implementation follows.
