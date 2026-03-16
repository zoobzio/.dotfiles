# Mission: cogito

Structured reasoning and LLM orchestration via the Thought-Note pattern.

## Purpose

Implement a Thought-Note architecture for building autonomous reasoning systems. A Thought accumulates Notes as reasoning progresses through primitives that read context, call LLM synapses, and store results. All primitives implement `pipz.Chainable[*Thought]` for pipeline composition.

Cogito exists because complex LLM-driven reasoning requires structured context accumulation, semantic routing, iterative refinement, and session management that shouldn't be ad-hoc per application.

## What This Package Contains

- Thought context object with intent, notes, session, trace ID, and clone support
- Note as atomic information unit with key, content, metadata, source
- Reasoning primitives: Decide, Analyze, Categorize, Assess, Prioritize, Reflect
- Control flow primitives: Sift (semantic gate), Discern (semantic router)
- Refinement primitives: Amplify (iterative refinement), Converge (parallel synthesis)
- Session management: Reset, Truncate (sliding window), Compress (LLM summarization)
- Provider interface with three-level resolution (step → context → global)
- Optional introspection (semantic summary after each step)
- Pipeline helpers wrapping pipz connectors for `*Thought`
- Capitan signals for reasoning lifecycle observability

## What This Package Does NOT Contain

- LLM provider implementations — Provider interface only
- Thought persistence or serialization
- UI or chat interface — that's chit's domain
- Tool use or function calling framework

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `zyn` | LLM synapses (Binary, Extract, Classification, Sentiment, Transform, Ranking) |
| `pipz` | Pipeline composition for primitive chaining |
| `capitan` | Observability signals |

Cogito is consumed by applications for autonomous reasoning and LLM orchestration.

## Design Constraints

- All primitives implement `pipz.Chainable[*Thought]` — composable into any pipz pipeline
- Thought is safe for concurrent reads but NOT concurrent writes — use Clone() for parallel processing
- Provider resolution: step-level overrides context, context overrides global
- Notes are append-only within a step — no mutation of existing notes

## Success Criteria

A developer can:
1. Build sequential reasoning chains with typed primitives
2. Route reasoning semantically with Sift (gate) and Discern (router)
3. Refine output iteratively with Amplify
4. Synthesize parallel reasoning branches with Converge
5. Manage session context with Reset, Truncate, and Compress
6. Access structured results from notes with Scan methods

## Non-Goals

- LLM provider implementation
- Thought persistence or serialization
- Chat interface or conversation UI
- Tool use or function calling
- General-purpose workflow engine
