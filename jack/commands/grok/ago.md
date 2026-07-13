# Ago

Deep understanding of `github.com/zoobzio/ago` — event-driven workflow orchestration via capitan signals and pipz pipelines.

## Core Concepts

Ago ("I do" in Latin) bridges capitan (event signals) with pipz (pipeline composition) for distributed workflow orchestration. It enables sagas with automatic compensation, request/response over async events, and correlation tracking across services.

- **Flow[T]** is the central data structure — typed payload with correlation context, accumulated fields, and error tracking
- **SagaStep** executes a step and registers compensation atomically
- **Compensate** rolls back completed steps in reverse (LIFO) order
- **Request/Await** provide synchronous RPC semantics over async events
- **Store** persists saga state for crash recovery

Key design: at-least-once delivery semantics with idempotency keys for exactly-once behaviour at the handler level.

**Dependencies:** `capitan` (event coordination), `pipz` (pipeline composition), `herald` (message broker integration), `sqlx` (PostgreSQL store), `uuid` (correlation IDs)

## Public API

### Flow[T]

```go
type Flow[T any] struct {
    Payload       T
    Signal        capitan.Signal
    Timestamp     time.Time
    Severity      capitan.Severity
    CorrelationID string
    CausationID   string
    Metadata      map[string]string
    Errors        []error
}
```

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `NewFlow` | `NewFlow[T](payload T, signal capitan.Signal) *Flow[T]` | Create from payload + signal |
| `NewFromEvent` | `NewFromEvent[T](e *capitan.Event, key capitan.GenericKey[T]) *Flow[T]` | Extract from capitan event. Returns nil if key absent. |

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Set` | `Set(field capitan.Field)` | Add/update typed field (thread-safe) |
| `Get` | `Get(key capitan.Key) capitan.Field` | Retrieve field by key |
| `From` | `From[T,V](f *Flow[T], key capitan.GenericKey[V]) (V, bool)` | Type-safe field extraction |
| `Fields` | `Fields() []capitan.Field` | All accumulated fields |
| `AddError` | `AddError(err error)` | Append error |
| `HasErrors` | `HasErrors() bool` | Check for accumulated errors |
| `Clone` | `Clone() *Flow[T]` | Deep copy (implements `pipz.Cloner`) |

Thread-safe via `sync.RWMutex` on field map.

### Store Interface

```go
type Store interface {
    // Pending request/await state
    SetPending(ctx, correlationID string, state *PendingState) error
    GetPending(ctx, correlationID string) (*PendingState, error)
    DeletePending(ctx, correlationID string) error

    // Saga state
    SetSaga(ctx, correlationID string, state *SagaState) error
    GetSaga(ctx, correlationID string) (*SagaState, error)
    UpdateSaga(ctx, correlationID string, state *SagaState) error
    DeleteSaga(ctx, correlationID string) error
    ListIncompleteSagas(ctx) ([]*SagaState, error)

    // Exclusive access for crash-safe mutations
    WithSaga(ctx, correlationID string, fn func(*SagaState) (*SagaState, error)) error

    // Idempotency tracking
    MarkCompensated(ctx, correlationID, stepName string) error
    IsCompensated(ctx, correlationID, stepName string) (bool, error)
}
```

`WithSaga` provides exclusive (transactional) access. Callback receives nil if saga doesn't exist. Returning non-nil state persists the change. Signal emission happens AFTER `WithSaga` returns (outside lock) for at-least-once semantics.

### SagaState

```go
type SagaState struct {
    CorrelationID string
    Status        SagaStatus  // pending, running, compensating, completed, failed
    CurrentStep   int
    Compensations []CompensationRecord  // Stack (LIFO)
    CreatedAt     time.Time
    UpdatedAt     time.Time
    Error         string
    Timeout       time.Duration  // 0 = no timeout
}

func (s *SagaState) IsExpired() bool

