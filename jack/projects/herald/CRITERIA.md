# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Provider interface correctly abstracts all 11 broker implementations
- Publisher observes capitan signals and publishes serialized data with metadata
- Subscriber consumes broker messages, deserializes, and emits capitan events
- Ack on success, Nack on any failure — no silent message loss
- Reliability options compose correctly via pipz without interfering with event flow
- Codec serialization/deserialization is correct and extensible
- Error signal emits structured errors for all operational failures

### What This Repo MUST NOT Contain

- Message routing or topic management logic
- Schema registry integration
- Dead letter queue management
- Ordering guarantees beyond broker capabilities

## Review Priorities

1. Ack/Nack correctness: message acknowledgment must match success/failure exactly
2. Provider contract: all implementations must satisfy the Provider interface completely
3. Serialization: codec round-trip must preserve all data without corruption
4. Loop prevention: same node publishing AND subscribing for same signal must be documented/prevented
5. Reliability composition: pipz options must not corrupt envelopes or lose metadata
6. Error propagation: all operational errors must emit on ErrorSignal with structured context

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Message acked but processing failed | Critical |
| Message lost (neither acked nor nacked) | Critical |
| Serialization corrupts data | Critical |
| Provider implementation violates interface contract | High |
| Same-signal publish+subscribe creates infinite loop | High |
| Metadata lost during publish or consume | High |
| Reliability option interferes with envelope data | Medium |
| Error signal missing structured context | Medium |
| Provider-specific option leaks into generic API | Low |

## Standing Concerns

- SNS is publish-only — verify Subscribe returns clear error
- NATS Core has no ack semantics — verify documentation is clear about fire-and-forget
- WaitGroup tracking in Publisher — verify Close() waits for all in-flight publishes
- Subscriber goroutine cleanup — verify context cancellation stops consumption cleanly

## Out of Scope

- 11 provider implementations in submodules is intentional — import only what you need
- JSONCodec as default is intentional — custom codecs are opt-in
- No message ordering guarantees is by design — broker-dependent
