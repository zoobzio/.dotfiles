# Mission: streamz

Type-safe stream processing primitives for Go channels.

## Purpose

Provide composable, type-safe stream processors over Go channels. Every processor follows a uniform signature: `Process(ctx, in) <-chan Result[Out]`. The `Result[T]` type unifies success and error handling into a single channel, eliminating dual-channel complexity.

Streamz exists because Go channels are powerful but composition is tedious — filtering, mapping, batching, windowing, fan-in/fan-out, and error routing all require careful goroutine and channel management that should be provided as reusable primitives.

## What This Package Contains

- `Result[T]` unifying success and error in a single channel type with immutable metadata
- Transform processors: Filter, Mapper (sync), AsyncMapper (parallel with optional ordering)
- Temporal processors: Batcher (size/time), Debounce (quiet period), Throttle (leading-edge rate limit)
- Fan-in/Fan-out for channel merging and splitting
- Routing: Partition (hash, round-robin, custom), Switch (key-based dynamic routing)
- Side effects: Tap (observe), Buffer (buffered pass-through), Sample (random sampling via crypto/rand)
- Error handling: DeadLetterQueue (separate success/failure streams)
- Window processors: TumblingWindow, SlidingWindow, SessionWindow — all with window metadata
- Clock integration via clockz for deterministic testing

## What This Package Does NOT Contain

- Persistent stream storage or replay
- Network transport (Kafka, NATS, etc.) — that's herald's domain
- Stream schema or serialization
- Backpressure signaling beyond Go channel semantics

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `clockz` | Deterministic time for testing temporal processors |

Streamz is consumed by applications for channel-based stream processing.

## Design Constraints

- Uniform processor signature: `Process(ctx, in) <-chan Result[Out]`
- Errors pass through most processors unchanged (fail-open by default)
- Result metadata is immutable — WithMetadata returns a new Result
- AsyncMapper preserves output order by default via sequence-based reordering
- Window processors attach standard window metadata to all emitted results

## Success Criteria

A developer can:
1. Compose channel processors into pipelines with type safety
2. Transform, filter, batch, and window stream data with composable primitives
3. Fan out to parallel workers and fan in results
4. Route items dynamically based on content
5. Separate error streams for independent handling via DeadLetterQueue
6. Test temporal processors deterministically with FakeClock

## Non-Goals

- Persistent stream storage or exactly-once delivery
- Network transport or distributed stream processing
- Backpressure beyond native Go channel blocking
- Stream schema validation or serialization
