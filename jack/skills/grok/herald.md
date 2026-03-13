# Herald

Deep understanding of `github.com/zoobzio/herald` — bidirectional bridge between capitan events and distributed message brokers.

## Core Concepts

Herald enables seamless event flow across service boundaries. Internal capitan events can be published to external brokers, and external messages can be consumed and emitted as internal events.

- **Publisher[T]** observes a capitan signal and publishes to a broker
- **Subscriber[T]** consumes from a broker and emits capitan events
- **Provider** is the broker abstraction (one interface, eleven implementations)
- **Envelope[T]** wraps a typed value with metadata for pipeline processing
- **Options** compose pipz reliability patterns onto the publish/subscribe pipeline

One signal + one key + one provider = unified event contract. A node should be either publisher OR subscriber for a given signal (prevents loops).

**Dependencies:** `capitan` (event coordination), `pipz` (pipeline composition)

## Public API

### Provider Interface

```go
type Provider interface {
    Publish(ctx context.Context, data []byte, metadata Metadata) error
    Subscribe(ctx context.Context) <-chan Result[Message]
    Ping(ctx context.Context) error
    Close() error
}
```

### Core Types

```go
type Metadata map[string]string

type Envelope[T any] struct {
    Value    T
    Metadata Metadata
}

type Message struct {
    Data     []byte
    Metadata Metadata
    Ack      func() error
    Nack     func() error
}

type Result[T any] struct { /* value T, err error */ }
// NewSuccess[T](value T), NewError[T](err error)
// IsError(), IsSuccess(), Value(), Error()
```

### Codec

```go
type Codec interface {
    Marshal(v any) ([]byte, error)
    Unmarshal(data []byte, v any) error
    ContentType() string
}
```

`JSONCodec` is the default. Custom codecs for Protobuf, MessagePack, Avro, etc.

### Publisher[T]

```go
func NewPublisher[T any](
    provider Provider,
    signal capitan.Signal,
    key capitan.GenericKey[T],
    pipelineOpts []Option[T],
    opts ...PublisherOption[T],
) *Publisher[T]
```

| Method | Behaviour |
|--------|-----------|
| `Start()` | Register capitan observer, begin publishing |
| `Close()` | Stop observer, wait for in-flight publishes |

**Options:** `WithPublisherCapitan[T](c)`, `WithPublisherCodec[T](c)`

### Subscriber[T]

```go
func NewSubscriber[T any](
    provider Provider,
    signal capitan.Signal,
    key capitan.GenericKey[T],
    pipelineOpts []Option[T],
    opts ...SubscriberOption[T],
) *Subscriber[T]
```

| Method | Behaviour |
|--------|-----------|
| `Start(ctx)` | Begin consuming; context cancellation stops |
| `Close()` | Cancel context, wait for goroutine |

**Options:** `WithSubscriberCapitan[T](c)`, `WithSubscriberCodec[T](c)`

**Ack Strategy:** Deserialise success + pipeline success → Ack. Any failure → Nack.

### Sentinel Errors

```go
var (
    ErrNoWriter = errors.New("herald: no writer configured for publishing")
    ErrNoReader = errors.New("herald: no reader configured for subscribing")
)
```

### Error Signals

```go
var (
    ErrorSignal = capitan.NewSignal("herald.error", "Herald operational error")
    ErrorKey    = capitan.NewKey[Error]("error", "herald.Error")
    MetadataKey = capitan.NewKey[Metadata]("metadata", "herald.Metadata")
)
```

All operational errors emit on `ErrorSignal`. Subscribers also emit `MetadataKey` with broker headers.

### Error Type

```go
type Error struct {
    Operation string  // "publish", "subscribe", "unmarshal"
    Signal    string
    Err       string
    Nack      bool    // True if message was nack'd
    Raw       []byte  // Original bytes (unmarshal errors)
}
```

## Pipeline Options

```go
type Option[T any] func(pipz.Chainable[*Envelope[T]]) pipz.Chainable[*Envelope[T]]
```

### Reliability (Whole Pipeline)

| Option | Behaviour |
|--------|-----------|
| `WithRetry[T](maxAttempts)` | Immediate retries |
| `WithBackoff[T](maxAttempts, baseDelay)` | Exponential backoff |
| `WithTimeout[T](duration)` | Operation deadline |
| `WithCircuitBreaker[T](failures, recovery)` | Stop after N failures |
| `WithRateLimit[T](rate, burst)` | Token bucket |
| `WithErrorHandler[T](handler)` | Custom error handling |
| `WithFallback[T](fallbacks...)` | Fallback alternatives |
| `WithPipeline[T](custom)` | Full pipeline replacement |
| `WithFilter[T](identity, condition)` | Conditional pipeline skip |
| `WithMiddleware[T](processors...)` | Sequence before terminal |

### Middleware Processors

