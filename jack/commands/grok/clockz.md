# Clockz

Deep understanding of `github.com/zoobzio/clockz` — type-safe clock abstractions with deterministic testing via FakeClock.

## Core Concepts

Clockz provides a `Clock` interface abstracting all time operations, with a real implementation wrapping stdlib and a fake implementation for deterministic testing. Code that accepts `Clock` instead of calling `time.*` directly becomes fully testable without real delays.

- **Clock** interface covers: Now, After, AfterFunc, NewTimer, NewTicker, Sleep, Since, WithTimeout, WithDeadline
- **RealClock** is a singleton wrapping stdlib — zero state, safe to share
- **FakeClock** provides manual time control — advance explicitly, synchronise with BlockUntilReady

**Dependencies:** None (zero dependencies)

## Public API

### Clock Interface

```go
type Clock interface {
    Now() time.Time
    After(d time.Duration) <-chan time.Time
    AfterFunc(d time.Duration, f func()) Timer
    NewTimer(d time.Duration) Timer
    NewTicker(d time.Duration) Ticker
    Sleep(d time.Duration)
    Since(t time.Time) time.Duration
    WithTimeout(ctx context.Context, timeout time.Duration) (context.Context, context.CancelFunc)
    WithDeadline(ctx context.Context, deadline time.Time) (context.Context, context.CancelFunc)
}
```

### Timer Interface

```go
type Timer interface {
    Stop() bool
    Reset(d time.Duration) bool
    C() <-chan time.Time
}
```

### Ticker Interface

```go
type Ticker interface {
    Stop()
    C() <-chan time.Time
}
```

### RealClock

```go
var RealClock Clock = &realClock{}
```

Singleton wrapping stdlib. Thin passthrough to `time.NewTimer`, `time.NewTicker`, `time.After`, `time.AfterFunc`, `context.WithTimeout`, `context.WithDeadline`.

### FakeClock

| Constructor | Signature | Behaviour |
|-------------|-----------|-----------|
| `NewFakeClock` | `NewFakeClock() *FakeClock` | Initialise to current real time |
| `NewFakeClockAt` | `NewFakeClockAt(t time.Time) *FakeClock` | Initialise to specific time |

**Clock interface methods:** All 9 methods implemented with manual time control.

**Testing-specific methods:**

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Advance` | `Advance(d time.Duration)` | Move time forward by duration |
| `SetTime` | `SetTime(t time.Time)` | Set absolute time. Panics if moving backward. |
| `HasWaiters` | `HasWaiters() bool` | Check for pending timers/contexts |
| `BlockUntilReady` | `BlockUntilReady()` | Synchronise — deliver all queued timer values |

## How FakeClock Works

1. **Create:** `clock := NewFakeClock()` or `NewFakeClockAt(specificTime)`
2. **Register timers/tickers:** Creating a timer registers a waiter in the clock
3. **Advance time:** `Advance(d)` or `SetTime(t)` triggers expired waiters in deadline order
4. **Synchronise:** `BlockUntilReady()` delivers all queued values to timer channels
5. **Read results:** Timer channels now have values; contexts are cancelled

**Key behaviours:**
- AfterFunc callbacks execute **synchronously** during `Advance`/`SetTime` (not in goroutines)
- Waiters sorted by deadline — deterministic execution order
- Tickers automatically reschedule (add period to target time)
- Abandoned channels handled gracefully (non-blocking sends)
- No backward time travel — `SetTime` panics if given a past time
- `BlockUntilReady()` is the critical synchronisation point — must be called after advancing

## Thread Safety

Two separate mutexes:

| Mutex | Protects | Lock Pattern |
|-------|----------|-------------|
| `mu sync.RWMutex` | time, waiters, pendingSends | RLock for `Now()`, Lock for mutations |
| `contextMu sync.Mutex` | contextWaiters | Separate to reduce contention |

`BlockUntilReady()` copies pending sends under lock, delivers outside lock. Context cancellation uses `sync.Once` to prevent double-close.

## File Layout

```
clockz/
├── api.go    # Clock, Timer, Ticker interfaces
├── real.go   # RealClock singleton (stdlib wrapper)
└── fake.go   # FakeClock with manual time control
```

## Common Patterns

**Injecting Clock:**

```go
type Service struct {
    clock clockz.Clock
}

func NewService(clock clockz.Clock) *Service {
    return &Service{clock: clock}
}
```

**Testing with FakeClock:**

```go
func TestTimeout(t *testing.T) {
    clock := clockz.NewFakeClock()
    svc := NewService(clock)

    ctx, cancel := clock.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    clock.Advance(5 * time.Second)
    clock.BlockUntilReady()

    // ctx is now cancelled
}
```

## Anti-Patterns

- **Forgetting BlockUntilReady()** — timer channels won't have values after Advance without synchronisation
- **Moving time backward** — SetTime panics. Time only moves forward.
- **Reading timer channels before BlockUntilReady** — race condition. Always synchronise first.
- **Using FakeClock in production** — testing only. Use `RealClock` singleton.

## Ecosystem

Clockz is consumed by:
- **capitan** — testable time for worker scheduling
- **pipz** — testable backoff, timeout, circuit breaker, rate limiter (via `WithClock` methods)
