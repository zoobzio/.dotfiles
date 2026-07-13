# Capitan

Deep understanding of `github.com/zoobzio/capitan` — the type-safe event coordination library for Go with zero dependencies.

## Core Concepts

Capitan is an asynchronous event routing system that decouples event emission from event handling.

- **Signals** identify event types (e.g., "order.created")
- **Keys** define typed field names; each key binds to a specific type at compile time
- **Fields** are key-value pairs carrying event data
- **Listeners** subscribe to specific signals and receive events asynchronously
- **Observers** subscribe to multiple signals (all or whitelist) for cross-cutting concerns
- **Workers** are per-signal goroutines that process events independently with backpressure

Mental model: emitters send signals with typed fields into a centralised dispatcher. Per-signal worker goroutines queue events in buffered channels. Each worker invokes all registered listeners sequentially in order, with panic recovery. Observers dynamically attach to signals as they're created, enabling logging, auditing, and metrics without coupling to individual signals.

Three deployment modes:
- **Async (default)** — Emit queues events; workers process asynchronously with backpressure
- **Sync (testing)** — Emit calls listeners directly in the same goroutine; no workers, no buffering
- **Replay** — Re-emit historical events synchronously, bypassing worker queues

**Docs:** `docs/1.learn/3.concepts.md`, `docs/1.learn/4.architecture.md`

## Public API

### Signals

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `NewSignal` | `NewSignal(name, description string) Signal` | Create a signal with identifier and description. Define as package-level variables. |

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Signal.Name()` | `Name() string` | Return signal identifier (e.g., "order.created") |
| `Signal.Description()` | `Description() string` | Return human-readable description |

### Keys (Typed Field Identifiers)

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `NewKey` | `NewKey[T any](name string, variant Variant) GenericKey[T]` | Create a key for custom type T |
| `NewStringKey` | `NewStringKey(name string) StringKey` | String key |
| `NewIntKey` | `NewIntKey(name string) IntKey` | Int key |
| `NewInt32Key` | `NewInt32Key(name string) Int32Key` | Int32 key |
| `NewInt64Key` | `NewInt64Key(name string) Int64Key` | Int64 key |
| `NewUintKey` | `NewUintKey(name string) UintKey` | Uint key |
| `NewUint32Key` | `NewUint32Key(name string) Uint32Key` | Uint32 key |
| `NewUint64Key` | `NewUint64Key(name string) Uint64Key` | Uint64 key |
| `NewFloat32Key` | `NewFloat32Key(name string) Float32Key` | Float32 key |
| `NewFloat64Key` | `NewFloat64Key(name string) Float64Key` | Float64 key |
| `NewBoolKey` | `NewBoolKey(name string) BoolKey` | Bool key |
| `NewTimeKey` | `NewTimeKey(name string) TimeKey` | time.Time key |
| `NewDurationKey` | `NewDurationKey(name string) DurationKey` | time.Duration key |
| `NewBytesKey` | `NewBytesKey(name string) BytesKey` | []byte key |
| `NewErrorKey` | `NewErrorKey(name string) ErrorKey` | error key |

| Key Method | Signature | Behaviour |
|------------|-----------|-----------|
| `Field(value T)` | `Field(value T) Field` | Create a field with this key and value |
| `From(e *Event)` | `From(e *Event) (T, bool)` | Extract typed value from event |
| `ExtractFromFields(fields []Field)` | `ExtractFromFields(fields []Field) T` | Extract from field slice (useful in tests) |
| `Name()` | `Name() string` | Return semantic identifier |
| `Variant()` | `Variant() Variant` | Return type discriminator |

### Events

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `NewEvent` | `NewEvent(signal Signal, severity Severity, timestamp time.Time, fields ...Field) *Event` | Create event for replay (not pooled; safe to hold) |

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Signal()` | `Signal() Signal` | Event's signal identifier |
| `Timestamp()` | `Timestamp() time.Time` | When event was created |
| `Context()` | `Context() context.Context` | Context passed at emission time |
| `Severity()` | `Severity() Severity` | Logging severity level |
| `IsReplay()` | `IsReplay() bool` | True if replayed from storage |
| `Get(key Key)` | `Get(key Key) Field` | Retrieve field by key; nil if not found |
| `Fields()` | `Fields() []Field` | All fields as defensive copy |
| `Clone()` | `Clone() *Event` | Deep copy (safe to retain beyond listener scope) |

