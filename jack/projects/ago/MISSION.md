# Mission: ago

Event-driven workflow orchestration via capitan signals and pipz pipelines.

## Purpose

Bridge capitan event coordination with pipz pipeline composition for distributed workflow orchestration. Enables sagas with automatic compensation, request/response over async events, correlation tracking, and crash recovery — all as composable pipz.Chainable[*Flow[T]] processors.

Ago exists because multi-step workflows across services require saga compensation, correlation tracking, idempotency, and crash recovery — concerns that are error-prone to implement per workflow.

## What This Package Contains

- Flow[T] typed payload with correlation context, accumulated fields, and error tracking
- SagaStep executes a step and registers compensation atomically
- Compensate rolls back completed steps in reverse (LIFO) order with idempotency
- Request/Await provides synchronous RPC semantics over async capitan events
- Emit for fire-and-forget signal emission with correlation propagation
- Enrich/EnrichOptional for external data augmentation
- Publish for message broker integration via herald
- DeadLetter for failure routing with optional broker publishing
- Tag/TagFrom for broker metadata enrichment
- Correlate/CorrelateFrom for correlation ID management
- Store interface with MemoryStore (testing) and CerealStore (PostgreSQL production)
- RecoverSagas for crash recovery of incomplete sagas at startup
- Helper functions wrapping pipz topology (Sequence, Filter, Switch, Gate, etc.)
- Lifecycle signals for flow, saga, request, and dead letter events

## What This Package Does NOT Contain

- Workflow definition DSL or visual designer
- Cron or scheduled triggers
- Long-running process management (process manager pattern)
- Distributed lock management beyond saga state

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `capitan` | Event coordination — signals and keys for workflow steps |
| `pipz` | Pipeline composition — all primitives are Chainable |
| `herald` | Message broker integration for Publish primitive |

Ago is consumed by applications with multi-step workflow orchestration needs.

## Design Constraints

- At-least-once delivery semantics — handlers MUST use IdempotencyKey for exactly-once behavior
- All primitives implement pipz.Chainable[*Flow[T]]
- Flow[T] designed for sequential processing within a pipeline (not cross-goroutine)
- WithSaga provides exclusive transactional access — signal emission happens AFTER lock release
- Compensation is LIFO with per-step idempotency via IsCompensated/MarkCompensated
- IdempotencyKey format: {correlationID}:{stepName} for execute, {correlationID}:compensate:{stepName} for compensation

## Success Criteria

A developer can:
1. Compose multi-step sagas with automatic compensation on failure
2. Use request/response patterns over async events with configurable timeout
3. Track correlation across service boundaries via correlation/causation IDs
4. Recover incomplete sagas after crashes via RecoverSagas at startup
5. Route failed messages to dead letter with full error context
6. Integrate with message brokers via herald's Publish primitive

## Non-Goals

- Visual workflow designer or DSL
- Scheduled or cron-based triggers
- Long-running process manager pattern
- Distributed locking beyond saga state exclusivity
