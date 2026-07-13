# Streamz

Deep understanding of `github.com/zoobzio/streamz` — type-safe stream processing primitives for Go channels.

## Core Concepts

Streamz provides composable, type-safe stream processors over Go channels. Every processor follows a uniform signature: `Process(ctx, in <-chan Result[T]) <-chan Result[Out]`. The `Result[T]` type unifies success and error handling into a single channel, eliminating dual-channel complexity.

- **Result[T]** carries either a value or a `StreamError[T]` — never both
- **Processors** are composable channel transformers
- **Metadata** is immutable key-value data attached to results
- **Window processors** group results by time with window metadata
- Errors pass through most processors unchanged (fail-open by default)

**Dependencies:** `clockz` (deterministic time for testing)

## Public API

### Result[T]

**Constructors:**

| Function | Signature |
|----------|-----------|
| `NewSuccess[T]` | `NewSuccess[T](value T) Result[T]` |
| `NewError[T]` | `NewError[T](item T, err error, processorName string) Result[T]` |

**Methods:**

| Method | Behaviour |
|--------|-----------|
| `IsError()` / `IsSuccess()` | Check result type |
| `Value()` | Get value (panics if error) |
| `Error()` | Get `*StreamError[T]` (nil if success) |
| `ValueOr(fallback T)` | Get value with fallback |
| `Map(fn func(T) T)` | Transform successful value |
| `MapError(fn)` | Transform error |
| `WithMetadata(key, value)` | Add metadata (returns new Result) |
| `GetMetadata(key)` | Retrieve metadata |
| `HasMetadata()` | Check if metadata exists |
| `MetadataKeys()` | Get all metadata keys |
| `GetStringMetadata`, `GetTimeMetadata`, `GetIntMetadata`, `GetDurationMetadata` | Type-safe metadata getters |

### StreamError[T]

```go
type StreamError[T any] struct {
    Item          T
    Err           error
    ProcessorName string
    Timestamp     time.Time
}
```

Implements `error`, `Unwrap()`, and `String()`.

### Processors

All processors follow the pattern: construct → configure → `Process(ctx, in)`.

#### Transform

| Processor | Constructor | Signature | Purpose |
|-----------|-------------|-----------|---------|
| `Filter[T]` | `NewFilter[T](predicate)` | `Process(ctx, in) <-chan Result[T]` | Keep matching items |
| `Mapper[In, Out]` | `NewMapper[In, Out](fn)` | `Process(ctx, in) <-chan Result[Out]` | Synchronous transform |
| `AsyncMapper[In, Out]` | `NewAsyncMapper[In, Out](fn)` | `Process(ctx, in) <-chan Result[Out]` | Parallel transform |

AsyncMapper options: `WithWorkers(n)`, `WithOrdered(bool)`, `WithBufferSize(n)`

Default: `runtime.NumCPU()` workers, ordered output, buffer size 100.

#### Temporal

| Processor | Constructor | Purpose |
|-----------|-------------|---------|
| `Batcher[T]` | `NewBatcher[T](config, clock)` | Group items by size/time |
| `Debounce[T]` | `NewDebounce[T](duration, clock)` | Emit after quiet period |
| `Throttle[T]` | `NewThrottle[T](duration, clock)` | Leading-edge rate limiting |

`BatchConfig`: `MaxLatency time.Duration`, `MaxSize int`

#### Fan-In / Fan-Out

| Processor | Constructor | Signature |
|-----------|-------------|-----------|
| `FanIn[T]` | `NewFanIn[T]()` | `Process(ctx, ins ...<-chan Result[T]) <-chan Result[T]` |
| `FanOut[T]` | `NewFanOut[T](count)` | `Process(ctx, in) []<-chan Result[T]` |

#### Routing

| Processor | Constructor | Signature |
|-----------|-------------|-----------|
| `Partition[T]` | `NewHashPartition`, `NewRoundRobinPartition`, `NewPartition` | `Process(ctx, in) []<-chan Result[T]` |
| `Switch[T, K]` | `NewSwitch[T, K](predicate, config)` / `NewSwitchSimple` | `Process(ctx, in) (routes, errors)` |

Partition adds metadata: `MetadataPartitionIndex`, `MetadataPartitionTotal`, `MetadataPartitionStrategy`

Switch supports dynamic routes: `AddRoute(key)`, `RemoveRoute(key)`, `HasRoute(key)`, `RouteKeys()`

#### Side Effects

| Processor | Constructor | Purpose |
|-----------|-------------|---------|
| `Tap[T]` | `NewTap[T](fn)` | Execute side effect per item (panic-safe) |
| `Buffer[T]` | `NewBuffer[T](size)` | Buffered pass-through |
| `Sample[T]` | `NewSample[T](rate)` | Random sampling (crypto/rand), rate [0.0, 1.0] |

#### Error Handling

