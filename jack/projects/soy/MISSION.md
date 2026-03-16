# Mission: soy

Type-safe, schema-validated SQL query builder for Go.

## Purpose

Provide a fluent query builder that wraps ASTQL with struct-driven schema validation, named parameter safety, and type-erased row scanning. Reflection happens once during construction — the query hot path is zero-reflection. Soy exists because application code needs to build SQL queries that are validated against the actual schema, safe from injection, and type-aware without writing raw SQL strings.

## What This Package Contains

- `Soy[T]` entry point — one instance per table/type pair with fluent builder factories
- Builders for SELECT, INSERT, UPDATE, DELETE, COUNT, SUM, AVG, MIN, MAX
- Struct tag-driven schema generation: `db`, `type`, `constraints`, `default`, `check`, `index`, `references`
- Named parameter binding through ASTQL — zero string interpolation
- Safety guards: UPDATE and DELETE require WHERE clauses (ErrUnsafeUpdate/ErrUnsafeDelete)
- WHERE clause helpers: conditions, AND/OR groups, NULL checks, BETWEEN, field comparisons
- Full SQL feature support: JOINs, window functions, aggregates with FILTER, CASE, set operations, row locking
- INSERT features: bulk inserts, RETURNING, ON CONFLICT (upsert)
- Transaction-aware execution (Exec/ExecTx variants)
- Type-erased execution via atom (ExecAtom variants)
- Batch execution for multiple parameter sets
- Capitan signals for query observability (QueryStarted, QueryCompleted, QueryFailed)
- OnScan/OnRecord callbacks for row-level processing

## What This Package Does NOT Contain

- Connection management or pooling — consumers provide `sqlx.ExtContext`
- Migration generation — soy builds queries, not DDL
- ORM features — no lazy loading, change tracking, or identity maps
- Raw SQL execution — all queries go through the builder

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Struct field metadata extraction |
| `astql` | SQL AST and multi-dialect rendering |
| `atom` | Type-erased row scanning |
| `capitan` | Query observability signals |
| `dbml` | Schema definition from struct tags |

Soy is consumed by applications as their primary database query interface.

## Design Constraints

- Reflection once at construction — query hot path is reflection-free
- Named parameters only — no string interpolation of values
- UPDATE and DELETE require WHERE — full-table operations need raw ASTQL escape hatch
- Builders are not thread-safe — create new builders per operation
- Soy[T] instance is thread-safe after construction

## Success Criteria

A developer can:
1. Define a struct with tags and get a validated query builder for its table
2. Build type-safe SELECT, INSERT, UPDATE, DELETE queries with fluent chains
3. Execute queries with named parameters and get typed results
4. Use transactions with ExecTx variants
5. Get compile-time schema validation from struct tag metadata
6. Switch database dialects by changing the renderer, not the query code
7. Observe all queries via capitan signals

## Non-Goals

- Connection pooling or management
- Migration or DDL generation
- ORM-style object tracking or lazy loading
- Supporting raw SQL bypass (use ASTQL directly for that)
- Thread-safe builder sharing — builders are per-operation
