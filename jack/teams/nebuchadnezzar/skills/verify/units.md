# Unit Test Patterns

Patterns for testing handlers, transformers, models, and stores in isolation.

## Testing Handlers

Handlers orchestrate — they accept a request, delegate to contracts, and return a response. Mock the contracts and verify the orchestration.

```go
func TestHandlerGetUser(t *testing.T) {
    mock := &MockUsers{
        OnGet: func(ctx context.Context, id string) (*models.User, error) {
            return &models.User{ID: id, Name: "Test"}, nil
        },
    }

    h := handlers.NewUsers(mock)
    req := httptest.NewRequest("GET", "/users/123", nil)
    w := httptest.NewRecorder()

    h.Get(w, req)

    if w.Code != http.StatusOK {
        t.Fatalf("status = %d, want %d", w.Code, http.StatusOK)
    }

    var body map[string]any
    json.NewDecoder(w.Body).Decode(&body)

    if body["name"] != "Test" {
        t.Fatalf("name = %q, want %q", body["name"], "Test")
    }
}
```

Test error handling in handlers:

```go
func TestHandlerGetUser_NotFound(t *testing.T) {
    mock := &MockUsers{
        OnGet: func(ctx context.Context, id string) (*models.User, error) {
            return nil, stores.ErrNotFound
        },
    }

    h := handlers.NewUsers(mock)
    req := httptest.NewRequest("GET", "/users/missing", nil)
    w := httptest.NewRecorder()

    h.Get(w, req)

    if w.Code != http.StatusNotFound {
        t.Fatalf("status = %d, want %d", w.Code, http.StatusNotFound)
    }
}
```

## Testing Transformers

Transformers are pure functions — input in, output out. Test the transformation directly.

```go
func TestTransformUser(t *testing.T) {
    user := &models.User{
        ID:    "123",
        Name:  "Test User",
        Email: "test@example.com",
        SSN:   "encrypted-value", // internal field
    }

    result := transformers.User(user)

    if result.ID != "123" {
        t.Fatalf("ID = %q, want %q", result.ID, "123")
    }

    if result.Name != "Test User" {
        t.Fatalf("Name = %q, want %q", result.Name, "Test User")
    }

    // Internal fields must not leak
    if result.SSN != "" {
        t.Fatal("SSN should not be in the response")
    }
}
```

Table-driven tests work well for transformers since they have many input/output combinations:

```go
func TestTransformUserStatus(t *testing.T) {
    cases := []struct {
        name   string
        status models.Status
        want   string
    }{
        {"active", models.StatusActive, "active"},
        {"inactive", models.StatusInactive, "inactive"},
        {"suspended", models.StatusSuspended, "suspended"},
        {"unknown", models.Status(99), "unknown"},
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            user := &models.User{Status: tc.status}
            result := transformers.User(user)
            if result.Status != tc.want {
                t.Fatalf("status = %q, want %q", result.Status, tc.want)
            }
        })
    }
}
```

## Testing Models

### Validate()

Test validation logic with both valid and invalid inputs.

```go
func TestUserValidate(t *testing.T) {
    t.Run("valid", func(t *testing.T) {
        u := &models.User{Name: "Test", Email: "test@example.com"}
        err := u.Validate()
        AssertNoError(t, err)
    })

    t.Run("missing name", func(t *testing.T) {
        u := &models.User{Email: "test@example.com"}
        err := u.Validate()
        AssertError(t, err)
    })

    t.Run("invalid email", func(t *testing.T) {
        u := &models.User{Name: "Test", Email: "not-an-email"}
        err := u.Validate()
        AssertError(t, err)
    })
}
```

### Clone()

Test that clones are independent copies.

```go
func TestUserClone(t *testing.T) {
    original := &models.User{
        ID:   "123",
        Name: "Test",
        Tags: []string{"admin", "user"},
    }

    clone := original.Clone()

    // Values match
    if clone.ID != original.ID {
        t.Fatalf("ID mismatch")
    }

    // Modifying clone does not affect original
    clone.Name = "Modified"
    clone.Tags[0] = "changed"

    if original.Name == "Modified" {
        t.Fatal("clone modified the original name")
    }

    if original.Tags[0] == "changed" {
        t.Fatal("clone modified the original tags slice")
    }
}
```

### Lifecycle Hooks in Isolation

Test `BeforeSave` and `AfterLoad` without a real store.

```go
func TestUserBeforeSave(t *testing.T) {
    u := &models.User{Email: "TEST@EXAMPLE.COM"}
    u.BeforeSave()

    if u.Email != "test@example.com" {
        t.Fatalf("BeforeSave did not normalise email: %q", u.Email)
    }
}

func TestUserAfterLoad(t *testing.T) {
    u := &models.User{CreatedAt: time.Now().Add(-24 * time.Hour)}
    u.AfterLoad()

    if u.Age == "" {
        t.Fatal("AfterLoad did not compute derived fields")
    }
}
```

## Testing Store Methods

Mock the database layer and verify query construction and result mapping.

```go
func TestUsersStoreGet(t *testing.T) {
    mockDB := &MockDB{
        OnQueryRow: func(query string, args ...any) *Row {
            if !strings.Contains(query, "WHERE id = $1") {
                t.Fatalf("unexpected query: %s", query)
            }
            if args[0] != "123" {
                t.Fatalf("unexpected arg: %v", args[0])
            }
            return NewRow(&models.User{ID: "123", Name: "Test"})
        },
    }

    store := stores.NewUsers(mockDB)
    user, err := store.Get(context.Background(), "123")
    AssertNoError(t, err)

    if user.Name != "Test" {
        t.Fatalf("name = %q, want %q", user.Name, "Test")
    }
}
```

## Table-Driven Tests

The standard pattern for testing multiple cases through the same logic.

```go
func TestParseRole(t *testing.T) {
    cases := []struct {
        name    string
        input   string
        want    models.Role
        wantErr bool
    }{
        {"admin", "admin", models.RoleAdmin, false},
        {"user", "user", models.RoleUser, false},
        {"empty", "", models.Role(0), true},
        {"unknown", "superuser", models.Role(0), true},
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()
            got, err := models.ParseRole(tc.input)

            if tc.wantErr {
                AssertError(t, err)
                return
            }

            AssertNoError(t, err)
            if got != tc.want {
                t.Fatalf("got %v, want %v", got, tc.want)
            }
        })
    }
}
```

Guidelines for table-driven tests:

- Name each case descriptively
- Include both success and failure cases
- Use `t.Parallel()` within subtests when safe
- Keep the test body short — complex setup belongs in helper functions
- Avoid deeply nested test tables; split into separate test functions if the setup differs significantly
