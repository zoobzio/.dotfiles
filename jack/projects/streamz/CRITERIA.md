# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- All processors follow uniform `Process(ctx, in) <-chan Result[Out]` signature
- Result[T] correctly carries either value or StreamError — never both
- AsyncMapper preserves output order when WithOrdered(true)
- Window processors attach correct metadata (start, end, type, size) to all results
- Errors pass through processors unchanged (fail-open)
- Context cancellation cleanly shuts down all processor goroutines
- Channel closure propagates through processor chains
- DeadLetterQueue correctly separates success and failure streams

### What This Repo MUST NOT Contain

- Persistent storage or replay logic
- Network transport or serialization
- Mutable Result metadata — WithMetadata must return a new Result
- Goroutine leaks on context cancellation or channel closure

## Review Priorities

1. Goroutine lifecycle: every processor must clean up goroutines on context cancel or channel close
2. Channel safety: no sends on closed channels, no double-close
3. Order preservation: AsyncMapper ordered mode must maintain input order
4. Window correctness: window boundaries, metadata timestamps, and session gap detection must be accurate
5. Error passthrough: errors must flow through processors without corruption or loss
6. Clock integration: temporal processors must use injected clock, not time package directly

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Goroutine leak on context cancellation | Critical |
| Send on closed channel panic | Critical |
| AsyncMapper ordered mode reorders output | Critical |
| Result carries both value and error | Critical |
| Window emits items outside window boundaries | High |
| Error lost during passthrough | High |
| DeadLetterQueue sends error to success channel | High |
| Temporal processor ignores injected clock | High |
| Partition metadata incorrect (index, total) | Medium |
| Sample rate not respected (statistical deviation) | Medium |
| Metadata mutation affects original Result | Medium |
| Missing test for a processor type | Medium |
| Buffer size not honored | Low |

## Standing Concerns

- AsyncMapper worker pool with sequence reordering adds complexity — verify no deadlock under backpressure
- SessionWindow gap detection runs on interval — verify no race between check and new item arrival
- SlidingWindow optimization to tumbling mode when slide == size — verify no behavioral difference
- Switch dynamic route management (AddRoute/RemoveRoute) concurrent with processing — verify RWMutex coverage
- Sample uses crypto/rand — verify no blocking under high throughput

## Out of Scope

- No persistent storage is intentional — streamz is in-memory channel processing
- No network transport — herald handles that
- Backpressure is native Go channel blocking — no custom mechanism
- Result[T].Value() panics on error results by design — use IsSuccess() first or ValueOr()
