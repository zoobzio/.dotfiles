# ASTQL

Deep understanding of `github.com/zoobzio/astql` — type-safe SQL query builder with multi-dialect rendering and DBML schema validation.

## Core Concepts

ASTQL converts fluent builder method calls into an internal AST, then renders it to dialect-specific SQL. All parameters are named (`:param_name`), never interpolated. Optional DBML schema integration provides compile-time field validation.

- **Builder** constructs queries via fluent chains → produces AST
- **AST** is the internal representation of a SQL query
- **Renderer** converts AST to dialect-specific SQL with named parameters
- **ASTQL instance** wraps a DBML schema for validated field/table/param access

**Dependencies:** `dbml` (schema definitions)

## Public API

### Builder Entry Points

| Function | Signature | Purpose |
|----------|-----------|---------|
| `Select` | `Select(table Table) *Builder` | SELECT query |
| `Insert` | `Insert(table Table) *Builder` | INSERT query |
| `Update` | `Update(table Table) *Builder` | UPDATE query |
| `Delete` | `Delete(table Table) *Builder` | DELETE query |
| `Count` | `Count(table Table) *Builder` | COUNT query |

### Builder Methods (Fluent, all return `*Builder`)

**Core:**
- `Fields(fields...)` — SELECT columns
- `Where(condition)` — WHERE (combines with AND)
- `WhereField(field, op, param)` — convenience WHERE
- `Set(field, param)` — UPDATE SET
- `SetExpr(field, expr)` — UPDATE with expression
- `Values(valueMap)` — INSERT row (call multiple times for bulk)

**JOINs:** `Join`, `InnerJoin`, `LeftJoin`, `RightJoin`, `FullOuterJoin`, `CrossJoin`

**Grouping:** `GroupBy(fields...)`, `Having(conditions...)`, `HavingAgg(conditions...)`

**Ordering:** `OrderBy(field, direction)`, `OrderByNulls(field, direction, nulls)`, `OrderByExpr(field, op, param, direction)`

**Pagination:** `Limit(int)`, `LimitParam(Param)`, `Offset(int)`, `OffsetParam(Param)`

**PostgreSQL:** `Distinct()`, `DistinctOn(fields...)`, `ForUpdate()`, `ForNoKeyUpdate()`, `ForShare()`, `ForKeyShare()`, `Returning(fields...)`, `OnConflict(columns...) *ConflictBuilder`

**Expressions:** `SelectExpr(expr)`, `SelectBinaryExpr(field, op, param, alias)`

**Build/Render:**
- `Build() (*AST, error)` — validate and return AST
- `MustBuild() *AST` — build or panic
- `Render(renderer) (*QueryResult, error)` — build + render
- `MustRender(renderer) *QueryResult` — render or panic

### Set Operations

| Function | Purpose |
|----------|---------|
| `Union(first, second)` | UNION |
| `UnionAll`, `Intersect`, `IntersectAll`, `Except`, `ExceptAll` | All variants |

Returns `*CompoundBuilder` with `OrderBy`, `Limit`, `Offset` methods.

### Operators

| Category | Operators |
|----------|-----------|
| Comparison | `=`, `!=`, `>`, `>=`, `<`, `<=` |
| Pattern | `LIKE`, `NOT LIKE`, `ILIKE`, `NOT ILIKE` |
| Set | `IN`, `NOT IN` |
| Null | `IS NULL`, `IS NOT NULL` |
| Existence | `EXISTS`, `NOT EXISTS` |
| Regex (PostgreSQL) | `~`, `~*`, `!~`, `!~*` |
| Arrays (PostgreSQL) | `@>`, `<@`, `&&` |
| pgvector | `<->` (L2), `<#>` (inner product), `<=>` (cosine), `<+>` (L1) |

### Condition Types

| Type | Purpose |
|------|---------|
| `Condition` | Simple: field op param |
| `ConditionGroup` | AND/OR group of conditions |
| `AggregateCondition` | HAVING with aggregate function |
| `BetweenCondition` | BETWEEN / NOT BETWEEN |
| `FieldComparison` | field1 op field2 |
| `SubqueryCondition` | field IN (SELECT ...) or EXISTS |

### Expression Builders

**Aggregates:** `Sum`, `Avg`, `Min`, `Max`, `CountField`, `CountDistinct`, `CountStar` — plus `*Filter` variants with FILTER clause

**CASE:** `Case().When(condition, result).Else(result).As(alias).Build()`

**NULL handling:** `Coalesce(values...)`, `NullIf(v1, v2)`, `Between`, `NotBetween`

**Math:** `Round`, `Floor`, `Ceil`, `Abs`, `Power`, `Sqrt`

**String:** `Upper`, `Lower`, `Trim`, `LTrim`, `RTrim`, `Length`, `Substring`, `Replace`, `Concat`

