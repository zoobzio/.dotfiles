# Technical Review

Spec correspondence and architecture review. Does the implementation faithfully represent the specification?

## Philosophy

The specification is a blueprint. The implementation is a building. This review verifies correspondence — does one faithfully represent the other? Are the patterns correct? Is the architecture sound? Is it complete?

A technically excellent implementation of the wrong design is still wrong. A correct design implemented with the wrong patterns will rot. Both the "what" and the "how" must be right. This review verifies both.

## Execution

1. Retrieve the architecture plan from the GitHub issue
2. Read the implementation — all affected files
3. Verify spec correspondence
4. Verify pattern correctness
5. Assess architecture soundness
6. Check completeness
7. Render judgment

## Specifications

### Spec Correspondence

Walk the architecture plan section by section:

| Check | Question |
|-------|----------|
| Summary | Does the implementation match the described approach? |
| Affected areas | Were all listed files/areas modified as specified? |
| Components | Does each component match its specified implementation? |
| Dependencies | Were specified dependencies used correctly? |

Deviations from the spec are not inherently wrong — the implementation may have improved on the design. But undocumented deviations are defects. If the implementation diverged from the spec, the spec should have been updated during Build.

### Pattern Correctness

| Check | Question |
|-------|----------|
| Existing patterns | Does the implementation follow patterns established in the codebase? |
| Specified patterns | Does it follow patterns called out in the architecture plan? |
| Consistency | Are patterns applied consistently across all affected files? |
| Conventions | Does naming, structure, and organisation follow project conventions? |

Pattern violations compound. One inconsistency becomes a precedent for the next.

### Architecture Soundness

| Check | Question |
|-------|----------|
| Abstractions | Are the abstraction boundaries in the right place? |
| Coupling | Are components appropriately decoupled? |
| Complexity | Is the complexity proportional to the problem? |
| Extensibility | Does the design accommodate reasonable future changes without over-engineering? |

### Completeness

| Check | Question |
|-------|----------|
| All components | Is everything in the spec implemented? |
| Error handling | Are error paths handled appropriately? |
| Edge cases | Are known edge cases from the spec addressed? |
| No orphans | Are there no dead code paths or unused scaffolding? |

### Regression Paths

| Finding | Path |
|---------|------|
| Implementation issue — pattern violation, missing error handling, incomplete component | Back to Build |
| Undocumented deviation — implementation diverged from spec without explanation | Back to Build (with spec update) |
| Architecture flaw — abstraction boundary wrong, coupling too tight, design doesn't hold | Back to Plan |
| Spec inadequacy — the architecture plan itself was insufficient | Back to Plan |

## Output

A determination:
- **Pass** — implementation corresponds to spec, patterns correct, architecture sound, complete
- **Regress to Build** — specific issues identified, listed with expected corrections
- **Regress to Plan** — architectural flaw identified, rationale provided
