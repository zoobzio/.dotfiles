# Pipz

Deep understanding of `github.com/zoobzio/pipz` — the type-safe, composable data processing pipeline framework for Go.

## Core Concepts

Pipz is a pipeline framework built around a single universal interface — `Chainable[T]` — that every component implements. Data flows through processors and connectors while maintaining compile-time type safety through Go generics.

- **Chainable[T]** is the universal interface: `Process`, `Identity`, `Schema`, `Close`
- **Processors** are leaf nodes that wrap user functions (Transform, Apply, Effect, Mutate, Enrich)
- **Connectors** are containers that compose multiple Chainables (Sequence, Fallback, Race, etc.)
- **Pipelines** are DAGs materialised at runtime through composition and introspectable via Schema

Two-tier architecture: processors do work, connectors control flow. Both implement `Chainable[T]`, so connectors nest arbitrarily.

**Dependencies:** `capitan` (signal emission), `clockz` (time mocking for tests), `google/uuid` (identity)

## Public API

### Universal Interface

```go
type Chainable[T any] interface {
    Process(context.Context, T) (T, error)
    Identity() Identity
    Schema() Node
    Close() error
}
```

Every processor and connector implements this. Connectors accept `Chainable[T]` — not concrete types — enabling arbitrary nesting.

### Identity

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `NewIdentity` | `NewIdentity(name, description string) Identity` | Create component metadata with auto-generated UUID |

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `ID()` | `ID() uuid.UUID` | Unique identifier |
| `Name()` | `Name() string` | Human-readable name |
| `Description()` | `Description() string` | Optional documentation |
| `String()` | `String() string` | Implements `fmt.Stringer` |

### Cloner Constraint

```go
type Cloner[T any] interface {
    Clone() T
}
```

Required by all parallel connectors (Concurrent, Scaffold, Race, Contest, WorkerPool). The user must implement deep copy correctly — pipz clones input before dispatching to parallel processors.

## Processors (Leaf Nodes)

All return `Processor[T]` and wrap user functions with panic recovery.

| Adapter | Signature | Purpose | Error Behaviour |
|---------|-----------|---------|-----------------|
| `Transform` | `Transform[T](identity, fn func(ctx, T) T) Processor[T]` | Pure transformation | Cannot fail |
| `Apply` | `Apply[T](identity, fn func(ctx, T) (T, error)) Processor[T]` | Fallible transformation | Wraps errors with context |
| `Effect` | `Effect[T](identity, fn func(ctx, T) error) Processor[T]` | Side effects (data passes through) | Error stops pipeline, data unchanged |
| `Mutate` | `Mutate[T](identity, transformer, condition) Processor[T]` | Conditional transformation | Cannot fail; condition false → passthrough |
| `Enrich` | `Enrich[T](identity, fn func(ctx, T) (T, error)) Processor[T]` | Best-effort enhancement | Swallows errors, returns original |

**When to use which:**
- Data in, different data out → `Transform` (infallible) or `Apply` (fallible)
- Data in, same data out, side effect → `Effect`
- Data in, maybe different data out → `Mutate` (conditional) or `Enrich` (best-effort)

## Connectors — Sequential

### Sequence[T]

Primary sequential composition. Output of one processor becomes input of the next. Fail-fast on first error.

| Constructor | `NewSequence[T](identity, processors ...Chainable[T]) *Sequence[T]` |
|-------------|----------------------------------------------------------------------|

**Modification API** (all thread-safe via RWMutex):

| Method | Behaviour |
|--------|-----------|
| `Register(processors...)` | Append processors |
| `Push(processors...)` | Append (alias) |
| `Unshift(processors...)` | Prepend |
| `Pop()` | Remove and return last |
| `Shift()` | Remove and return first |
| `Before(id, processors...)` | Insert before identity |
| `After(id, processors...)` | Insert after identity |
| `Replace(id, processor)` | Replace by identity |
| `Remove(id)` | Remove by identity |
| `Clear()` | Remove all |
| `Len()` | Count |
| `Names()` | List processor names |

### Pipeline[T]

