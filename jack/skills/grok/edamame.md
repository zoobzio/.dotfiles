# Edamame

Deep understanding of `github.com/zoobzio/edamame` — statement-driven query execution with typed queries and no magic strings.

## Core Concepts

Edamame implements **statement-driven query execution**: queries are defined as typed, immutable statement objects containing serializable specs. An `Executor[T]` converts specs to parameterized SQL via soy/astql, then executes against sqlx.

Flow: **Statement → Spec → Soy Builder → astql Renderer → sqlx Execution**

- **Statements** are immutable, named, typed query definitions
- **Specs** are serializable data structures describing query semantics
- **Executor[T]** bridges statements to database execution
- All values are bound as named parameters — never interpolated

**Dependencies:** `soy` (query building), `astql` (SQL rendering), `atom` (type-erased records), `capitan` (events), `sqlx` (database access), `uuid` (statement IDs)

## Public API

### Executor[T]

**Constructor:**

```go
func New[T any](db *sqlx.DB, tableName string, renderer astql.Renderer) (*Executor[T], error)
```

**Introspection:**

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Soy` | `Soy() *soy.Soy[T]` | Access underlying soy instance |
| `TableName` | `TableName() string` | Get executor's table name |

### Statement Types

| Type | Constructor | Purpose |
|------|-------------|---------|
| `QueryStatement` | `NewQueryStatement(name, description, spec, tags...)` | Multi-record SELECT |
| `SelectStatement` | `NewSelectStatement(name, description, spec, tags...)` | Single-record SELECT |
| `UpdateStatement` | `NewUpdateStatement(name, description, spec, tags...)` | UPDATE |
| `DeleteStatement` | `NewDeleteStatement(name, description, spec, tags...)` | DELETE |
| `AggregateStatement` | `NewAggregateStatement(name, description, fn, spec, tags...)` | COUNT/SUM/AVG/MIN/MAX |

All statements have: `ID() uuid.UUID`, `Name() string`, `Description() string`, `Params() []ParamSpec`, `Tags() []string`

### Execution Methods

#### Query (returns `[]*T`)

| Method | Signature |
|--------|-----------|
| `ExecQuery` | `ExecQuery(ctx, stmt, params) ([]*T, error)` |
| `ExecQueryTx` | `ExecQueryTx(ctx, tx, stmt, params) ([]*T, error)` |
| `ExecQueryAtom` | `ExecQueryAtom(ctx, stmt, params) ([]*atom.Atom, error)` |

#### Select (returns `*T`)

| Method | Signature |
|--------|-----------|
| `ExecSelect` | `ExecSelect(ctx, stmt, params) (*T, error)` |
| `ExecSelectTx` | `ExecSelectTx(ctx, tx, stmt, params) (*T, error)` |
| `ExecSelectAtom` | `ExecSelectAtom(ctx, stmt, params) (*atom.Atom, error)` |

#### Update (returns `*T`)

| Method | Signature |
|--------|-----------|
| `ExecUpdate` | `ExecUpdate(ctx, stmt, params) (*T, error)` |
| `ExecUpdateTx` | `ExecUpdateTx(ctx, tx, stmt, params) (*T, error)` |
| `ExecUpdateBatch` | `ExecUpdateBatch(ctx, stmt, batchParams) (int64, error)` |
| `ExecUpdateBatchTx` | `ExecUpdateBatchTx(ctx, tx, stmt, batchParams) (int64, error)` |

#### Delete (returns `int64` affected rows)

| Method | Signature |
|--------|-----------|
| `ExecDelete` | `ExecDelete(ctx, stmt, params) (int64, error)` |
| `ExecDeleteTx` | `ExecDeleteTx(ctx, tx, stmt, params) (int64, error)` |
| `ExecDeleteBatch` | `ExecDeleteBatch(ctx, stmt, batchParams) (int64, error)` |
| `ExecDeleteBatchTx` | `ExecDeleteBatchTx(ctx, tx, stmt, batchParams) (int64, error)` |

#### Aggregate (returns `float64`)

| Method | Signature |
|--------|-----------|
| `ExecAggregate` | `ExecAggregate(ctx, stmt, params) (float64, error)` |
| `ExecAggregateTx` | `ExecAggregateTx(ctx, tx, stmt, params) (float64, error)` |

#### Insert

| Method | Signature |
|--------|-----------|
| `ExecInsert` | `ExecInsert(ctx, record) (*T, error)` |
| `ExecInsertTx` | `ExecInsertTx(ctx, tx, record) (*T, error)` |
| `ExecInsertBatch` | `ExecInsertBatch(ctx, records) (int64, error)` |
| `ExecInsertBatchTx` | `ExecInsertBatchTx(ctx, tx, records) (int64, error)` |
| `ExecInsertAtom` | `ExecInsertAtom(ctx, params) (*atom.Atom, error)` |

#### Compound (UNION/INTERSECT/EXCEPT, returns `[]*T`)

| Method | Signature |
|--------|-----------|
| `ExecCompound` | `ExecCompound(ctx, spec, params) ([]*T, error)` |
| `ExecCompoundTx` | `ExecCompoundTx(ctx, tx, spec, params) ([]*T, error)` |

### Render Methods (debugging)

`RenderQuery`, `RenderSelect`, `RenderUpdate`, `RenderDelete`, `RenderAggregate`, `RenderCompound` — all return `(string, error)` with the generated SQL.

### Builder Access

`Query`, `Select`, `Update`, `Delete`, `Aggregate`, `Insert`, `Compound` — return underlying soy builders for advanced/incremental building.

## Spec Types

### ConditionSpec

```go
type ConditionSpec struct {
    Field, Operator, Param string     // Simple condition
    IsNull                 bool       // IS NULL/IS NOT NULL
    Between, NotBetween    bool       // BETWEEN conditions
    LowParam, HighParam   string     // BETWEEN params
    RightField             string     // Field-to-field comparison
    Logic                  string     // "AND" or "OR" for groups
    Group                  []ConditionSpec // Nested conditions
}
```

Methods: `IsGroup()`, `IsBetween()`, `IsNotBetween()`, `IsFieldComparison()`

### OrderBySpec

```go
type OrderBySpec struct {
    Field, Direction string // Column + "asc"/"desc"
    Nulls            string // "first" or "last"
    Operator, Param  string // For expression ordering (e.g. vector distance)
}
```

Methods: `HasNulls()`, `IsExpression()`

### QuerySpec / SelectSpec

```go
type QuerySpec struct {
    Fields      []string
    SelectExprs []SelectExprSpec
    Where       []ConditionSpec
    OrderBy     []OrderBySpec
    GroupBy     []string
    Having      []ConditionSpec
    HavingAgg   []HavingAggSpec
    Limit       *int
    LimitParam  string
    Offset      *int
    OffsetParam string
    Distinct    bool
    DistinctOn  []string
    ForLocking  string
}
```

SelectSpec has the same structure (for single-record retrieval).

### UpdateSpec / DeleteSpec

```go
type UpdateSpec struct {
    Set   map[string]string   // field → param
    Where []ConditionSpec
}

