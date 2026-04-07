# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Out declarations observe capitan signals and publish via herald transparently
- In declarations subscribe via herald and emit capitan signals transparently
- Application code never touches herald directly — ergo is the abstraction boundary
- Handlers are standard capitan hooks — no ergo-specific handler interface or callback type
- Mesh Start activates all publishers/subscribers, Close tears them all down cleanly
- Delivery semantics correctly inferred from configuration (stream+group = durable, pubsub = broadcast)
- Reliability options (retry, backoff, circuit breaker) apply per-channel without affecting others
- Graceful shutdown drains in-flight publishes and stops subscribers before returning

### What This Repo MUST NOT Contain

- Herald provider implementations — that's herald's responsibility
- In-process event routing — that's capitan's responsibility
- Business logic or domain-specific handler code
- Service registry integration (sum.Register)
- Message routing, fan-out logic, or topic management

## Review Priorities

1. Transparency: application code must not know ergo exists — only capitan.Emit and capitan.Hook
2. Lifecycle correctness: Start activates everything, Close drains and stops everything, no leaked goroutines
3. Loop prevention: same signal as both In and Out in one process must be rejected or clearly documented
4. Reliability isolation: a circuit breaker opening on one channel must not affect other channels
5. Shutdown ordering: in-flight publishes must complete before Close returns
6. Topology correctness: catalog must accurately reflect all declared In/Out channels

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Event published but signal not observed (silent data loss) | Critical |
| Event consumed but capitan signal not emitted (silent drop) | Critical |
| Close returns before in-flight publishes complete | Critical |
| Same signal In+Out creates infinite loop | Critical |
| Leaked goroutine after Close | High |
| Reliability option on one channel affects another | High |
| Herald imported in application code alongside ergo | High |
| Topology catalog missing a declared channel | Medium |
| Serialization error not surfaced via capitan signal | Medium |
| Consumer group not cleaned up on shutdown | Low |

## Standing Concerns

- Herald's ErrorSignal and ergo's lifecycle signals must not conflict — verify separate signal names
- Redis Streams vs PubSub selection must be driven by configuration, not implicit heuristics
- Verify that In declarations with consumer groups correctly pass group+consumer to herald provider
- Verify that Out declarations don't double-publish if capitan has multiple listeners on same signal
- Test that mesh works with zero In declarations (publish-only process) and zero Out declarations (consume-only process)

## Out of Scope

- Only supporting Redis initially is acceptable — additional herald providers can be added later
- No schema validation on serialized messages is by design — herald's codec handles serialization
- No exactly-once delivery guarantees — at-least-once via broker ack semantics is sufficient
