# Integration Test Infrastructure

Integration tests live in `testing/integration/` and test the seams where components connect using real dependencies.

## Directory Structure

```
testing/
└── integration/
    ├── README.md
    ├── setup.go          # Registry, setup, teardown
    ├── users_test.go     # User flow integration tests
    ├── posts_test.go     # Post flow integration tests
    └── search_test.go    # Search integration tests
```

Each `[feature]_test.go` file tests a complete flow through real stores and real services.

## setup.go Pattern

The setup file provides a real registry wired to real backends, configured via the option pattern.

```go
package integration

import (
    "testing"
    "github.com/zoobzio/[app]/stores"
)

type TestRegistry struct {
    stores *stores.Stores
    cleanup []func()
}

type Option func(*TestRegistry)

func NewTestRegistry(t *testing.T, opts ...Option) *TestRegistry {
    t.Helper()
    r := &TestRegistry{}
    for _, opt := range opts {
        opt(r)
    }
    t.Cleanup(func() {
        for i := len(r.cleanup) - 1; i >= 0; i-- {
            r.cleanup[i]()
        }
    })
    return r
}
```

### Store Options

Each store gets its own option function. The option connects to the real backend and registers cleanup.

```go
func WithUsers(dsn string) Option {
    return func(r *TestRegistry) {
        db := connectDB(dsn)
        r.stores.Users = stores.NewUsers(db)
        r.cleanup = append(r.cleanup, func() {
            db.Exec("TRUNCATE users CASCADE")
            db.Close()
        })
    }
}

func WithPosts(dsn string) Option {
    return func(r *TestRegistry) {
        db := connectDB(dsn)
        r.stores.Posts = stores.NewPosts(db)
        r.cleanup = append(r.cleanup, func() {
            db.Exec("TRUNCATE posts CASCADE")
            db.Close()
        })
    }
}
```

### Usage in Tests

```go
func TestUserCreation(t *testing.T) {
    reg := NewTestRegistry(t,
        WithUsers(testDSN),
        WithPosts(testDSN),
    )

    // Test against real stores through reg.stores
    err := reg.stores.Users.Create(ctx, user)
    if err != nil {
        t.Fatalf("create user: %v", err)
    }
}
```

## Setup and Teardown

Use `t.Cleanup` for teardown rather than manual defer chains. Cleanup functions run in LIFO order, so resources are released in the correct sequence.

```go
func NewTestRegistry(t *testing.T, opts ...Option) *TestRegistry {
    t.Helper()
    r := &TestRegistry{}
    for _, opt := range opts {
        opt(r)
    }
    t.Cleanup(func() {
        for i := len(r.cleanup) - 1; i >= 0; i-- {
            r.cleanup[i]()
        }
    })
    return r
}
```

For per-test isolation, truncate tables in cleanup rather than dropping them. This keeps the schema intact across tests.

## Connecting to Real Services

Integration tests connect to real databases and services. Use environment variables or a test configuration file for connection details.

```go
var testDSN = os.Getenv("TEST_DATABASE_URL")

func TestMain(m *testing.M) {
    if testDSN == "" {
        fmt.Println("TEST_DATABASE_URL not set, skipping integration tests")
        os.Exit(0)
    }
    os.Exit(m.Run())
}
```

Skip gracefully when dependencies are unavailable:

```go
func TestFeature(t *testing.T) {
    if testDSN == "" {
        t.Skip("requires database")
    }
    // ...
}
```

Use build tags to separate integration tests from unit tests:

```go
//go:build integration
```

## CI Coverage Capture

Integration tests must contribute to coverage reports. Run them with a separate coverage profile, then merge.

```yaml
- name: Run tests with coverage
  run: |
    go test -v -race -coverprofile=coverage-unit.out -covermode=atomic ./...
    go test -v -race -coverprofile=coverage-integration.out -covermode=atomic ./testing/integration/...
    echo "mode: atomic" > coverage.out
    tail -n +2 coverage-unit.out >> coverage.out
    tail -n +2 coverage-integration.out >> coverage.out 2>/dev/null || true
```

The Makefile equivalent:

```makefile
coverage:
	@go test -coverprofile=coverage-unit.out -covermode=atomic ./...
	@go test -coverprofile=coverage-integration.out -covermode=atomic ./testing/integration/... 2>/dev/null || true
	@echo "mode: atomic" > coverage.out
	@tail -n +2 coverage-unit.out >> coverage.out
	@tail -n +2 coverage-integration.out >> coverage.out 2>/dev/null || true
	@go tool cover -html=coverage.out -o coverage.html
	@go tool cover -func=coverage.out | tail -1
```
