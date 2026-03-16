# Mission: flux

Reactive configuration synchronization with validation and rollback.

## Purpose

Provide live configuration reloading that watches sources for changes, validates new configuration, applies it through a composable reliability pipeline, and rolls back to the last known-good state on failure. Flux exists because applications need to react to configuration changes at runtime without restarts, and doing so safely requires validation, debouncing, state tracking, and failure handling as first-class concerns.

## What This Package Contains

- `Capacitor[T]` — watches a single source, validates, and applies configuration changes
- `CompositeCapacitor[T]` — merges multiple sources via a `Reducer` function
- State machine tracking configuration health (Loading → Healthy/Empty/Degraded)
- Automatic rollback to last valid configuration when changes fail validation or application
- Debounced change processing to coalesce rapid updates
- Composable reliability via pipz: retry, backoff, timeout, circuit breaker, fallback
- Middleware pipeline for transform, enrichment, filtering, and rate limiting
- Built-in JSON and YAML codecs with pluggable codec interface
- Watcher interface for custom source implementations
- Capitan signals for observability of all state transitions and failures
- Test utilities: ChannelWatcher, SyncMode, injectable Clock

## What This Package Does NOT Contain

- Configuration file parsing or format-specific logic beyond codec unmarshal
- Source implementations (file watchers, HTTP pollers, etc.) — consumers provide Watcher implementations
- Configuration schema definition — types must implement the Validator interface
- Persistent storage of configuration versions or history
- Distributed configuration consensus

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `pipz` | Reliability pipeline composition (retry, backoff, circuit breaker) |
| `capitan` | Observability signals for state changes and failures |
| `clockz` | Testable time for deterministic debounce and timeout testing |

Flux is consumed by applications that need live configuration reloading with safety guarantees.

## Design Constraints

- Configuration types must implement `Validator` — no unvalidated config can enter the system
- Watchers must emit current value immediately on `Watch()` — initial load is synchronous
- State machine is atomic — lock-free reads via `sync/atomic`
- Single-start enforcement via mutex — `Start()` can only be called once
- Debounce default of 100ms — configurable but always present

## Success Criteria

A developer can:
1. Watch a configuration source and receive validated updates via a typed callback
2. Merge multiple configuration sources with a custom reducer
3. Query current state, current config, and error history at any time
4. Add retry, backoff, circuit breaker, and timeout to the processing pipeline
5. Test configuration flows deterministically with SyncMode and fake clocks
6. Observe all state transitions and failures via capitan signals

## Non-Goals

- Implementing specific source watchers (file, HTTP, etcd, etc.)
- Configuration diffing or partial updates — each change is a full replacement
- Distributed consensus or leader election for shared configuration
- Configuration versioning or rollback to arbitrary previous versions
- Schema migration between configuration versions
