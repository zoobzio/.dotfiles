# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- SagaStep registers compensation atomically with step execution
- Compensate rolls back in LIFO order with idempotency per step
- WithSaga provides exclusive access — no concurrent mutations to same saga
- Signal emission happens AFTER WithSaga returns (outside lock)
- Request/Await correctly correlate responses by correlation ID
- RecoverSagas finds and compensates running/compensating/expired sagas
- All primitives implement pipz.Chainable[*Flow[T]] correctly
- IdempotencyKey format is consistent for execute and compensation

### What This Repo MUST NOT Contain

- Workflow definition DSL or visual designer
- Cron or scheduled triggers
- Long-running process management
- Distributed lock management beyond saga state

## Review Priorities

1. Saga correctness: compensation must run all steps in LIFO order without skipping
2. Idempotency: duplicate step execution must not corrupt state
3. Crash recovery: RecoverSagas must handle all incomplete states (running, compensating, expired)
4. Correlation: request/await must match responses by correlation ID without cross-talk
5. Exclusivity: WithSaga must prevent concurrent mutations to same saga
6. Signal ordering: emission must happen after state persistence, not before

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Compensation skips a step | Critical |
| Duplicate execution corrupts saga state | Critical |
| Signal emitted before state persisted | Critical |
| WithSaga allows concurrent mutation | Critical |
| RecoverSagas misses incomplete saga | High |
| Request/Await matches wrong correlation | High |
| Dead letter loses error context | High |
| Flow field access races under concurrent use | Medium |
| Timeout default not documented | Low |

## Standing Concerns

- At-least-once delivery means handlers MUST deduplicate — verify IdempotencyKey is always available
- MemoryStore uses deep copies — verify no mutation of returned state
- CerealStore uses SELECT FOR UPDATE — verify deadlock potential with multiple sagas
- Flow[T] RWMutex on field map — verify no deadlock in nested field access
- RecoverSagas must be called at startup — verify documentation is prominent

## Out of Scope

- At-least-once (not exactly-once) delivery is by design — handlers own deduplication
- Flow[T] not safe for cross-goroutine use is intentional — sequential pipeline processing
- sqlx dependency for CerealStore is intentional for PostgreSQL production use
- MemoryStore for testing only is intentional