type CompensationRecord struct {
    StepName string
    Signal   capitan.Signal
    Data     []byte  // Serialised payload
}
```

### Store Implementations

| Store | Package | Locking | Use Case |
|-------|---------|---------|----------|
| `MemoryStore` | main | Per-saga mutex + deep copies | Testing, single-instance |
| `CerealStore` | main | `SELECT FOR UPDATE` in transaction | Production (PostgreSQL) |

`CerealStore.Migrate(ctx)` creates tables: `ago_pending_states`, `ago_saga_states`, `ago_compensated_steps`.

## Primitives (Processors)

All primitives implement `pipz.Chainable[*Flow[T]]` and follow a builder pattern with `.Build()`.

### SagaStep[T] — Distributed Transaction Step

```go
func NewSagaStep[T any](
    name pipz.Name, store Store, key capitan.GenericKey[T],
    execute capitan.Signal, compensate capitan.Signal,
) *SagaStep[T]
```

Builder: `WithCapitan(c)`, `WithTimeout(d)`, `Build()`

**Execution:**
1. Serialise payload for compensation
2. `WithSaga` for exclusive access — create saga if needed, check idempotency
3. Push compensation record, increment step counter
4. Outside lock: emit execute signal with `IdempotencyKey = correlationID:stepName`
5. Emit `SagaStepCompleted`

### Compensate[T] — Rollback

```go
func NewCompensate[T any](name pipz.Name, store Store, key capitan.GenericKey[T]) *Compensate[T]
```

Builder: `WithCapitan(c)`, `Build()`

**Execution (multi-step for crash recovery):**
1. `WithSaga`: transition to "compensating", capture records
2. Per step: check `IsCompensated`, emit compensation signal, `MarkCompensated`
3. `WithSaga`: transition to "failed"

LIFO order. Idempotent via `IsCompensated`/`MarkCompensated`.

### Request[T, R] — Synchronous RPC over Async Events

```go
func NewRequest[T, R any](
    name pipz.Name,
    requestSignal, responseSignal capitan.Signal,
    requestKey capitan.GenericKey[T], responseKey capitan.GenericKey[R],
) *Request[T, R]
```

Builder: `WithCapitan(c)`, `Timeout(d)` (default 30s), `Build()`

Emits request signal, hooks response signal filtered by correlation ID, waits for response or timeout.

### Await[T, V] — Wait for Correlated Event

```go
func NewAwait[T, V any](name pipz.Name, signal capitan.Signal, key capitan.GenericKey[V]) *Await[T, V]
```

Builder: `WithCapitan(c)`, `Timeout(d)` (default 30s), `Build()`

Hooks signal, waits for correlated event, extracts payload, adds to flow via `Set`.

### Emit[T] — Fire-and-Forget Signal

```go
func NewEmit[T any](name pipz.Name, signal capitan.Signal, key capitan.GenericKey[T]) *Emit[T]
```

Builder: `WithCapitan(c)`, `Build()`

Emits payload + all accumulated fields + correlation/causation IDs.

### Enrich / EnrichOptional — External Data Augmentation

```go
func Enrich[T, V any](name, key, enrichFn func(ctx, T) (V, error)) pipz.Chainable[*Flow[T]]
func EnrichOptional[T, V any](name, key, enrichFn) pipz.Chainable[*Flow[T]]
```

`Enrich` fails pipeline on error. `EnrichOptional` logs error and continues.

### Publish[T] — Message Broker Integration

```go
func Publish[T any](name pipz.Name, provider herald.Provider) pipz.Chainable[*Flow[T]]
```

JSON marshals payload, publishes with correlation/causation metadata.

### DeadLetter[T] — Failure Routing

```go
func NewDeadLetter[T any](name pipz.Name, key capitan.GenericKey[T]) *DeadLetter[T]
```

Builder: `WithCapitan(c)`, `WithSignal(signal)`, `WithProvider(provider)`, `Build()`

Emits `DeadLetterRouted` signal. Optionally publishes to broker with error metadata.

### Tag / TagFrom — Broker Metadata

```go
func Tag[T any](name pipz.Name, key, value string) pipz.Chainable[*Flow[T]]
func TagFrom[T any](name pipz.Name, key string, valueFn func(T) string) pipz.Chainable[*Flow[T]]
```

### Correlate / CorrelateFrom — Correlation ID

```go
func Correlate[T any](name pipz.Name) pipz.Chainable[*Flow[T]]
func CorrelateFrom[T any](name pipz.Name, parentCorrelation string) pipz.Chainable[*Flow[T]]
```

Generates UUID if missing. `CorrelateFrom` also sets `CausationID`.

## Helper Functions (pipz Wrappers)

Type-safe wrappers returning `pipz.Chainable[*Flow[T]]`:

| Category | Functions |
|----------|-----------|
| Adapters | `Do`, `Transform`, `Effect`, `Mutate`, `EnrichWith` |
| Sequential | `Sequence` |
| Control Flow | `Filter`, `Switch`, `Gate` |
| Error Handling | `Fallback`, `Retry`, `Backoff`, `Timeout`, `Handle` |
| Resource Protection | `RateLimiter`, `CircuitBreaker` |
| Parallel | `Concurrent`, `Race`, `WorkerPool` |

## Recovery

```go
func RecoverSagas[T any](ctx, store Store, key capitan.GenericKey[T], c *capitan.Capitan) error
```

Finds and compensates sagas in "running" or "compensating" state, plus expired sagas. Call at startup for crash recovery.

## Signals

| Category | Signals |
|----------|---------|
| Flow | `FlowCreated`, `FlowCompleted`, `FlowFailed` |
| Saga | `SagaStarted`, `SagaStepCompleted`, `SagaCompensating`, `SagaCompleted`, `SagaFailed` |
| Request | `RequestSent`, `ResponseReceived`, `RequestTimeout` |
| Dead Letter | `DeadLetterRouted` |

## Coordination Keys

```go
var (
    CorrelationKey = capitan.NewStringKey("correlation_id")
    CausationKey   = capitan.NewStringKey("causation_id")
    IdempotencyKey = capitan.NewStringKey("idempotency_key")
    StepNameKey    = capitan.NewStringKey("step_name")
    SagaStatusKey  = capitan.NewKey[SagaStatus]("saga_status", "ago.SagaStatus")
    ErrorKey       = capitan.NewErrorKey("error")
)
```

**IdempotencyKey format:** `{correlationID}:{stepName}` for execute, `{correlationID}:compensate:{stepName}` for compensation. Handlers calling external systems MUST use this for exactly-once semantics.

## Sentinel Errors

```go
var (
    ErrNotFound = errors.New("ago: state not found")
    ErrTimeout  = errors.New("ago: request timeout")
)
```

## Thread Safety

| Component | Model |
|-----------|-------|
| `Flow[T]` | RWMutex on field map; designed for sequential processing |
| `MemoryStore` | Global RWMutex + per-saga mutexes; deep copies prevent external mutation |
| `CerealStore` | PostgreSQL transactions + `SELECT FOR UPDATE` |

## File Layout

```
ago/
├── flow.go          # Flow[T] + field management
├── signals.go       # Lifecycle signals
├── keys.go          # Correlation, causation, idempotency keys
├── store.go         # Store interface, SagaState, PendingState
├── memory_store.go  # In-memory store (testing/single-instance)
├── cereal_store.go  # PostgreSQL store (production)
├── saga_step.go     # SagaStep execution + compensation registration
├── compensate.go    # Rollback orchestration
├── recovery.go      # Crash recovery
├── request.go       # Request/response over events
├── await.go         # Await correlated event
├── emit.go          # Fire-and-forget emission
├── enrich.go        # External data augmentation
├── publish.go       # Message broker integration
├── dead_letter.go   # Failure routing
├── tag.go           # Metadata enrichment
├── correlate.go     # Correlation ID management
├── helpers.go       # pipz topology wrappers
└── testing/
    ├── helpers.go   # MockStore, SignalTracker, assertions
    └── integration/
