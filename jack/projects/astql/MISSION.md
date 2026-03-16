# Mission: astql

Type-safe SQL AST with multi-dialect rendering and DBML schema validation.

## Purpose

Provide a fluent builder that constructs SQL queries as an internal AST, then renders them to dialect-specific SQL with named parameters. Optional DBML schema integration validates tables, fields, and parameters at build time. ASTQL exists because writing raw SQL strings is error-prone, dialect-switching is painful, and string interpolation invites injection vulnerabilities.

## What This Package Contains

- Fluent builder API for SELECT, INSERT, UPDATE, DELETE, and COUNT queries
- Internal AST representation decoupled from any specific SQL dialect
- Named parameter binding (`:param_name`) — never string interpolation
- Dialect renderers: PostgreSQL, MariaDB, SQLite, SQL Server
- Capability-aware rendering that rejects unsupported features with clear errors
- DBML schema integration for validated table, field, and parameter access
- Full expression system: aggregates, CASE, window functions, math, string, date/time, type casting
- Condition types: simple, grouped (AND/OR), aggregate, between, field comparison, subquery
- Set operations: UNION, INTERSECT, EXCEPT with ALL variants
- PostgreSQL-specific: DISTINCT ON, ON CONFLICT, RETURNING, row locking, ILIKE, regex, arrays, pgvector operators
- Validation limits for subquery depth, join count, condition depth, field count

## What This Package Does NOT Contain

- Query execution — ASTQL builds SQL strings, it does not run them
- Connection management or driver integration
- Migration generation or schema management
- ORM features — no object mapping, no lazy loading, no change tracking
- Raw SQL passthrough — all queries must go through the builder

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `dbml` | Schema definitions for build-time field validation |

| Consumer | Role |
|----------|------|
| `soy` | Type-safe query builder built on ASTQL |
| `edamame` | Statement-driven query execution using ASTQL ASTs |

## Design Constraints

- All parameters are named — never interpolated into SQL
- Renderers validate capabilities — unsupported dialect features are rejected, not silently dropped
- Validation limits enforced at build time (max 3 subquery depth, 10 joins, 5 condition depth, 100 fields)
- Schema-validated mode panics on invalid references; Try* variants return errors

## Success Criteria

A developer can:
1. Build any standard SQL query using a fluent, type-safe API
2. Render the same AST to different SQL dialects without changing builder code
3. Get build-time validation of table and field references against a DBML schema
4. Use PostgreSQL-specific features (DISTINCT ON, pgvector, ON CONFLICT) and get clear errors on other dialects
5. Compose complex queries with subqueries, window functions, CTEs, and set operations
6. Trust that no user input is ever interpolated into the SQL string

## Non-Goals

- Query execution or result scanning
- Database connection management
- Schema migration or DDL generation
- ORM-style object mapping
- Supporting every SQL dialect feature — capabilities are explicit per renderer
