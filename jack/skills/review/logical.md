# Logical Review

Requirements satisfaction review. Does the implementation deliver what was specified?

## Philosophy

Technical excellence means nothing if it solves the wrong problem. The logical review exists to answer one question: did we build what we said we would build? Not approximately — exactly. Every acceptance criterion, every scope boundary, every requirement. If the answer is "mostly," the answer is no.

This review does not look at code. It looks at outcomes. The implementation is a means to an end, and the end is defined by the scope posted at the start of Plan phase. That scope is the contract. This review enforces it.

## Execution

1. Retrieve the scope from the GitHub issue (requirements, acceptance criteria, scope boundaries)
2. Walk through each acceptance criterion
3. Verify scope adherence — nothing missing, nothing extra
4. Assess user value — does this solve the stated problem?
5. Render judgment

## Specifications

### Acceptance Criteria Verification

For each criterion posted during scope:

| Check | Question |
|-------|----------|
| Met | Does the implementation satisfy this criterion exactly? |
| Observable | Can satisfaction be verified from outside the implementation? |
| Evidence | What evidence supports the pass/fail determination? |

Every criterion must be individually assessed. A blanket "looks good" is not a review.

### Scope Adherence

| Check | Question |
|-------|----------|
| Completeness | Is everything in "In Scope" addressed? |
| Boundaries | Has anything from "Out of Scope" crept in? |
| Creep | Has the implementation expanded beyond what was specified? |
| Intent | Does the result match the original motivation — the "why"? |

Scope creep is a defect. Building less than specified is a defect. Both require regression.

### User Value

Beyond the letter of the criteria, does the implementation serve the user?

| Check | Question |
|-------|----------|
| Problem solved | Does this address the stated problem, not an adjacent one? |
| Usability | Would a user find this intuitive and useful? |
| Completeness | Are there gaps a user would notice even if the criteria technically pass? |

This is judgment, not measurement. It is the Captain's judgment, and it matters.

### Regression Paths

| Finding | Path |
|---------|------|
| Minor gap — criterion nearly met, small fix needed | Back to Build |
| Missing requirement — something in scope was not addressed | Back to Build |
| Scope misalignment — the work doesn't match the mission | Back to Plan |
| Requirements gap — the requirements themselves were insufficient | Back to Plan |

## Output

A determination:
- **Pass** — all acceptance criteria met, scope adhered to, user value confirmed
- **Regress to Build** — specific gaps identified, listed with expected corrections
- **Regress to Plan** — fundamental misalignment identified, rationale provided
