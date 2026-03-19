# Fixtures, Mocks, and Helpers

Shared test infrastructure lives in the `testing/` directory. Every file here has its own test file.

```
testing/
├── fixtures.go
├── fixtures_test.go
├── mocks.go
├── mocks_test.go
├── helpers.go
└── helpers_test.go
```

## Fixture Pattern

Fixtures are factory functions that return domain models with sensible defaults. Use the option pattern for customisation.

```go
package testing

import (
    "testing"
    "github.com/zoobzio/[app]/models"
)

type UserOption func(*models.User)

func NewUser(t *testing.T, opts ...UserOption) *models.User {
    t.Helper()
    u := &models.User{
        ID:    "test-user-id",
        Name:  "Test User",
        Email: "test@example.com",
    }
    for _, opt := range opts {
        opt(u)
    }
    return u
}
```

Option functions modify specific fields:

```go
func WithUserID(id string) UserOption {
    return func(u *models.User) {
        u.ID = id
    }
}

func WithUserName(name string) UserOption {
    return func(u *models.User) {
        u.Name = name
    }
}

func WithUserEmail(email string) UserOption {
    return func(u *models.User) {
        u.Email = email
    }
}
```

Usage:

```go
user := NewUser(t)                              // all defaults
user := NewUser(t, WithUserName("Alice"))       // custom name
user := NewUser(t, WithUserID("abc"), WithUserName("Bob")) // multiple options
```

Defaults should be valid — `NewUser(t)` returns a user that passes `Validate()` without any options.

## Mock Pattern

Mocks use function-field structs that implement contract interfaces. Each method delegates to a function field, returning zero values if the field is nil.

```go
package testing

import (
    "context"
    "github.com/zoobzio/[app]/models"
)

type MockUsers struct {
    OnGet    func(ctx context.Context, id string) (*models.User, error)
    OnCreate func(ctx context.Context, u *models.User) error
    OnUpdate func(ctx context.Context, u *models.User) error
    OnDelete func(ctx context.Context, id string) error
    OnList   func(ctx context.Context) ([]*models.User, error)
}

func (m *MockUsers) Get(ctx context.Context, id string) (*models.User, error) {
    if m.OnGet != nil {
        return m.OnGet(ctx, id)
    }
    return nil, nil
}

func (m *MockUsers) Create(ctx context.Context, u *models.User) error {
    if m.OnCreate != nil {
        return m.OnCreate(ctx, u)
    }
    return nil
}
```

This pattern lets each test configure only the methods it cares about:

```go
mock := &MockUsers{
    OnGet: func(ctx context.Context, id string) (*models.User, error) {
        return NewUser(t, WithUserID(id)), nil
    },
}
// OnCreate, OnUpdate, OnDelete, OnList all return zero values
```

Compile-time interface check:

```go
var _ stores.UserContract = (*MockUsers)(nil)
```

## Helper Pattern

Helpers are domain-specific test utilities. Every helper calls `t.Helper()` as its first statement and accepts `*testing.T` as its first parameter.

```go
package testing

import "testing"

func AssertNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}

func AssertError(t *testing.T, err error) {
    t.Helper()
    if err == nil {
        t.Fatal("expected error, got nil")
    }
}

func AssertEqual(t *testing.T, got, want any) {
    t.Helper()
    if got != want {
        t.Fatalf("got %v, want %v", got, want)
    }
}
```

`t.Helper()` ensures that test failure messages report the caller's line number, not the helper's.

## Naming Conventions

| Kind | Pattern | Examples |
|------|---------|----------|
| Assertions | `Assert[Condition]` | `AssertNoError`, `AssertEqual`, `AssertContains` |
| Factories | `New[Thing]` | `NewUser`, `NewPost`, `NewRequest` |
| Options | `With[Thing]` | `WithUserID`, `WithUserName`, `WithStatus` |
| Setup | `Setup[Thing]` | `SetupServer`, `SetupDatabase` |

Do not use generic names like `check` or `verify` — be specific about what is being asserted.

## File Organisation

### testing/fixtures.go

All factory functions. One `New[Entity]` function per domain model, with corresponding `[Entity]Option` type and `With[Field]` option functions.

### testing/fixtures_test.go

Tests for every fixture function. Verify defaults are valid and options apply correctly.

```go
func TestNewUser(t *testing.T) {
    t.Run("defaults are valid", func(t *testing.T) {
        u := NewUser(t)
        err := u.Validate()
        AssertNoError(t, err)
    })

    t.Run("options apply", func(t *testing.T) {
        u := NewUser(t, WithUserName("Custom"))
        if u.Name != "Custom" {
            t.Fatalf("name = %q, want %q", u.Name, "Custom")
        }
    })
}
```

### testing/mocks.go

All mock implementations. One `Mock[Entity]` struct per contract interface. Include the compile-time interface check.

### testing/mocks_test.go

Tests for mock implementations. Verify that function fields are called correctly and nil fields return zero values.

```go
func TestMockUsersGet(t *testing.T) {
    t.Run("delegates to OnGet", func(t *testing.T) {
        called := false
        m := &MockUsers{
            OnGet: func(ctx context.Context, id string) (*models.User, error) {
                called = true
                return NewUser(t), nil
            },
        }
        m.Get(context.Background(), "123")
        if !called {
            t.Fatal("OnGet was not called")
        }
    })

    t.Run("nil returns zero", func(t *testing.T) {
        m := &MockUsers{}
        user, err := m.Get(context.Background(), "123")
        if user != nil || err != nil {
            t.Fatal("expected nil, nil for unconfigured mock")
        }
    })
}
```

### testing/helpers.go

All assertion and setup helpers. Keep them domain-specific — a helper that only makes sense for one test belongs in that test file, not here.

### testing/helpers_test.go

Tests for every helper. Test both the passing and failing paths.

```go
func TestAssertNoError(t *testing.T) {
    // Passing case — no error
    AssertNoError(t, nil)

    // Failing case — use a sub-test that we expect to fail
    // (verify the helper calls t.Fatalf by checking the message)
}
```
