# Soy

Deep understanding of `github.com/zoobzio/soy` — type-safe, schema-validated SQL query builder for Go.

## Core Concepts

Soy wraps ASTQL to provide a simplified, type-safe query builder. Reflection happens once during `New()` — the query hot path is zero-reflection. Named parameters prevent SQL injection. Struct tags drive schema validation at construction time.

- **Soy[T]** is the entry point — one instance per table/type pair
- **Builders** (Select, Query, Create, Update, Delete, Aggregate, Compound) construct SQL via fluent chains
- **Sentinel integration** extracts struct field metadata for schema validation
- **ASTQL** provides the underlying SQL AST and dialect rendering
- **atom** provides type-erased row scanning

**Dependencies:** `sentinel` (struct metadata), `astql` (SQL AST), `atom` (row scanning), `capitan` (observability), `sqlx` (database access), `dbml` (schema definition)

## Public API

### Constructor

```go
func New[T any](db sqlx.ExtContext, tableName string, renderer astql.Renderer) (*Soy[T], error)
```

Registers struct tags with sentinel, performs reflection once, builds DBML schema for ASTQL validation. Returns error if table name empty or renderer nil.

### Factory Methods

| Method | Returns | Purpose |
|--------|---------|---------|
| `Select()` | `*Select[T]` | Single-row query |
| `Query()` | `*Query[T]` | Multi-row query |
| `Count()` | `*Aggregate[T]` | COUNT(*) |
| `Sum(field)` | `*Aggregate[T]` | SUM |
| `Avg(field)` | `*Aggregate[T]` | AVG |
| `Min(field)` | `*Aggregate[T]` | MIN |
| `Max(field)` | `*Aggregate[T]` | MAX |
| `Insert()` | `*Create[T]` | INSERT (excludes PKs) |
| `InsertFull()` | `*Create[T]` | INSERT (includes PKs) |
| `Modify()` | `*Update[T]` | UPDATE |
| `Remove()` | `*Delete[T]` | DELETE |

### Metadata Accessors

| Method | Returns | Purpose |
|--------|---------|---------|
| `TableName()` | `string` | Table name |
| `Metadata()` | `sentinel.Metadata` | Struct field metadata |
| `Instance()` | `*astql.ASTQL` | Escape hatch to ASTQL |

### Callbacks

| Method | Purpose |
|--------|---------|
| `OnScan(fn func(ctx, *T) error)` | Called after scanning each row |
| `OnRecord(fn func(ctx, *T) error)` | Called before inserting each record |

## Struct Tags

```go
type User struct {
    ID    int    `db:"id" type:"integer" constraints:"primarykey"`
    Email string `db:"email" type:"text" constraints:"notnull,unique"`
    Name  string `db:"name" type:"text"`
    Age   *int   `db:"age" type:"integer"`
}
```

| Tag | Purpose |
|-----|---------|
| `db:"column_name"` | SQL column name |
| `type:"sql_type"` | SQL type (inferred if omitted) |
| `constraints:"primarykey,notnull,unique"` | Constraints |
| `default:"value"` | Default value |
| `check:"expression"` | Check constraint |
| `index:"index_name"` | Index specification |
| `references:"table(column)"` | Foreign key reference |

## Query Building

### WHERE Conditions

| Method | Behaviour |
|--------|-----------|
| `Where(field, op, param)` | Single condition |
| `WhereAnd(conditions...)` | AND group |
| `WhereOr(conditions...)` | OR group |
| `WhereNull(field)` | IS NULL |
| `WhereNotNull(field)` | IS NOT NULL |
| `WhereBetween(field, low, high)` | BETWEEN |
| `WhereNotBetween(field, low, high)` | NOT BETWEEN |
| `WhereFields(conditions...)` | Multiple conditions |

### Condition Helpers

| Function | Signature | Purpose |
|----------|-----------|---------|
| `C` | `C(field, operator, param) Condition` | Simple condition |
| `Null` | `Null(field) Condition` | IS NULL |
| `NotNull` | `NotNull(field) Condition` | IS NOT NULL |
| `Between` | `Between(field, low, high) Condition` | BETWEEN |
| `NotBetween` | `NotBetween(field, low, high) Condition` | NOT BETWEEN |

### Supported Operators

```
Comparison: =, !=, >, >=, <, <=
Pattern:    LIKE, NOT LIKE, ILIKE, NOT ILIKE
Set:        IN, NOT IN
Regex:      ~, ~*, !~, !~*       (PostgreSQL)
Arrays:     @>, <@, &&            (PostgreSQL)
Vectors:    <->, <#>, <=>, <+>   (pgvector)
Arithmetic: +, -, *, /, %
```

### SELECT Features

Ordering, pagination, distinct, group by, having, window functions (ROW_NUMBER, RANK, DENSE_RANK, etc.), row locking (FOR UPDATE/SHARE), string functions, math functions, aggregate functions with FILTER, date functions, type casting, CASE expressions, COALESCE/NULLIF, set operations (UNION/INTERSECT/EXCEPT).

### INSERT Features

Simple inserts, bulk inserts with RETURNING, ON CONFLICT (DO NOTHING, DO UPDATE), upserts.

### Safety

