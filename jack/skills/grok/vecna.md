# Vecna

Deep understanding of `github.com/zoobzio/vecna` — schema-validated filter builder for vector database queries.

## Core Concepts

Vecna builds type-safe filters for vector database queries. A generic `Builder[T]` extracts field metadata from struct types via sentinel, validates field names and operator compatibility at construction time, and produces an immutable filter AST. Errors are deferred — attached to Filter objects rather than returned immediately — enabling fluent nested filter construction with a single error check at the end.

- **Builder[T]** is the schema-aware filter factory
- **FieldBuilder[T]** applies operators to a specific field
- **Filter** is an immutable AST node with deferred error semantics
- **FilterSpec** is the JSON-serializable representation for dynamic/LLM-generated queries
- Field names resolved from `json` tags (falls back to Go field name)

**Dependencies:** `sentinel` (struct metadata extraction)

## Public API

### Builder[T]

**Constructor:**

```go
func New[T any]() (*Builder[T], error)
```

Returns `ErrNotStruct` if T is not a struct. Fields with `json:"-"` are excluded.

**Methods:**

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Spec` | `Spec() Spec` | Returns schema for export |
| `Where` | `Where(field string) *FieldBuilder[T]` | Begin field condition |
| `And` | `And(filters ...*Filter) *Filter` | Logical AND |
| `Or` | `Or(filters ...*Filter) *Filter` | Logical OR |
| `Not` | `Not(filter *Filter) *Filter` | Logical NOT |
| `FromSpec` | `FromSpec(spec *FilterSpec) *Filter` | Convert JSON spec to Filter |

### FieldBuilder[T]

All methods return `*Filter`:

| Method | Operator | Restriction |
|--------|----------|-------------|
| `Eq(value)` | `=` | Any field kind |
| `Ne(value)` | `!=` | Any field kind |
| `Gt(value)` | `>` | Numeric only (KindInt, KindFloat) |
| `Gte(value)` | `>=` | Numeric only |
| `Lt(value)` | `<` | Numeric only |
| `Lte(value)` | `<=` | Numeric only |
| `In(values...)` | `IN` | Value must be slice |
| `Nin(values...)` | `NOT IN` | Value must be slice |
| `Like(pattern)` | `LIKE` | KindString only |
| `Contains(value)` | `CONTAINS` | KindSlice only |

### Filter

Immutable AST node:

| Method | Behaviour |
|--------|-----------|
| `Op()` | Filter operator |
| `Field()` | Field name (empty for logical ops) |
| `Value()` | Comparison value (nil for logical ops) |
| `Children()` | Child filters (logical ops only) |
| `Err()` | Deferred error (checks self + all descendants) |

### Operators

```go
type Op uint8

const (
    Eq, Ne, Gt, Gte, Lt, Lte, In, Nin, Like, Contains, And, Or, Not Op
)
```

`Op.String()` returns lowercase name (`"eq"`, `"ne"`, etc.).

### Field Kinds

```go
type FieldKind uint8

const (
    KindString, KindInt, KindFloat, KindBool, KindSlice, KindUnknown FieldKind
)
```

### Schema Types

```go
type FieldSpec struct {
    Name   string    // JSON field name
    GoName string    // Original Go field name
    Kind   FieldKind // Type category
}

type Spec struct {
    TypeName string
    Fields   []FieldSpec
}
```

`Spec.Field(name string) *FieldSpec` — lookup field by name.

### FilterSpec (JSON-serializable)

```go
type FilterSpec struct {
    Op       string        `json:"op"`
    Field    string        `json:"field,omitempty"`
    Value    any           `json:"value,omitempty"`
    Children []*FilterSpec `json:"children,omitempty"`
}
```

## Sentinel Errors

| Error | Purpose |
|-------|---------|
| `ErrNotStruct` | Type parameter is not a struct |
| `ErrFieldNotFound` | Field name not in schema |
| `ErrInvalidFilter` | Operator/type mismatch or malformed spec |

## Validation Rules

| Rule | Detail |
|------|--------|
| Comparison ops (Gt, Gte, Lt, Lte) | Only on KindInt, KindFloat |
| Like | Only on KindString |
| Contains | Only on KindSlice |
| In/Nin | Value must be a slice |
| Logical ops (And, Or, Not) | No field kind restrictions |

## Field Name Resolution

1. `json` tag value (before comma) → used as field name
2. No tag or malformed → Go field name
3. `json:"-"` → field excluded entirely

## Deferred Error Model

Errors attach to Filter objects rather than returning immediately:

```go
// Builds without error even with invalid field
filter := builder.And(
    builder.Where("category").Eq("tech"),
    builder.Where("nonexistent").Eq("value"),
)

// Error discovered here — walks entire tree
if err := filter.Err(); err != nil {
    // ErrFieldNotFound for "nonexistent"
}
```

## Thread Safety

- `Builder[T]` — immutable after creation, safe to share for reads
- `Filter` — immutable, safe to share
- `FieldBuilder[T]` — short-lived, typically not shared

## File Layout

```
vecna/
├── api.go       # Op, FieldKind, Filter, FieldSpec, Spec, sentinel errors
├── builder.go   # Builder[T], FieldBuilder[T], New[T](), validation
├── spec.go      # FilterSpec, FromSpec(), spec→filter conversion
└── testing/
    └── helpers.go # DocumentMetadata, NewTestBuilder, assertions
```

## Common Patterns

**Simple filter:**

```go
builder, _ := vecna.New[Metadata]()
filter := builder.Where("category").Eq("tech")
```

**Complex nested filter:**

```go
filter := builder.And(
    builder.Where("category").Eq("tech"),
    builder.Or(
        builder.Where("score").Gte(0.8),
        builder.Where("active").Eq(true),
    ),
)
if err := filter.Err(); err != nil { /* handle */ }
```

**Dynamic filter from JSON spec:**

```go
var spec vecna.FilterSpec
json.Unmarshal(data, &spec)
filter := builder.FromSpec(&spec)
if err := filter.Err(); err != nil { /* handle */ }
```

**Array membership:**

```go
filter := builder.Where("tags").Contains("featured")
filter := builder.Where("category").In("tech", "science", "art")
```

## Ecosystem

Vecna depends on:
- **sentinel** — struct metadata extraction for schema validation

Vecna is consumed by:
- **grub** — translates vecna Filter AST to provider-specific vector DB queries (Pinecone, Qdrant, Weaviate, Milvus, pgvector)
