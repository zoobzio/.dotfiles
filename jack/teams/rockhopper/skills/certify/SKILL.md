# Comment Test Plan

Post the testing strategy as an issue comment. This is the tester's counterpart to the execution plan — it documents what will be tested, how, and in what order.

## Philosophy

The execution plan says what will be built. The test plan says what will be verified. Together they give the full picture: build chunk, test chunk, build chunk, test chunk. When both plans are visible on the issue, every agent can see the full pipeline — what's coming, what's being verified, and where the risks are.

The test plan is also a commitment. It declares what the tester considers important, what risks they've identified, and what coverage strategy they'll follow. If the plan misses something, that's visible before Build starts — not after a bug ships.

## Execution

1. Read checklist.md in this skill directory
2. Compile the testing strategy from `assess-plan`
3. Format as an issue comment
4. Post via `gh issue comment`
5. Request approval from the plan author via SendMessage
6. Incorporate requested changes and update the comment

## Specifications

### Inputs

The test plan is derived from the output of `assess-plan`:

| Input | Content |
|-------|---------|
| Per-chunk testing map | Test type, risk, key cases, dependencies, complexity per chunk |
| Flow awareness | When test work becomes available, idle periods |
| Infrastructure needs | Helpers, scaffolding, integration, benchmarks |
| Open questions | Unresolved items from plan assessment |

If `assess-plan` has not been completed, stop. The test plan is not guesswork.

### Comment Structure

The issue comment follows this template:

```markdown
## Test Plan

### Overview

Brief summary of the testing approach — what types of tests, overall risk assessment, infrastructure needs.

### Per-Chunk Coverage

| Chunk | Test Type | Primary Risk | Key Verifications |
|-------|-----------|-------------|-------------------|
| chunk-name | unit | description of risk | what tests will check |
| ... | ... | ... | ... |

### Infrastructure

What test infrastructure is needed before or during Build:
- Helpers to create
- Scaffolding to set up
- Integration scenarios to prepare

### Flow

How testing maps to the build order:
- When test work begins
- Where idle periods exist
- Quick wins vs heavy lifts

### Open Questions

Unresolved items that may affect testing scope or approach.
```

### Content Rules

#### Be Specific
- "Verify error wrapping includes context" not "test errors"
- "Boundary conditions: nil input, empty slice, max size" not "test edge cases"
- "Race detector under concurrent Get/Set" not "test concurrency"

#### Be Honest About Risk
- State what's most likely to break and why
- State what's hardest to test and why
- Don't claim comprehensive coverage where only happy-path testing is planned

#### Be Actionable
- Each row in the coverage table should map directly to test work during Build
- Infrastructure needs should be concrete enough to act on immediately
- Open questions should be specific enough to answer

### Relationship to Execution Plan

The test plan is a response to the execution plan. The two should be readable in sequence:

1. Reader sees execution plan → understands what's being built
2. Reader sees test plan → understands what's being verified

Chunk names in the test plan must match chunk names in the execution plan. If the execution plan changes, the test plan must be updated.

### Approval

After posting the test plan, request approval from the execution plan author via SendMessage. The test plan is a proposal — the builder who wrote the execution plan knows the work best and may see gaps, misaligned priorities, or misunderstood chunk boundaries.

**Send a direct message to the plan author:**
- Reference the test plan comment
- Ask for approval or requested changes
- Keep it concise — the comment speaks for itself

**If changes are requested:**
1. Understand the feedback — ask clarifying questions via SendMessage if needed
2. Update the testing strategy accordingly
3. Edit the issue comment with the revised plan (use `gh issue comment edit`)
4. Confirm the changes with the plan author via SendMessage
5. Repeat until approved

**If approved:**
- The test plan is locked. Both builder and tester have agreed on what will be verified.
- Build can proceed with both plans as the contract.

Do not proceed past this skill without approval. The test plan is a two-party agreement.

## Output

An approved issue comment containing:
- Overview of testing approach
- Per-chunk coverage table with test type, risk, and key verifications
- Infrastructure needs
- Flow mapping (when test work begins, idle periods)
- Open questions