UPDATE and DELETE require a WHERE clause. Returns `ErrUnsafeUpdate` / `ErrUnsafeDelete` without one.

## Execution

All builders share these execution methods:

| Method | Behaviour |
|--------|-----------|
| `Exec(ctx, params)` | Execute against database |
| `ExecTx(ctx, tx, params)` | Execute in transaction |
| `ExecAtom(ctx, params)` | Execute, return type-erased atom |
| `ExecTxAtom(ctx, tx, params)` | Execute in transaction, return atom |
| `ExecBatch(ctx, batchParams)` | Execute with multiple parameter sets |
| `ExecBatchTx(ctx, tx, batchParams)` | Batch in transaction |
| `Render()` | Return rendered SQL without executing |
| `MustRender()` | Render or panic |

Parameters are named maps: `map[string]any{"user_email": "foo@bar.com"}`.

## Sentinel Errors

### Data Errors

| Error | Meaning |
|-------|---------|
| `ErrNotFound` | Zero rows when at least one expected |
| `ErrMultipleRows` | Multiple rows when exactly one expected |
| `ErrNoRowsAffected` | No rows affected when rows expected |

### Safety Errors

| Error | Meaning |
|-------|---------|
| `ErrUnsafeUpdate` | UPDATE without WHERE |
| `ErrUnsafeDelete` | DELETE without WHERE |

### Validation Errors

`ValidationError` struct with `Kind`, `Name`, `Message`, `Err` fields.

Sentinels: `ErrInvalidField`, `ErrInvalidParam`, `ErrInvalidOperator`, `ErrInvalidDirection`, `ErrInvalidNullsOrdering`, `ErrInvalidTable`, `ErrInvalidCondition`, `ErrInvalidAggregateFunc`

### Query Errors

`QueryError` struct with `Operation`, `Phase`, `Err`.

Sentinels: `ErrQueryFailed`, `ErrScanFailed`, `ErrIterationFailed`, `ErrRenderFailed`

### Builder Errors

`BuilderError` struct with `Builder`, `Err`. Sentinel: `ErrBuilderHasErrors`.

### Initialisation Errors

`ErrEmptyTableName`, `ErrNilRenderer`

## Database Dialect Support

| Renderer | Target |
|----------|--------|
| `astql.postgres.New()` | PostgreSQL (primary) |
| `astql.mariadb.New()` | MariaDB |
| `astql.sqlite.New()` | SQLite |
| `astql.mssql.New()` | Microsoft SQL Server |

## Capitan Signals

| Signal | Emitted When |
|--------|-------------|
| `QueryStarted` | Before execution |
| `QueryCompleted` | After success |
| `QueryFailed` | On error |

**Field Keys:** `TableKey`, `OperationKey`, `SQLKey`, `DurationMsKey`, `RowsAffectedKey`, `RowsReturnedKey`, `ErrorKey`, `FieldKey`, `ResultValueKey`

## Thread Safety

- **Soy[T] instance:** Safe for concurrent use after construction
- **Builders:** NOT safe for concurrent use (mutable state during chain building)
- Use `ExecTx()` variants with `*sqlx.Tx` for transaction safety

## File Layout

```
soy/
├── api.go          # Soy[T] type, constructor, factory methods
├── select.go       # Select[T] single-row queries
├── query.go        # Query[T] multi-row queries
├── create.go       # Create[T] INSERT operations
├── update.go       # Update[T] UPDATE operations
├── delete.go       # Delete[T] DELETE operations
├── aggregate.go    # Aggregate[T] COUNT/SUM/AVG/MIN/MAX
├── compound.go     # Compound[T] UNION/INTERSECT/EXCEPT
├── builder.go      # Shared builder implementation
├── where.go        # WHERE clause building
├── case.go         # CASE expression builders
├── window.go       # Window function builders
├── batch.go        # Batch operation execution
├── exec.go         # Execution helpers
├── errors.go       # Error types and sentinels
├── events.go       # Capitan signals and keys
├── dbml.go         # DBML schema generation from struct tags
├── testing/
│   ├── helpers.go
│   ├── integration/
│   └── benchmarks/
└── internal/scanner/
```

## Common Patterns

**Basic Query:**

```go
s, _ := soy.New[User](db, "users", postgres.New())
user, _ := s.Select().Where("email", "=", "user_email").Exec(ctx, map[string]any{
    "user_email": "john@example.com",
})
```

**Safe Update:**

```go
s.Modify().Set("name", "new_name").Where("id", "=", "user_id").Exec(ctx, map[string]any{
    "new_name": "John",
    "user_id":  42,
})
```

**Upsert:**

```go
s.Insert().OnConflict("email").DoUpdate("name").Exec(ctx, &user)
```

## Anti-Patterns

- **Sharing builders across goroutines** — builders are not thread-safe. Create new builders per operation.
- **Omitting WHERE on Update/Delete** — returns safety error. Intentional full-table operations need raw ASTQL.
- **Ignoring named parameter validation** — ASTQL validates at build time. Parameter names must match `db` tag values.

## Ecosystem

Soy depends on:
- **sentinel** — struct field metadata extraction
- **astql** — SQL AST and dialect rendering
- **atom** — type-erased row scanning
- **capitan** — observability signals
- **dbml** — database schema definition

Soy is consumed by applications with database access needs.
