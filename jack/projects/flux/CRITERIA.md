# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- `Capacitor[T]` correctly watches a source, deserializes, validates, and applies configuration
- `CompositeCapacitor[T]` correctly merges multiple sources via a Reducer and validates the merged result
- State machine transitions are correct: Loading → Healthy on success, Loading → Empty on initial failure, Healthy → Degraded on subsequent failure
- Rollback preserves the last valid configuration when new changes fail
- Debouncing coalesces rapid changes without dropping the final value
- Pipeline options (retry, backoff, timeout, circuit breaker) correctly wrap processing via pipz
- Watcher contract enforced: must emit current value immediately on Watch()
- All state transitions and failures emit appropriate capitan signals

### What This Repo MUST NOT Contain

- Source watcher implementations — consumers provide those via the Watcher interface
- Configuration format logic beyond codec unmarshal — no schema awareness
- Unvalidated configuration reaching the apply callback — Validator must always run
- Persistent configuration storage or history beyond error ring buffer
- Distributed coordination or consensus logic

## Review Priorities

1. State machine correctness: transitions must be exact — wrong state leads to wrong rollback behavior
2. Thread safety: concurrent reads of state/config during active processing must not race
3. Rollback reliability: failed changes must never corrupt the current valid configuration
4. Debounce correctness: rapid changes must coalesce, final value must never be dropped
5. Pipeline integration: pipz options must compose correctly without interfering with core state machine
6. Watcher lifecycle: context cancellation must cleanly stop watching without goroutine leaks
7. Signal accuracy: capitan signals must reflect actual state, not intended state

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| State machine reaches impossible state | Critical |
| Data race on config or state access | Critical |
| Rollback fails, leaving no valid config in Degraded state | Critical |
| Goroutine leak on context cancellation | Critical |
| Debounce drops the final pending change | High |
| Pipeline option silently ignored | High |
| Watcher error not surfaced to state machine | High |
| Capitan signal emitted for wrong state transition | High |
| StartupTimeout not enforced | Medium |
| Error history ring buffer races | Medium |
| Missing test for a pipeline option | Medium |
| Metrics provider callback missing for a state change | Low |
| Internal naming inconsistency | Low |

## Standing Concerns

- Atomic state storage means ordering matters — verify state reads are consistent with config reads
- Debounce timer resets on every change — verify no edge case where timer fires with stale data
- CompositeCapacitor tracks per-source state — verify partial source failures correctly degrade without losing healthy sources
- SyncMode disables goroutines — verify Process() faithfully reproduces async behavior
- Pipeline options wrap the entire processing chain — verify they don't interfere with state machine transitions

## Out of Scope

- No built-in source watchers is intentional — flux provides the framework, not the implementations
- Full replacement on every change (no partial/diff) is by design
- No distributed consensus — flux is a single-process library
- YAML dependency (gopkg.in/yaml.v3) is intentional for the built-in YAMLCodec
- Error ring buffer has fixed size — not a memory leak, intentional bounded history
