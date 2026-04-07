# Mission: ergo

Declarative event mesh over capitan signals and herald transport.

## Purpose

Make distributed event flow invisible. ergo is to capitan signals what rocco is to HTTP routes — the application author declares what goes out and what comes in, attaches handlers via standard capitan hooks, and ergo handles the transport transparently.

ergo exists because wiring herald publishers and subscribers is repetitive, error-prone, and scatters event topology across process main files. The same domain event publisher gets copy-pasted verbatim across four processes. ergo eliminates this by making the distributed event layer declarative.

## What This Package Contains

- Mesh — the event router, analogous to rocco's Engine. Holds all In/Out declarations, manages lifecycle.
- Out — declares that a local capitan signal should be published to an external stream. Application code continues to use `capitan.Emit` as normal. ergo observes and publishes transparently.
- In — declares that an external stream should be consumed and emitted as a local capitan signal. Handler code uses standard `capitan.Hook`. It doesn't know the event arrived from an external service.
- Unified lifecycle — `Start(ctx)` activates all publishers/subscribers, `Close()` tears them down. No per-channel lifecycle management.
- Delivery semantics inferred from configuration — stream with consumer group = durable, pubsub = fan-out broadcast.
- Reliability options per channel — retry, backoff, circuit breaker, rate limit.
- Topology catalog — generates a map of all signal flow across the system for documentation and security review.
- Capitan signals for mesh lifecycle — publish/subscribe events for observability via aperture.

## What This Package Does NOT Contain

- Message broker implementations — that's herald's job
- In-process event coordination — that's capitan's job
- Business logic or handler registration — handlers are capitan hooks
- Service registry integration — ergo is a router, not a service
- Message routing or fan-out logic — ergo declares topology, herald handles delivery

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `capitan` | Event bus — ergo observes and emits capitan signals |
| `herald` | Transport layer — ergo uses herald publishers/subscribers internally |

ergo is consumed by:
- Applications needing cross-process event distribution without herald boilerplate
- sum applications where distributed signals should be as easy as local signals

## Design Constraints

- Application code never imports herald — ergo is the only consumer
- Handlers are capitan hooks — no ergo-specific handler interface
- A signal is either In or Out per process, never both (prevents loops)
- The mesh takes a broker connection at construction, not per-channel
- Serialization defaults to JSON, configurable per-channel
- Consumer group and consumer ID configuration belongs on In declarations

## Success Criteria

A developer can:
1. Declare outbound signals with `Out` and have them publish automatically when emitted via capitan
2. Declare inbound signals with `In` and handle them with standard `capitan.Hook` — no awareness of transport
3. Start and stop all publishers/subscribers with a single `Start`/`Close` call
4. Configure reliability (retry, backoff) per channel without touching handler code
5. Generate a topology catalog showing all signal flow across the system
6. Swap transport (Redis Streams → Kafka) by changing mesh configuration, not handlers

## Non-Goals

- Replacing capitan for in-process events
- Replacing herald for broker abstraction
- Schema evolution or registry integration
- Message ordering guarantees beyond what the broker provides
- Dead letter queue management