### Emission

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Emit` | `Emit(ctx, signal, ...Field)` | Dispatch with Info severity. Creates worker lazily. Drops silently if no listeners. |
| `Debug` | `Debug(ctx, signal, ...Field)` | Dispatch with Debug severity |
| `Info` | `Info(ctx, signal, ...Field)` | Dispatch with Info severity |
| `Warn` | `Warn(ctx, signal, ...Field)` | Dispatch with Warn severity |
| `Error` | `Error(ctx, signal, ...Field)` | Dispatch with Error severity |
| `Replay` | `Replay(ctx, *Event)` | Re-emit historical event synchronously. Preserves original timestamp/severity. Marked as replay. |

### Listeners

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Hook` | `Hook(signal, callback) *Listener` | Register callback for signal. Returns nil if MaxListeners exceeded. |
| `HookOnce` | `HookOnce(signal, callback) *Listener` | One-time callback; auto-unregisters after firing. |

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Close()` | `Close()` | Unregister; blocks until queued events before Close are processed. |
| `Drain(ctx)` | `Drain(ctx) error` | Block until queued events processed; listener remains active. |

### Observers

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Observe` | `Observe(callback, ...Signal) *Observer` | Subscribe to all signals (or whitelist). Dynamically attaches to future signals. |

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Close()` | `Close()` | Remove all underlying listeners. |
| `Drain(ctx)` | `Drain(ctx) error` | Block until all queued events processed across all signals. |

### Instance Management

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `New` | `New(opts ...Option) *Capitan` | Create isolated instance |
| `Default` | `Default() *Capitan` | Return default singleton |
| `Configure` | `Configure(opts ...Option)` | Set options for default instance before first use |

All emission and listener functions exist as both module-level (operate on default instance) and instance methods.

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Shutdown()` | `Shutdown()` | Drain all pending events, stop all workers. Safe to call multiple times. |
| `IsShutdown()` | `IsShutdown() bool` | Check if Shutdown has been called. |
| `Drain(ctx)` | `Drain(ctx) error` | Wait for all queued events without shutting down workers. |
| `Stats()` | `Stats() Stats` | Runtime metrics snapshot. |
| `ApplyConfig(cfg)` | `ApplyConfig(cfg Config) error` | Apply per-signal configuration. Returns ConfigError on validation failure. |

### Options

| Function | Default | Behaviour |
|----------|---------|-----------|
| `WithBufferSize(n)` | 16 | Event queue buffer per signal |
| `WithPanicHandler(fn)` | nil | Callback when listener panics: `func(Signal, any)` |
| `WithSyncMode()` | false | Synchronous processing (testing only) |

**Docs:** `docs/4.reference/1.api.md`

## Types

### Signal

```go
type Signal struct {
    name        string
    description string
}
```

### Key / Field Interfaces

```go
type Key interface {
    Name() string
    Variant() Variant
}

type Field interface {
    Variant() Variant
    Key() Key
    Value() any
}
```

### GenericKey and Aliases

```go
type GenericKey[T any] struct {
    name    string
    variant Variant
}

type StringKey = GenericKey[string]
type IntKey = GenericKey[int]
type Int32Key = GenericKey[int32]
type Int64Key = GenericKey[int64]
type UintKey = GenericKey[uint]
type Uint32Key = GenericKey[uint32]
type Uint64Key = GenericKey[uint64]
type Float32Key = GenericKey[float32]
type Float64Key = GenericKey[float64]
type BoolKey = GenericKey[bool]
type TimeKey = GenericKey[time.Time]
type DurationKey = GenericKey[time.Duration]
type BytesKey = GenericKey[[]byte]
type ErrorKey = GenericKey[error]
```

### Variant Constants

```go
type Variant string

const (
    VariantString   Variant = "string"
    VariantInt      Variant = "int"
    VariantInt32    Variant = "int32"
    VariantInt64    Variant = "int64"
    VariantUint     Variant = "uint"
    VariantUint32   Variant = "uint32"
    VariantUint64   Variant = "uint64"
    VariantFloat32  Variant = "float32"
    VariantFloat64  Variant = "float64"
    VariantBool     Variant = "bool"
    VariantTime     Variant = "time.Time"
    VariantDuration Variant = "time.Duration"
    VariantBytes    Variant = "[]byte"
    VariantError    Variant = "error"
)
```

### Severity

```go
type Severity string

const (
    SeverityDebug Severity = "DEBUG"
    SeverityInfo  Severity = "INFO"
    SeverityWarn  Severity = "WARN"
    SeverityError Severity = "ERROR"
)
```

