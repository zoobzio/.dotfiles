# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Handle lifecycle executes in correct order: input→history→pipeline→result→emit
- Continuations resume correctly and run through the same reliability pipeline
- History updated correctly: user input appended before processing, response/yield after
- Emitter injected into context before processor call
- Reliability options wrap the pipeline correctly via pipz
- Capitan signals fire for all lifecycle events

### What This Repo MUST NOT Contain

- LLM client or provider implementations
- Conversation persistence
- Transport layer logic
- Concurrent Handle support on same Chat instance

## Review Priorities

1. Lifecycle correctness: Handle must follow documented step order exactly
2. Continuation safety: stored continuation must be cleared on fresh processor call, preserved on yield
3. History integrity: concurrent Handle calls must not corrupt history (mutex)
4. Emitter lifecycle: Close must be called appropriately, errors propagated
5. Pipeline composition: middleware + terminal + reliability must compose correctly

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| History corrupted by concurrent Handle | Critical |
| Continuation lost or executed incorrectly | Critical |
| Emitter not injected into context | High |
| History not updated after successful processing | High |
| Reliability option silently ignored | High |
| Capitan signal missing for lifecycle event | Medium |
| Result type not correctly dispatched (Response vs Yield) | Medium |

## Standing Concerns

- Mutex held briefly at start of Handle, released before processor call — verify no path holds lock during processing
- Continuation stored as function closure — verify no stale state captured
- ChatRequest implements Cloner for concurrent middleware — verify deep copy is correct
- Fallback creates second Chat — verify lifecycle (close, signals) is independent

## Out of Scope

- Serialized Handle calls per Chat is by design — use separate instances for parallelism
- No conversation persistence is intentional — Chat is in-memory
- ProcessorFunc adapter is intentional — convenience for simple processors
