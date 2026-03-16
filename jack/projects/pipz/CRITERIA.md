# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- `Chainable[T]` interface implemented correctly by every processor and connector
- Panic recovery in all processor adapters — user function panics must not crash the pipeline
- Parallel connectors clone input before dispatch — no shared mutable state across goroutines
- CircuitBreaker state machine transitions (closed→open→half-open→closed) are correct
- RateLimiter token bucket is accurate across wait and drop modes
- Backoff delays follow exponential schedule with correct clock integration
- Sequence fail-fast: first error stops processing
- Close follows LIFO order and is idempotent
- All connectors emit appropriate capitan signals
- Schema introspection produces accurate DAG representation

### What This Repo MUST NOT Contain

- `interface{}` or `any` in processor/connector type parameters — generics only
- Reflection or runtime type assertions
- Per-request CircuitBreaker or RateLimiter creation patterns
- Shared mutable state across parallel processor invocations without cloning
- Goroutine leaks on context cancellation, timeout, or close

## Review Priorities

1. Goroutine safety: parallel connectors must not leak goroutines on cancel/timeout/close
2. Clone correctness: parallel dispatch must clone input — shared mutation is a data race
3. Circuit breaker state machine: wrong transitions cause cascading failures or stuck-open circuits
4. Panic recovery: all processor adapters must recover panics — unrecovered panics crash workers
5. Close ordering: LIFO close prevents use-after-close in dependent processors
6. Rate limiter accuracy: token replenishment must be correct under clock injection
7. Error propagation: Error[T] path tracking must accurately reflect pipeline traversal

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Goroutine leak on context cancellation | Critical |
| Parallel dispatch without input cloning | Critical |
| Unrecovered panic in processor | Critical |
| Circuit breaker stuck in wrong state | Critical |
| Data race in connector mutable state | Critical |
| Rate limiter allows requests beyond configured rate | High |
| Backoff delay calculation wrong | High |
| Sequence continues after processor error | High |
| Close not LIFO or not idempotent | High |
| Schema does not reflect actual pipeline structure | Medium |
| Capitan signal missing for a connector operation | Medium |
| Error[T] path incomplete or incorrect | Medium |
| WorkerPool semaphore leak | Medium |
| Missing benchmark for a connector type | Low |

## Standing Concerns

- Scaffold uses context.WithoutCancel — background tasks outlive parent context by design, but verify cleanup
- Concurrent reducer receives results and errors — verify reducer is called even when all processors fail
- Race cancels remaining processors on first success — verify cancelled processors clean up
- CircuitBreaker half-open allows limited requests — verify concurrent half-open requests don't exceed limit
- RateLimiter token bucket needs clock integration — verify deterministic testing with FakeClock
- Sequence modification API (Push, Unshift, Before, After, Replace, Remove) is thread-safe — verify RWMutex coverage

## Out of Scope

- No distributed execution is intentional — pipz is in-process
- Scaffold fire-and-forget with no error reporting is by design
- User responsible for Cloner correctness — pipz cannot verify deep copy
- Stateful connectors (CircuitBreaker, RateLimiter) must be reused — per-request is an anti-pattern, not a bug
- No automatic parallelism — developer explicitly chooses connectors
