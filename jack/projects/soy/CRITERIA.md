# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Named parameter binding for all queries — zero string interpolation
- Struct tag parsing produces correct DBML schema for ASTQL validation
- Safety guards enforce WHERE on UPDATE and DELETE (ErrUnsafeUpdate/ErrUnsafeDelete)
- All builders (Select, Query, Create, Update, Delete, Aggregate, Compound) produce valid SQL via ASTQL
- Row scanning correctly maps database columns to struct fields
- Transaction execution (ExecTx) correctly participates in the provided transaction
- Capitan signals fire for every query: started, completed, failed
- Soy[T] instance is safe for concurrent use after construction

### What This Repo MUST NOT Contain

- String interpolation of values into SQL
- Reflection on the query hot path — registration-time only
- UPDATE or DELETE without WHERE guard
- Connection management or pooling logic
- ORM patterns (lazy loading, change tracking, identity maps)

## Review Priorities

1. SQL injection safety: any path where values enter SQL without named parameters is critical
2. Safety guards: UPDATE/DELETE without WHERE must always error
3. Schema validation: struct tags must correctly produce DBML that ASTQL validates against
4. Row scanning: type mismatches between database columns and struct fields must error, not corrupt
5. Transaction correctness: ExecTx must use the provided transaction, not the base connection
6. Builder isolation: concurrent builder use on the same Soy[T] must not interfere
7. Dialect portability: same builder chain must produce valid SQL for all supported renderers

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Value interpolated into SQL | Critical |
| UPDATE/DELETE without WHERE succeeds | Critical |
| Row scan produces wrong typed result | Critical |
| ExecTx uses base connection instead of transaction | Critical |
| Struct tag parsed incorrectly, wrong schema generated | High |
| Named parameter missing from rendered SQL | High |
| Builder state leaks between operations | High |
| Capitan signal not emitted for query | Medium |
| OnScan/OnRecord callback error not propagated | Medium |
| Batch execution partial failure handling incorrect | Medium |
| Aggregate FILTER clause renders incorrectly | Medium |
| Missing test for a builder type | Medium |
| Error message missing table/operation context | Low |

## Standing Concerns

- Struct tags drive everything — verify tag parsing handles edge cases (missing tags, conflicting constraints, unusual types)
- Atom integration for type-erased scanning adds a layer — verify no data loss in atomize→scan path
- Safety guards can be circumvented via raw ASTQL Instance() escape hatch — this is intentional but worth noting
- Bulk INSERT with RETURNING must correctly map returned rows to input order
- ON CONFLICT (upsert) must correctly handle composite keys and partial updates

## Out of Scope

- Builders are not thread-safe by design — create per operation
- No raw SQL support is intentional — use ASTQL Instance() for escape hatch
- sqlx dependency is intentional — soy wraps it, does not replace it
- Safety guards on UPDATE/DELETE are non-negotiable — full-table operations require ASTQL