| Processor | Constructor | Signature |
|-----------|-------------|-----------|
| `DeadLetterQueue[T]` | `NewDeadLetterQueue[T](clock)` | `Process(ctx, in) (success, failure)` |

Methods: `DroppedCount() uint64`

#### Window Processors

| Processor | Constructor | Options |
|-----------|-------------|---------|
| `TumblingWindow[T]` | `NewTumblingWindow[T](size, clock)` | `WithName` |
| `SlidingWindow[T]` | `NewSlidingWindow[T](size, clock)` | `WithSlide(duration)`, `WithName` |
| `SessionWindow[T]` | `NewSessionWindow[T](keyFunc, clock)` | `WithGap(duration)`, `WithName` |

All window processors attach metadata: `MetadataWindowStart`, `MetadataWindowEnd`, `MetadataWindowType`, `MetadataWindowSize`

SessionWindow defaults: gap 30 minutes, checks at gap/4 intervals.

SlidingWindow: when slide == size, optimises to tumbling mode.

### Window Metadata

| Key | Type | Applies To |
|-----|------|-----------|
| `MetadataWindowStart` | `time.Time` | All windows |
| `MetadataWindowEnd` | `time.Time` | All windows |
| `MetadataWindowType` | string | All windows |
| `MetadataWindowSize` | `time.Duration` | All windows |
| `MetadataWindowSlide` | `time.Duration` | Sliding only |
| `MetadataWindowGap` | `time.Duration` | Session only |
| `MetadataSessionKey` | string | Session only |

General metadata keys: `MetadataSource`, `MetadataTimestamp`, `MetadataProcessor`, `MetadataRetryCount`, `MetadataSessionID`

### Configuration Types

```go
type BatchConfig struct {
    MaxLatency time.Duration
    MaxSize    int
}

type WindowConfig struct {
    Size     time.Duration
    Slide    time.Duration
    MaxCount int
}
```

### Clock Integration

Type aliases for `clockz`:

```go
type Clock = clockz.Clock
type Timer = clockz.Timer
type Ticker = clockz.Ticker
```

`RealClock` — default production clock. Use `clockz.NewFakeClock()` for deterministic testing.

## Thread Safety

**Single-goroutine processors** (inherently race-free): Filter, Mapper, Batcher, Buffer, Debounce, FanIn, FanOut, Tap, TumblingWindow, SlidingWindow, SessionWindow

**Multi-goroutine processors**: AsyncMapper (worker pool with sequence-based reordering), Partition (atomic operations)

**Mutex-protected**: Throttle (lastEmit timestamp), Switch (RWMutex for route management), DeadLetterQueue (atomic dropped counter)

## File Layout

```
streamz/
├── api.go               # BatchConfig, WindowConfig
├── result.go            # Result[T], metadata, WindowCollector
├── error.go             # StreamError[T]
├── clock.go             # Clock aliases (clockz)
├── filter.go            # Filter
├── mapper.go            # Mapper (sync)
├── async_mapper.go      # AsyncMapper (parallel)
├── batcher.go           # Batcher
├── buffer.go            # Buffer
├── debounce.go          # Debounce
├── throttle.go          # Throttle
├── fanin.go             # FanIn
├── fanout.go            # FanOut
├── tap.go               # Tap
├── dlq.go               # DeadLetterQueue
├── partition.go         # Partition (hash, round-robin, custom)
├── sample.go            # Sample
├── switch.go            # Switch
├── window_tumbling.go   # TumblingWindow
├── window_sliding.go    # SlidingWindow
├── window_session.go    # SessionWindow
└── testing/
    └── helpers.go       # CollectResultsWithTimeout, SendValues, assertions
```

## Common Patterns

**Simple pipeline composition:**

```go
filtered := streamz.NewFilter[Order](func(o Order) bool { return o.Total > 100 }).
    Process(ctx, input)
mapped := streamz.NewMapper[Order, Summary](summarize).
    Process(ctx, filtered)
batched := streamz.NewBatcher[Summary](streamz.BatchConfig{MaxSize: 50, MaxLatency: time.Second}, streamz.RealClock).
    Process(ctx, mapped)
```

**Parallel processing with order preservation:**

```go
mapper := streamz.NewAsyncMapper[Raw, Enriched](enrich).
    WithWorkers(10).
    WithOrdered(true)
results := mapper.Process(ctx, input)
```

**Error separation:**

```go
dlq := streamz.NewDeadLetterQueue[Order](streamz.RealClock)
successes, failures := dlq.Process(ctx, input)
// Process successes and failures independently
```

**Time-based windowing:**

```go
window := streamz.NewTumblingWindow[Event](time.Minute, streamz.RealClock)
windowed := window.Process(ctx, events)
```

## Ecosystem

Streamz depends on:
- **clockz** — deterministic time for testing

Streamz is consumed by:
- Applications for channel-based stream processing
