# Flume

Deep understanding of `github.com/zoobzio/flume` — dynamic pipeline factory for pipz with schema-driven construction and hot-reloading.

## Core Concepts

Flume is a registry-and-factory that constructs pipz pipelines from YAML/JSON schemas. Components (processors, predicates, conditions, reducers, error handlers) are registered once in code; schemas define pipeline topology as configuration. Bindings enable hot-reloading — schema updates atomically swap running pipelines without downtime.

- **Factory[T]** is the central registry and builder
- **Schema** defines pipeline structure (YAML/JSON/Go)
- **Node** represents one pipeline element (processor ref or connector definition)
- **Binding[T]** provides lock-free hot-reload of running pipelines
- All data types must implement `pipz.Cloner[T]`

**Dependencies:** `pipz` (pipeline composition), `capitan` (observability), `yaml.v3` (schema parsing)

## Public API

### Factory Creation

```go
func New[T pipz.Cloner[T]]() *Factory[T]
```

### Identity Management

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Identity` | `Identity(name, description string) pipz.Identity` | Create/retrieve managed identity (panics on description mismatch) |

### Component Registration

All registration methods are fluent-compatible and thread-safe.

#### Processors

| Method | Signature |
|--------|-----------|
| `Add` | `Add(processors ...pipz.Chainable[T])` |
| `AddWithMeta` | `AddWithMeta(processors ...ProcessorMeta[T])` |
| `Remove` | `Remove(names ...string) int` |
| `HasProcessor` | `HasProcessor(name string) bool` |
| `ListProcessors` | `ListProcessors() []string` |

#### Predicates (boolean conditions for filter/contest)

| Method | Signature |
|--------|-----------|
| `AddPredicate` | `AddPredicate(predicates ...Predicate[T])` |
| `RemovePredicate` | `RemovePredicate(names ...string) int` |
| `HasPredicate` | `HasPredicate(name string) bool` |
| `ListPredicates` | `ListPredicates() []string` |

#### Conditions (string-returning for switch)

| Method | Signature |
|--------|-----------|
| `AddCondition` | `AddCondition(conditions ...Condition[T])` |
| `RemoveCondition` | `RemoveCondition(names ...string) int` |
| `HasCondition` | `HasCondition(name string) bool` |
| `ListConditions` | `ListConditions() []string` |

#### Reducers (merge concurrent results)

| Method | Signature |
|--------|-----------|
| `AddReducer` | `AddReducer(reducers ...Reducer[T])` |
| `RemoveReducer` | `RemoveReducer(names ...string) int` |
| `HasReducer` | `HasReducer(name string) bool` |
| `ListReducers` | `ListReducers() []string` |

#### Error Handlers

| Method | Signature |
|--------|-----------|
| `AddErrorHandler` | `AddErrorHandler(handlers ...ErrorHandler[T])` |
| `RemoveErrorHandler` | `RemoveErrorHandler(names ...string) int` |
| `HasErrorHandler` | `HasErrorHandler(name string) bool` |
| `ListErrorHandlers` | `ListErrorHandlers() []string` |

#### Channels (output streams)

| Method | Signature |
|--------|-----------|
| `AddChannel` | `AddChannel(name string, channel chan<- T)` |
| `GetChannel` | `GetChannel(name string) (chan<- T, bool)` |
| `RemoveChannel` | `RemoveChannel(name string) bool` |
| `HasChannel` | `HasChannel(name string) bool` |
| `ListChannels` | `ListChannels() []string` |

### Schema Management

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `SetSchema` | `SetSchema(id string, schema Schema) error` | Register/update (triggers auto-sync rebuilds) |
| `GetSchema` | `GetSchema(id string) (Schema, bool)` | Retrieve |
| `RemoveSchema` | `RemoveSchema(id string) bool` | Remove |
| `HasSchema` | `HasSchema(id string) bool` | Check existence |
| `ListSchemas` | `ListSchemas() []string` | List all IDs |

### Pipeline Building

| Method | Signature |
|--------|-----------|
| `Build` | `Build(schema Schema) (pipz.Chainable[T], error)` |
| `BuildFromYAML` | `BuildFromYAML(yamlStr string) (pipz.Chainable[T], error)` |
| `BuildFromJSON` | `BuildFromJSON(jsonStr string) (pipz.Chainable[T], error)` |
| `BuildFromFile` | `BuildFromFile(path string) (pipz.Chainable[T], error)` |

### Schema Validation

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `ValidateSchema` | `ValidateSchema(schema Schema) error` | Full validation with reference checking |
| `ValidateSchemaStructure` | `ValidateSchemaStructure(schema Schema) error` | Static validation (no references needed) |

### Binding (Hot-Reload)

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Bind` | `Bind(identity, schemaID, opts...) (*Binding[T], error)` | Create hot-reload binding |
| `Get` | `Get(identity) *Binding[T]` | Retrieve existing binding |
| `ListBindings` | `ListBindings() []string` | List all binding names |

**Binding[T] methods:**

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Process` | `Process(ctx, data T) (T, error)` | Execute pipeline (lock-free) |
| `Identity` | `Identity() pipz.Identity` | Get binding identity |
| `SchemaID` | `SchemaID() string` | Get bound schema ID |
| `AutoSync` | `AutoSync() bool` | Check auto-sync state |
| `Pipeline` | `Pipeline() *pipz.Pipeline[T]` | Get underlying pipeline |

**Binding option:** `WithAutoSync[T]()` — automatically rebuild on schema updates.

### Introspection

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Spec` | `Spec() FactorySpec` | Complete capabilities snapshot (sorted) |
| `SpecJSON` | `SpecJSON() (string, error)` | Specification as JSON |

## Types

### Component Types

