# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Zero production dependencies — stdlib only
- Type-safe keys that bind field names to specific Go types at compile time
- Per-signal worker goroutines with buffered channels and configurable backpressure
- Listener registration and unregistration that is thread-safe under concurrent access
- Observer dynamic attachment to new signals as they are created
- Event pooling that recycles events after listener invocation without data corruption
- Panic recovery in listener callbacks that does not crash the worker or skip remaining listeners
- Sync mode that faithfully reproduces async semantics without goroutines or buffering
- Event replay that preserves original timestamp/severity and marks events as replay
- Graceful shutdown that drains all queued events before stopping workers

### What This Repo MUST NOT Contain

- Any external dependency — zero-dependency is a hard constraint
- Persistent event storage or durable queues
- Network transport or serialization for distributed routing
- Dynamic signal creation at runtime — signals must be package-level variables
- Mutable events after creation — events are immutable

## Review Priorities

1. Thread safety: concurrent Hook/Emit/Close must not race — this is a concurrent system by design
2. Zero dependencies: any import outside stdlib is a blocking defect
3. Event pool safety: recycled events must not leak data between emissions or corrupt listener reads
4. Worker lifecycle: goroutine leaks on shutdown, double-close, or context cancellation are critical
5. Backpressure correctness: buffer-full behavior must match configured DropPolicy exactly
6. Listener ordering: within a signal, listeners must fire in registration order
7. Observer attachment: observers must attach to signals created after the observer was registered
8. Config resolution: exact match → longest glob → alphabetical tie-breaking must be precise

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Data race in Hook/Emit/Close path | Critical |
| External dependency added | Critical |
| Event pool returns corrupted event data | Critical |
| Goroutine leak on Shutdown | Critical |
| Listener receives event from wrong signal | Critical |
| Backpressure policy not honored (block vs drop) | High |
| Observer misses dynamically created signal | High |
| Panic in listener crashes worker or skips remaining listeners | High |
| Rate limiter allows events beyond configured limit | High |
| Config glob matching returns wrong signal config | High |
| Replay event not marked as replay | Medium |
| Stats snapshot inconsistent with actual state | Medium |
| Missing test for a public API function | Medium |
| Severity filter off by one level | Medium |
| Minor godoc wording issue | Low |

## Standing Concerns

- Event pooling means listeners that retain event references without Clone() will see corrupted data — verify pool lifecycle is correct
- Per-signal workers are created lazily — verify no race between first Emit and Hook for the same signal
- Listener version counter drives cache invalidation in workers — verify counter increments on every Hook/Close
- Observer attachment to future signals requires coordination with worker creation — verify no missed signals
- Configure() is one-shot before first use — verify late Configure() calls are rejected or documented
- HookOnce auto-unregisters — verify it fires exactly once even under concurrent emission

## Out of Scope

- No persistent storage is intentional — capitan is in-memory event routing only
- No guaranteed delivery is by design — configurable policies handle overload
- No cross-signal ordering — only within-signal ordering is guaranteed
- Global singleton pattern is intentional alongside isolated instances for testing
- Silent event dropping (no listeners, disabled signal, rate limit) is by design, not a bug
