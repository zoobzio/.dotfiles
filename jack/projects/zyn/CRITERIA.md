# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- All eight synapse types correctly construct pipz pipelines with terminal provider call
- JSON schema generated from Go types matches sentinel metadata
- Response parsing validates JSON structure and calls T.Validate()
- Session updated transactionally — only after successful execution
- Reliability options (retry, backoff, timeout, circuit breaker, rate limit) correctly wrap the pipeline
- Provider interface is minimal — single Call method with messages and temperature
- Capitan signals fire for all lifecycle events

### What This Repo MUST NOT Contain

- LLM provider implementations (API clients)
- Prompt template logic beyond the Prompt struct
- Token counting or context window management
- Mutable synapse state after construction

## Review Priorities

1. Response validation: LLM output must be parsed and validated — no raw string returns
2. Session transactionality: session must not be modified on failure
3. Pipeline correctness: reliability options must compose correctly via pipz
4. Schema accuracy: generated JSON schema must match Go type structure exactly
5. Thread safety: Session must be safe for concurrent access
6. Temperature handling: 0 must be treated as unset, TemperatureZero as actual zero

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Unvalidated LLM response reaches caller | Critical |
| Session modified on failed execution | Critical |
| JSON schema doesn't match Go type | High |
| Reliability option silently ignored | High |
| Temperature 0 treated as actual zero | High |
| Synapse mutation after construction | High |
| Capitan signal missing for lifecycle event | Medium |
| MockProvider doesn't match real provider behavior | Medium |
| Prompt.Validate() misses required field | Medium |
| Missing test for a synapse type | Medium |

## Standing Concerns

- JSON schema generation via sentinel must handle all Go types including nested structs, slices, maps, pointers
- Session mutex must not be held during provider calls (long-running)
- SynapseRequest is modified by the pipeline — verify no retained references
- MockProvider pattern matching must be deterministic for tests
- Fallback option creates a second pipeline — verify cleanup on Close

## Out of Scope

- No provider implementations is intentional — Provider interface is the contract
- No streaming is by design — synapses return complete structured responses
- Temperature 0 semantics are intentional — Go zero-value ergonomics
- Synapses created per-task, not per-request — construction builds the pipeline
