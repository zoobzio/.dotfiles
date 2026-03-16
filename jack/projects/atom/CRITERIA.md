# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- `Use[T]()` registers types exactly once with cached singleton
- `Atomize` decomposes all supported field types into correct typed maps
- `Deatomize` reconstructs the original struct with no data loss for supported types
- Width normalization widens correctly (int8→int64, float32→float64) during atomize
- Overflow detection catches invalid narrowing during deatomize
- Nested struct composition (embedded, recursive, circular) handled correctly
- `Atomizable`/`Deatomizable` interfaces bypass reflection when implemented

### What This Repo MUST NOT Contain

- Reflection on the hot path — registration-time only
- Support for channels, functions, or interface fields
- Non-string-keyed map support
- Wire format serialization

## Review Priorities

1. Data fidelity: atomize→deatomize round-trip must be lossless for all supported types
2. Width normalization: widening must not lose data, narrowing must detect overflow
3. Registration safety: concurrent `Use[T]()` calls for the same type must not race or double-register
4. Nested handling: embedded structs, pointer-to-struct, recursive types, circular references must all work
5. Performance: hot-path (atomize/deatomize) must be reflection-free after registration
6. Table mapping: field-to-table lookups must be correct and consistent

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Data loss in atomize→deatomize round-trip | Critical |
| Reflection on hot path (atomize/deatomize) | Critical |
| Race condition in type registration | Critical |
| Overflow not detected during deatomize | High |
| Nested struct fields placed in wrong table | High |
| Circular reference causes infinite loop | High |
| Unsupported type silently dropped instead of erroring | High |
| Field placed in wrong typed map | Medium |
| Missing test for a type category (scalar/pointer/slice/map) | Medium |
| NewAtom allocates unnecessary tables | Low |

## Standing Concerns

- 29 typed maps means 29 code paths for atomize and deatomize — verify each is tested
- Width normalization creates asymmetry between atomize and deatomize — verify round-trip for every width
- Circular reference detection must not prevent valid recursive types
- Sentinel integration means sentinel bugs could affect atom — verify metadata extraction is correct for edge cases

## Out of Scope

- No channel/function/interface support is intentional — these are not data
- Non-string map keys excluded by design — atom maps are always string-keyed
- Atoms are not thread-safe for mutation — single-owner by design
- Width normalization is not optional — always applies
