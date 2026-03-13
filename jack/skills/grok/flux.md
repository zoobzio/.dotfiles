# Flux

Deep understanding of `github.com/zoobzio/flux` — reactive configuration synchronization with validation and rollback.

## Core Concepts

Flux provides live configuration reloading with automatic validation, rollback on failure, and composable reliability via pipz. A `Capacitor[T]` watches a single source; `CompositeCapacitor[T]` merges multiple sources via a `Reducer`. Configuration types must implement `Validator`. All changes flow through a state machine (Loading → Healthy/Empty/Degraded) with debounced processing.

- **Capacitor[T]** watches one source, validates, and applies configuration
- **CompositeCapacitor[T]** merges multiple sources via a Reducer function
- **Watcher** emits raw bytes on change; must emit current value immediately on Watch()
- **State machine** tracks configuration health: Loading → Healthy, Empty, or Degraded
- **Pipeline options** add retry, backoff, timeout, circuit breaker via pipz

**Dependencies:** `pipz` (reliability pipeline), `capitan` (observability), `clockz` (testable time), `gopkg.in/yaml.v3`

## Public API

### Interfaces

```go
type Validator interface {
    Validate() error
}

type Watcher interface {
    Watch(ctx context.Context) (<-chan []byte, error)
}

type Codec interface {
    Unmarshal(data []byte, v any) error
    ContentType() string
}

type MetricsProvider interface {
    OnStateChange(from, to State)
    OnProcessSuccess(duration time.Duration)
    OnProcessFailure(stage string, duration time.Duration)
    OnChangeReceived()
}
```

Built-in codecs: `JSONCodec` (`application/json`), `YAMLCodec` (`application/x-yaml`).

### State

```go
type State int32

const (
    StateLoading  State = iota // Initial — no config yet
    StateHealthy               // Valid config applied
    StateDegraded              // Last change failed, previous config active
    StateEmpty                 // Initial load failed, no valid config ever
)
```

### Capacitor[T] (Single Source)

```go
func New[T Validator](watcher Watcher, fn func(ctx context.Context, prev, curr T) error, opts ...Option[T]) *Capacitor[T]
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Debounce` | `Debounce(d time.Duration) *Capacitor[T]` | Change debounce (default: 100ms) |
| `SyncMode` | `SyncMode() *Capacitor[T]` | Synchronous processing for tests |
| `Clock` | `Clock(clock clockz.Clock) *Capacitor[T]` | Inject fake clock for tests |
| `Codec` | `Codec(codec Codec) *Capacitor[T]` | Deserialization format (default: JSON) |
| `StartupTimeout` | `StartupTimeout(d time.Duration) *Capacitor[T]` | Max wait for initial config |
| `Metrics` | `Metrics(provider MetricsProvider) *Capacitor[T]` | Observability integration |
| `OnStop` | `OnStop(fn func(State)) *Capacitor[T]` | Callback when watching stops |
| `ErrorHistorySize` | `ErrorHistorySize(n int) *Capacitor[T]` | Recent error retention count |
| `Start` | `Start(ctx context.Context) error` | Begin watching (blocks until first config) |
| `Process` | `Process(ctx context.Context) bool` | Manual tick (sync mode only) |
| `State` | `State() State` | Current state |
| `Current` | `Current() (T, bool)` | Current valid config |
| `LastError` | `LastError() error` | Most recent error |
| `ErrorHistory` | `ErrorHistory() []error` | Recent errors (oldest first) |

### CompositeCapacitor[T] (Multi-Source)

```go
type Reducer[T Validator] func(ctx context.Context, prev, curr []T) (T, error)

func Compose[T Validator](reducer Reducer[T], sources []Watcher, opts ...Option[T]) *CompositeCapacitor[T]
```

Same configuration and state query methods as Capacitor[T], plus:

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `SourceErrors` | `SourceErrors() []SourceError` | Per-source error details |

```go
type SourceError struct {
    Index int
    Error error
}
```

### Request[T]

```go
type Request[T Validator] struct {
    Previous T
    Current  T
    Raw      []byte
}
```

### Pipeline Options

#### Boundary Options (wrap entire pipeline)

