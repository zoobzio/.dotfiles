# Mission: clockz

Deterministic time abstractions for Go with zero dependencies.

## Purpose

Provide a Clock interface that abstracts all time operations so that code using timers, tickers, sleeps, and context deadlines can be tested deterministically without real delays. Clockz exists because any package that touches time becomes untestable or flaky without a way to control the clock.

## What This Package Contains

- `Clock` interface covering Now, After, AfterFunc, NewTimer, NewTicker, Sleep, Since, WithTimeout, WithDeadline
- `Timer` and `Ticker` interfaces matching stdlib semantics
- `RealClock` singleton wrapping stdlib — zero state, safe to share
- `FakeClock` with manual time control: Advance, SetTime, HasWaiters, BlockUntilReady
- Deterministic waiter execution in deadline order during time advancement
- Context deadline/timeout support with proper cancellation semantics

## What This Package Does NOT Contain

- Wall clock or monotonic clock selection — wraps stdlib behavior as-is
- Time zone handling or parsing
- Scheduling or cron-like functionality
- Persistent time state or clock synchronization

## Ecosystem Position

Clockz is a foundation package with zero dependencies:

| Consumer | Role |
|----------|------|
| `capitan` | Testable time for worker scheduling |
| `pipz` | Testable backoff, timeout, circuit breaker, rate limiter |

## Design Constraints

- Zero production dependencies — stdlib only
- No backward time travel — FakeClock.SetTime panics if given a past time
- AfterFunc callbacks execute synchronously during Advance/SetTime for determinism
- BlockUntilReady is the critical synchronization point — must be called after advancing
- RealClock is a singleton — one instance, shared safely

## Success Criteria

A developer can:
1. Accept a Clock interface and have all time operations testable
2. Create a FakeClock and advance time explicitly without real delays
3. Verify timer, ticker, and context deadline behavior deterministically
4. Synchronize with BlockUntilReady to safely read timer channels after advancement
5. Use RealClock in production with zero overhead over stdlib

## Non-Goals

- Replacing the time package — clockz wraps it, does not reimplement it
- Distributed clock synchronization
- Time zone awareness or locale-specific formatting
- Production use of FakeClock
