# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Statement objects are immutable after creation — no mutation path
- All values bound as named parameters — zero string interpolation
- Spec→soy builder conversion produces correct queries for all spec types
- Executor[T] is thread-safe for concurrent statement execution
- Transaction execution uses the provided tx, not the base connection
- Parameter derivation (ParamSpec) correctly reflects all parameters a statement needs
- Batch execution handles partial failures appropriately

### What This Repo MUST NOT Contain

- String interpolation of values into SQL
- Mutable statement objects
- Connection management or pooling
- ORM patterns
- Direct SQL string construction — all SQL flows through soy/astql

## Review Priorities

1. SQL injection safety: any value interpolation path is critical
2. Statement immutability: mutation after creation would break concurrent use
3. Spec conversion correctness: every spec type must produce the correct soy builder chain
4. Transaction isolation: ExecTx must not fall back to base connection
5. Parameter derivation: ParamSpec must be complete and accurate
6. Type safety: execution return types must match statement types (Query→[]*T, Select→*T, etc.)
7. Batch correctness: partial failures, row counts, and transaction behavior

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Value interpolated into SQL | Critical |
| Statement mutation after creation | Critical |
| ExecTx uses base connection | Critical |
| Spec conversion produces wrong SQL | High |
| ParamSpec missing a required parameter | High |
| Batch execution loses records silently | High |
| Type mismatch between execution method and return type | High |
| Compound query parameter namespace collision | Medium |
| Render method produces different SQL than execution | Medium |
| Missing test for a spec type | Medium |
| Event not emitted for executor creation | Low |

## Standing Concerns

- convert.go is ~860 lines — verify all spec types have test coverage
- ConditionSpec supports nested groups — verify arbitrary nesting depth works
- CompoundQuerySpec merges parameter namespaces — verify no collisions
- UpdateSpec/DeleteSpec inherit soy's WHERE safety guards — verify they propagate
- Builder access methods expose mutable soy builders — verify they don't affect executor state

## Out of Scope

- Statements as package-level variables is the intended pattern — not a limitation
- Specs are data structures, not query DSLs — simplicity over expressiveness
- No dynamic query construction — use soy directly for ad-hoc queries
- sqlx dependency is intentional — edamame wraps it
