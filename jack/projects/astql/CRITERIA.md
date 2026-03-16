# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- All query parameters use named binding (`:param_name`) — zero string interpolation
- AST correctly represents all supported SQL constructs
- Each dialect renderer produces valid SQL for its target database
- Renderers reject unsupported features with descriptive errors, never silently degrade
- DBML schema validation catches invalid table/field/param references at build time
- Validation limits (subquery depth, join count, etc.) enforced during Build()
- PostgreSQL renderer supports: DISTINCT ON, ON CONFLICT, RETURNING, row locking, pgvector operators, FILTER clause, window functions

### What This Repo MUST NOT Contain

- String interpolation of values into SQL — named parameters only
- Silent feature degradation across dialects — unsupported features must error
- Query execution logic — ASTQL builds, it does not run
- Connection or driver management
- ORM patterns (object mapping, change tracking, lazy loading)

## Review Priorities

1. SQL injection safety: any path where user input enters SQL without named parameter binding is critical
2. Dialect correctness: rendered SQL must be valid for the target database — syntax errors are critical
3. Capability enforcement: using PostgreSQL features on SQLite must produce clear errors, not broken SQL
4. AST integrity: builder methods must produce correct AST nodes — wrong operator, missing field, or bad nesting breaks downstream
5. Schema validation: DBML-validated mode must catch all invalid references
6. Expression correctness: aggregates, CASE, window functions must render with correct syntax per dialect
7. Validation limits: exceeding limits must fail at build time, not at render time

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Value interpolated into SQL string | Critical |
| Rendered SQL has syntax error for target dialect | Critical |
| Unsupported feature silently produces wrong SQL | Critical |
| Named parameter missing from RequiredParams | High |
| DBML validation misses invalid field reference | High |
| Condition group produces wrong AND/OR precedence | High |
| Window function renders with wrong PARTITION BY / ORDER BY | High |
| Validation limit not enforced | Medium |
| pgvector operator renders incorrectly | Medium |
| Missing test for a dialect-specific feature | Medium |
| Try* variant panics instead of returning error | Medium |
| Error message missing dialect or feature context | Low |

## Standing Concerns

- Named parameter names must be unique within a query — verify no collision across subqueries
- ON CONFLICT (PostgreSQL) has complex syntax — verify all upsert patterns render correctly
- pgvector distance operators are unusual — verify they render with correct precedence
- Set operations (UNION, INTERSECT) compose builders — verify parameter namespaces don't collide
- DBML schema validation uses panicking methods by default — verify Try* variants cover the same paths

## Out of Scope

- No query execution is intentional — ASTQL is a builder, not a runner
- No raw SQL passthrough — all queries must go through the builder for safety
- Panicking methods in schema-validated mode are intentional — development-time safety check, not production error handling
- Validation limits are fixed constants — not configurable, by design
