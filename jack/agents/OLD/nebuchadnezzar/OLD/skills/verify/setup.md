# Unit Test Infrastructure

Unit tests live next to their source files and share infrastructure through the `testing/` directory.

## 1:1 Mapping Rule

Every `.go` source file MUST have a corresponding `_test.go` file in the same directory.

```
models/
├── user.go
└── user_test.go
stores/
├── users.go
└── users_test.go
api/
├── handlers/
│   ├── users.go
│   └── users_test.go
└── transformers/
    ├── users.go
    └── users_test.go
admin/
├── handlers/
│   ├── users.go
│   └── users_test.go
└── transformers/
    ├── users.go
    └── users_test.go
```

**Exception:** Files containing only delegation, re-exports, or trivial wiring with no testable logic may omit the test file.

## Colocated Tests

Test files live next to the source they test, not in a separate directory. This keeps the relationship visible in the file tree.

```
stores/users.go       # source
stores/users_test.go  # tests for this source
```

The test file uses the same package as the source:

```go
package stores

import "testing"

func TestUsersGet(t *testing.T) {
    // ...
}
```

## testing/ Directory Structure

Shared test infrastructure lives in the `testing/` directory at the project root.

```
testing/
├── README.md
├── fixtures.go         # Test data factories
├── fixtures_test.go    # Tests for fixtures
├── mocks.go            # Mock implementations
├── mocks_test.go       # Tests for mocks
├── helpers.go          # Domain-specific test utilities
├── helpers_test.go     # Tests for helpers
├── benchmarks/
│   ├── README.md
│   └── core_test.go
└── integration/
    ├── README.md
    ├── setup.go
    └── [feature]_test.go
```

Every file in `testing/` has its own test file. The infrastructure that tests your code must itself be tested.

## Coverage Targets

| Metric | Target | Threshold |
|--------|--------|-----------|
| Project | 70% | 1% drop allowed |
| Patch (new code) | 80% | 0% drop allowed |

Run coverage analysis:

```bash
make test       # All tests with race detector
make coverage   # Generate coverage report
```

The coverage report combines unit and integration test profiles:

```makefile
test:
	@go test -v -race ./...

coverage:
	@go test -coverprofile=coverage-unit.out -covermode=atomic ./...
	@go test -coverprofile=coverage-integration.out -covermode=atomic ./testing/integration/... 2>/dev/null || true
	@echo "mode: atomic" > coverage.out
	@tail -n +2 coverage-unit.out >> coverage.out
	@tail -n +2 coverage-integration.out >> coverage.out 2>/dev/null || true
	@go tool cover -html=coverage.out -o coverage.html
	@go tool cover -func=coverage.out | tail -1
```

## Test Conventions

Use the standard `testing` package. No third-party test frameworks.

```go
func TestFeature(t *testing.T) {
    t.Run("success case", func(t *testing.T) {
        t.Parallel()
        // ...
    })

    t.Run("error case", func(t *testing.T) {
        t.Parallel()
        // ...
    })
}
```

- Use `t.Run()` for subtests
- Use `t.Parallel()` where safe
- Test both success and failure paths
- Use table-driven tests for multiple cases

```bash
go test -v -race ./...
```
