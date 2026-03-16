# Mission: herald

Bidirectional bridge between capitan events and distributed message brokers.

## Purpose

Enable seamless event flow across service boundaries. Internal capitan events publish to external brokers, and external messages consume into internal capitan events. One signal + one key + one provider = unified event contract with composable reliability via pipz.

Herald exists because cross-service event distribution requires broker abstraction, typed serialization, acknowledgment handling, and reliability patterns — concerns that shouldn't be reimplemented per broker.

## What This Package Contains

- Publisher[T] observing capitan signals and publishing to message brokers
- Subscriber[T] consuming from brokers and emitting capitan events
- Provider interface abstracting all broker operations (Publish, Subscribe, Ping, Close)
- Envelope[T] wrapping typed values with metadata for pipeline processing
- Codec interface with JSON default for message serialization
- Ack/Nack semantics — success → Ack, any failure → Nack
- Reliability options via pipz: retry, backoff, timeout, circuit breaker, rate limiter, fallback
- Middleware processors: transform, apply, effect, mutate, enrich, filter
- Error signal for operational errors with structured Error type
- Metadata propagation from broker headers to capitan events
- 11 provider implementations across broker, storage, and utility categories

## What This Package Does NOT Contain

- Message routing or topic management
- Schema registry integration
- Dead letter queue management (ago handles this)
- Message ordering guarantees beyond what the broker provides

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `capitan` | Event coordination — observes and emits events |
| `pipz` | Pipeline composition for reliability middleware |

Herald is consumed by:
- `ago` — workflow orchestration publishes to brokers via herald
- Applications needing cross-service event distribution

## Provider Implementations

### Brokers
Kafka, NATS Core, NATS JetStream, Google Pub/Sub, Redis Streams, AWS SQS, RabbitMQ/AMQP, AWS SNS (publish-only)

### Storage
BoltDB (embedded), Google Firestore (cloud persistence)

### Utility
io.Reader/Writer (testing, CLI piping, files)

## Design Constraints

- A node must be either publisher OR subscriber for a given signal (prevents loops)
- All providers follow same constructor pattern: New(topic/subject/queue, opts...)
- SNS is publish-only — no subscribe capability
- NATS Core is fire-and-forget — no ack semantics
- Custom codecs supported for Protobuf, MessagePack, Avro, etc.

## Success Criteria

A developer can:
1. Publish internal capitan events to any supported broker with one setup
2. Subscribe from any broker and receive typed capitan events
3. Add reliability patterns (retry, circuit breaker) without changing event logic
4. Use custom serialization codecs for performance or compatibility
5. Access broker metadata (headers, attributes) from consumed events
6. Switch between brokers by changing the provider, not the application code

## Non-Goals

- Message routing or fan-out logic
- Schema evolution or registry integration
- Guaranteed ordering across partitions
- Dead letter queue management
