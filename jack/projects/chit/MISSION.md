# Mission: chit

Conversation lifecycle controller for LLM-powered applications.

## Purpose

Manage multi-turn chat interactions by separating conversation lifecycle management from reasoning logic. The Chat controller handles sessions, history, continuation, and reliability — the pluggable Processor handles the brain.

Chit exists because conversational AI applications need structured lifecycle management (history tracking, multi-step workflows, yield/resume, streaming output) that shouldn't be reimplemented in every processor.

## What This Package Contains

- `Chat` controller orchestrating conversation lifecycle with Handle method
- `Processor` interface for pluggable reasoning engines (LLM, agent, tool, anything)
- `Emitter` dual-channel output: streaming text (Message) and structured data (Resource)
- Result types: Response (complete) and Yield (awaiting input with Continuation)
- Continuation functions enabling multi-step workflows without state machines
- Reliability options via pipz: retry, backoff, timeout, circuit breaker, rate limiter
- Middleware pipeline for pre-processing before terminal processor
- Fallback composition with WithFallback(ChatProvider)
- Context injection for emitter access within processors
- Capitan signals for full conversation lifecycle observability
- Test helpers: MockProcessor, MockEmitter, CollectingEmitter

## What This Package Does NOT Contain

- LLM client or provider implementation — Processor interface abstracts that
- Conversation persistence or storage
- UI rendering or transport (WebSocket, SSE, etc.)
- Message formatting or template logic

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `pipz` | Reliability patterns (retry, timeout, circuit breaker) |
| `capitan` | Lifecycle observability |

Chit is consumed by applications for conversational AI interfaces.

## Design Constraints

- Chat uses sync.Mutex — Handle calls are serialized per Chat instance
- Continuations run through the same reliability pipeline as fresh processor calls
- Emitter injected into context before processor call — processors access via EmitterFromContext
- History snapshot taken before processor call — processor sees immutable view

## Success Criteria

A developer can:
1. Create a chat controller with any Processor implementation
2. Handle multi-turn conversations with automatic history management
3. Implement multi-step workflows with Yield/Continuation without state machines
4. Stream text and push structured resources through the Emitter
5. Add reliability (retry, timeout, fallback) without changing processor logic
6. Observe full conversation lifecycle via capitan signals

## Non-Goals

- LLM provider implementation
- Conversation persistence
- Transport layer (WebSocket, SSE, HTTP)
- Concurrent Handle calls on the same Chat (use separate instances)
