# Follow

Read the execution plan, design the testing strategy, and post the test plan to the issue. This is Kevin's contribution to Plan.

## Philosophy

The execution plan says what will be built. The test plan says what will be verified. Together they give the full picture: build chunk, test chunk, build chunk, test chunk. When both plans are visible on the issue, every agent can see the full pipeline.

The tester's job starts here — not when code lands, but when the plan is posted. If the tester doesn't understand what each chunk does, what it produces, and where the risks are, testing will be reactive instead of prepared. Reading the plan is probing — checking that every chunk is clear enough to test, that error paths are accounted for, and that the test surface is real and not vague.

## Execution

1. Read checklist.md in this skill directory
2. Read the execution plan comment on the issue
3. Walk through each chunk for mechanical understanding
4. Raise questions via SendMessage to Midgel
5. Design the testing strategy per chunk — test types, risks, key cases
6. Assess flow and infrastructure needs
7. Post the test plan to the issue
8. Request approval from Midgel via SendMessage

## Specifications

### Reading the Execution Plan

The execution plan contains chunks, each with:

| Field | What to look for |
|-------|-----------------|
| Name | Does this clearly describe a testable unit of work? |
| Scope | Which files are involved? |
| Produces | What types, functions, interfaces become available? |
| Depends on | Is the dependency chain sound? Are there hidden dependencies? |
| Test surface | Is this actually testable? Is the surface specific enough? |

Read the full plan before assessing individual chunks. Note the overall shape — how many chunks, how deep the dependency chain, where the parallel lanes are.

### Per-Chunk Understanding

For each chunk, answer honestly:

| Aspect | Question |
|--------|----------|
| What it builds | Can I describe what this chunk produces in my own words? |
| What to test | Can I identify specific behaviours to verify? Are inputs and outputs clear? |
| Error paths | Are error conditions identified or implied? |
| Boundaries | Where does this chunk start and end? What's deferred to later chunks? |

### Questioning the Plan

If something is unclear — ask Midgel via SendMessage. Do not guess. Do not wait until Build.

| Signal | Question |
|--------|----------|
| Vague test surface | "What specifically should tests verify for chunk X?" |
| Missing error paths | "Chunk X produces a function returning error — what triggers the error?" |
| Long serial chain | "Chunks A → B → C → D are sequential — is there a way to test earlier?" |
| No test surface | "Chunk X has no test surface — intentional or omission?" |
| Unclear boundary | "Does chunk X include validation, or does that come later?" |
| Can't explain it | "I can't describe what chunk X produces in plain terms — walk me through it?" |

### Per-Chunk Testing Strategy

For each chunk, determine:

#### Test Type

| Test Type | When to use |
|-----------|------------|
| Unit (`test/unit`) | Exported functions, methods, constructors — behaviour verification |
| Integration (`test/integration`) | Cross-component interactions, external dependencies |
| Benchmark (`test/benchmark`) | Performance-critical paths, allocation-sensitive code |
| Helper (`test/helper`) | Consumer-facing types that are hard to construct or verify |

#### Primary Risk

| Risk category | Signals |
|---------------|---------|
| Correctness | Complex logic, many branches, subtle state transitions |
| Concurrency | Shared state, goroutines, channels, mutexes |
| Performance | Hot paths, allocation-heavy operations, scaling concerns |
| API misuse | Confusing constructors, easy-to-misorder operations |
| Error handling | Many error paths, wrapping chains, sentinel error matching |

#### Key Test Cases

Be specific:
- "Constructor rejects nil config and returns ErrInvalidConfig"
- "Concurrent Get/Set on same key produces no races under -race"
- "Options apply in order, last write wins for conflicting settings"

Not: "test the constructor", "test concurrency", "test options"

#### Bug Likelihood

Where bugs are most likely to hide:
- Boundary conditions (zero, nil, empty, max)
- Error paths that are hard to trigger
- State transitions with implicit preconditions
- Race conditions in concurrent access patterns

### Flow Awareness

Map when testing work becomes available relative to the build order:
- Which chunks unblock test work immediately?
- Where are the idle periods?
- Which test tasks are quick wins vs heavy lifts?
- What's the optimal order for tackling test tasks?

### Infrastructure Assessment

| Need | Question |
|------|----------|
| Test helpers | Are new helpers needed for types that are hard to construct? |
| Test scaffolding | Does the package have a `testing/` directory with the expected structure? |
| Integration setup | Are there integration scenarios requiring external dependencies? |
| Benchmarks | Are benchmarks warranted? For which chunks? |

### Test Plan Format

Post to the issue:

```markdown
## Test Plan

### Overview

Brief summary — test types, overall risk, infrastructure needs.

### Per-Chunk Coverage

| Chunk | Test Type | Primary Risk | Key Verifications |
|-------|-----------|-------------|-------------------|
| chunk-name | unit | risk description | what tests will check |
| ... | ... | ... | ... |

### Infrastructure

What test infrastructure is needed:
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

### Approval

After posting, request approval from Midgel via SendMessage. Midgel wrote the execution plan and can spot misaligned priorities or misunderstood chunk boundaries.

If changes are requested: update the test plan, edit the issue comment, confirm with Midgel. Repeat until approved.

Do not proceed past this skill without approval. The test plan is a two-party agreement.

## Output

An approved issue comment containing:
- Per-chunk coverage table (test type, risk, key verifications)
- Infrastructure needs
- Flow mapping (when test work begins, idle periods)
- Open questions
