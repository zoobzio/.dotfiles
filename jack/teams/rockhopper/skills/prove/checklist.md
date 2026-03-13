# Prove Checklist

## Phase 1: Verify Input

- [ ] `follow` has been completed
- [ ] Per-chunk understanding is confirmed
- [ ] Resolved questions are available
- [ ] Remaining concerns are noted

## Phase 2: Design Per-Chunk Strategy

For each chunk:

### Test Type
- [ ] Unit tests needed? (`test/unit`)
- [ ] Integration tests needed? (`test/integration`)
- [ ] Benchmarks needed? (`test/benchmark`)
- [ ] Helpers needed? (`test/helper`)
- [ ] All applicable test types identified

### Primary Risk
- [ ] Risk category identified (correctness, concurrency, performance, API misuse, error handling)
- [ ] Risk is specific to this chunk, not generic

### Key Test Cases
- [ ] Specific test cases outlined (not vague)
- [ ] Happy path cases identified
- [ ] Error path cases identified
- [ ] Boundary condition cases identified
- [ ] Each case is concrete enough to implement

### Bug Likelihood
- [ ] Most likely bug locations identified
- [ ] Boundary conditions flagged
- [ ] Hard-to-trigger error paths flagged
- [ ] State transition risks flagged
- [ ] Concurrency risks flagged

### Complexity
- [ ] Estimated as light, moderate, or heavy
- [ ] Estimate accounts for setup, assertions, and edge cases

## Phase 3: Assess Flow

- [ ] Chunks that immediately unblock test work identified
- [ ] Idle periods mapped (waiting for sequential builds)
- [ ] Quick wins vs heavy lifts ordered
- [ ] Optimal test task sequencing determined
- [ ] Advance work opportunities identified

## Phase 4: Assess Infrastructure

- [ ] New test helpers needed? Listed with purpose
- [ ] Test scaffolding present? (`testing/` directory with expected structure)
- [ ] Integration scenarios requiring setup? Listed
- [ ] Benchmarks warranted? For which chunks?
- [ ] Advance work that can happen before Build? Listed

## Phase 5: Compile Output

- [ ] Per-chunk testing map complete (type, risk, cases, bugs, complexity)
- [ ] Flow awareness documented
- [ ] Infrastructure needs listed
- [ ] Strategy is actionable — feeds directly into `certify`
