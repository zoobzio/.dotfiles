# Mission: zyn

Typed, composable LLM interactions built on pipz pipelines.

## Purpose

Provide synapses — typed LLM interactions that wrap specific tasks (classification, extraction, binary decision, etc.) with type-safe input/output, structured prompt generation, JSON schema enforcement, and composable reliability. Zyn exists because LLM interactions need structure, type safety, and resilience as first-class concerns rather than ad-hoc string wrangling.

## What This Package Contains

- Eight synapse types: Binary, Classification, Extraction, Transform, Analyze, Convert, Ranking, Sentiment
- Generic `Service[T]` foundation wrapping each synapse's pipz pipeline
- Provider interface abstracting LLM backends (single `Call` method)
- Session for multi-turn conversation context with thread-safe history management
- Structured Prompt type with consistent rendering and validation
- Automatic JSON schema generation from Go types via sentinel
- Composable reliability options: retry, backoff, timeout, circuit breaker, rate limiter, fallback
- Three API levels per synapse: Fire (simple), FireWithDetails (full response), FireWithInput (rich input)
- WithDefaults for default input configuration per synapse instance
- Capitan signals for all lifecycle events (request, provider call, parse, validation)
- MockProvider with pattern-matched responses for testing
- Test helpers: ResponseBuilder, SequencedProvider, FailingProvider, CallRecorder, LatencyProvider

## What This Package Does NOT Contain

- LLM provider implementations (API clients) — consumers implement the Provider interface
- Prompt engineering or template libraries
- Token management or context window optimization
- Conversation state persistence
- Streaming or chunked responses

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `pipz` | Pipeline composition for request processing and reliability |
| `capitan` | Signal emission for observability |
| `sentinel` | Type metadata for JSON schema generation |

Zyn is consumed by applications with AI/LLM integration needs, and by cogito for reasoning primitives.

## Design Constraints

- Response types must implement Validator — no unvalidated LLM output
- Temperature 0 is "unset" — use TemperatureZero (0.0001) for actual zero
- Synapses are immutable after construction — create once, reuse with different sessions
- Session updated transactionally — only after successful execution
- JSON schema enforced on all responses — providers return structured JSON

## Success Criteria

A developer can:
1. Create a typed synapse for any common LLM task pattern
2. Execute with type-safe input and get validated, typed output
3. Compose reliability (retry, timeout, circuit breaker) without touching business logic
4. Maintain multi-turn conversations with session context
5. Test with MockProvider and deterministic response builders
6. Observe all LLM interactions via capitan signals

## Non-Goals

- Implementing specific LLM provider clients
- Prompt engineering frameworks or template systems
- Token counting or context window management
- Streaming responses
- Conversation persistence
