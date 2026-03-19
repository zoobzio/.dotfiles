# Store Integration Testing

Testing store operations against real database connections and storage backends. No mocks — these tests verify actual data persistence and retrieval.

## Real Database Connections

Integration tests connect to real databases. Use the test registry from `setup.go` to wire stores.

```go
func TestUserStore(t *testing.T) {
    if testDSN == "" {
        t.Skip("requires database")
    }

    reg := NewTestRegistry(t, WithUsers(testDSN))
    ctx := context.Background()

    // Test against the real store
    err := reg.stores.Users.Create(ctx, user)
    if err != nil {
        t.Fatalf("create: %v", err)
    }
}
```

Each test gets a clean state via the registry's cleanup functions, which truncate tables between tests.

## CRUD Operations

Test the full create-read-update-delete cycle against the real backend.

```go
func TestUserCRUD(t *testing.T) {
    reg := NewTestRegistry(t, WithUsers(testDSN))
    ctx := context.Background()

    // Create
    user := &models.User{Name: "Test", Email: "test@example.com"}
    err := reg.stores.Users.Create(ctx, user)
    AssertNoError(t, err)

    if user.ID == "" {
        t.Fatal("create must assign an ID")
    }

    // Read
    got, err := reg.stores.Users.Get(ctx, user.ID)
    AssertNoError(t, err)

    if got.Name != user.Name {
        t.Fatalf("get: name = %q, want %q", got.Name, user.Name)
    }

    // Update
    user.Name = "Updated"
    err = reg.stores.Users.Update(ctx, user)
    AssertNoError(t, err)

    got, err = reg.stores.Users.Get(ctx, user.ID)
    AssertNoError(t, err)

    if got.Name != "Updated" {
        t.Fatalf("update: name = %q, want %q", got.Name, "Updated")
    }

    // Delete
    err = reg.stores.Users.Delete(ctx, user.ID)
    AssertNoError(t, err)

    _, err = reg.stores.Users.Get(ctx, user.ID)
    if err == nil {
        t.Fatal("expected error after delete")
    }
}
```

## Custom Queries

Test queries that go beyond basic CRUD — filters, pagination, sorting.

```go
func TestUserSearch(t *testing.T) {
    reg := NewTestRegistry(t, WithUsers(testDSN))
    ctx := context.Background()

    // Seed data
    for i := 0; i < 10; i++ {
        reg.stores.Users.Create(ctx, &models.User{
            Name:  fmt.Sprintf("User %d", i),
            Email: fmt.Sprintf("user%d@example.com", i),
        })
    }

    // Test filtered query
    results, err := reg.stores.Users.Search(ctx, stores.UserFilter{
        NameContains: "User 5",
    })
    AssertNoError(t, err)

    if len(results) != 1 {
        t.Fatalf("search: got %d results, want 1", len(results))
    }
}
```

## Vector Similarity

For stores that support vector operations, test similarity search with known vectors.

```go
func TestVectorSimilarity(t *testing.T) {
    reg := NewTestRegistry(t, WithDocuments(testDSN))
    ctx := context.Background()

    // Seed with known embeddings
    docs := []*models.Document{
        {Title: "cats", Embedding: []float64{1.0, 0.0, 0.0}},
        {Title: "dogs", Embedding: []float64{0.9, 0.1, 0.0}},
        {Title: "cars", Embedding: []float64{0.0, 0.0, 1.0}},
    }
    for _, d := range docs {
        reg.stores.Documents.Create(ctx, d)
    }

    // Query with a vector close to "cats"
    results, err := reg.stores.Documents.Similar(ctx, []float64{1.0, 0.05, 0.0}, 2)
    AssertNoError(t, err)

    if len(results) != 2 {
        t.Fatalf("similar: got %d results, want 2", len(results))
    }

    if results[0].Title != "cats" {
        t.Fatalf("closest match should be cats, got %q", results[0].Title)
    }
}
```

## Lifecycle Hooks

Test that `BeforeSave` and `AfterLoad` hooks fire correctly with real store operations.

```go
func TestBeforeSaveHook(t *testing.T) {
    reg := NewTestRegistry(t, WithUsers(testDSN))
    ctx := context.Background()

    user := &models.User{
        Name:  "test",
        Email: "TEST@EXAMPLE.COM", // uppercase
    }

    // BeforeSave should normalise the email
    err := reg.stores.Users.Create(ctx, user)
    AssertNoError(t, err)

    got, err := reg.stores.Users.Get(ctx, user.ID)
    AssertNoError(t, err)

    if got.Email != "test@example.com" {
        t.Fatalf("BeforeSave did not normalise email: got %q", got.Email)
    }
}

func TestAfterLoadHook(t *testing.T) {
    reg := NewTestRegistry(t, WithUsers(testDSN))
    ctx := context.Background()

    // Create a user with an encrypted field
    user := &models.User{Name: "test", SSN: "123-45-6789"}
    reg.stores.Users.Create(ctx, user)

    // AfterLoad should decrypt the field
    got, err := reg.stores.Users.Get(ctx, user.ID)
    AssertNoError(t, err)

    if got.SSN != "123-45-6789" {
        t.Fatalf("AfterLoad did not decrypt: got %q", got.SSN)
    }
}
```

## Transaction Support

Test that transactions commit and rollback correctly.

```go
func TestTransactionCommit(t *testing.T) {
    reg := NewTestRegistry(t, WithUsers(testDSN), WithPosts(testDSN))
    ctx := context.Background()

    err := reg.stores.InTransaction(ctx, func(tx stores.Transaction) error {
        user := &models.User{Name: "txn-user"}
        if err := tx.Users().Create(ctx, user); err != nil {
            return err
        }
        post := &models.Post{AuthorID: user.ID, Title: "txn-post"}
        return tx.Posts().Create(ctx, post)
    })
    AssertNoError(t, err)

    // Both records should exist
    users, _ := reg.stores.Users.List(ctx)
    posts, _ := reg.stores.Posts.List(ctx)

    if len(users) != 1 || len(posts) != 1 {
        t.Fatalf("transaction commit: users=%d posts=%d", len(users), len(posts))
    }
}

func TestTransactionRollback(t *testing.T) {
    reg := NewTestRegistry(t, WithUsers(testDSN))
    ctx := context.Background()

    err := reg.stores.InTransaction(ctx, func(tx stores.Transaction) error {
        tx.Users().Create(ctx, &models.User{Name: "rollback-user"})
        return fmt.Errorf("deliberate failure")
    })

    if err == nil {
        t.Fatal("expected transaction error")
    }

    // No records should exist
    users, _ := reg.stores.Users.List(ctx)
    if len(users) != 0 {
        t.Fatalf("rollback failed: %d users exist", len(users))
    }
}
```

## Test Fixtures for Seeding

Use fixture functions from `testing/fixtures.go` to seed integration test data consistently.

```go
func TestWithSeededData(t *testing.T) {
    reg := NewTestRegistry(t, WithUsers(testDSN))
    ctx := context.Background()

    // Seed using fixtures
    users := []*models.User{
        NewUser(t, WithUserName("Alice")),
        NewUser(t, WithUserName("Bob")),
        NewUser(t, WithUserName("Charlie")),
    }
    for _, u := range users {
        reg.stores.Users.Create(ctx, u)
    }

    // Test against seeded data
    results, err := reg.stores.Users.List(ctx)
    AssertNoError(t, err)

    if len(results) != 3 {
        t.Fatalf("expected 3 users, got %d", len(results))
    }
}
```

Keep fixture usage consistent between unit and integration tests. The same `NewUser(t, ...)` factory works in both contexts — only the store behind it changes.
