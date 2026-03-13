# Scio

Deep understanding of `github.com/zoobzio/scio` — URI-based data catalog with atomic operations across storage types.

## Core Concepts

Scio provides logical addressing for data across multiple storage backends. Resources are registered with URI schemes (`db://`, `kv://`, `bcs://`, `idx://`), and operations route to the correct grub backend based on the URI. All data flows through `atom.Atom` — type-agnostic. Topology intelligence enables discovering related resources by shared type.

- **Scio** is the central catalog and access point
- **URI** provides logical addressing: `variant://resource/key`
- **Resource** is a registered data source with metadata and spec
- **Four variants:** database (SQL), store (key-value), bucket (blob), index (vector)
- Operations are type-agnostic — all data as `atom.Atom`

**Dependencies:** `grub` (storage interfaces), `atom` (type-agnostic data), `edamame` (query statements), `vecna` (vector filtering), `uuid`

## Public API

### Variants

```go
const (
    VariantDatabase Variant = "db"   // db://
    VariantStore    Variant = "kv"   // kv://
    VariantBucket   Variant = "bcs"  // bcs://
    VariantIndex    Variant = "idx"  // idx://
)
```

### URI

```go
type URI struct {
    Variant  Variant
    Resource string
    Key      string  // May be empty for queries
}
```

| Function | Behaviour |
|----------|-----------|
| `ParseURI(raw string)` | Parse `variant://resource/key` → `*URI, error` |
| `URI.String()` | Reconstruct URI string |
| `URI.ResourceURI()` | URI without key component |

### Resource

```go
type Resource struct {
    URI      string
    Variant  Variant
    Name     string
    Spec     atom.Spec
    Metadata Metadata
}

type Metadata struct {
    Description string
    Version     string
    Tags        map[string]string
}
```

### Registry (Registration)

| Method | Signature |
|--------|-----------|
| `RegisterDatabase` | `RegisterDatabase(uri string, db grub.AtomicDatabase, opts ...RegistrationOption) error` |
| `RegisterStore` | `RegisterStore(uri string, store grub.AtomicStore, opts ...RegistrationOption) error` |
| `RegisterBucket` | `RegisterBucket(uri string, bucket grub.AtomicBucket, opts ...RegistrationOption) error` |
| `RegisterIndex` | `RegisterIndex(uri string, index grub.AtomicIndex, opts ...RegistrationOption) error` |

**Registration options:** `WithDescription(desc)`, `WithVersion(ver)`, `WithTag(key, value)`

### Catalog (Introspection)

| Method | Behaviour |
|--------|-----------|
| `Sources()` | All registered resources |
| `Databases()` / `Stores()` / `Buckets()` / `Indexes()` | Filter by variant |
| `Spec(uri)` | Get `atom.Spec` for URI |
| `FindBySpec(spec)` | Resources with same spec (by FQDN) |
| `FindByField(field)` | Resources containing field |
| `Related(uri)` | Other resources with same spec |
| `Resource(uri)` | Resource metadata (nil if not found) |

### Operations (Data Access)

#### Key-Value (db://, kv://)

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Get` | `Get(ctx, uri) (*atom.Atom, error)` | Retrieve by key |
| `Set` | `Set(ctx, uri, data) error` | Store at key |
| `SetWithTTL` | `SetWithTTL(ctx, uri, data, ttl) error` | Store with expiration (kv:// only) |
| `Delete` | `Delete(ctx, uri) error` | Remove at key |
| `Exists` | `Exists(ctx, uri) (bool, error)` | Check key presence |

#### Database Query (db:// only)

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Query` | `Query(ctx, uri, stmt, params) ([]*atom.Atom, error)` | Multi-record SELECT |
| `Select` | `Select(ctx, uri, stmt, params) (*atom.Atom, error)` | Single-record SELECT |

#### Blob (bcs:// only)

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Put` | `Put(ctx, uri, obj *grub.AtomicObject) error` | Store blob |

### Index Operations (idx:// only)

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `GetVector` | `GetVector(ctx, uri) (*grub.AtomicVector, error)` | Retrieve by UUID key |
| `UpsertVector` | `UpsertVector(ctx, uri, vector, metadata) error` | Insert/update vector |
| `DeleteVector` | `DeleteVector(ctx, uri) error` | Remove vector |
| `VectorExists` | `VectorExists(ctx, uri) (bool, error)` | Check existence |
| `SearchVectors` | `SearchVectors(ctx, uri, vector, k, filter) ([]grub.AtomicVector, error)` | k-NN with atom filter |
| `QueryVectors` | `QueryVectors(ctx, uri, vector, k, filter) ([]grub.AtomicVector, error)` | k-NN with vecna filter |
| `FilterVectors` | `FilterVectors(ctx, uri, filter, limit) ([]grub.AtomicVector, error)` | Metadata filter only |

## Error Types

### Scio Errors

| Error | Purpose |
|-------|---------|
| `ErrInvalidURI` | URI parsing failed |
| `ErrUnknownVariant` | Unrecognised scheme |
| `ErrResourceNotFound` | Resource not registered |
| `ErrResourceExists` | Duplicate registration |
| `ErrVariantMismatch` | Operation on wrong variant |
| `ErrKeyRequired` | Key missing but needed |
| `ErrKeyNotExpected` | Key provided but not used |
| `ErrInvalidUUID` | Failed to parse key as UUID |

### Re-exported from grub

`ErrNotFound`, `ErrDuplicate`, `ErrConflict`, `ErrConstraint`, `ErrInvalidKey`, `ErrReadOnly`, `ErrTTLNotSupported`

## Thread Safety

Scio is thread-safe via `sync.RWMutex`:
- **Write lock:** registration operations
- **Read lock:** data access and introspection
- Lock scope is minimal — held during state access, not I/O

## File Layout

```
scio/
├── api.go          # Interfaces: Catalog, Operations, Registry, IndexOperations
├── errors.go       # Error definitions
├── uri.go          # URI parsing and manipulation
├── metadata.go     # Registration options
├── catalog.go      # Catalog implementation
├── registry.go     # Registry implementation + Scio constructor
├── operations.go   # Operations implementation
├── index.go        # IndexOperations implementation
└── testing/
    └── helpers.go  # MockDatabase, MockStore, MockBucket, MockIndex
```

## Common Patterns

**Register and access:**

```go
s := scio.New()
s.RegisterDatabase("db://users", usersDB, scio.WithDescription("User records"))
s.RegisterStore("kv://sessions", sessionsKV)
s.RegisterIndex("idx://embeddings", vectorIdx)

// Key-value access
user, _ := s.Get(ctx, "db://users/123")
_ = s.Set(ctx, "kv://sessions/abc", sessionData)

// Database query
users, _ := s.Query(ctx, "db://users", queryStmt, params)

// Vector search
results, _ := s.SearchVectors(ctx, "idx://embeddings", queryVec, 10, nil)
```

**Topology discovery:**

```go
spec, _ := s.Spec("db://users")
related := s.FindBySpec(spec)     // Other resources with same type
byField := s.FindByField("email") // Resources containing "email" field
```

## Ecosystem

Scio depends on:
- **grub** — storage backend interfaces (AtomicDatabase, AtomicStore, AtomicBucket, AtomicIndex)
- **atom** — type-agnostic data representation
- **edamame** — query statement types
- **vecna** — vector filter types

Scio is consumed by:
- Applications for unified data access across storage types
