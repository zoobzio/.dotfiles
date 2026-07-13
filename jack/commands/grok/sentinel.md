# Sentinel

Deep understanding of `github.com/zoobzio/sentinel` — the struct introspection library that underpins type-driven development across zoobzio.

## Core Concepts

Sentinel extracts metadata from Go structs and caches it permanently. The cache is global (one type system, one cache) and append-only (types don't change at runtime).

Two extraction modes:
- **Inspect** — Single type, no recursion. Fast, minimal.
- **Scan** — Recursive extraction of the target type and all related types within the same module. Uses a `visited` map for cycle detection.

Module boundaries are detected via `debug.ReadBuildInfo()`. Scan will not recurse into stdlib or third-party types. If build info is unavailable, Scan behaves like Inspect.

**Docs:** `docs/1.learn/3.concepts.md`, `docs/1.learn/4.architecture.md`

## Public API

### Extraction

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Inspect` | `Inspect[T any]() Metadata` | Extract single type. Panics on non-struct. Dereferences pointers. |
| `TryInspect` | `TryInspect[T any]() (Metadata, error)` | Returns `ErrNotStruct` instead of panicking. |
| `Scan` | `Scan[T any]() Metadata` | Recursive extraction within module. Panics on non-struct. |
| `TryScan` | `TryScan[T any]() (Metadata, error)` | Returns `ErrNotStruct` instead of panicking. |

### Cache Queries

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Browse` | `Browse() []string` | All cached type FQDNs. |
| `Lookup` | `Lookup(typeName string) (Metadata, bool)` | Retrieve by FQDN. Returns `(meta, true)` or `(zero, false)`. |
| `Schema` | `Schema() map[string]Metadata` | All cached metadata. |

### Relationships

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `GetRelationships` | `GetRelationships[T any]() []TypeRelationship` | All types T references. |
| `GetReferencedBy` | `GetReferencedBy[T any]() []TypeRelationship` | All cached types that reference T (reverse lookup). |

### Configuration

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Tag` | `Tag(tagName string)` | Register a custom struct tag for extraction. Call before Inspect/Scan. Thread-safe. |

### Testing

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Reset` | `Reset()` | Clear cache and tag registry. Only available with `-tags testing`. |

**Docs:** `docs/4.reference/1.api.md`

## Types

### Metadata

```go
type Metadata struct {
    ReflectType   reflect.Type       // Underlying reflect.Type (excluded from JSON)
    FQDN          string             // "github.com/app/models.User"
    TypeName      string             // "User"
    PackageName   string             // "github.com/app/models"
    Fields        []FieldMetadata    // All exported fields
    Relationships []TypeRelationship // References to other structs
}
```

### FieldMetadata

```go
type FieldMetadata struct {
    ReflectType reflect.Type      // Underlying reflect.Type
    Tags        map[string]string // {"json": "id", "db": "user_id"}
    Name        string            // "ID"
    Type        string            // "string", "*Profile", "[]Order"
    Kind        FieldKind         // scalar, pointer, slice, struct, map, interface
    Index       []int             // Field index for FieldByIndex()
}
```

### TypeRelationship

```go
type TypeRelationship struct {
    From      string // Source type FQDN
    To        string // Target type FQDN
    Field     string // Field name creating the relationship
    Kind      string // "reference", "collection", "embedding", "map"
    ToPackage string // Target type's package path
}
```

### FieldKind

Constants: `scalar`, `pointer`, `slice`, `struct`, `map`, `interface`.

### Relationship Kinds

| Kind | Trigger | Example |
|------|---------|---------|
| `reference` | Direct struct or pointer field | `Profile *Profile` |
| `collection` | Slice or array of structs | `Orders []Order` |
| `embedding` | Anonymous struct field | `BaseModel` |
| `map` | Map with struct values | `Items map[string]Item` |

**Docs:** `docs/4.reference/2.types.md`

## Tag System

Eight tags are always extracted: `json`, `db`, `validate`, `scope`, `encrypt`, `redact`, `desc`, `example`.

Custom tags are registered with `sentinel.Tag("tagname")` before any extraction call. Registration is thread-safe and applies to all subsequent extractions.

**Docs:** `docs/2.guides/2.tags.md`

## Thread Safety

After initial extraction, all operations are read-only (RLock). Cache writes only occur on first access for a given type. Tag registration uses a write lock but is a rare, startup-time operation.

Safe pattern: extract all types at startup (e.g., in `init()` or early `main()`), then query freely from any goroutine.

## Error Handling

One exported error: `ErrNotStruct` — returned by `TryInspect` and `TryScan` when the type parameter is not a struct.

The panicking variants (`Inspect`, `Scan`) are intended for startup-time use where a non-struct type is a programming error, not a runtime condition.

## File Layout

```
sentinel/
├── api.go              Core API (Inspect, Scan, Browse, Lookup, Schema, Tag)
├── extraction.go       Metadata extraction pipeline
├── metadata.go         Metadata, FieldMetadata, FieldKind types
├── relationship.go     TypeRelationship, GetRelationships, GetReferencedBy
├── cache.go            Thread-safe cache (sync.RWMutex + map)
├── reset.go            Reset() behind //go:build testing
├── testing/
│   ├── helpers.go      AssertMetadataValid, AssertFieldExists, etc.
│   ├── helpers_test.go
│   ├── benchmarks/
│   └── integration/
└── docs/               Full documentation tree
```

## Test Helpers

`sentinel/testing/helpers.go` provides (behind `//go:build testing`):

| Helper | Purpose |
|--------|---------|
| `AssertMetadataValid(t, meta)` | Verify required metadata fields are populated |
| `AssertFieldExists(t, meta, name)` | Verify a field exists in metadata |
| `AssertRelationshipExists(t, meta, field)` | Verify a relationship exists |
| `AssertTagValue(t, field, tag, expected)` | Verify a specific tag value |
| `AssertCached(t, typeName)` | Verify a type is in the cache |
| `AssertNotCached(t, typeName)` | Verify a type is not cached |
| `ResetCache(t)` | Clear cache for test isolation |

All helpers call `t.Helper()` and accept `testing.TB`.

## Ecosystem

Sentinel is consumed by:
- **erd** — Reads `Metadata.Relationships` to generate Mermaid/DOT diagrams. Optional `erd` struct tags for key constraints.
- **soy** — Reads `FieldMetadata.Tags` (especially `db`) to build SQL queries.
- **rocco** — Reads `Metadata` to generate OpenAPI specifications.

Any new tool that needs struct metadata should consume sentinel rather than reimplementing reflection.

## Common Patterns

**Scan once at startup:**
```go
func init() {
    sentinel.Scan[RootType]()
}
```
This caches the entire type graph reachable from `RootType`.

**Query cached types:**
```go
meta, ok := sentinel.Lookup("github.com/app/models.User")
```

**Register custom tags before extraction:**
```go
sentinel.Tag("graphql")
sentinel.Tag("erd")
// Then extract...
```

**Export full schema:**
```go
schema := sentinel.Schema()
for fqdn, meta := range schema {
    // Generate from metadata
}
```

## Anti-Patterns

- Calling `Inspect` when you need related types — use `Scan` instead
- Registering tags after extraction — tags must be registered before the first `Inspect`/`Scan` call for them to be captured
- Using `Reset()` in production — it exists solely for test isolation
- Manually caching sentinel output — sentinel already caches permanently
- Expecting unexported fields — reflection cannot access them from outside the package

## Prohibitions

DO NOT:
- Skip reading sentinel docs when the task involves non-obvious behaviour (module boundaries, cycle detection, embedding relationships)
- Assume sentinel scans across module boundaries — it does not
- Introduce dependencies into sentinel — zero-dependency is a hard constraint
- Use `Reset()` outside of tests