Execution context wrapper. Injects execution ID and pipeline ID into context for distributed tracing.

| Constructor | `NewPipeline[T](identity, root Chainable[T]) *Pipeline[T]` |
|-------------|--------------------------------------------------------------|

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `ExecutionIDFromContext` | `ExecutionIDFromContext(ctx) (uuid.UUID, bool)` | Extract execution ID from context |
| `PipelineIDFromContext` | `PipelineIDFromContext(ctx) (uuid.UUID, bool)` | Extract pipeline ID from context |

## Connectors — Parallel

All parallel connectors require `[T Cloner[T]]` — input is cloned before dispatch.

### Concurrent[T Cloner[T]]

Run all processors in parallel, wait for all to complete.

| Constructor | `NewConcurrent[T](identity, reducer, processors...) *Concurrent[T]` |
|-------------|----------------------------------------------------------------------|

- **reducer** `func(original T, results map[Identity]T, errors map[Identity]error) T` — aggregates results
- Without reducer: returns original input unchanged
- Waits for all processors to complete

### Scaffold[T Cloner[T]]

Fire-and-forget parallel execution. Returns immediately.

| Constructor | `NewScaffold[T](identity, processors...) *Scaffold[T]` |
|-------------|----------------------------------------------------------|

- Launches processors in background
- Returns original input immediately without waiting
- Uses `context.WithoutCancel()` — processors continue even if parent context cancelled
- No error reporting from background tasks

### Race[T Cloner[T]]

First success wins. Cancels remaining processors.

| Constructor | `NewRace[T](identity, processors...) *Race[T]` |
|-------------|--------------------------------------------------|

- Runs all in parallel with derived context
- Returns first successful result, cancels others
- If all fail, returns last error

### Contest[T Cloner[T]]

First result meeting a condition wins.

| Constructor | `NewContest[T](identity, condition, processors...) *Contest[T]` |
|-------------|------------------------------------------------------------------|

- `condition func(context.Context, T) bool` — quality gate
- First result passing condition wins
- If none pass, returns original input with error

### WorkerPool[T Cloner[T]]

Bounded parallelism via semaphore.

| Constructor | `NewWorkerPool[T](identity, workers int, processors...) *WorkerPool[T]` |
|-------------|--------------------------------------------------------------------------|

| Method | Behaviour |
|--------|-----------|
| `WithTimeout(d)` | Per-task timeout |
| `SetWorkerCount(n)` | Resize pool |
| `GetWorkerCount()` | Current limit |
| `GetActiveWorkers()` | Currently executing |

## Connectors — Conditional

### Switch[T]

Multi-way routing based on data.

| Constructor | `NewSwitch[T](identity, condition Condition[T]) *Switch[T]` |
|-------------|---------------------------------------------------------------|

```go
type Condition[T any] func(context.Context, T) string
```

| Method | Behaviour |
|--------|-----------|
| `AddRoute(key, processor)` | Register route |
| `RemoveRoute(key)` | Remove route |
| `HasRoute(key)` | Check existence |

- Condition returns route key (string)
- No matching route → data passes through unchanged

### Filter[T]

Process or skip.

| Constructor | `NewFilter[T](identity, condition, processor) *Filter[T]` |
|-------------|-------------------------------------------------------------|

- Condition true → execute processor
- Condition false → pass through unchanged

## Error Handling

### Error[T]

Rich error type carrying failure context through the pipeline.

```go
type Error[T any] struct {
    Timestamp time.Time
    InputData T
    Err       error
    Path      []Identity   // Full path through pipeline at failure point
    Duration  time.Duration
    Timeout   bool
    Canceled  bool
}
```

| Method | Behaviour |
|--------|-----------|
| `Error()` | Formats `path → error message` |
| `Unwrap()` | For `errors.As` / `errors.Is` support |
| `IsTimeout()` | Was this a timeout? |
| `IsCanceled()` | Was this a cancellation? |

### Fallback[T]

Try alternatives in sequence until one succeeds.

| Constructor | `NewFallback[T](identity, processors...) *Fallback[T]` |
|-------------|----------------------------------------------------------|