### Event

```go
type Event struct {
    signal    Signal
    timestamp time.Time
    ctx       context.Context
    fields    map[string]Field
    severity  Severity
    replay    bool
}
```

Events are pooled internally via `sync.Pool`. Events from `Emit` are recycled after listener invocation — use `Clone()` to retain. Events from `NewEvent` (replay) are not pooled and safe to hold.

### EventCallback

```go
type EventCallback func(context.Context, *Event)
```

### Stats

```go
type Stats struct {
    ActiveWorkers   int
    SignalCount     int
    DroppedEvents   uint64
    QueueDepths     map[Signal]int
    ListenerCounts  map[Signal]int
    EmitCounts      map[Signal]uint64
    FieldSchemas    map[Signal][]Key
}
```

### Configuration

```go
type DropPolicy string

const (
    DropPolicyBlock      DropPolicy = "block"
    DropPolicyDropNewest DropPolicy = "drop_newest"
)

type SignalConfig struct {
    BufferSize   int
    Disabled     bool
    MinSeverity  Severity
    MaxListeners int
    DropPolicy   DropPolicy
    RateLimit    float64
    BurstSize    int
}

type Config struct {
    Signals map[string]SignalConfig  // Exact signal names or glob patterns
}
```

Config resolution order: exact match → longest matching glob → alphabetical for ties.

### ConfigError

```go
type ConfigError struct {
    Pattern string
    Field   string
    Reason  string
}

func (e *ConfigError) Error() string
```

**Docs:** `docs/2.guides/1.configuration.md`

## Worker System

Each signal gets its own worker goroutine, created lazily on first Emit.

**Backpressure:** When buffer fills, Emit blocks waiting for space (default `DropPolicyBlock`). Slow listeners cause their signal's buffer to fill, slowing emitters to that signal. Other signals unaffected.

**Panic Recovery:** Each listener invocation wrapped in defer/recover. If panic handler is configured, called with signal and recovered value. Other listeners still execute.

**Rate Limiting:** Token bucket algorithm. Events exceeding rate are dropped silently.

**Listener Caching:** Workers cache the listener slice and only re-copy when the listener version counter changes. Eliminates allocations in steady state.

**Context Handling:** Context checked before queueing and before processing. Cancelled contexts prevent both queueing and processing.

## Thread Safety

| Operation | Lock Type |
|-----------|-----------|
| Hook (register) | Write |
| Emit (existing worker) | Read |
| Emit (new worker) | Write then Read |
| processEvent | Read (listener copy only if version changed) |
| Close (unregister) | Write |
| Stats | Read |
| ApplyConfig | Write |

All public API methods are safe for concurrent use. Listener callbacks execute outside the lock. Events must not be modified in callbacks.

## Error Handling

No exported sentinel errors. Validation uses `ConfigError`.

Emit never returns error. Events silently dropped when:
- No listeners registered
- Signal disabled via config
- MinSeverity filter excludes event
- Rate limit exceeded
- Context cancelled
- DropPolicyDropNewest and buffer full

Listener panics recovered and optionally logged via PanicHandler.

## File Layout

```
capitan/
├── api.go           # Signal, Key, Field, Variant, Severity types
├── service.go       # Capitan singleton, module-level API (Hook, Emit, Observe, Shutdown, Default)
├── config.go        # Config, SignalConfig, DropPolicy, validation, ApplyConfig
├── event.go         # Event type, pooling, construction, accessors
├── fields.go        # GenericKey, type aliases, NewKey*, NewStringKey, etc.
├── listener.go      # Listener, HookOnce, Close, Drain
├── observer.go      # Observer, Observe, attachObservers
├── worker.go        # Emit, Debug, Info, Warn, Error, Replay, processEvents, Shutdown, Drain
└── testing/
    ├── helpers.go       # EventCapture, EventCounter, PanicRecorder, FieldExtractor, TestCapitan, StatsWaiter
    ├── helpers_test.go
    ├── integration/
    │   ├── concurrency_test.go
    │   └── real_world_test.go
    └── benchmarks/
        └── core_performance_test.go
```

## Test Helpers

`capitan/testing/helpers.go` provides:

