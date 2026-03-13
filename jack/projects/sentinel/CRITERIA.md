# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- `Inspect[T]()` and `Scan[T]()` must return complete, correct metadata for any struct type
- Cache must be thread-safe — concurrent calls to extraction and query functions must not race
- Relationship discovery must find all struct-to-struct references within module boundaries
- Custom struct tag registration must work before and only before first extraction
- Cache query API (`Browse`, `Lookup`, `Schema`) must return consistent, normalized results
- Package must build and test cleanly with zero external dependencies

### What This Repo MUST NOT Contain

- Any external dependency — stdlib only, no exceptions
- Support for non-struct types — intentionally out of scope
- Cross-module scanning — limited to module boundaries by design
- Cache invalidation or expiration — types are immutable at runtime
- Runtime type mutation or dynamic field injection

## Review Priorities

Ordered by importance. When findings conflict, higher-priority items take precedence.

1. Correctness: metadata extraction must be accurate — wrong field types, missing tags, or broken relationships are critical
2. Thread safety: the global cache is accessed concurrently — races are critical
3. API surface: exported API must be minimal and stable — every exported symbol is a commitment to downstream consumers
4. Zero dependencies: any import outside stdlib is a blocking defect
5. Consumer experience: API must be discoverable from godoc alone — sentinel is a foundation package used by erd, soy, and rocco
6. Performance: extraction is cached but first-call cost matters — reflection should be efficient

## Severity Calibration

Guidance for how Armitage classifies finding severity for this specific repo.

| Condition | Severity |
|-----------|----------|
| Data race in cache access | Critical |
| Incorrect metadata for a field type or struct tag | Critical |
| External dependency added | Critical |
| Relationship discovery misses a valid reference | High |
| Exported symbol without godoc | High |
| Exported symbol that should be unexported | High |
| Custom tag registration after extraction silently succeeds | High |
| Cache query returns inconsistent results across calls | High |
| Missing test for an exported function | Medium |
| Benchmark missing or dishonest | Medium |
| Error message without actionable context | Medium |
| Minor godoc wording issue | Low |
| Internal naming inconsistency | Low |

## Standing Concerns

Persistent issues or areas of known weakness that should always be checked.

- Global singleton pattern means initialization order matters — verify tag registration before extraction is enforced
- Reflection-heavy code is easy to get subtly wrong — verify extracted metadata against actual struct definitions
- Downstream consumers (erd, soy, rocco) depend on the exact shape of metadata types — changes to exported types are breaking
- Cache is permanent — verify no memory leak patterns from scanning large type graphs
- Build tag `testing` gates cache reset — verify it is not accessible in production builds

## Out of Scope

Things the red team should NOT flag for this repo, even if they look wrong.

- Global singleton is intentional — one type system, one cache, by design
- No support for non-struct types — this is a design constraint, not a gap
- No cache invalidation — types are immutable at runtime, expiration is meaningless
- Reflect usage is unavoidable — sentinel's purpose is to normalize reflection output
