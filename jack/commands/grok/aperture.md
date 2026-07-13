# Aperture

Deep understanding of `github.com/zoobzio/aperture` — config-driven bridge from capitan events to OpenTelemetry observability signals.

## Core Concepts

Aperture transforms capitan event coordination into OpenTelemetry observability. Define domain events once in capitan, configure observability separately in YAML/JSON. Change what's observed without recompiling.

- **Aperture** observes all capitan events and converts them to OTEL signals
- **Schema** is the serializable configuration (YAML/JSON) that drives conversion
- **Logs** — all events logged by default (configurable whitelist)
- **Metrics** — configured signals become counters, gauges, histograms, or up/down counters
- **Traces** — signal pairs automatically correlated into spans via correlation keys

**Dependencies:** `capitan` (event source), `go.opentelemetry.io/otel` (traces, metrics, logs SDKs), OTLP HTTP exporters, `yaml.v3`

## Public API

### Constructor

```go
func New(
    c *capitan.Capitan,
    logProvider log.LoggerProvider,
    meterProvider metric.MeterProvider,
    traceProvider trace.TracerProvider,
) (*Aperture, error)
```

All four parameters required. Returns error if any is nil.

### Methods

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `RegisterContextKey` | `RegisterContextKey(name string, key any)` | Register context key for extraction. Must be called before Apply(). |
| `Logger` | `Logger(name string) log.Logger` | OTEL logger for scope |
| `Meter` | `Meter(name string) metric.Meter` | OTEL meter for scope |
| `Tracer` | `Tracer(name string) trace.Tracer` | OTEL tracer for scope |
| `Apply` | `Apply(schema Schema) error` | Update config atomically. Drains old observer, creates new one. Thread-safe. No events lost. |
| `Close` | `Close()` | Stop observing. Does NOT shutdown OTEL providers (caller responsibility). |

## Configuration

### Schema

```go
type Schema struct {
    Metrics []MetricSchema
    Traces  []TraceSchema
    Logs    *LogSchema
    Context *ContextSchema
    Stdout  bool
}
```

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `LoadSchemaFromYAML` | `LoadSchemaFromYAML(data []byte) (Schema, error)` | Parse YAML config |
| `LoadSchemaFromJSON` | `LoadSchemaFromJSON(data []byte) (Schema, error)` | Parse JSON config |
| `Validate` | `(s Schema) Validate() error` | Check required fields, value_key requirements |

### MetricSchema

```go
type MetricSchema struct {
    Signal      string // Capitan signal name (required)
    Name        string // OTEL metric name (required)
    Type        string // "counter" | "gauge" | "histogram" | "updowncounter" (default: "counter")
    ValueKey    string // Field key for value extraction (required for non-counter types)
    Description string // Optional
}
```

| Type | Behaviour | ValueKey Required |
|------|-----------|-------------------|
| `counter` | Count signal occurrences (int64) | No |
| `gauge` | Record instantaneous value | Yes |
| `histogram` | Record value distribution | Yes |
| `updowncounter` | Increment/decrement by value | Yes |

### TraceSchema

```go
type TraceSchema struct {
    Start          string // Start signal name (required)
    End            string // End signal name (required)
    CorrelationKey string // Field key for correlation (required)
    SpanName       string // Optional (defaults to start signal name)
    SpanTimeout    string // Max wait for end event (default: "5m")
}
```

Spans created when both start and end events arrive with matching correlation value. Timestamp-accurate — uses event timestamps, not wall-clock time.

### LogSchema

```go
type LogSchema struct {
    Whitelist []string // Signal names to log (empty = log all)
}
```

### ContextSchema

```go
type ContextSchema struct {
    Logs    []string // Context key names for log attributes
    Metrics []string // Context key names for metric dimensions
    Traces  []string // Context key names for span attributes
}
```

**Warning:** High-cardinality context values in metrics significantly increase storage costs.

## Severity Mapping

| Capitan | OTEL |
|---------|------|
| `SeverityDebug` | `log.SeverityDebug` |
| `SeverityInfo` | `log.SeverityInfo` |
| `SeverityWarn` | `log.SeverityWarn` |
| `SeverityError` | `log.SeverityError` |

## Numeric Value Handling

Metrics extract numeric values from capitan event fields:

