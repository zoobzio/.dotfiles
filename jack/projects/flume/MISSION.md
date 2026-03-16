# Mission: flume

Dynamic pipeline factory for pipz — schema-driven construction and hot-reloading.

## Purpose

Provide a registry-and-factory that constructs pipz pipelines from YAML/JSON schemas. Components are registered in code; schemas define pipeline topology as configuration. Bindings enable hot-reloading — schema updates atomically swap running pipelines without downtime.

Flume exists because applications need to change pipeline behavior through configuration rather than code changes, and to support runtime pipeline reconfiguration without restarts.

## What This Package Contains

- `Factory[T]` central registry for processors, predicates, conditions, reducers, error handlers, and channels
- Schema-driven pipeline construction from YAML, JSON, files, or Go structs
- 14 connector types: sequence, concurrent, race, fallback, filter, switch, contest, retry, timeout, circuit-breaker, rate-limit, stream, handle, scaffold, worker-pool
- `Binding[T]` for lock-free hot-reload of running pipelines via atomic pointer swap
- Schema validation with path-aware error collection and cycle detection
- Identity management for consistent component naming
- Introspection API (Spec/SpecJSON) for capability discovery
- Auto-sync bindings that rebuild automatically on schema updates
- Capitan signals for factory lifecycle, registration, schema operations

## What This Package Does NOT Contain

- Pipeline processing logic — delegates to pipz primitives
- Schema storage or persistence — consumers manage schema lifecycle
- Schema versioning or migration between schema formats
- Network transport for distributed pipeline execution

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `pipz` | Pipeline composition primitives |
| `capitan` | Observability events |

Flume is consumed by applications for dynamic pipeline orchestration.

## Design Constraints

- Data types must implement `pipz.Cloner[T]` — required by parallel connectors
- Binding execution is lock-free via `atomic.Pointer` — zero contention on the hot path
- Schema updates atomically swap the pipeline — in-flight requests complete on the old pipeline
- Cycle detection prevents infinite ref loops in schemas
- Factory operations protected by sync.RWMutex

## Success Criteria

A developer can:
1. Register processors and auxiliary components in code
2. Define pipeline topology as YAML/JSON configuration
3. Build pipz pipelines from schemas with full validation
4. Hot-reload running pipelines by updating schemas
5. Introspect factory capabilities for documentation or LLM-driven pipeline generation
6. Validate schemas before building with path-aware error reporting

## Non-Goals

- Replacing pipz — flume is a factory layer, not a pipeline runtime
- Schema persistence or version control
- Distributed pipeline execution
- GUI-based pipeline design