type DeleteSpec struct {
    Where []ConditionSpec
}
```

### AggregateSpec

```go
type AggregateSpec struct {
    Field string
    Where []ConditionSpec
}
```

### Aggregate Functions

`AggCount`, `AggSum`, `AggAvg`, `AggMin`, `AggMax`

### SelectExprSpec

Supports: `upper`, `lower`, `length`, `trim`, `ltrim`, `rtrim`, `substring`, `replace`, `concat`, `abs`, `ceil`, `floor`, `round`, `sqrt`, `power`, `now`, `current_date`, `current_time`, `current_timestamp`, `cast`, `count_star`, `count`, `count_distinct`, `sum`, `avg`, `min`, `max`, `coalesce`, `nullif`

### CompoundQuerySpec

```go
type CompoundQuerySpec struct {
    Base     QuerySpec
    Operands []SetOperandSpec  // "union", "union_all", "intersect", etc.
    OrderBy  []OrderBySpec
    Limit    *int
    Offset   *int
}
```

### ParamSpec

```go
type ParamSpec struct {
    Name, Type, Description string
    Required                bool
    Default                 any
}
```

Auto-derived from statement specs — documents what parameters a statement needs.

## Capitan Signals

| Signal | Key | Purpose |
|--------|-----|---------|
| `ExecutorCreated` | — | Emitted on `New[T]()` |

Event keys: `KeyTable` (string), `KeyError` (string), `KeyDuration` (duration)

## Thread Safety

- `Executor[T]` is safe for concurrent use
- Statement objects are immutable
- Parameter maps should not be modified concurrently during execution

## File Layout

```
edamame/
├── executor.go    # Executor creation and initialization
├── dispatch.go    # All execution methods (Exec*, ExecTx, ExecBatch)
├── statement.go   # Statement types and parameter derivation
├── spec.go        # Spec data structures (QuerySpec, ConditionSpec, etc.)
├── convert.go     # Spec → soy builder conversion (~860 lines)
├── events.go      # Capitan signal definitions
└── testing/
    └── helpers.go # QueryCapture, ExecutorEventCapture, ParamBuilder
```

## Common Patterns

**Define statements as package variables:**

```go
var (
    QueryAll = edamame.NewQueryStatement("query-all", "List all users",
        edamame.QuerySpec{})

    SelectByID = edamame.NewSelectStatement("by-id", "Find user by ID",
        edamame.SelectSpec{
            Where: []edamame.ConditionSpec{
                {Field: "id", Operator: "=", Param: "id"},
            },
        })

    UpdateEmail = edamame.NewUpdateStatement("update-email", "Update user email",
        edamame.UpdateSpec{
            Set:   map[string]string{"email": "email"},
            Where: []edamame.ConditionSpec{{Field: "id", Operator: "=", Param: "id"}},
        })
)
```

**Execute with parameters:**

```go
exec, _ := edamame.New[User](db, "users", postgres.New())

users, _ := exec.ExecQuery(ctx, QueryAll, nil)
user, _ := exec.ExecSelect(ctx, SelectByID, map[string]any{"id": 123})
_, _ = exec.ExecUpdate(ctx, UpdateEmail, map[string]any{"id": 123, "email": "new@example.com"})
```

**Transaction support:**

```go
tx, _ := db.BeginTxx(ctx, nil)
user, _ := exec.ExecSelectTx(ctx, tx, SelectByID, params)
_, _ = exec.ExecUpdateTx(ctx, tx, UpdateEmail, params)
tx.Commit()
```

**Type-erased execution:**

```go
atoms, _ := exec.ExecQueryAtom(ctx, stmt, params)
// atoms[0].Strings["name"], atoms[0].Ints["age"]
```

## Testing Helpers

| Helper | Purpose |
|--------|---------|
| `NewQueryCapture()` | Thread-safe SQL capture for assertions |
| `NewExecutorEventCapture()` | Capture executor creation events |
| `NewParamBuilder()` | Fluent builder for parameter maps |

QueryCapture methods: `CaptureQuery`, `Queries`, `Count`, `Reset`, `Last`, `ByType`, `ByStatement`

## Ecosystem

Edamame depends on:
- **soy** — query building from specs
- **astql** — SQL rendering and dialect support
- **atom** — type-erased record representation
- **capitan** — event emission

Edamame is consumed by:
- Applications for database access