| Option | Signature |
|--------|-----------|
| `WithRetry` | `WithRetry[T Validator](maxAttempts int) Option[T]` |
| `WithBackoff` | `WithBackoff[T Validator](maxAttempts int, baseDelay time.Duration) Option[T]` |
| `WithTimeout` | `WithTimeout[T Validator](d time.Duration) Option[T]` |
| `WithCircuitBreaker` | `WithCircuitBreaker[T Validator](failures int, recovery time.Duration) Option[T]` |
| `WithFallback` | `WithFallback[T Validator](fallbacks ...pipz.Chainable[*Request[T]]) Option[T]` |
| `WithErrorHandler` | `WithErrorHandler[T Validator](handler pipz.Chainable[*pipz.Error[*Request[T]]]) Option[T]` |
| `WithPipeline` | `WithPipeline[T Validator](identity pipz.Identity) Option[T]` |

#### Middleware Options

| Option | Signature |
|--------|-----------|
| `WithMiddleware` | `WithMiddleware[T Validator](processors ...pipz.Chainable[*Request[T]]) Option[T]` |

#### Middleware Processors

| Function | Purpose |
|----------|---------|
| `UseTransform` | Transform request (infallible) |
| `UseApply` | Transform request (fallible) |
| `UseEffect` | Side effect, request passes through |
| `UseMutate` | Conditional transform |
| `UseEnrich` | Optional enrichment (failure logged, not propagated) |
| `UseRetry` | Wrap processor with retry |
| `UseBackoff` | Wrap processor with exponential backoff |
| `UseTimeout` | Wrap processor with deadline |
| `UseFallback` | Wrap processor with fallback alternatives |
| `UseFilter` | Conditional processor execution |
| `UseRateLimit` | Token bucket rate limiting |

### Testing

```go
func NewChannelWatcher(ch <-chan []byte) *ChannelWatcher
func NewSyncChannelWatcher(ch <-chan []byte) *ChannelWatcher  // For SyncMode()
```

## Capitan Signals

| Signal | Purpose |
|--------|---------|
| `CapacitorStarted` | Watching began |
| `CapacitorStopped` | Watching stopped |
| `CapacitorStateChanged` | State transition |
| `CapacitorChangeReceived` | Raw data from watcher |
| `CapacitorTransformFailed` | Unmarshal failure |
| `CapacitorValidationFailed` | Validation failure |
| `CapacitorApplyFailed` | Callback/reducer failure |
| `CapacitorApplySucceeded` | Config applied |

**Field keys:** `KeyState`, `KeyOldState`, `KeyNewState`, `KeyError`, `KeyDebounce`

## Thread Safety

- **Capacitor[T] / CompositeCapacitor[T]** — thread-safe for concurrent reads after `Start()`. Uses `sync/atomic` for lock-free state and config, `sync.Mutex` for single-start enforcement
- **ChannelWatcher** — thread-safe
- **errorRing** — internal, `sync.RWMutex` protected

## File Layout

```
flux/
├── api.go              # Capacitor[T] — constructor, methods, lifecycle
├── compose.go          # CompositeCapacitor[T] and Reducer[T]
├── codec.go            # Codec interface, JSONCodec, YAMLCodec
├── state.go            # State type and constants
├── request.go          # Request[T] and Reducer[T]
├── options.go          # Option[T] and all pipeline configuration
├── metrics.go          # MetricsProvider interface, NoOpMetricsProvider
├── signals.go          # Capitan signal definitions
├── fields.go           # Capitan field key definitions
├── error_ring.go       # Internal ring buffer for error history
├── channel_watcher.go  # ChannelWatcher for testing
└── testing/
    └── helpers.go      # Test utilities
```

## Common Patterns

**Basic live config:**

```go
cap := flux.New(watcher, func(ctx context.Context, prev, curr Config) error {
    // Apply new config
    return nil
})
cap.Start(ctx)
```

**Multi-source merge:**

```go
cap := flux.Compose(func(ctx context.Context, prev, curr []Config) (Config, error) {
    return merge(curr[0], curr[1]), nil
}, []flux.Watcher{fileWatcher, envWatcher})
cap.Start(ctx)
```

**Reliable with rollback:**

```go
cap := flux.New(watcher, applyFn,
    flux.WithRetry[Config](3),
    flux.WithCircuitBreaker[Config](5, time.Minute),
)
```

**Deterministic testing:**

```go
ch := make(chan []byte, 1)
ch <- configJSON
cap := flux.New(flux.NewSyncChannelWatcher(ch), applyFn).SyncMode()
cap.Start(ctx)
cap.Process(ctx) // Manual tick
```

## Ecosystem

Flux depends on:
- **pipz** — reliability pipeline composition
- **capitan** — observability signals
- **clockz** — testable time

Flux is consumed by:
- Applications for live configuration reloading with validation
