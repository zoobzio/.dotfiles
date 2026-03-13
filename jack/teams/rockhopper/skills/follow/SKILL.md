# Follow

Ingest the execution plan and build mechanical understanding of what's being built. Ensure every chunk is understood well enough to test before Build begins.

## Philosophy

The execution plan is the builder's promise: these chunks, in this order, producing these surfaces. The tester's job starts here — not when code lands, but when the plan is posted. If the tester doesn't mechanically understand what each chunk does, what it produces, and what its boundaries are, testing will be reactive instead of prepared.

Reading the plan is not passive. It's probing — checking that every chunk is clear enough to test, that error paths are accounted for, that the test surface is real and not vague. If something doesn't make sense, ask now. A question during Plan costs nothing. A misunderstanding during Build costs a bug task, a fix cycle, and lost momentum.

## Execution

1. Read checklist.md in this skill directory
2. Read the execution plan comment on the issue
3. Walk through each chunk for mechanical understanding
4. Identify questions and concerns
5. Raise questions via SendMessage to the plan author
6. Confirm understanding of each chunk

## Specifications

### Reading the Plan

The execution plan contains chunks, each with:

| Field | What to look for |
|-------|-----------------|
| Name | Does this clearly describe a testable unit of work? |
| Scope | Which files are involved? Do they fall within expected ownership? |
| Produces | What types, functions, interfaces become available? |
| Depends on | Is the dependency chain sound? Are there hidden dependencies? |
| Test surface | Is this actually testable? Is the surface specific enough? |

Read the full plan before assessing individual chunks. Note the overall shape — how many chunks, how deep the dependency chain, where the parallel lanes are.

### Per-Chunk Understanding

For each chunk, answer these questions honestly:

#### Do I Understand What This Builds?
- Can I describe what this chunk produces in my own words?
- Do I know what types, functions, or interfaces will exist after this chunk?
- Do I understand how this chunk relates to the chunks before and after it?

#### Do I Understand What to Test?
- Can I identify specific behaviours to verify?
- Are the inputs and outputs clear enough to write test cases?
- Are error paths identified or at least implied by the spec?
- Is the test surface specific enough, or is it hand-waving?

#### Do I See the Boundaries?
- Where does this chunk start and end?
- What's in scope for this chunk vs deferred to a later chunk?
- Are there implicit dependencies the plan doesn't state?

### Questioning the Plan

The plan is a proposal, not a decree. If something is unclear, incomplete, or suspicious — ask.

**Ask the plan author directly via SendMessage.** Do not guess. Do not assume. Do not wait until Build to discover the answer.

Questions worth asking:

| Signal | Question |
|--------|----------|
| Vague test surface | "What specifically should tests verify for chunk X?" |
| Missing error paths | "Chunk X produces a function returning error — what triggers the error?" |
| Long dependency chain | "Chunks A → B → C → D are sequential — is there a way to test earlier?" |
| No test surface listed | "Chunk X has no test surface — is this intentionally untestable or an omission?" |
| Unclear boundary | "Does chunk X include validation, or does that come in a later chunk?" |
| Implied concurrency | "The spec mentions concurrent access — which chunk introduces the concurrency-safe path?" |
| Can't explain it | "I can't describe what chunk X produces in plain terms — can you walk me through it?" |

Do not stockpile questions. Ask as they arise. Short, specific messages. The plan author can clarify incrementally.

### Confirming Understanding

After all questions are resolved, the tester should be able to state for each chunk:

1. **What it builds** — concrete types, functions, interfaces
2. **What to verify** — specific behaviours, error paths, boundaries
3. **What it depends on** — which earlier chunks must be complete
4. **What it unblocks** — which test tasks become available

If any chunk can't be stated this clearly, the questioning isn't done.

## Output

A confirmed understanding of the execution plan:
- **Per-chunk summary** — what it builds, what to verify, dependencies, unblocks
- **Resolved questions** — questions asked and answers received
- **Remaining concerns** — anything that's understood but flagged as risky