| Method | Behaviour |
|--------|-----------|
| `AddFallback(processor)` | Append backup |
| `GetPrimary()` | First processor |
| `SetPrimary(processor)` | Replace first |

### Handle[T]

Error observation without changing flow.

| Constructor | `NewHandle[T](identity, processor, errorHandler Chainable[*Error[T]]) *Handle[T]` |
|-------------|--------------------------------------------------------------------------------------|

- On error: passes `*Error[T]` to error handler (logging, cleanup, metrics)
- Always returns original error (does not suppress)

### Sentinel Errors

```go
var (
    ErrIndexOutOfBounds = errors.New("index out of bounds")
    ErrEmptySequence    = errors.New("sequence is empty")
    ErrInvalidRange     = errors.New("invalid range")
)
```

## Resilience

### Retry[T]

Simple retry without delay.

| Constructor | `NewRetry[T](identity, processor, maxAttempts int) *Retry[T]` |
|-------------|----------------------------------------------------------------|

Retries immediately on failure. Same input each attempt. Returns last error if exhausted.

### Backoff[T]

Retry with exponential backoff.

| Constructor | `NewBackoff[T](identity, processor, maxAttempts int, baseDelay time.Duration) *Backoff[T]` |
|-------------|--------------------------------------------------------------------------------------------|

Delays: baseDelay, 2×baseDelay, 4×baseDelay, ... Uses `clockz.Clock` for testability.

| Method | Behaviour |
|--------|-----------|
| `WithClock(clock)` | Inject test clock |
| `SetBaseDelay(d)` | Change delay |
| `SetMaxAttempts(n)` | Change attempts |

### CircuitBreaker[T]

Prevent cascading failures. Three states: closed → open → half-open → closed.

| Constructor | `NewCircuitBreaker[T](identity, processor, failureThreshold int, resetTimeout time.Duration) *CircuitBreaker[T]` |
|-------------|-------------------------------------------------------------------------------------------------------------------|

| State | Behaviour |
|-------|-----------|
| Closed | Normal operation; count consecutive failures |
| Open | Fail immediately; wait resetTimeout |
| Half-Open | Allow limited requests to test recovery |

**CRITICAL: Stateful — create once and reuse. Do not create per-request.**

| Method | Behaviour |
|--------|-----------|
| `GetState()` | Current state string |
| `Reset()` | Force closed state |
| `SetSuccessThreshold(n)` | Required successes to close from half-open (default 1) |
| `WithClock(clock)` | Inject test clock |

### Timeout[T]

Enforce time limits.

| Constructor | `NewTimeout[T](identity, processor, duration time.Duration) *Timeout[T]` |
|-------------|---------------------------------------------------------------------------|

Creates derived context with timeout. Runs processor in separate goroutine. Uses `clockz.Clock` for testability.

### RateLimiter[T]

Token bucket rate limiting.

| Constructor | `NewRateLimiter[T](identity, ratePerSecond float64, burst int, processor) *RateLimiter[T]` |
|-------------|--------------------------------------------------------------------------------------------|

| Mode | Behaviour |
|------|-----------|
| `"wait"` (default) | Block until token available |
| `"drop"` | Return error immediately if no token |

**CRITICAL: Stateful — create once and reuse. Do not create per-request.**

| Method | Behaviour |
|--------|-----------|
| `SetRate(ratePerSecond)` | Change rate |
| `SetBurst(burst)` | Change burst |
| `SetMode(mode)` | `"wait"` or `"drop"` |
| `GetAvailableTokens()` | Current token count |
| `WithClock(clock)` | Inject test clock |

## Schema & Introspection

### Node

```go
type Node struct {
    Identity Identity
    Type     string           // "processor", "sequence", "fallback", etc.
    Flow     Flow             // Nil for processors; semantic flow for connectors
    Metadata map[string]any   // Configuration metadata
}
```

### Flow Types

Each connector produces a typed flow implementing `Flow` (with `Variant() FlowVariant`):

