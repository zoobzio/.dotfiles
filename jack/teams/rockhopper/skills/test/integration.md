# Integration Tests

Add integration tests for features that span components, depend on external services, or exercise system-level behaviour.

## Principles

1. **Integration tests complement unit tests** — they test the seams, not the units
2. **Self-contained** — each test manages its own setup and teardown
3. **Graceful degradation** — skip when dependencies are unavailable
4. **Isolation** — tests must not interfere with each other

## When Integration Tests Are Needed

- Cross-component interactions (service A calls service B)
- External dependency integration (databases, APIs, message queues)
- System-level behaviour (startup/shutdown sequences, configuration loading)
- End-to-end workflows that span multiple packages

## File Placement

Integration tests live in `testing/integration/`:

```
testing/
└── integration/
    ├── README.md
    ├── api_test.go
    └── workflow_test.go
```

## Build Tags

```go
//go:build integration

package integration
```

Use `//go:build integration` to separate integration tests from unit tests. This allows:
- `go test ./...` runs only unit tests
- `go test -tags integration ./testing/integration/...` runs integration tests

## Test Isolation

Every test manages its own state:

```go
func TestFeatureIntegration(t *testing.T) {
    // Setup
    db := setupTestDB(t)
    t.Cleanup(func() { teardownTestDB(t, db) })

    // Test
    // ...
}
```

- Use `t.Cleanup()` for teardown — runs even on test failure
- No shared state between tests
- No dependency on test execution order

## Dependency Management

When external dependencies are required:

```go
func TestWithDatabase(t *testing.T) {
    if os.Getenv("TEST_DB_URL") == "" {
        t.Skip("requires TEST_DB_URL")
    }
    // ...
}
```

- Use `t.Skip()` with a clear reason when dependencies are unavailable
- Document required dependencies in `testing/integration/README.md`
- Tests must pass or skip — never hang waiting for unavailable services

## Test Structure

```go
func TestWorkflow(t *testing.T) {
    // Setup dependencies
    svc := setupService(t)
    t.Cleanup(func() { svc.Close() })

    t.Run("step one", func(t *testing.T) {
        // ...
    })

    t.Run("step two depends on step one", func(t *testing.T) {
        // ...
    })
}
```

- Use `t.Run()` for logical steps within a workflow
- Sequential subtests are acceptable for integration tests (shared state within a test)
- Do NOT use `t.Parallel()` for subtests that share state

## Output

An integration test file that:
- Lives in `testing/integration/`
- Uses `//go:build integration` build tag
- Manages its own setup and teardown
- Skips gracefully when dependencies are unavailable
- Tests real interactions between components
- Passes with `go test -v -race -tags integration ./testing/integration/...`

## Checklist

### Identify Scope
- [ ] What feature or interaction is being tested?
- [ ] Which components are involved?
- [ ] What external dependencies are required?
- [ ] What behaviour can only be verified at the integration level?

### Dependency Setup
- [ ] Document required dependencies in `testing/integration/README.md`
- [ ] Create setup helpers for each dependency
- [ ] Use `t.Cleanup()` for all teardown
- [ ] Add `t.Skip()` guards for unavailable dependencies

### Write Tests
- [ ] File placed in `testing/integration/`
- [ ] Build tag: `//go:build integration`
- [ ] Package: `integration`
- [ ] Each test is self-contained (own setup/teardown)
- [ ] No shared mutable state between tests
- [ ] No dependency on test execution order
- [ ] Happy path through the full interaction tested
- [ ] Error propagation across component boundaries tested
- [ ] Timeout and cancellation behaviour tested
- [ ] Resource cleanup on failure tested

### Run and Verify
- [ ] `go test -v -race -tags integration ./testing/integration/...` passes
- [ ] Tests skip gracefully when dependencies are unavailable
- [ ] No test pollution (each test independent)
- [ ] Cleanup runs even on failure
- [ ] No hanging tests (timeouts configured)
