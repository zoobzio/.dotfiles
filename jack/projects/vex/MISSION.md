# Mission: vex

Type-safe embedding vector generation with provider-agnostic reliability.

## Purpose

Provide embedding vector generation across multiple LLM providers with built-in reliability patterns via pipz. A Service wraps a Provider with optional chunking, pooling, normalization, and reliability middleware.

Vex exists because embedding generation requires provider abstraction, text chunking for long inputs, vector normalization, and production reliability — concerns that shouldn't be reimplemented per provider.

## What This Package Contains

- `Vector` type ([]float32) with similarity/distance methods (cosine, dot product, euclidean)
- `Provider` interface for embedding APIs (Embed, Name, Dimensions)
- `QueryProviderFactory` for providers that distinguish query vs document embeddings
- `Service` wrapping Provider with chunking, pooling, normalization, and reliability
- Text chunking strategies: none, sentence, paragraph, fixed-size with overlap
- Vector pooling modes: mean, first, max
- L2 normalization (enabled by default)
- Provider implementations: OpenAI, Cohere, Gemini, Voyage
- Reliability options via pipz: retry, backoff, timeout, circuit breaker, rate limiter, fallback
- Capitan signals for embedding lifecycle observability

## What This Package Does NOT Contain

- Vector storage or search
- Similarity search algorithms
- Model training or fine-tuning
- Token counting or context window management

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `pipz` | Reliability pipeline composition |
| `capitan` | Observability signals |

Vex is consumed by applications for embedding generation in search and ML pipelines.

## Success Criteria

A developer can:
1. Generate embeddings from any supported provider with a unified API
2. Switch providers without changing application code
3. Handle long text with automatic chunking and vector pooling
4. Distinguish query vs document embeddings when the provider supports it
5. Add reliability (retry, timeout, circuit breaker) without changing embedding logic
6. Compare vectors with similarity and distance metrics
