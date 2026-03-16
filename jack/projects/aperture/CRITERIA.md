# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Schema validation catches invalid configs before Apply() creates observers
- Apply() transitions atomically — no events lost between old and new config
- Metric value extraction handles all numeric types correctly (int, float, Duration)
- Trace correlation matches start/end events by correlation key without data loss
- Context key registration enforced before Apply()
- Severity mapping from capitan to OTEL is correct and complete
- Diagnostic signals emit on internal errors without causing recursion

### What This Repo MUST NOT Contain

- OTEL provider creation or lifecycle management
- Custom OTEL exporters
- Application-level instrumentation beyond capitan event observation
- Sampling or filtering logic

## Review Priorities

1. Atomic Apply: configuration transitions must not lose events or corrupt state
2. Metric correctness: value extraction must handle all numeric types, overflow protection must work
3. Trace correlation: start/end pairing must match correctly, expired spans must clean up
4. Schema validation: invalid configs must be rejected before creating observers
5. Thread safety: concurrent Apply(), Close(), and event handling must not race
6. Context enrichment: high-cardinality values in metrics must be documented as dangerous

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Events lost during Apply() transition | Critical |
| Metric value extraction returns wrong number | Critical |
| Trace correlation matches wrong events | Critical |
| Diagnostic signal causes recursion | Critical |
| Schema validation accepts invalid config | High |
| Expired span cleanup misses entries | High |
| Context key registration after Apply() silently ignored | High |
| Severity mapping incorrect | Medium |
| Stdout mode formatting issue | Low |

## Standing Concerns

- Both int64 and float64 instruments created per metric — verify no excessive resource usage
- Cleanup goroutine runs every minute for expired spans — verify no goroutine leak on Close()
- High-cardinality context keys in metrics can explode storage — verify documentation warns
- Overlapping trace configs for same signal — verify ambiguity is caught or documented

## Out of Scope

- OTEL provider lifecycle is caller's responsibility — not a gap
- YAML/JSON dependency is intentional for config-driven design
- Proactive dual-instrument creation is by design for runtime type flexibility