`SequenceFlow`, `FallbackFlow`, `RaceFlow`, `ContestFlow`, `ConcurrentFlow`, `SwitchFlow`, `FilterFlow`, `HandleFlow`, `ScaffoldFlow`, `BackoffFlow`, `RetryFlow`, `TimeoutFlow`, `RateLimiterFlow`, `CircuitBreakerFlow`, `WorkerpoolFlow`, `PipelineFlow`

### Schema

```go
type Schema struct {
    Root Node
}
```

| Method | Behaviour |
|--------|-----------|
| `Walk(fn func(Node))` | Depth-first traversal |
| `Find(predicate)` | First match |
| `FindByName(name)` | By name |
| `FindByType(type)` | All of type |
| `Count()` | Total nodes |

All schemas are JSON-serializable.

## Capitan Signals

All connectors emit typed signals via capitan for observability.

| Category | Signals | Severity |
|----------|---------|----------|
| Sequence | completed | Info |
| Concurrent | completed | Info |
| Race | winner | Info |
| Contest | winner | Info |
| Scaffold | dispatched | Info |
| Switch | routed | Info |
| Filter | evaluated | Info |
| Handle | error-handled | Info |
| Retry | attempt-start, attempt-fail | Warn |
| Retry | exhausted | Error |
| Backoff | waiting | Warn |
| Fallback | attempt, failed | Warn |
| Timeout | triggered | Error |
| CircuitBreaker | opened, rejected | Error |
| CircuitBreaker | closed, half-open | Warn |
| RateLimiter | allowed | Info |
| RateLimiter | throttled | Warn |
| RateLimiter | dropped | Error |
| WorkerPool | saturated | Warn |
| WorkerPool | acquired, released | Info |

**Field Keys:** `FieldIdentityID`, `FieldName`, `FieldError`, `FieldTimestamp`, `FieldState`, `FieldFailures`, `FieldSuccesses`, `FieldFailureThreshold`, `FieldSuccessThreshold`, `FieldRate`, `FieldBurst`, `FieldTokens`, `FieldMode`, `FieldWaitTime`, `FieldWorkerCount`, `FieldActiveWorkers`, `FieldAttempt`, `FieldMaxAttempts`, `FieldProcessorIndex`, `FieldProcessorName`, `FieldDuration`, `FieldDelay`, `FieldNextDelay`, `FieldProcessorCount`, `FieldErrorCount`, `FieldWinnerName`, `FieldRouteKey`, `FieldMatched`, `FieldPassed`

## Thread Safety

**Processors:** Immutable after creation. No mutable fields.

**Connectors:** Thread-safe via `sync.RWMutex` for configuration and `sync.Once` for idempotent Close.

**Cloning:** Required for parallel connectors. User responsible for deep copy correctness.

**Close:** LIFO ordering — child processors closed in reverse order. Returns `errors.Join()` on multiple failures. Idempotent.

## Performance

From benchmarks:
- Transform: ~2.7ns/op, zero allocations
- Apply/Effect (success): ~46ns/op, zero allocations
- Basic pipeline overhead: ~88 bytes, 3 allocations (constant regardless of chain length)
- Linear scaling: 5-step ~560ns, 50-step ~2.8μs
- No reflection or runtime type assertions

## File Layout

```
pipz/
├── api.go              # Package docs, Chainable, Identity, Processor, Cloner
├── error.go            # Error[T], panic recovery, sanitisation
├── schema.go           # Node, Flow types, Schema traversal
├── signals.go          # All signal definitions and field keys
├── transform.go        # Transform[T]
├── apply.go            # Apply[T]
├── effect.go           # Effect[T]
├── mutate.go           # Mutate[T]
├── enrich.go           # Enrich[T]
├── sequence.go         # Sequence[T] with modification API
├── pipeline.go         # Pipeline[T] with execution context
├── concurrent.go       # Concurrent[T Cloner[T]]
├── scaffold.go         # Scaffold[T Cloner[T]]
├── race.go             # Race[T Cloner[T]]
├── contest.go          # Contest[T Cloner[T]]
├── workerpool.go       # WorkerPool[T Cloner[T]]
├── switch.go           # Switch[T] with Condition type
├── filter.go           # Filter[T]
├── handle.go           # Handle[T] error observation
├── fallback.go         # Fallback[T]
├── retry.go            # Retry[T]
├── backoff.go          # Backoff[T] exponential backoff
├── timeout.go          # Timeout[T]
├── circuitbreaker.go   # CircuitBreaker[T] state machine
├── ratelimiter.go      # RateLimiter[T] token bucket
└── testing/
    ├── helpers.go
    ├── integration/
    └── benchmarks/
```

