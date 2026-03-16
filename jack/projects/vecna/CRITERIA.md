# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Builder[T] validates field names against struct metadata
- Operator/type compatibility enforced (numeric ops on numeric fields only, Like on strings, Contains on slices)
- Filter AST is immutable after creation
- Deferred errors propagate through nested And/Or/Not compositions
- FilterSpec→Filter conversion validates against schema
- Field names resolved from json tags correctly

### What This Repo MUST NOT Contain

- Vector database client or transport
- Embedding generation
- Provider-specific rendering (grub handles that)

## Review Priorities

1. Type/operator validation: wrong operator on wrong field type must error
2. Deferred error propagation: Err() must walk entire filter tree
3. Filter immutability: no mutation path after creation
4. FilterSpec conversion: JSON spec must be validated against schema
5. Field resolution: json tag, fallback to Go name, json:"-" excluded

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Numeric operator accepted on string field | Critical |
| Invalid field name not caught | High |
| Filter mutation after creation | High |
| Deferred error lost in nested composition | High |
| FilterSpec conversion skips validation | Medium |
| Field resolution wrong for json tag edge cases | Medium |

## Standing Concerns

- Deferred error model means errors can be ignored — verify Err() walks all descendants
- In/Nin require slice values — verify type checking
- FilterSpec from external sources (LLM) may have arbitrary content — verify robust validation

## Out of Scope

- No provider-specific rendering is intentional — grub translates the AST
- Deferred error model is by design for fluent construction
- Filter immutability is intentional — safe to share across goroutines