| Function | Behaviour |
|----------|-----------|
| `UseTransform[T]` | Pure transformation |
| `UseApply[T]` | Transform with error |
| `UseEffect[T]` | Side effect (passthrough) |
| `UseMutate[T]` | Conditional transform |
| `UseEnrich[T]` | Best-effort enhancement |
| `UseRetry[T]` | Wrap processor with retries |
| `UseBackoff[T]` | Processor with backoff |
| `UseTimeout[T]` | Processor deadline |
| `UseFallback[T]` | Processor fallback chain |
| `UseFilter[T]` | Conditional processor |
| `UseRateLimit[T]` | Rate-limited processor |

## Provider Implementations

### Broker Providers

| Provider | Package | Ack Model | Metadata |
|----------|---------|-----------|----------|
| **Kafka** | `kafka/` | Commit offset | Headers |
| **NATS Core** | `nats/` | No-op (fire-and-forget) | Not supported |
| **NATS JetStream** | `jetstream/` | `msg.Ack()` / `msg.Nak()` | Headers |
| **Google Pub/Sub** | `pubsub/` | `msg.Ack()` / `msg.Nack()` | Attributes |
| **Redis Streams** | `redis/` | `XAck` (consumer groups) | Stream fields |
| **AWS SQS** | `sqs/` | DeleteMessage | Message attributes |
| **RabbitMQ/AMQP** | `amqp/` | `delivery.Ack()` / `delivery.Nack()` with requeue | Headers |
| **AWS SNS** | `sns/` | Publish-only (no subscribe) | Message attributes |

### Storage Providers

| Provider | Package | Ack Model | Use Case |
|----------|---------|-----------|----------|
| **BoltDB** | `bolt/` | Delete key | Embedded, single-process |
| **Firestore** | `firestore/` | Delete document | Cloud persistence |

### Utility Providers

| Provider | Package | Ack Model | Use Case |
|----------|---------|-----------|----------|
| **io.Reader/Writer** | `io/` | No-op | Testing, CLI piping, files |

Each provider follows the same constructor pattern: `New(topic/subject/queue, opts...)` with broker-specific options.

## Thread Safety

- **Publisher:** `sync.WaitGroup` for in-flight tracking
- **Subscriber:** Goroutine per subscription with context cancellation
- **io Provider:** Mutex-protected writer access

## Test Helpers

`herald/testing/helpers.go`:

| Helper | Purpose |
|--------|---------|
| `MockProvider` | Thread-safe mock with publish tracking and callbacks |
| `NewTestMessage` | Create message with no-op ack/nack |
| `NewTestMessageWithAck` | Create message with tracking callbacks |
| `MessageCapture` | Thread-safe message collection. `WaitForCount()`. |
| `ErrorCapture` | Thread-safe error collection. `WaitForCount()`. |

## File Layout

```
herald/
├── api.go          # Types: Metadata, Envelope, Message, Result, Error, Provider interface
├── codec.go        # Codec interface, JSONCodec
├── options.go      # Reliability options
├── processing.go   # Middleware processors
├── publisher.go    # Publisher[T]
├── subscriber.go   # Subscriber[T]
├── kafka/          # Kafka provider
├── nats/           # NATS Core provider
├── jetstream/      # NATS JetStream provider
├── pubsub/         # Google Pub/Sub provider
├── redis/          # Redis Streams provider
├── sqs/            # AWS SQS provider
├── amqp/           # RabbitMQ/AMQP provider
├── sns/            # AWS SNS provider (publish-only)
├── bolt/           # BoltDB provider
├── firestore/      # Google Firestore provider
├── io/             # io.Reader/Writer provider
└── testing/        # Test helpers
```

## Common Patterns

**Publish Internal Events to Kafka:**

```go
orderKey := capitan.NewKey[Order]("order", "app.Order")
orderCreated := capitan.NewSignal("order.created", "New order")

pub := herald.NewPublisher(kafkaProvider, orderCreated, orderKey, nil)
pub.Start()
defer pub.Close()

capitan.Emit(ctx, orderCreated, orderKey.Field(order)) // Auto-published to Kafka
```

**Subscribe from Broker:**

```go
sub := herald.NewSubscriber(kafkaProvider, orderCreated, orderKey, nil)
sub.Start(ctx)
defer sub.Close()

capitan.Hook(orderCreated, func(ctx context.Context, e *capitan.Event) {
    order, _ := orderKey.From(e)
    metadata, _ := herald.MetadataKey.From(e) // Broker headers
})
```

**With Reliability:**

```go
pub := herald.NewPublisher(provider, signal, key, []herald.Option[Order]{
    herald.WithRetry[Order](3),
    herald.WithCircuitBreaker[Order](5, 30*time.Second),
})
```

## Anti-Patterns

- **Same node publishing AND subscribing for same signal** — creates infinite loops
- **Ignoring Ack/Nack** — message loss or duplicate processing
- **Using NATS Core for reliable delivery** — fire-and-forget model. Use JetStream for ack semantics.
- **SNS for subscribing** — publish-only. Use SQS for consuming.

## Ecosystem

Herald depends on:
- **capitan** — event coordination (observes and emits events)
- **pipz** — pipeline composition for middleware

Herald is consumed by applications needing cross-service event distribution.
