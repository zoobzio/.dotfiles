# Unit Tests

Add unit tests for a source file. Tests verify behaviour, not implementation.

## Principles

1. **1:1 mapping** — every source file has a corresponding test file
2. **Behaviour over implementation** — test what it does, not how
3. **No flaccid tests** — every test must verify something meaningful
4. **Error paths matter** — happy path is necessary but not sufficient

## 1:1 Mapping Rule

Source file `foo.go` → test file `foo_test.go` in the same package.

Exception: files containing only delegation, re-exports, or trivial wiring with no testable logic.

## Test Structure

```go
func TestFunctionName(t *testing.T) {
    t.Parallel()

    tests := []struct {
        name string
        // inputs
        // expected outputs
    }{
        // cases
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()
            // arrange, act, assert
        })
    }
}
```

Conventions:
- Table-driven tests for multiple cases
- `t.Run()` for subtests with descriptive names
- `t.Parallel()` where safe (no shared mutable state)
- Standard `testing` package only — no third-party frameworks

## Flaccid Test Prevention

DO NOT write tests that exhibit these patterns:

| Pattern | Problem | Fix |
|---------|---------|-----|
| No assertions | Calls code, ignores result | Assert return values and side effects |
| Weak assertions | Checks `len > 0`, not content | Assert specific expected values |
| Happy path only | No error/edge cases | Add error, nil, empty, boundary cases |
| Tautological | Asserts what was just set | Test real behaviour through the API |
| Mock everything | Tests wiring, not logic | Use real dependencies where feasible |

## What to Test

Prioritise by impact:

1. **Public API** — all exported functions and methods
2. **Error paths** — every error return reachable via test
3. **Security-sensitive code** — input validation, auth, sanitisation
4. **Business logic** — core domain rules
5. **Edge cases** — boundaries, nil, empty, zero, max

## Error Path Coverage

- Every function returning `error` must have tests triggering each error path
- Error wrapping must be tested (correct context added)
- Error types must be verified, not just `err != nil`

## Boundary Conditions

- Zero values
- Empty collections
- Single element
- Maximum / overflow
- Nil pointers
- Unicode and special characters where relevant

## Concurrent Safety

- Run with `-race` flag
- Test concurrent access patterns for shared state
- Check for goroutine leaks

## Output

A test file that:
- Maintains 1:1 mapping with its source file
- Uses table-driven tests with `t.Run()` and `t.Parallel()`
- Covers public API, error paths, and edge cases
- Contains no flaccid tests
- Passes with `go test -v -race -tags testing ./...`

## Checklist

### Understand the Source
- [ ] Read the source file thoroughly
- [ ] Identify all exported functions and methods
- [ ] Identify all error return paths
- [ ] Identify boundary conditions and edge cases
- [ ] Note any concurrent access patterns

### Plan Test Cases
- [ ] List every exported function/method that needs tests
- [ ] For each, identify: happy path, error paths, edge cases
- [ ] Map every `return err` path
- [ ] Plan assertions for error types and wrapping
- [ ] Plan edge cases (zero, empty, nil, max, invalid)

### Write Tests
- [ ] Test file matches source file: `foo.go` → `foo_test.go`
- [ ] Same package as source
- [ ] Table-driven tests for functions with multiple cases
- [ ] `t.Run()` for subtests with descriptive names
- [ ] `t.Parallel()` at test and subtest level where safe
- [ ] At least one assertion per subtest
- [ ] Assertions check specific values, not just existence
- [ ] Error types verified (not just `err != nil`)
- [ ] No tautological assertions
- [ ] No unused return values from function under test

### Run and Verify
- [ ] `go test -v -race -tags testing ./...` passes
- [ ] No data races detected
- [ ] All subtests have descriptive names
- [ ] No flaccid test patterns present
