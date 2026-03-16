# Mission: pipz

Type-safe, composable data processing pipeline framework for Go.

## Purpose

Provide a pipeline framework built around a single universal interface — `Chainable[T]` — where processors do work and connectors control flow. Pipz exists because data processing requires composable building blocks for sequencing, parallelism, routing, error handling, and resilience that maintain compile-time type safety through Go generics.

## What This Package Contains

- Universal `Chainable[T]` interface: Process, Identity, Schema, Close
- Processors (leaf nodes): Transform, Apply, Effect, Mutate, Enrich — wrapping user functions with panic recovery
- Sequential connectors: Sequence (fail-fast chain), Pipeline (execution context wrapper)
- Parallel connectors: Concurrent (fan-out/aggregate), Scaffold (fire-and-forget), Race (first-wins), Contest (condition-wins), WorkerPool (bounded parallelism)
- Conditional connectors: Switch (multi-way routing), Filter (process-or-skip)
- Error handling: Error[T] with full pipeline path, Handle (error observation), Fallback (try alternatives)
- Resilience: Retry, Backoff (exponential), CircuitBreaker (three-state), Timeout, RateLimiter (token bucket)
- Schema introspection: typed Node/Flow DAG with Walk, Find, Count
- Capitan signals for all connectors (observability without coupling)
- Cloner constraint for safe parallel dispatch with deep copy

## What This Package Does NOT Contain

- Data source or sink implementations — pipz is a processing framework
- Serialization or wire format handling
- Scheduling or cron-like triggering
- Distributed pipeline execution across processes

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `capitan` | Signal emission for all connectors |
| `clockz` | Testable time for backoff, timeout, circuit breaker, rate limiter |

| Consumer | Role |
|----------|------|
| `zyn` | LLM request processing pipelines |
| `herald` | Message broker publish/subscribe pipelines |
| `ago` | Workflow step execution |
| `flume` | Dynamic pipeline factory |
| `flux` | Reliability options for configuration processing |

## Design Constraints

- Two-tier architecture: processors do work, connectors control flow — both implement Chainable[T]
- Parallel connectors require Cloner[T] — user responsible for correct deep copy
- Stateful connectors (CircuitBreaker, RateLimiter) must be created once and reused
- Close follows LIFO order — child processors closed in reverse order
- No reflection or runtime type assertions — generics-native throughout

## Success Criteria

A developer can:
1. Build sequential pipelines with type-safe processor chains
2. Fan out to parallel processors with result aggregation
3. Route data conditionally based on content
4. Add retry, backoff, circuit breaker, timeout, and rate limiting without changing business logic
5. Handle errors with observation and fallback alternatives
6. Introspect pipeline structure via Schema for debugging and documentation
7. Test pipelines deterministically with injectable clocks

## Non-Goals

- Data source/sink management
- Distributed pipeline execution
- Pipeline persistence or checkpointing
- Dynamic pipeline modification during processing (Sequence modification is between-processing)
- Automatic parallelism detection — developer chooses sequential vs parallel explicitly