## Common Patterns

**Basic Sequential Pipeline:**

```go
pipeline := pipz.NewSequence(pipelineID,
    pipz.Transform(normaliseID, func(ctx context.Context, order Order) Order {
        order.Email = strings.ToLower(order.Email)
        return order
    }),
    pipz.Apply(validateID, func(ctx context.Context, order Order) (Order, error) {
        if order.Total <= 0 {
            return order, fmt.Errorf("invalid total: %f", order.Total)
        }
        return order, nil
    }),
    pipz.Effect(auditID, func(ctx context.Context, order Order) error {
        log.Printf("Processing order %s", order.ID)
        return nil
    }),
)
```

**Resilience Stack:**

```go
protected := pipz.NewSequence(protectedID,
    pipz.NewRateLimiter(rlID, 100, 200,
        pipz.NewCircuitBreaker(cbID,
            pipz.NewBackoff(backoffID, apiCall, 3, time.Second),
            5, 30*time.Second,
        ),
    ),
)
```

**Parallel with Aggregation:**

```go
enriched := pipz.NewConcurrent(enrichID,
    func(original Order, results map[pipz.Identity]Order, errs map[pipz.Identity]Order) Order {
        for _, r := range results {
            original.Metadata = merge(original.Metadata, r.Metadata)
        }
        return original
    },
    geoLookup, fraudCheck, loyaltyLookup,
)
```

**Conditional Routing:**

```go
router := pipz.NewSwitch(routerID, func(ctx context.Context, order Order) string {
    if order.Total > 1000 { return "high-value" }
    return "standard"
})
router.AddRoute("high-value", manualReviewPipeline)
router.AddRoute("standard", autoProcessPipeline)
```

**Fallback with Error Observation:**

```go
resilient := pipz.NewHandle(handleID,
    pipz.NewFallback(fallbackID, primaryAPI, cachedResult, defaultValue),
    pipz.Apply(logErrorID, func(ctx context.Context, e *pipz.Error[Order]) (*pipz.Error[Order], error) {
        log.Printf("Pipeline error at %v: %s", e.Path, e.Err)
        return e, nil
    }),
)
```

## Anti-Patterns

- **Creating stateful connectors per-request** — CircuitBreaker, RateLimiter must be created once and reused. Per-request creation defeats their purpose.
- **Incorrect Cloner implementation** — Shallow copy in `Clone()` leads to data races in parallel connectors. Must deep copy all mutable fields.
- **Ignoring context** — Long-running processors should check `ctx.Err()` periodically. Not checking means timeouts and cancellations don't propagate.
- **Nesting resilience redundantly** — A Retry inside a Backoff is redundant. A Timeout inside a Timeout is confusing. Choose one strategy per concern.
- **Using Scaffold for critical work** — Scaffold is fire-and-forget with no error reporting. Use Concurrent when results matter.
- **Holding Error[T].InputData references** — InputData is captured at failure time. If T contains pointers, the referenced data may have changed.

## Prohibitions

DO NOT:
- Use `interface{}` — pipz is generics-native; every type parameter is explicit
- Create CircuitBreaker or RateLimiter per-request
- Implement `Cloner` with shallow copy for types containing pointers, slices, or maps
- Ignore `Close()` — connectors manage goroutines and child resources
- Assume processor execution order in parallel connectors

## Ecosystem

Pipz is consumed by:
- **zyn** — LLM request processing pipelines built on pipz primitives

Pipz depends on:
- **capitan** — signal emission for observability (all connectors emit signals)
- **clockz** — time mocking for testable backoff, timeout, circuit breaker, rate limiter
