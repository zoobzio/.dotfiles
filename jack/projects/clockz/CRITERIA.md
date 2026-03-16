# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Clock interface covers all time operations: Now, After, AfterFunc, NewTimer, NewTicker, Sleep, Since, WithTimeout, WithDeadline
- RealClock faithfully wraps stdlib with no behavioral differences
- FakeClock Advance/SetTime triggers expired waiters in deterministic deadline order
- BlockUntilReady delivers all queued timer values before returning
- Context deadlines and timeouts cancel correctly when FakeClock advances past them
- Thread-safe under concurrent access — multiple goroutines can use the same clock
- Zero production dependencies — stdlib only

### What This Repo MUST NOT Contain

- Any external dependency
- Backward time travel — SetTime with past time must panic
- Non-deterministic behavior in FakeClock — all operations must be reproducible
- Production code paths that use FakeClock
- Timer channel sends that can block indefinitely (abandoned channels handled gracefully)

## Review Priorities

1. Determinism: FakeClock must produce identical results given identical operations — this is the entire point
2. Thread safety: concurrent timer creation, advancement, and channel reads must not race
3. Zero dependencies: stdlib only
4. Stdlib fidelity: RealClock must behave identically to direct stdlib usage
5. Synchronization: BlockUntilReady must be the single reliable synchronization point
6. Context integration: WithTimeout/WithDeadline must respect FakeClock time, not wall clock

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Non-deterministic FakeClock behavior | Critical |
| Data race in timer/waiter management | Critical |
| External dependency added | Critical |
| BlockUntilReady returns before all values delivered | Critical |
| Context not cancelled when FakeClock advances past deadline | High |
| Waiters not fired in deadline order | High |
| Ticker fails to reschedule after firing | High |
| AfterFunc callback runs asynchronously in FakeClock | High |
| SetTime allows backward time movement | Medium |
| Abandoned channel send blocks advancement | Medium |
| Missing test for a Clock interface method | Medium |
| Internal naming inconsistency | Low |

## Standing Concerns

- Two separate mutexes (mu for time/waiters, contextMu for context waiters) — verify no deadlock potential
- BlockUntilReady copies pending sends under lock, delivers outside lock — verify no race between copy and delivery
- Context cancellation uses sync.Once — verify no double-close panics
- Tickers auto-reschedule by adding period to target time — verify drift does not accumulate
- AfterFunc synchronous execution during Advance means callbacks can observe intermediate time states — verify this is consistent

## Out of Scope

- FakeClock is testing-only by design — not a production concern
- No backward time travel is intentional — determinism requires monotonic advancement
- Synchronous AfterFunc in FakeClock differs from stdlib's goroutine-based execution — this is intentional for determinism
- RealClock singleton is intentional — zero state makes sharing safe
