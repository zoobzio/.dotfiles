# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Schema-driven pipeline construction produces correct pipz pipeline topology
- All 14 connector types build correctly from schema nodes
- Binding hot-reload is lock-free and atomically swaps the pipeline pointer
- In-flight requests on old pipeline complete without interruption during swap
- Schema validation catches all structural errors with path-aware messages
- Cycle detection prevents infinite ref loops
- Component registration is thread-safe
- Auto-sync bindings rebuild automatically on schema updates

### What This Repo MUST NOT Contain

- Pipeline processing logic — factory only, delegates to pipz
- Schema persistence or storage management
- Lock contention on the binding execution hot path
- Schema construction without validation

## Review Priorities

1. Hot-reload atomicity: pipeline swap must be atomic — no partial state visible to callers
2. Validation completeness: every invalid schema must be caught before building
3. Cycle detection: ref loops must be detected — infinite recursion during build is critical
4. Thread safety: factory registration concurrent with build/bind must not race
5. Connector construction: all 14 types must correctly translate schema nodes to pipz primitives
6. Default values: missing optional fields must use documented defaults
7. Schema parsing: YAML/JSON must round-trip correctly through Schema structs

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Binding hot-reload exposes partial pipeline state | Critical |
| Cycle in schema refs causes infinite loop during build | Critical |
| Race condition in factory registration | Critical |
| Connector type builds wrong pipz primitive | High |
| Schema validation misses structural error | High |
| Auto-sync binding fails to rebuild on schema update | High |
| Default value wrong for connector configuration | Medium |
| Validation error missing path context | Medium |
| YAML/JSON schema parse loses fields | Medium |
| Capitan signal missing for schema operation | Low |
| FactorySpec listing not sorted | Low |

## Standing Concerns

- Atomic pointer swap for bindings means old pipeline is garbage collected — verify Close() is called on the old pipeline
- Schema validation has two modes (full vs structure-only) — verify both cover their intended scope
- 14 connector builders is a large surface — verify each has dedicated test coverage
- Identity management panics on description mismatch — verify error messaging is clear
- YAML parsing via yaml.v3 may have edge cases with complex node types — verify round-trip fidelity

## Out of Scope

- No schema persistence is intentional — flume is a factory, not a database
- yaml.v3 dependency is intentional for schema parsing
- Cloner[T] requirement is inherited from pipz — not a flume limitation
- Factory is not a pipeline runtime — it builds pipz pipelines, doesn't execute them
