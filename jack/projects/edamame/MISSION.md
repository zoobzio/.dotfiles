# Mission: edamame

Statement-driven query execution — typed queries without magic strings.

## Purpose

Provide an execution layer where queries are defined as immutable, named statement objects containing serializable specs. Statements are converted to parameterized SQL via soy/astql, then executed against the database. Edamame exists because application code needs a clear separation between query definition and query execution, with statements that can be documented, tested, and introspected independently.

## What This Package Contains

- `Executor[T]` that bridges typed statement objects to database execution
- Immutable statement types: QueryStatement, SelectStatement, UpdateStatement, DeleteStatement, AggregateStatement
- Serializable spec types describing query semantics (conditions, ordering, grouping, pagination, etc.)
- Automatic parameter derivation from specs (ParamSpec documents what each statement needs)
- Transaction-aware execution (Exec/ExecTx variants)
- Type-erased execution via atom (ExecAtom variants)
- Batch execution for bulk operations
- Compound query support (UNION/INTERSECT/EXCEPT)
- Render methods for SQL debugging without execution
- Builder access for advanced incremental query construction
- Test helpers: QueryCapture, ExecutorEventCapture, ParamBuilder

## What This Package Does NOT Contain

- Query building logic — delegates to soy/astql
- Connection management — consumers provide sqlx.DB
- ORM features — no object tracking, lazy loading, or identity maps
- Schema management or migrations
- Dynamic query construction at runtime — statements are defined upfront

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `soy` | Query building from specs |
| `astql` | SQL rendering and dialect support |
| `atom` | Type-erased record representation |
| `capitan` | Event emission for executor lifecycle |

Edamame is consumed by applications as their statement-driven database access layer.

## Design Constraints

- Statements are immutable after creation — defined as package-level variables
- All values bound as named parameters — never interpolated
- Executor[T] is thread-safe after construction
- Specs are serializable data structures — no functions, no closures

## Success Criteria

A developer can:
1. Define query statements as typed, immutable package-level variables
2. Execute statements with named parameter maps and get typed results
3. Introspect statement parameters via auto-derived ParamSpec
4. Use transactions with ExecTx variants
5. Debug generated SQL with Render methods
6. Execute batch operations for bulk inserts, updates, and deletes
7. Test query behavior with QueryCapture and ParamBuilder helpers

## Non-Goals

- Runtime query construction — statements are defined upfront
- Connection pooling or management
- Schema generation or migration
- Replacing soy for ad-hoc query building — edamame is for structured, reusable queries