| Go Type | OTEL Type |
|---------|-----------|
| `int`, `int32`, `int64`, `uint`, `uint32`, `uint64` | int64 (with overflow protection) |
| `float32`, `float64` | float64 |
| `time.Duration` | float64 milliseconds |

Both int64 and float64 instrument variants created proactively to handle any numeric type at runtime.

## Diagnostic Signals

Internal aperture diagnostics emit as capitan events at DEBUG level:

| Signal | Name | Meaning |
|--------|------|---------|
| `SignalTraceExpired` | `aperture:trace:expired` | Pending span timed out without matching start/end |
| `SignalMetricValueMissing` | `aperture:metric:value_missing` | Metric event lacks required value field |
| `SignalTraceCorrelationMissing` | `aperture:trace:correlation_missing` | Trace event missing correlation ID field |

Diagnostics use a separate internal capitan instance to avoid recursion.

## Provider Helper

```go
type Providers struct {
    Log   *sdklog.LoggerProvider
    Meter *sdkmetric.MeterProvider
    Trace *sdktrace.TracerProvider
}

func (p *Providers) Shutdown(ctx context.Context) error
```

Gracefully shuts down all providers in order: trace → meter → log. Flushes pending telemetry.

## Thread Safety

- `sync.RWMutex` protects configuration
- All public methods are concurrent-safe
- `Apply()` drains old observer before switching — atomic transition, no events lost
- Trace handler uses `sync.Mutex` for pending span map
- Cleanup goroutine runs every 1 minute for expired pending spans

## Test Helpers

`aperture/testing/helpers.go`:

| Helper | Purpose |
|--------|---------|
| `TestProviders(ctx, serviceName, version, endpoint)` | Create OTEL providers for testing |
| `MockLoggerProvider` / `MockLogger` | In-memory log capture |
| `LogCapture` | Thread-safe log record collection. `Records()`, `Count()`, `WaitForCount()`. |
| `EventCapture` | Thread-safe capitan event collection. `Events()`, `Count()`, `WaitForCount()`. |

## File Layout

```
aperture/
├── api.go          # Aperture type, constructor, public methods
├── capitan.go      # capitanObserver, event handling pipeline
├── config.go       # Internal config types, MetricType constants
├── schema.go       # Schema types, YAML/JSON loaders, validation
├── metrics.go      # Metrics handler, instrument creation, value extraction
├── traces.go       # Traces handler, correlation, pending span management
├── transform.go    # Field-to-attribute transformation
├── internal.go     # Diagnostic signal system
├── stdout.go       # Human-readable stdout logging via slog
├── providers.go    # Provider lifecycle helper
└── testing/
    ├── helpers.go
    ├── integration/
    └── benchmarks/
```

## Common Patterns

**Basic Setup:**

```go
a, _ := aperture.New(capitan.Default(), logProvider, meterProvider, traceProvider)
schema, _ := aperture.LoadSchemaFromYAML(configBytes)
a.Apply(schema)
defer a.Close()
```

**YAML Configuration:**

```yaml
metrics:
  - signal: "order.created"
    name: "orders_total"
    type: counter
  - signal: "request.duration"
    name: "request_duration_ms"
    type: histogram
    value_key: "duration_ms"

traces:
  - start: "request.started"
    end: "request.completed"
    correlation_key: "request_id"
    span_name: "http.request"

logs:
  whitelist:
    - "order.created"
    - "order.failed"

context:
  logs: ["tenant_id", "user_id"]
  metrics: ["service"]
  traces: ["tenant_id"]
```

**Hot Reload:**

```go
newSchema, _ := aperture.LoadSchemaFromYAML(newConfigBytes)
a.Apply(newSchema) // Atomic transition, no events lost
```

## Anti-Patterns

- **High-cardinality context keys in metrics** — creates massive metric series. Use for logs/traces, not metrics.
- **Forgetting to call Close()** — observer keeps processing events after intended shutdown.
- **Shutting down OTEL providers before Close()** — lose in-flight events. Close aperture first, then providers.
- **Overlapping trace configs for same signal** — ambiguous correlation. One trace config per signal pair.

## Ecosystem

Aperture depends on:
- **capitan** — event source (observes all events)
- **OpenTelemetry** — traces, metrics, logs SDKs and OTLP exporters

Aperture is consumed by applications needing observability from capitan events.
