# Prove

Design the testing strategy for each chunk. Determine what test types apply, where bugs will hide, and what infrastructure is needed.

## Philosophy

After `follow`, the tester mechanically understands every chunk — what it builds, what to verify, where the boundaries are. Now comes the internal work: deciding *how* to prove each chunk works. Which test types apply. What the primary risks are. Where bugs are most likely to surface. What infrastructure needs to exist before testing can begin.

This is the tester's domain expertise applied to the builder's plan. No collaboration needed — the understanding is already established. This is about strategy.

## Execution

1. Read checklist.md in this skill directory
2. Review the confirmed understanding from `follow`
3. Design the testing strategy per chunk
4. Assess flow and infrastructure needs
5. Produce the testing strategy

## Specifications

### Input

The confirmed understanding from `follow`:

| Input | Content |
|-------|---------|
| Per-chunk summary | What each chunk builds, what to verify, dependencies, unblocks |
| Resolved questions | Clarifications from the plan author |
| Remaining concerns | Understood but flagged risks |

If `follow` has not been completed, stop. Strategy without understanding is guesswork.

### Per-Chunk Testing Strategy

For each chunk, determine:

#### Test Type

Which testing skills apply:

| Test Type | When to use |
|-----------|------------|
| Unit (`test/unit`) | Exported functions, methods, constructors — behaviour verification |
| Integration (`test/integration`) | Cross-component interactions, external dependencies |
| Benchmark (`test/benchmark`) | Performance-critical paths, allocation-sensitive code |
| Helper (`test/helper`) | Consumer-facing types that are hard to construct or verify |

A chunk may require multiple test types. Identify all that apply.

#### Primary Risk

What's most likely to break:

| Risk category | Signals |
|---------------|---------|
| Correctness | Complex logic, many branches, subtle state transitions |
| Concurrency | Shared state, goroutines, channels, mutexes |
| Performance | Hot paths, allocation-heavy operations, scaling concerns |
| API misuse | Confusing constructors, easy-to-misorder operations, implicit preconditions |
| Error handling | Many error paths, wrapping chains, sentinel error matching |

#### Key Test Cases

High-level description of what tests will verify. Be specific:

- "Constructor rejects nil config and returns ErrInvalidConfig"
- "Concurrent Get/Set on same key produces no races under -race"
- "Options apply in order, last write wins for conflicting settings"

Not: "test the constructor", "test concurrency", "test options"

#### Bug Likelihood

Where bugs are most likely to hide in this chunk:

- Boundary conditions (zero, nil, empty, max)
- Error paths that are hard to trigger
- State transitions with implicit preconditions
- Race conditions in concurrent access patterns
- Off-by-one in iteration or slicing

#### Estimated Complexity

How much testing work this chunk requires:

| Level | Meaning |
|-------|---------|
| Light | Few test cases, straightforward assertions, no setup |
| Moderate | Multiple test cases, some setup, error paths to cover |
| Heavy | Many cases, complex setup/teardown, concurrency testing, benchmarks |

### Flow Awareness

Map when testing work becomes available relative to the build order:

- Which chunks unblock test work immediately?
- Where are the idle periods (waiting for sequential builds)?
- Which test tasks are quick wins vs heavy lifts?
- What's the optimal order for tackling test tasks?

Use this to plan the testing sequence — quick wins first to build momentum, or heavy lifts first to front-load risk?

### Infrastructure Assessment

Determine what must exist before or during Build:

| Need | Question |
|------|----------|
| Test helpers | Are new helpers needed for types that are hard to construct? |
| Test scaffolding | Does the package have a `testing/` directory with the expected structure? |
| Integration setup | Are there integration scenarios requiring external dependencies? |
| Benchmarks | Are benchmarks warranted? For which chunks? |
| Advance work | Can any infrastructure be set up before Build starts? |

## Output

A testing strategy containing:
- **Per-chunk testing map** — test type, primary risk, key test cases, bug likelihood, complexity
- **Flow awareness** — when test work becomes available, idle periods, optimal sequencing
- **Infrastructure needs** — helpers, scaffolding, integration setup, benchmarks, advance work
