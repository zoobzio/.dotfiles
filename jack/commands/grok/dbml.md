# DBML

Deep understanding of `github.com/zoobzio/dbml` — programmatic DBML (Database Markup Language) generation from Go with fluent builders.

## Core Concepts

DBML provides a fluent, type-safe Go API for building database schema definitions. Users chain builder methods to construct a schema, validate it, and generate DBML text output suitable for visualisation tools (e.g., dbdiagram.io). Also supports JSON/YAML serialisation for schema storage.

- **Project** is the root — contains tables, enums, refs, table groups
- **Table** has columns and indexes
- **Column** has type, settings (PK, nullable, unique, etc.), and optional inline refs
- **Ref** defines relationships with cardinality and referential actions

**Dependencies:** `yaml.v3`

## Public API

### Constructors

| Function | Signature | Purpose |
|----------|-----------|---------|
| `NewProject` | `NewProject(name string) *Project` | Create project |
| `NewTable` | `NewTable(name string) *Table` | Create table (default schema: "public") |
| `NewColumn` | `NewColumn(name, colType string) *Column` | Create column |
| `NewIndex` | `NewIndex(columns ...string) *Index` | Column-based index |
| `NewExpressionIndex` | `NewExpressionIndex(expressions ...string) *Index` | Expression-based index |
| `NewRef` | `NewRef(relType RelType) *Ref` | Create relationship |
| `NewEnum` | `NewEnum(name string, values ...string) *Enum` | Create enum |
| `NewTableGroup` | `NewTableGroup(name string) *TableGroup` | Create table group |

### Builder Methods (Fluent, all return self)

**Project:** `WithDatabaseType(dbType)`, `WithNote(note)`, `AddTable(table)`, `AddEnum(enum)`, `AddRef(ref)`, `AddTableGroup(group)`

**Table:** `WithSchema(schema)`, `WithAlias(alias)`, `WithNote(note)`, `WithSetting(key, value)`, `WithHeaderColor(color)`, `AddColumn(column)`, `AddIndex(index)`

**Column:** `WithPrimaryKey()`, `WithNull()`, `WithUnique()`, `WithIncrement()`, `WithDefault(value)`, `WithCheck(constraint)`, `WithNote(note)`, `WithRef(relType, schema, table, column)`

**Index:** `WithType(indexType)`, `WithName(name)`, `WithUnique()`, `WithPrimaryKey()`, `WithNote(note)`

**Ref:** `WithName(name)`, `From(schema, table, columns...)`, `To(schema, table, columns...)`, `WithOnDelete(action)`, `WithOnUpdate(action)`, `WithColor(color)`

**Enum:** `WithSchema(schema)`, `WithNote(note)`

**TableGroup:** `AddTable(schema, name)`

### Generation

Every type has a `Generate() string` method producing DBML text. Default schema "public" is omitted from output.

### Serialisation

| Method | Purpose |
|--------|---------|
| `(*Project) ToJSON() ([]byte, error)` | Marshal to JSON |
| `(*Project) FromJSON(data []byte) error` | Unmarshal from JSON |
| `(*Project) ToYAML() ([]byte, error)` | Marshal to YAML |
| `(*Project) FromYAML(data []byte) error` | Unmarshal from YAML |

### Validation

Every type has `Validate() error` returning `*ValidationError`.

| Type | Rules |
|------|-------|
| Project | Non-empty name, all children valid |
| Table | Non-empty name/schema, at least one column |
| Column | Non-empty name/type |
| Index | At least one column, each has Name XOR Expression |
| Ref | Both endpoints non-nil, valid type and actions |
| Enum | Non-empty name/schema, at least one value |
| TableGroup | Non-empty name, at least one table ref |

## Types

### Constants

```go
type RelType string
const (
    OneToMany  RelType = "<"
    ManyToOne  RelType = ">"
    OneToOne   RelType = "-"
    ManyToMany RelType = "<>"
)

type RefAction string
const (
    Cascade    RefAction = "cascade"
    Restrict   RefAction = "restrict"
    SetNull    RefAction = "set null"
    SetDefault RefAction = "set default"
    NoAction   RefAction = "no action"
)
```

### ColumnSettings

```go
type ColumnSettings struct {
    Default    *string
    Check      *string
    PrimaryKey bool
    Null       bool
    Unique     bool
    Increment  bool
}
```

## File Layout

```
dbml/
├── api.go         # Type definitions and constants
├── builder.go     # Fluent builder methods
├── generator.go   # DBML text generation
├── serialize.go   # JSON/YAML serialisation
└── validate.go    # Validation logic
```

## Common Patterns

```go
project := dbml.NewProject("myapp").
    WithDatabaseType("PostgreSQL").
    AddTable(dbml.NewTable("users").
        AddColumn(dbml.NewColumn("id", "bigint").WithPrimaryKey().WithIncrement()).
        AddColumn(dbml.NewColumn("email", "varchar(255)").WithUnique()).
        AddIndex(dbml.NewIndex("email").WithUnique())).
    AddRef(dbml.NewRef(dbml.OneToMany).
        From("public", "users", "id").
        To("public", "orders", "user_id").
        WithOnDelete(dbml.Cascade))

output := project.Generate()
```

## Ecosystem

DBML is consumed by:
- **astql** — schema validation for SQL query building
- **soy** — generates DBML from struct tags for astql integration
