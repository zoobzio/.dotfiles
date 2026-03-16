# Mission: capitan

Type-safe event coordination for Go with zero dependencies.

## Purpose

Provide an asynchronous event routing system that decouples event emission from event handling. Capitan gives every package in the ecosystem a shared language for signaling state changes, errors, and lifecycle events without coupling producers to consumers.

Capitan exists because cross-cutting concerns like logging, auditing, metrics, and workflow triggers all need to react to the same events. Without a typed, centralized event system, every integration becomes point-to-point wiring.

## What This Package Contains

- Signals that identify event types with name and description
- Typed keys that bind field names to specific types at compile time
- Asynchronous per-signal worker goroutines with configurable backpressure
- Listeners that subscribe to individual signals
- Observers that subscribe to multiple signals for cross-cutting concerns
- Event replay for re-emitting historical events synchronously
- Severity levels (Debug, Info, Warn, Error) with configurable filtering
- Per-signal configuration: buffer size, rate limiting, drop policy, max listeners
- Glob-based configuration matching for signal groups
- Sync mode for deterministic testing
- Event pooling via sync.Pool for zero-allocation steady state
- Comprehensive test helpers: EventCapture, EventCounter, PanicRecorder, StatsWaiter

## What This Package Does NOT Contain

- Persistent event storage — capitan is in-memory only
- Network transport or distributed event routing
- Event schemas or contracts beyond typed keys
- Guaranteed delivery — events can be dropped by policy, rate limit, or cancellation
- Ordering guarantees across different signals

## Ecosystem Position

Capitan is a foundation package with zero dependencies, consumed by the entire ecosystem:

| Consumer | Role |
|----------|------|
| `pipz` | Emits signals for retry, timeout, circuit breaker events |
| `aperture` | Observes events, exports OpenTelemetry traces/metrics/logs |
| `herald` | Bridges events to/from message brokers (Kafka, NATS, SQS) |
| `ago` | Coordinates workflows via capitan signals |
| `rocco` | HTTP lifecycle signals |
| `soy` | Query execution signals |
| `flux` | Configuration state change signals |
| `sum` | Re-exports typed event API for applications |

## Design Constraints

- Zero production dependencies — stdlib only, no exceptions
- Per-signal worker isolation — slow listeners on one signal cannot affect others
- Events are pooled and recycled — consumers must Clone() to retain
- Signals must be defined at package level — dynamic signal creation is prohibited
- Sync mode is testing-only — production must use async workers
- Configure before first use — options cannot be changed after the default instance is created

## Success Criteria

A developer can:
1. Define typed signals and keys at package level with compile-time safety
2. Emit events with typed fields and have them routed to registered listeners
3. Observe all signals (or a whitelist) for cross-cutting concerns like logging
4. Configure per-signal buffer sizes, rate limits, and severity filters
5. Replay historical events synchronously with replay guards on side effects
6. Test event flows deterministically with sync mode and test helpers
7. Shut down gracefully with all queued events drained

## Non-Goals

- Persistent event log or event sourcing
- Distributed event routing across processes or machines
- Schema registry or event contract validation
- Guaranteed delivery — capitan is best-effort with configurable policies
- Cross-signal ordering guarantees
