# Mission: aperture

Config-driven OpenTelemetry bridge for capitan events.

## Purpose

Transform capitan event coordination into OpenTelemetry observability signals (logs, metrics, traces) driven entirely by YAML/JSON configuration. Define domain events once in capitan, configure what's observed separately — change observability without recompiling.

Aperture exists because wiring capitan events to OpenTelemetry requires repetitive boilerplate per signal. This package makes observability a configuration concern, not a code concern.

## What This Package Contains

- Aperture type observing all capitan events and converting to OTEL signals
- Schema configuration (YAML/JSON) driving log, metric, and trace conversion
- Metric types: counter, gauge, histogram, up/down counter with automatic value extraction
- Trace spans from signal pairs with correlation key matching and configurable timeout
- Log whitelist filtering (empty = log all)
- Context key extraction for enriching logs, metrics, and traces with request-scoped data
- Severity mapping from capitan to OTEL log severity levels
- Atomic hot-reload via Apply() — no events lost during configuration transitions
- Provider lifecycle helper for graceful OTEL shutdown
- Diagnostic signals for internal aperture issues (expired traces, missing values)
- Stdout mode for human-readable slog output

## What This Package Does NOT Contain

- OpenTelemetry SDK setup or provider creation — caller provides providers
- Custom exporters — uses OTLP HTTP exporters
- Application-level instrumentation — aperture observes capitan events, not code
- Sampling strategies — delegated to OTEL SDK configuration

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `capitan` | Event source — observes all emitted events |
| `OpenTelemetry` | Traces, metrics, logs SDKs and OTLP exporters |

Aperture is consumed by applications needing observability from capitan events.

## Design Constraints

- All four constructor parameters required (capitan, log provider, meter provider, trace provider)
- Apply() is atomic — drains old observer, creates new one, no events lost
- Context keys must be registered before Apply()
- Aperture does NOT shut down OTEL providers — caller responsibility
- Diagnostic signals use a separate internal capitan to avoid recursion
- Both int64 and float64 instrument variants created proactively per metric

## Success Criteria

A developer can:
1. Wire capitan events to OpenTelemetry with zero per-signal code
2. Configure which events become metrics, traces, or logs via YAML/JSON
3. Hot-reload observability configuration without restart or event loss
4. Correlate trace spans across signal pairs using correlation keys
5. Enrich telemetry with request-scoped context values
6. Diagnose aperture issues via dedicated diagnostic signals

## Non-Goals

- Replacing direct OpenTelemetry instrumentation for non-capitan code
- Managing OTEL provider lifecycle (creation, shutdown, flush)
- Implementing custom OTEL exporters
- Sampling or filtering at the OTEL SDK level