| Helper | Purpose |
|--------|---------|
| `EventCapture` | Capture events for verification. `Handler()`, `Events()`, `Count()`, `WaitForCount()` |
| `EventCounter` | Count events. `Handler()`, `Count()`, `WaitForCount()` |
| `PanicRecorder` | Record panics. `Handler()`, `Panics()`, `Count()` |
| `FieldExtractor` | Extract typed values. `GetString()`, `GetInt()`, `GetBool()`, `GetFloat64()` |
| `TestCapitan()` | Create isolated instance for testing |
| `StatsWaiter` | Poll stats. `WaitForWorkers()`, `WaitForEmptyQueues()`, `WaitForEmitCount()` |

**Docs:** `docs/2.guides/4.testing.md`, `docs/4.reference/3.testing.md`

## Common Patterns

**Emit/Hook/Drain:**

```go
var (
    orderCreated = capitan.NewSignal("order.created", "New order placed")
    orderID      = capitan.NewStringKey("order_id")
    total        = capitan.NewFloat64Key("total")
)

listener := capitan.Hook(orderCreated, func(ctx context.Context, e *capitan.Event) {
    id, _ := orderID.From(e)
    amount, _ := total.From(e)
    fmt.Printf("Order %s: $%.2f\n", id, amount)
})
defer listener.Close()

capitan.Emit(ctx, orderCreated,
    orderID.Field("ORD-123"),
    total.Field(99.99),
)

capitan.Shutdown()
```

**Custom Type Fields:**

```go
type OrderInfo struct {
    ID    string
    Total float64
}

var orderKey = capitan.NewKey[OrderInfo]("order", "myapp.OrderInfo")

capitan.Emit(ctx, signal, orderKey.Field(OrderInfo{ID: "123", Total: 99.99}))

capitan.Hook(signal, func(ctx context.Context, e *capitan.Event) {
    order, ok := orderKey.From(e)
    if ok {
        fmt.Printf("Order: %+v\n", order)
    }
})
```

**Observing All Signals (Logging):**

```go
observer := capitan.Observe(func(ctx context.Context, e *capitan.Event) {
    log.Printf("[%s] %s", e.Signal().Name(), e.Signal().Description())
})
defer observer.Close()
```

**Replay with Side-Effect Guard:**

```go
capitan.Hook(signal, func(ctx context.Context, e *capitan.Event) {
    if !e.IsReplay() {
        sendConfirmationEmail(e) // Skip external calls during replay
    }
    recordOrderConfirmed(e) // Always update internal state
})

e := capitan.NewEvent(signal, capitan.SeverityInfo, storedTimestamp, fields...)
capitan.Replay(ctx, e)
```

**Sync Mode for Testing:**

```go
c := capitan.New(capitan.WithSyncMode())
capture := testing.NewEventCapture()
c.Hook(signal, capture.Handler())
c.Emit(ctx, signal, field1, field2)
// Deterministic — capture.Count() == 1 immediately
```

**Severity Filtering:**

```go
cfg := capitan.Config{
    Signals: map[string]capitan.SignalConfig{
        "debug.*": {MinSeverity: capitan.SeverityInfo},
    },
}
capitan.ApplyConfig(cfg)
```

**Rate Limiting:**

```go
cfg := capitan.Config{
    Signals: map[string]capitan.SignalConfig{
        "notification.*": {RateLimit: 10, BurstSize: 50},
    },
}
capitan.ApplyConfig(cfg)
```

## Anti-Patterns

- **Dynamic signal creation** — unbounded registry growth. Define signals at package level.
- **Holding event references beyond listener scope** — pooled events are recycled. Use `Event.Clone()`.
- **Sync mode in production** — testing only. Production loses isolation benefits.
- **Not draining before shutdown** — risk of losing queued events. Always call `Shutdown()`.
- **Modifying events in callbacks** — events are immutable after creation.
- **Calling Configure() after default instance created** — configure before first use.
- **Ignoring nil from Hook** — returns nil when MaxListeners exceeded. Check return value.
- **Assuming ordering across signals** — guaranteed within a signal only.

## Prohibitions

DO NOT:
- Introduce dependencies into capitan — zero-dependency is a hard constraint
- Create signals dynamically at runtime
- Retain pooled event references without cloning
- Use sync mode outside of tests
- Assume event delivery order across different signals

## Ecosystem

Capitan is consumed by:
- **pipz** — emits signals for retry, timeout, circuit breaker, rate limiter events
- **aperture** — OpenTelemetry integration; observes events and exports traces/metrics
- **herald** — message broker bridge; consumes capitan events, publishes to Kafka/NATS
- **ago** — workflow orchestration via capitan signals (experimental)

Capitan sits alongside sentinel as a foundation package. Both have zero production dependencies and are consumed by higher-level packages.
