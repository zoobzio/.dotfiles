# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Builder[T] validates field names against struct metadata via sentinel
- All query types produce correct Query DSL JSON for their target engine
- Deferred errors propagate correctly through compound queries and aggregations
- Dialect renderers produce valid JSON for their specific engine version
- kNN queries render correctly for both Elasticsearch and OpenSearch formats

### What This Repo MUST NOT Contain

- HTTP client or transport logic
- Index management or mapping operations
- Result parsing or deserialization

## Review Priorities

1. Query correctness: rendered JSON must be valid Query DSL for the target engine
2. Schema validation: invalid field names must produce ErrUnknownField
3. Deferred error propagation: Err() must walk entire tree including nested compounds
4. Dialect differences: kNN format, RETURNING support, etc. must be correct per engine
5. Aggregation nesting: SubAggs must compose correctly at any depth

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Rendered JSON rejected by target engine | Critical |
| Invalid field name not caught | High |
| Deferred error lost in compound query | High |
| kNN format wrong for engine version | High |
| Aggregation nesting produces invalid JSON | Medium |
| Highlight configuration not applied | Medium |
| Missing test for a query type | Medium |

## Standing Concerns

- OpenSearch kNN uses field-nested format vs Elasticsearch top-level — verify both renderers
- Deferred error model means errors can be silently ignored — verify Err() is comprehensive
- Builder[T] is read-only after creation but returned builders are mutable — verify no shared state

## Out of Scope

- No HTTP client is intentional — lucene builds JSON, transport is separate
- Deferred error model is by design — enables fluent nested construction
- sentinel dependency for field validation is intentional