**Date/Time:** `Now`, `CurrentDate`, `CurrentTime`, `CurrentTimestamp`, `Extract(part, field)`, `DateTrunc(part, field)`

**Type Casting:** `Cast(field, castType)` — TEXT, INTEGER, BIGINT, NUMERIC, BOOLEAN, DATE, TIMESTAMP, UUID, JSON, JSONB, etc.

**Window Functions:** `RowNumber`, `Rank`, `DenseRank`, `Ntile`, `Lag`, `Lead`, `FirstValue`, `LastValue`, `SumOver`, `AvgOver`, `CountOver`, `MinOver`, `MaxOver` — with `Window().PartitionBy().OrderBy().Rows()` spec builder

### ASTQL Instance (Schema-Validated)

```go
func NewFromDBML(project *dbml.Project) (*ASTQL, error)
```

| Method | Behaviour |
|--------|-----------|
| `T(name, alias...)` | Get validated Table |
| `F(name)` | Get validated Field |
| `P(name)` | Get validated Param |
| `C(field, op, param)` | Validated Condition |
| `AggC(func, field, op, param)` | Validated AggregateCondition |
| `Null(field)`, `NotNull(field)` | NULL conditions |
| `And(conditions...)`, `Or(conditions...)` | Logic groups |
| `JSONBText(field, keyParam)`, `JSONBPath(field, keyParam)` | JSONB access |

Panicking methods; `Try*` variants return errors.

### Renderer Interface

```go
type Renderer interface {
    Render(ast *AST) (*QueryResult, error)
    RenderCompound(query *CompoundQuery) (*QueryResult, error)
    Capabilities() Capabilities
}

type QueryResult struct {
    SQL            string
    RequiredParams []string
}
```

### Dialect Implementations

| Dialect | Package | Key Features |
|---------|---------|-------------|
| **PostgreSQL** | `postgres/` | Full support — DISTINCT ON, ON CONFLICT, RETURNING, row locking, ILIKE, regex, arrays, pgvector, FILTER, window functions |
| **MariaDB** | `mariadb/` | ON DUPLICATE KEY UPDATE, RETURNING (INSERT/DELETE only), backtick quoting. No DISTINCT ON, ILIKE, regex, arrays, pgvector. |
| **SQLite** | `sqlite/` | Minimal — INSERT OR REPLACE, limited windows. No RETURNING, row locking, DISTINCT ON, FILTER. |
| **SQL Server** | `mssql/` | OFFSET/FETCH (requires ORDER BY), OUTPUT for RETURNING, bracket quoting. No upsert, ILIKE, regex, arrays. |

Each renderer validates capabilities and rejects unsupported features with clear error messages.

### Validation Limits

| Limit | Value |
|-------|-------|
| MaxSubqueryDepth | 3 |
| MaxJoinCount | 10 |
| MaxConditionDepth | 5 |
| MaxFieldCount | 100 |
| MaxWindowFunctions | 10 |
| MaxSetOperations | 5 |

## File Layout

```
astql/
├── api.go          # Public type exports
├── builder.go      # Fluent builder API
├── expressions.go  # Expression helpers (CASE, aggregates, window, functions)
├── instance.go     # ASTQL schema-validated instance
├── render.go       # Renderer interface
├── internal/
│   ├── types/      # AST, Condition, Field, Operator, Param, Table types
│   └── render/     # Capabilities, errors
├── postgres/       # PostgreSQL renderer
├── mariadb/        # MariaDB renderer
├── sqlite/         # SQLite renderer
├── mssql/          # SQL Server renderer
└── testing/
```

## Common Patterns

**Simple Query:**

```go
query := astql.Select(users).
    Fields(email, name).
    Where(astql.Condition{Field: age, Operator: astql.GT, Value: minAge}).
    OrderBy(name, astql.ASC).
    Limit(10)

result, _ := query.Render(postgres.New())
// result.SQL: SELECT "email", "name" FROM "users" WHERE "age" > :min_age ORDER BY "name" ASC LIMIT 10
```

**Schema-Validated:**

```go
instance, _ := astql.NewFromDBML(project)
query := astql.Select(instance.T("users")).
    Fields(instance.F("email")).
    Where(instance.C(instance.F("age"), astql.GT, instance.P("min_age")))
```

## Anti-Patterns

- **String interpolation in queries** — all values must use named Param types
- **Ignoring renderer capabilities** — check dialect support before using PostgreSQL-specific features
- **Exceeding validation limits** — deeply nested subqueries or excessive joins rejected at build time

## Ecosystem

ASTQL depends on:
- **dbml** — schema definitions for validation

ASTQL is consumed by:
- **soy** — type-safe query builder
- **edamame** — statement-driven query execution
