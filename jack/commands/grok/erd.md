# ERD

Deep understanding of `github.com/zoobzio/erd` — entity relationship diagram generation from Go domain models via sentinel metadata.

## Core Concepts

ERD generates entity relationship diagrams from Go structs. It operates in two modes:

- **Automatic** — scan Go structs via sentinel, extract type metadata and relationships, convert to diagrams
- **Manual** — programmatic construction via fluent builder API

Relationships are inferred from struct field types: pointers (one-to-one), slices (one-to-many), embeddings (one-to-one), maps (many-to-many). Output in Mermaid (web) or GraphViz DOT (print-quality) format.

**Dependencies:** `sentinel` (type scanning and metadata extraction)

## Public API

### Sentinel Integration

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `FromSchema` | `FromSchema(title string, schema map[string]sentinel.Metadata) *Diagram` | Convert sentinel schema to ERD. Filters relationship fields (shown as lines, not attributes). |
| `FromMetadata` | `FromMetadata(meta sentinel.Metadata) *Entity` | Convert single metadata to entity (includes all fields). |

Registers the `"erd"` struct tag with sentinel via `init()`.

### Struct Tag

Format: `erd:"pk,fk,uk,note:annotation text"` — comma-separated, space-trimmed.

| Tag | Meaning |
|-----|---------|
| `pk` | Primary key |
| `fk` | Foreign key |
| `uk` | Unique key |
| `note:...` | Attribute annotation |

### Builder API

All constructors return pointers with chainable methods.

**Diagram:**

| Function/Method | Signature | Behaviour |
|-----------------|-----------|-----------|
| `NewDiagram` | `NewDiagram(title string) *Diagram` | Create diagram |
| `WithDescription` | `WithDescription(desc string) *Diagram` | Set description |
| `AddEntity` | `AddEntity(entity *Entity) *Diagram` | Add entity |
| `AddRelationship` | `AddRelationship(rel *Relationship) *Diagram` | Add relationship |

**Entity:**

| Function/Method | Signature | Behaviour |
|-----------------|-----------|-----------|
| `NewEntity` | `NewEntity(name string) *Entity` | Create entity |
| `WithPackage` | `WithPackage(pkg string) *Entity` | Set package name |
| `WithNote` | `WithNote(note string) *Entity` | Set annotation |
| `AddAttribute` | `AddAttribute(attr *Attribute) *Entity` | Add attribute |

**Attribute:**

| Function/Method | Signature | Behaviour |
|-----------------|-----------|-----------|
| `NewAttribute` | `NewAttribute(name, attrType string) *Attribute` | Create attribute |
| `WithPrimaryKey` | `WithPrimaryKey() *Attribute` | Mark as PK |
| `WithForeignKey` | `WithForeignKey() *Attribute` | Mark as FK |
| `WithUnique` | `WithUnique() *Attribute` | Mark as UK |
| `WithNullable` | `WithNullable() *Attribute` | Mark nullable |
| `WithKey` | `WithKey(keyType KeyType) *Attribute` | Set key type |
| `WithNote` | `WithNote(note string) *Attribute` | Set annotation |

**Relationship:**

| Function/Method | Signature | Behaviour |
|-----------------|-----------|-----------|
| `NewRelationship` | `NewRelationship(from, to, field string, cardinality Cardinality) *Relationship` | Create relationship |
| `WithLabel` | `WithLabel(label string) *Relationship` | Set label |
| `WithNote` | `WithNote(note string) *Relationship` | Set annotation |

## Types

### Diagram

```go
type Diagram struct {
    Title         string
    Description   *string
    Entities      map[string]*Entity
    Relationships []*Relationship
}
```

### Entity

```go
type Entity struct {
    Package    *string
    Note       *string
    Name       string
    Attributes []*Attribute
}
```

### Attribute

```go
type Attribute struct {
    Key      *KeyType
    Note     *string
    Name     string
    Type     string
    Nullable bool
}
```

### Relationship

```go
type Relationship struct {
    Label       *string
    Note        *string
    From        string
    To          string
    Field       string
    Cardinality Cardinality
}
```

### Constants

```go
type KeyType string
const (
    PrimaryKey KeyType = "PK"
    ForeignKey KeyType = "FK"
    UniqueKey  KeyType = "UK"
)

type Cardinality string
const (
    OneToOne   Cardinality = "one-to-one"
    OneToMany  Cardinality = "one-to-many"
    ManyToOne  Cardinality = "many-to-one"
    ManyToMany Cardinality = "many-to-many"
)
```

### ValidationError

```go
type ValidationError struct {
    Field   string
    Message string
}
```

## Output Formats

| Method | Format | Purpose |
|--------|--------|---------|
| `ToMermaid()` | `erDiagram` syntax | Web rendering, documentation |
| `ToDOT()` | GraphViz `digraph` | Print-quality diagrams |

Both sort entity names before rendering for deterministic output.

## Validation

| Method | Behaviour |
|--------|-----------|
| `Diagram.Validate()` | Non-empty title, at least one entity |
| `Entity.Validate()` | Non-empty name, at least one attribute |
| `Attribute.Validate()` | Non-empty name/type, valid key type if present |
| `Relationship.ValidateAgainst(entities)` | Both entities exist, valid cardinality |

All return `[]ValidationError` — empty slice means valid.

## Cardinality Inference

| Field Type | Inferred Cardinality |
|-----------|---------------------|
| `*Type` (pointer) | OneToOne |
| `[]Type` (slice) | OneToMany |
| Embedded struct | OneToOne |
| `map[K]V` | ManyToMany |

Nullability automatically detected from pointer types.

## Common Patterns

**From Sentinel Schema:**

```go
sentinel.Scan[User]()
sentinel.Scan[Order]()
schema := sentinel.Schema()
diagram := erd.FromSchema("Domain Model", schema)
mermaid := diagram.ToMermaid()
```

**Manual Construction:**

```go
diagram := erd.NewDiagram("Users").
    AddEntity(erd.NewEntity("User").
        AddAttribute(erd.NewAttribute("id", "uuid").WithPrimaryKey()).
        AddAttribute(erd.NewAttribute("email", "string").WithUnique())).
    AddRelationship(erd.NewRelationship("User", "Order", "orders", erd.OneToMany))
```

## File Layout

```
erd/
├── api.go          # Type definitions (Diagram, Entity, Attribute, Relationship, constants)
├── builder.go      # Constructor and builder methods
├── sentinel.go     # Sentinel integration (FromSchema, FromMetadata, tag parsing)
├── mermaid.go      # Mermaid rendering
├── dot.go          # GraphViz DOT rendering
└── validate.go     # Validation logic
```

## Thread Safety

All operations are pure data structure manipulations. No shared mutable state. No global state except sentinel tag registration (one-time `init()`).

## Ecosystem

ERD depends on:
- **sentinel** — type scanning and metadata extraction

ERD is used by applications with data models that need visual documentation.
