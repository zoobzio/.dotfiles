# Helpers

Add testing helpers that help *consumers* of the package test their integration code. Helpers are part of the package's public testing API.

## Philosophy

Helpers are consumer-facing. When someone imports your package, they need to test code that integrates with it. Good helpers make that easy. Bad helpers make consumers reinvent the wheel or write fragile tests.

This is distinct from internal test utilities. Internal helpers serve the package's own tests. These helpers serve everyone who depends on the package.

## File Placement

Helpers live in `testing/helpers.go`:

```
testing/
├── helpers.go        # Consumer-facing test helpers
└── helpers_test.go   # Tests for the helpers
```

## Build Tag

```go
//go:build testing

package testing
```

The `testing` build tag ensures helpers are only compiled when testing. Consumers use `-tags testing` to access them.

## Required Conventions

Every helper function MUST:

1. Call `t.Helper()` as its first statement
2. Accept `*testing.T` as its first parameter
3. Be domain-specific (not generic utilities)

```go
func AssertValidResponse(t *testing.T, resp *Response) {
    t.Helper()
    if resp.StatusCode < 200 || resp.StatusCode >= 300 {
        t.Errorf("expected success status, got %d", resp.StatusCode)
    }
}
```

## Helper Categories

### Assert Functions
Validate domain-specific conditions:
- Naming: `Assert[Condition]`
- Purpose: verify that something is correct

```go
func AssertValidToken(t *testing.T, token *Token) {
    t.Helper()
    if token.ExpiresAt.Before(time.Now()) {
        t.Error("token is expired")
    }
    if token.Subject == "" {
        t.Error("token has no subject")
    }
}
```

### Setup / Factory Functions
Create test instances of package types:
- Naming: `New[Thing]` or `With[Thing]`
- Purpose: provide valid instances for testing

```go
func NewTestClient(t *testing.T, opts ...Option) *Client {
    t.Helper()
    client, err := NewClient(append([]Option{WithTimeout(5 * time.Second)}, opts...)...)
    if err != nil {
        t.Fatalf("failed to create test client: %v", err)
    }
    t.Cleanup(func() { client.Close() })
    return client
}
```

## What Consumers Need

Analyse the package's public API to determine:

1. **Types that are hard to construct** — provide `New[Thing]` factories
2. **Conditions that are hard to verify** — provide `Assert[Condition]` functions
3. **State that is hard to set up** — provide `With[Thing]` helpers
4. **Resources that need cleanup** — use `t.Cleanup()` in factory helpers

## Helpers Must Be Tested

`testing/helpers_test.go` MUST exist and test every helper:

- Test both passing and failing cases for assertions
- Test that factories produce valid instances
- Test that cleanup runs correctly
- Verify error messages are helpful and diagnostic

## Documentation

Helpers are consumer-facing, so documentation quality matters:

- Every exported helper has a godoc comment
- Comments explain *when* to use the helper, not just *what* it does
- Examples show realistic usage in consumer test code

## Prohibitions

DO NOT:
- Create helpers without `t.Helper()` as first statement
- Create helpers without `*testing.T` as first parameter
- Create generic utilities (string comparison, file reading)
- Skip testing the helpers themselves
- Omit the `//go:build testing` build tag

## Output

Helper file(s) that:
- Live in `testing/helpers.go`
- Use `//go:build testing` build tag
- Follow `Assert[Condition]` / `New[Thing]` / `With[Thing]` naming
- Call `t.Helper()` first, accept `*testing.T` first
- Are themselves tested in `testing/helpers_test.go`
- Are documented with consumer-oriented godoc comments

## Checklist

### Understand the Package API
- [ ] Read the package's public API (exported types, functions, methods)
- [ ] Identify types that are complex to construct
- [ ] Identify conditions that are complex to verify
- [ ] Identify resources that need cleanup

### Design Helpers
- [ ] Assert functions named `Assert[Condition]` with clear error messages
- [ ] Factory functions named `New[Thing]` or `With[Thing]` with sensible defaults
- [ ] `t.Cleanup()` for resources in factory helpers
- [ ] Options for customisation where needed

### Write Helpers
- [ ] File: `testing/helpers.go`
- [ ] Build tag: `//go:build testing`
- [ ] `t.Helper()` is the first statement in every helper
- [ ] `*testing.T` is the first parameter in every helper
- [ ] Helpers are domain-specific (not generic)
- [ ] Godoc comment on every exported helper

### Test Helpers
- [ ] File: `testing/helpers_test.go`
- [ ] Passing case tested for each helper
- [ ] Failing case tested for each assertion helper
- [ ] Error messages verified for clarity
- [ ] Cleanup verified (resources released)

### Verify
- [ ] `go test -v -race -tags testing ./testing/...` passes
- [ ] No generic utilities (only domain-specific helpers)
