# Recon

Survey the testing landscape before acting. Understand what exists, what's missing, and what's lying.

## Philosophy

Before writing a single test, understand the terrain. Coverage percentage is a vanity metric — a codebase can have 90% coverage and still be undertested. Benchmarks lie by default. Infrastructure may be missing entirely.

This maps the testing landscape: what infrastructure exists, what's covered, what's flaccid, what's missing.

## Infrastructure Survey

Check for the existence and completeness of:

| Element | Location | What to check |
|---------|----------|---------------|
| testing/ directory | `testing/` | Exists? Has README? |
| Helpers | `testing/helpers.go` | Exists? Has tests? Build tag? |
| Benchmarks | `testing/benchmarks/` | Exists? Has README? Has benchmarks? |
| Integration tests | `testing/integration/` | Exists? Has README? Has tests? |

## 1:1 Mapping Check

Every `.go` source file should have a corresponding `_test.go` file. List:
- Source files without test files
- Test files without source files (orphans)
- Exception: delegation, re-export, or trivial wiring files

## Flaccid Test Patterns

Tests that inflate coverage without providing value:

| Pattern | Problem |
|---------|---------|
| No assertions | Calls code but doesn't verify outcome |
| Only happy path | Skips error handling, edge cases |
| Weak assertions | Checks existence, not correctness |
| Mock everything | Tests wiring, not behavior |
| Tautological | Asserts what was just set |

## Quality Indicators

Good coverage includes:

| Indicator | What to check |
|-----------|---------------|
| Error paths tested | Every error return has a test that triggers it |
| Boundary conditions | Zero, one, many, max, overflow |
| Nil/empty handling | Nil inputs, empty slices, zero values |
| Concurrent safety | Race conditions under test |
| State transitions | All valid state changes exercised |

## Coverage Analysis

When analyzing coverage reports:

1. **Uncovered lines** — identify what's missing
2. **Partially covered** — branches not fully exercised
3. **Covered but untested** — lines hit without meaningful assertions

### Prioritisation

Focus coverage efforts on:

1. Public API surface
2. Error handling paths
3. Security-sensitive code
4. Complex business logic
5. Recently changed code

Lower priority: simple getters/setters, delegation-only code, generated code.

## Naive Benchmark Patterns

Benchmarks that produce misleadingly good numbers:

| Pattern | Problem |
|---------|---------|
| Pre-allocated input | Hides allocation cost |
| Cache-hot data | Unrealistic memory access |
| Compiler elimination | Dead code removed |
| Single goroutine | Hides contention |
| Tiny input | Hides scaling issues |
| No allocations check | Hides memory pressure |

### Benchmark Result Interpretation

| Metric | What it means |
|--------|---------------|
| ns/op | Time per operation |
| B/op | Bytes allocated per operation |
| allocs/op | Number of allocations per operation |

Red flags:
- 0 B/op when allocations expected
- Wildly different parallel vs sequential
- Linear scaling when sub-linear expected

## Output

Structured report containing:
- **Infrastructure status** — what exists, what's missing
- **1:1 mapping gaps** — source files without test files
- **Coverage metrics** — overall and per-package
- **Flaccid tests found** — categorised by pattern
- **Benchmark assessment** — naive patterns, missing benchmarks
- **Prioritised recommendations** — what to fix first

## Checklist

### Infrastructure Survey
- [ ] Check for `testing/` directory
- [ ] Check for `testing/README.md`
- [ ] Check for `testing/helpers.go`
- [ ] Check for `testing/helpers_test.go`
- [ ] Check for `testing/benchmarks/` directory
- [ ] Check for `testing/integration/` directory
- [ ] Note any missing infrastructure components

### 1:1 Mapping Check
- [ ] List all `.go` source files in the package
- [ ] List all `_test.go` files
- [ ] Identify source files without corresponding test files
- [ ] Identify orphan test files (test without source)
- [ ] Note exceptions (delegation, re-export, trivial wiring)

### Coverage Analysis
- [ ] Run coverage: `go test -coverprofile=coverage.out -covermode=atomic ./...`
- [ ] Generate HTML report: `go tool cover -html=coverage.out -o coverage.html`
- [ ] Get summary: `go tool cover -func=coverage.out`
- [ ] List functions with 0% coverage
- [ ] List files with less than 50% coverage
- [ ] Identify public API methods without tests
- [ ] Identify which branches are missed
- [ ] Check if error returns are covered

### Test Quality Audit
- [ ] Check for no-assertion tests
- [ ] Check for weak assertions (length not content)
- [ ] Check for happy-path-only tests
- [ ] Check for tautological tests
- [ ] Verify error path coverage
- [ ] Verify boundary testing
- [ ] Verify concurrency testing (`go test -race`)

### Benchmark Assessment
- [ ] Run all benchmarks: `go test -bench=. -benchmem -count=10 ./testing/benchmarks/...`
- [ ] Audit for naive patterns (pre-allocated input, compiler elimination, no `b.ReportAllocs()`)
- [ ] Record ns/op, B/op, allocs/op
- [ ] Flag suspicious results

### Report
- [ ] Infrastructure status documented
- [ ] Coverage summary with per-package breakdown
- [ ] Flaccid tests catalogued by pattern
- [ ] Benchmark summary with results table
- [ ] Prioritised recommendations stated
