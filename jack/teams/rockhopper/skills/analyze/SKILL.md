# Analyze

Ensure the requirements are fully understood before designing a solution. Collaborative with Zidgel — this is Fidgel's half of the Plan iteration.

## Philosophy

Architecture begins with understanding. Before decomposing a problem, before considering patterns or approaches, the architect must understand what is being asked — not just what the issue says, but what it means. Requirements have implications. Acceptance criteria have edge cases. Constraints interact with each other in ways that aren't obvious until someone sits down and thinks about them.

This is collaborative work. The Captain defines what needs doing. The architect determines whether what's been defined is complete, consistent, and feasible. If something is unclear, ask now. If something is missing, raise it now. A question during Analyze costs nothing. A misunderstood requirement during Build costs a regression to Plan.

After the briefing, the architect may already have a thorough understanding. If so, this step is quick — confirm understanding and move on. If not, this is where the gaps get filled.

## Execution

1. Read checklist.md in this skill directory
2. Read the issue — requirements, acceptance criteria, context
3. Cross-reference with the briefing discussion
4. Identify gaps, ambiguities, and implications
5. Raise questions via SendMessage to Zidgel
6. Confirm understanding of the full problem space

## Specifications

### Reading the Issue

The issue typically contains:

| Element | What to look for |
|---------|-----------------|
| Problem statement | What is being solved? Is it clear and specific? |
| Requirements | What must the solution do? Are they testable? |
| Acceptance criteria | How do we know it's done? Are criteria measurable? |
| Scope | What's in scope and what's explicitly out? |
| Context | Why is this being done? What motivated the issue? |
| Constraints | What must not change? What limitations exist? |

### Identifying Gaps

After reading the issue, determine what's missing or unclear:

| Gap type | Signal |
|----------|--------|
| Ambiguous requirement | Multiple valid interpretations exist |
| Missing edge case | Requirements don't cover boundary conditions |
| Implicit assumption | The issue assumes something not stated |
| Scope boundary | It's unclear whether something is in or out of scope |
| Conflicting criteria | Two acceptance criteria can't both be satisfied |
| Missing context | The "why" is unclear, making design tradeoffs impossible |
| Feasibility concern | A requirement may be technically impossible or prohibitively complex |

### Questioning the Requirements

Questions go to Zidgel via SendMessage. The Captain owns requirements — the architect clarifies, not redefines.

Questions worth asking:

| Signal | Question |
|--------|----------|
| Ambiguous scope | "Does requirement X include Y, or is Y a separate concern?" |
| Missing edge case | "What should happen when input is empty/nil/zero?" |
| Implicit assumption | "The issue assumes Z exists — is that a prerequisite or part of this work?" |
| Conflicting criteria | "Criterion A requires X but criterion B requires Y — which takes precedence?" |
| Feasibility concern | "Requirement X would require Z — is that acceptable, or should we scope down?" |
| Missing motivation | "What problem does requirement X solve? Knowing the 'why' affects the design." |

Do not stockpile questions. Ask as they arise. Short, specific messages.

If there are no questions after the briefing — that's fine. Confirm understanding and move to `evaluate`.

### Confirming Understanding

After all questions are resolved, the architect should be able to state:

1. **The problem** — what we're solving and why
2. **The requirements** — what the solution must do, with no ambiguity
3. **The boundaries** — what's in scope and what isn't
4. **The constraints** — what must not change, what limitations exist
5. **The acceptance criteria** — how we know it's done, measurably

If any of these can't be stated clearly, the questioning isn't done.

## Output

A confirmed understanding of the requirements:
- **Problem statement** — clear, unambiguous, one paragraph
- **Requirements** — each requirement stated as a testable assertion
- **Scope boundaries** — explicit in/out decisions
- **Constraints** — technical and non-technical limitations
- **Resolved questions** — questions asked and answers received
- **Remaining concerns** — understood but flagged as risky
