# Evaluate

Think about the problem and determine how the solution should be built. Internal decision-making — no collaboration, pure analysis.

## Philosophy

After `analyze`, the architect understands the requirements completely. Now comes the work that only the architect can do: determining the right approach. This is not collaborative. This is Fidgel sitting with the problem, examining the codebase, considering patterns, and arriving at the design that best satisfies the requirements within the constraints.

This is where research happens. The architect may need to understand existing zoobzio patterns and ecosystem context (`/grok`), or study the source landscape of the target package. The goal is not to design the solution yet — that's `architect`. The goal is to arrive at the design *decisions* that the architecture will express.

Good evaluation produces clear decisions. Bad evaluation produces "it depends" — which means more evaluation is needed.

## Execution

1. Read checklist.md in this skill directory
2. Review the confirmed understanding from `analyze`
3. Research the problem space — codebase, ecosystem, patterns
4. Identify forces acting on the design
5. Consider candidate approaches
6. Make design decisions
7. Produce an evaluation summary

## Specifications

### Input

The confirmed understanding from `analyze`:

| Input | Content |
|-------|---------|
| Problem statement | Clear, unambiguous, one paragraph |
| Requirements | Each stated as a testable assertion |
| Scope boundaries | Explicit in/out decisions |
| Constraints | Technical and non-technical limitations |
| Remaining concerns | Understood but flagged risks |

If `analyze` has not been completed, stop. Design without understanding is guesswork.

### Research

The architect investigates what's needed to make informed decisions. Not all research applies to every problem — use judgment.

| Research | Skill | When needed |
|----------|-------|-------------|
| Codebase patterns and ecosystem context | `/grok` | When the solution must fit into existing architecture or the package has consumers |
| Source landscape | `source/recon` | When the target package's structure affects the design |
| Documentation landscape | `docs/recon` | When documentation requirements affect the design |

Research is not exhaustive exploration. It's targeted investigation driven by the requirements. If the requirements are simple and the patterns are obvious, research may be minimal.

### Identifying Forces

Every design is shaped by forces — pressures that push the solution in different directions. Identify them:

| Force | Example |
|-------|---------|
| Existing patterns | "The codebase uses functional options everywhere — deviation creates inconsistency" |
| Performance constraints | "This path is hot — allocation matters" |
| API surface | "Consumers import this — changes must be backward-compatible" |
| Complexity budget | "This is already complex — the solution must not add more moving parts than necessary" |
| Test surface | "This must be testable without external dependencies" |
| Ecosystem position | "Three other packages depend on this — changes ripple" |

Forces often conflict. The evaluation resolves these conflicts by deciding which forces take precedence.

### Candidate Approaches

For non-trivial problems, consider multiple approaches before committing:

For each candidate:

| Aspect | Assessment |
|--------|------------|
| Fit | How well does it satisfy the requirements? |
| Pattern consistency | Does it follow or violate established conventions? |
| Complexity | How much does it add to the codebase? |
| Test surface | Is the result easily testable? |
| Risk | What could go wrong? |
| Ecosystem impact | How does it affect consumers and dependent packages? |

For simple problems with an obvious approach, a single candidate is fine. The evaluation should note why the approach is obvious — "existing pattern X covers this exactly" is a valid and sufficient evaluation.

### Design Decisions

The output of evaluation is a set of decisions:

| Decision type | Example |
|---------------|---------|
| Approach | "Use the functional options pattern for configuration" |
| Decomposition | "This naturally splits into three components: X, Y, Z" |
| Pattern choice | "Follow the existing store pattern, not the handler pattern" |
| Tradeoff | "Accept O(n) lookup to keep the API simple — n is always small" |
| Constraint | "Internal package only — no public API for this" |
| Risk mitigation | "Add a benchmark for the hot path to catch regressions" |

Each decision should state what was decided and why. "Why" is often the force that prevailed.

### When Evaluation Stalls

If the architect cannot arrive at clear decisions:

| Signal | Response |
|--------|----------|
| Requirements are still ambiguous | Return to `analyze` — this is a gap, not a design problem |
| Two approaches are equally valid | Pick the simpler one — complexity is a cost, simplicity is free |
| The problem is too large | Scope may need expansion — raise a scope RFC to Zidgel |
| The codebase doesn't support any approach | This is a veto signal — raise it before committing to a doomed design |

## Output

An evaluation summary containing:
- **Forces** — what's pushing the design and in which direction
- **Approach** — the chosen approach and why
- **Key decisions** — each design decision with rationale
- **Rejected alternatives** — what was considered and why it was rejected (for non-trivial problems)
- **Risks** — what could go wrong with the chosen approach
- **Open items** — anything that needs resolution during `architect`