```go
type Predicate[T any] struct {
    Predicate func(context.Context, T) bool
    Identity  pipz.Identity
}

type Condition[T any] struct {
    Condition func(context.Context, T) string
    Identity  pipz.Identity
    Values    []string  // Documented possible return values
}

type Reducer[T any] struct {
    Reducer  func(original T, results map[pipz.Identity]T, errors map[pipz.Identity]error) T
    Identity pipz.Identity
}

type ErrorHandler[T any] struct {
    Handler  pipz.Chainable[*pipz.Error[T]]
    Identity pipz.Identity
}

type ProcessorMeta[T any] struct {
    Processor pipz.Chainable[T]
    Tags      []string
}
```

### Schema and Node

```go
type Schema struct {
    Version string
    Node    Node
}
```

**Node fields:** `Ref`, `Type`, `Children`, `Child`, `Predicate`, `Condition`, `ErrorHandler`, `Reducer`, `Stream`, `Attempts`, `Duration`, `Backoff`, `StreamTimeout`, `RecoveryTimeout`, `RequestsPerSecond`, `BurstSize`, `FailureThreshold`, `Workers`, `Routes`, `Then`, `Else`, `Default`, `Name`

### 14 Connector Types

| Category | Types |
|----------|-------|
| Composition | `sequence`, `concurrent`, `race`, `fallback` |
| Control Flow | `filter`, `switch`, `contest` |
| Resilience | `retry`, `timeout`, `circuit-breaker`, `rate-limit` |
| Integration | `stream`, `handle` |
| Advanced | `scaffold`, `worker-pool` |

### Default Configuration

| Constant | Value |
|----------|-------|
| `DefaultRetryAttempts` | 3 |
| `DefaultTimeoutDuration` | 30s |
| `DefaultCircuitBreakerThreshold` | 5 |
| `DefaultRecoveryTimeout` | 60s |
| `DefaultRequestsPerSecond` | 10.0 |
| `DefaultBurstSize` | 1 |
| `DefaultWorkerCount` | 4 |

## Validation

`ValidationError` carries `Message` and `Path []string` (e.g., `["root", "children[0]", "then"]`).

`ValidationErrors` collects multiple errors with formatted output.

**Per-connector rules:**
- `sequence`/`concurrent`/`race`: at least one child
- `fallback`: exactly 2 children
- `retry`/`timeout`: child required, duration parseable
- `filter`: predicate + then required
- `switch`: condition + routes required
- `circuit-breaker`: child required, recovery timeout parseable
- `rate-limit`: child required, rps ≥ 0, burst ≥ 0
- `stream`: stream name required, channel must exist
- Cycle detection prevents infinite loops in refs

## Capitan Signals

**Factory lifecycle:** `FactoryCreated`

**Registration:** `ProcessorRegistered`, `PredicateRegistered`, `ConditionRegistered`, `ReducerRegistered`, `ErrorHandlerRegistered`

**Schema operations:** `SchemaValidationStarted/Completed/Failed`, `SchemaBuildStarted/Completed/Failed`, `SchemaRegistered`, `SchemaUpdated`, `SchemaUpdateFailed`, `SchemaRemoved`

**File operations:** `SchemaFileLoaded`, `SchemaFileFailed`, `SchemaYAMLParsed`, `SchemaJSONParsed`, `SchemaParseFailed`

**Field keys:** `KeyName`, `KeyType`, `KeySchema`, `KeyVersion`, `KeyOldVersion`, `KeyNewVersion`, `KeyPath`, `KeyError`, `KeyDuration`, `KeyErrorCount`, `KeySizeBytes`, `KeyFound`

## Thread Safety

- Factory operations protected by `sync.RWMutex` (read operations use RLock)
- Binding execution is lock-free via `atomic.Pointer[pipz.Pipeline[T]]`
- Schema updates atomically swap the pipeline pointer — in-flight requests complete on the old pipeline

## File Layout

```
flume/
├── api.go            # Introspection API, FactorySpec
├── factory.go        # Core Factory[T] implementation
├── schema.go         # Schema and Node type definitions
├── validation.go     # Schema validation with error collection
├── binding.go        # Hot-reload binding implementation
├── builders.go       # 14 connector builders
├── loader.go         # File/JSON/YAML loading
├── observability.go  # Capitan signal definitions
└── testing/
    └── helpers.go    # TestFactory, SchemaBuilder, MockProcessor, BenchmarkHelper
```

## Common Patterns

**Register and build:**

```go
factory := flume.New[Order]()
factory.Add(pipz.Apply("validate", validateFn))
factory.Add(pipz.Apply("enrich", enrichFn))

schema := flume.Schema{
    Version: "1.0",
    Node: flume.Node{Type: "sequence", Children: []flume.Node{
        {Ref: "validate"},
        {Ref: "enrich"},
    }},
}

pipeline, _ := factory.Build(schema)
result, _ := pipeline.Process(ctx, order)
```

**Hot-reload:**

```go
factory.SetSchema("orders", schema)
binding, _ := factory.Bind(identity, "orders", flume.WithAutoSync[Order]())

// Execution is lock-free
result, _ := binding.Process(ctx, order)

// Update schema — binding auto-rebuilds
factory.SetSchema("orders", newSchema)
```

**From YAML:**

```yaml
version: "2.0"
type: sequence
children:
  - ref: validate
  - type: retry
    attempts: 3
    child:
      ref: submit
```

**Introspection for LLMs:**

```go
spec, _ := factory.SpecJSON()
// Inject into LLM prompt for pipeline generation
```

## Ecosystem

Flume depends on:
- **pipz** — pipeline composition primitives
- **capitan** — observable events

Flume is consumed by:
- Applications for dynamic pipeline orchestration
