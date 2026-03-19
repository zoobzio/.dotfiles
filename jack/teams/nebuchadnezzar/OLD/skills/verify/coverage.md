# Coverage Analysis

Coverage is a quality signal, not a target to game. High coverage with weak assertions is worse than moderate coverage with strong tests.

## Quality Over Percentage

A test that executes code without verifying behaviour is a flaccid test. It inflates coverage numbers while providing no safety net.

```go
// Flaccid test — executes the code but verifies nothing
func TestHandlerGet(t *testing.T) {
    h := handlers.NewUsers(mock)
    req := httptest.NewRequest("GET", "/users/123", nil)
    w := httptest.NewRecorder()
    h.Get(w, req)
    // no assertions
}
```

```go
// Strong test — verifies actual behaviour
func TestHandlerGet(t *testing.T) {
    h := handlers.NewUsers(mock)
    req := httptest.NewRequest("GET", "/users/123", nil)
    w := httptest.NewRecorder()
    h.Get(w, req)

    if w.Code != http.StatusOK {
        t.Fatalf("status = %d, want %d", w.Code, http.StatusOK)
    }

    var body map[string]any
    json.NewDecoder(w.Body).Decode(&body)
    if body["id"] != "123" {
        t.Fatalf("id = %v, want %q", body["id"], "123")
    }
}
```

## Detecting Flaccid Tests

Signs of a flaccid test:

- No assertions after calling the function under test
- Only checks `err == nil` without verifying the return value
- Uses `_ =` to discard results
- Asserts on mocked return values instead of real behaviour

Audit technique — temporarily break the code and see which tests catch it. If a test still passes after you introduce a bug in the function it covers, it is flaccid.

```go
// If this test passes when Get() returns the wrong user, it's flaccid
func TestUsersGet(t *testing.T) {
    user, err := store.Get(ctx, "123")
    if err != nil {
        t.Fatal(err)
    }
    // Missing: verify user.ID == "123"
}
```

## Coverage Targets

| Metric | Target | Threshold |
|--------|--------|-----------|
| Project | 70% | 1% drop allowed |
| Patch (new code) | 80% | 0% drop allowed |

These targets are floors, not ceilings. New code should aim for 80% minimum. The project-wide target accounts for legacy code and generated files.

## Running Coverage Analysis

Generate a coverage report:

```bash
make test       # Run all tests with race detector
make coverage   # Generate combined coverage report (unit + integration)
```

Inspect coverage by function:

```bash
go tool cover -func=coverage.out
```

Inspect coverage visually:

```bash
go tool cover -html=coverage.out
```

The HTML report highlights uncovered lines in red. Focus on:

- Red lines in error handling paths — these are common gaps
- Red lines in branching logic — missing test cases
- Entire functions in red — missing test files (violates 1:1 rule)

## What to Do When Coverage Drops

When a change reduces coverage below the threshold:

1. **Check for missing test files.** Run through the 1:1 mapping rule. Every source file needs a test file.

2. **Check for untested error paths.** Most coverage gaps are in error handling. Add tests for failure cases.

3. **Check for new branches.** If you added an `if` or `switch`, each branch needs a test case.

4. **Check for flaccid tests.** Existing tests might cover the lines but not assert on the behaviour. Strengthen the assertions.

5. **Check for generated code.** If coverage dropped because of generated files, exclude them from the coverage profile:

```bash
go test -coverprofile=coverage.out -covermode=atomic ./... \
    -coverpkg=./models/...,./stores/...,./api/...,./admin/...
```

Do not reduce the threshold to accommodate the drop. Fix the gap or justify why the code is untestable.
