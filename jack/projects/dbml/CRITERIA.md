# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Fluent builders produce correct, complete DBML schema objects
- `Generate()` produces valid DBML text that visualization tools accept
- `Validate()` catches all invalid schemas: missing names, empty tables, invalid refs
- JSON and YAML serialization round-trips without data loss
- All relationship types and referential actions generate correctly
- Column settings (PK, nullable, unique, increment, default, check) render in correct DBML syntax
- Index generation supports both column-based and expression-based indexes

### What This Repo MUST NOT Contain

- DBML parsing — generation only
- SQL DDL output
- Database connections or drivers
- Migration logic or schema diffing

## Review Priorities

1. Generation correctness: output must be valid DBML accepted by dbdiagram.io and astql
2. Validation completeness: every invalid state must be caught by Validate()
3. Serialization fidelity: JSON/YAML round-trip must preserve all schema information
4. Builder safety: no nil pointer panics from incomplete builder chains
5. Downstream compatibility: generated schemas must work correctly with astql validation

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Generate() produces invalid DBML syntax | Critical |
| Validation misses an invalid schema state | High |
| JSON/YAML round-trip loses data | High |
| Builder method panics on nil or empty input | High |
| Relationship type renders with wrong cardinality symbol | High |
| Default schema "public" not omitted from output | Medium |
| ValidationError missing context about which element failed | Medium |
| Missing test for a builder method | Medium |
| Note or setting not properly escaped in output | Low |

## Standing Concerns

- DBML syntax has no formal spec — verify output against dbdiagram.io behavior
- Column inline refs vs top-level refs are two paths to the same output — verify both generate correctly
- Composite indexes and composite foreign keys need multiple columns — verify ordering is preserved
- Default schema omission logic must not affect non-"public" schemas

## Out of Scope

- No DBML parsing is intentional — generation only
- yaml.v3 dependency is intentional for YAML serialization
- No SQL DDL output — DBML is for visualization and astql, not database execution