```

## Common Patterns

**Saga with Compensation:**

```go
pipeline := ago.Sequence("order-saga",
    ago.Correlate[Order]("correlate"),
    ago.NewSagaStep("reserve-inventory", store, orderKey, reserveSignal, unreserveSignal).Build(),
    ago.NewSagaStep("charge-payment", store, orderKey, chargeSignal, refundSignal).Build(),
    ago.NewSagaStep("ship-order", store, orderKey, shipSignal, cancelShipSignal).Build(),
    ago.NewEmit("confirm", confirmSignal, orderKey).Build(),
)
```

**Request/Response:**

```go
enriched := ago.NewRequest[Order, Inventory](
    "check-inventory", checkSignal, inventorySignal, orderKey, inventoryKey,
).Timeout(5 * time.Second).Build()
```

**Crash Recovery at Startup:**

```go
ago.RecoverSagas[Order](ctx, store, orderKey, capitan.Default())
```

## Anti-Patterns

- **Omitting idempotency in handlers** — ago guarantees at-least-once delivery. Handlers for external systems MUST deduplicate via `IdempotencyKey`.
- **Creating sagas without correlation** — all primitives require `CorrelationID`. Use `Correlate` as first step.
- **Sharing Flow across goroutines** — designed for sequential processing within a pipeline.
- **Forgetting RecoverSagas at startup** — running/compensating sagas from crashes won't complete without recovery.

## Ecosystem

Ago depends on:
- **capitan** — event coordination (signals and keys)
- **pipz** — pipeline composition (all primitives are Chainable)
- **herald** — message broker integration (Publish primitive)

Ago is consumed by applications with multi-step workflow orchestration needs.
