# Vex

Deep understanding of `github.com/zoobzio/vex` — type-safe embedding vector generation with provider-agnostic reliability.

## Core Concepts

Vex provides embedding vector generation across multiple LLM providers with built-in reliability patterns via pipz. A `Service` wraps a `Provider` with optional chunking, pooling, normalization, and reliability middleware (retry, timeout, circuit breaker, rate limiting). Query vs document embedding distinction handled automatically when providers support it.

- **Vector** is `[]float32` with similarity/distance methods
- **Provider** is the minimal interface for embedding APIs
- **Service** wraps Provider with chunking, pooling, normalization, and reliability
- **QueryProviderFactory** — optional interface for providers that distinguish query vs document embeddings
- All reliability features compose via pipz pipeline

**Dependencies:** `pipz` (reliability pipeline), `capitan` (observability), `uuid` (request IDs)

## Public API

### Vector

```go
type Vector []float32
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Normalize` | `Normalize() Vector` | L2 normalization to unit vector |
| `Norm` | `Norm() float64` | L2 magnitude |
| `Dot` | `Dot(other Vector) float64` | Dot product |
| `CosineSimilarity` | `CosineSimilarity(other Vector) float64` | [-1, 1] direction similarity |
| `EuclideanDistance` | `EuclideanDistance(other Vector) float64` | L2 distance |
| `Similarity` | `Similarity(other Vector, metric SimilarityMetric) float64` | Metric-agnostic |
| `Pool` | `Pool(vectors []Vector, mode PoolingMode) Vector` | Aggregate vectors |

### Enumerations

```go
type SimilarityMetric // Cosine, DotProduct, Euclidean
type ChunkStrategy    // ChunkNone, ChunkSentence, ChunkParagraph, ChunkFixed
type PoolingMode      // PoolMean, PoolFirst, PoolMax
```

### Provider Interface

```go
type Provider interface {
    Embed(ctx context.Context, texts []string) (*EmbeddingResponse, error)
    Name() string
    Dimensions() int
}

type QueryProviderFactory interface {
    Provider
    ForQuery() Provider  // Returns query-optimized provider
}
```

### EmbeddingResponse

```go
type EmbeddingResponse struct {
    Model      string
    Vectors    []Vector
    Usage      Usage    // PromptTokens, TotalTokens
    Dimensions int
}
```

### Service

**Constructor:**

```go
func NewService(provider Provider, opts ...Option) *Service
```

Auto-detects `QueryProviderFactory` for query/document pipeline initialization.

**Core Methods:**

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Embed` | `Embed(ctx, text) (Vector, error)` | Single document embedding |
| `EmbedQuery` | `EmbedQuery(ctx, text) (Vector, error)` | Query-optimized (falls back to Embed) |
| `Batch` | `Batch(ctx, texts) ([]Vector, error)` | Multiple document embeddings |
| `BatchQuery` | `BatchQuery(ctx, texts) ([]Vector, error)` | Multiple query embeddings |

**Configuration (fluent):**

| Method | Purpose |
|--------|---------|
| `WithChunker(c *Chunker)` | Set chunking strategy |
| `WithPooling(mode PoolingMode)` | Set chunk vector aggregation (default: PoolMean) |
| `WithNormalize(bool)` | Enable/disable L2 normalization (default: true) |

**Introspection:**

`GetPipeline()`, `Dimensions()`, `Provider()`

### Reliability Options

All compose into the pipz pipeline:

| Option | Signature | Purpose |
|--------|-----------|---------|
| `WithRetry` | `WithRetry(maxAttempts int)` | Immediate retry |
| `WithBackoff` | `WithBackoff(maxAttempts int, baseDelay time.Duration)` | Exponential backoff |
| `WithTimeout` | `WithTimeout(duration time.Duration)` | Context cancellation |
| `WithCircuitBreaker` | `WithCircuitBreaker(failures int, recovery time.Duration)` | Cascade prevention |
| `WithRateLimit` | `WithRateLimit(rps float64, burst int)` | Token bucket rate limiting |
| `WithErrorHandler` | `WithErrorHandler(handler)` | Custom error handling |
| `WithFallback` | `WithFallback(ServiceProvider)` | Fallback to another service |

### Chunker

```go
type Chunker struct {
    Strategy  ChunkStrategy
    MaxSize   int           // ChunkFixed only
    Overlap   int           // ChunkFixed only
    TrimSpace bool          // Default: true
}
```

`DefaultChunker()` — ChunkNone, MaxSize=512, Overlap=50, TrimSpace=true

`Chunk(text string) []string` — returns non-empty chunks.

Strategies: `ChunkNone` (passthrough), `ChunkSentence` (`.!?` boundaries), `ChunkParagraph` (`\n\n`), `ChunkFixed` (overlapping windows).

## Provider Implementations

### OpenAI (`vex/openai`)

```go
openai.New(Config{APIKey, Model, BaseURL, Dimensions, Timeout})
```

| Model | Dimensions |
|-------|-----------|
| `text-embedding-ada-002` | 1536 |
| `text-embedding-3-small` | 1536 |
| `text-embedding-3-large` | 3072 |

Does NOT implement `QueryProviderFactory` — no query/document distinction.

### Cohere (`vex/cohere`)

```go
cohere.New(Config{APIKey, Model, BaseURL, InputType, Dimensions, Timeout})
```

| Model | Dimensions |
|-------|-----------|
| `embed-english-v3.0` | 1024 |
| `embed-multilingual-v3.0` | 1024 |

Implements `QueryProviderFactory`. Input types: `SearchDocument`, `SearchQuery`, `Classification`, `Clustering`.

### Gemini (`vex/gemini`)

```go
gemini.New(Config{APIKey, Model, BaseURL, TaskType, Dimensions, Timeout})
```

| Model | Dimensions |
|-------|-----------|
| `text-embedding-004` | 768 |

Implements `QueryProviderFactory`. Task types: `RetrievalQuery`, `RetrievalDocument`, `Semantic`, `Classification`, `Clustering`.

### Voyage (`vex/voyage`)

```go
voyage.New(Config{APIKey, Model, BaseURL, InputType, Dimensions, Timeout})
```

| Model | Dimensions |
|-------|-----------|
| `voyage-3` | 1024 |
| `voyage-3-lite` | 512 |
| `voyage-large-2` | 1536 |

Implements `QueryProviderFactory`. Input types: `Document`, `Query`.

## Capitan Signals

| Signal | Fields |
|--------|--------|
| `vex.embed.started` | request.id, provider, input.count |
| `vex.embed.completed` | request.id, provider, model, dimensions, duration.ms, tokens.prompt, tokens.total |
| `vex.embed.failed` | request.id, provider, error, duration.ms |
| `vex.provider.call.started` | provider, input.count |
| `vex.provider.call.completed` | provider, model, dimensions, duration.ms, tokens |
| `vex.provider.call.failed` | provider, error, duration.ms |

## Thread Safety

- **Service** — stateless after construction, safe for concurrent use
- **Providers** — share `*http.Client`, no per-call state, thread-safe
- **Vector** — immutable slice, safe for concurrent reads
- **Chunker** — stateless, safe for concurrent use

## File Layout

```
vex/
├── api.go         # Vector, Provider, QueryProviderFactory, enums
├── vector.go      # Vector operations and pooling
├── service.go     # Service implementation, EmbedRequest
├── options.go     # Reliability Options
├── hooks.go       # Capitan signal emission
├── chunker.go     # Text chunking strategies
├── openai/        # OpenAI provider
├── cohere/        # Cohere provider
├── gemini/        # Google Gemini provider
├── voyage/        # Voyage AI provider
└── testing/
    └── helpers.go # MockProvider, assertions, vector generators
```

## Common Patterns

**Basic embedding:**

```go
provider := openai.New(openai.Config{APIKey: key})
svc := vex.NewService(provider)
vec, _ := svc.Embed(ctx, "hello world")
```

**Query vs document (Voyage/Cohere/Gemini):**

```go
docVecs, _ := svc.Batch(ctx, documents)
queryVec, _ := svc.EmbedQuery(ctx, "search term")
similarity := queryVec.CosineSimilarity(docVecs[0])
```

**Long text chunking:**

```go
svc := vex.NewService(provider).
    WithChunker(&vex.Chunker{Strategy: vex.ChunkParagraph}).
    WithPooling(vex.PoolMean)
vec, _ := svc.Embed(ctx, longText)
```

**Reliability stack:**

```go
svc := vex.NewService(provider,
    vex.WithRetry(3),
    vex.WithBackoff(3, 100*time.Millisecond),
    vex.WithTimeout(30*time.Second),
    vex.WithCircuitBreaker(5, time.Minute),
    vex.WithRateLimit(10, 20),
)
```

**Fallback provider:**

```go
primary := vex.NewService(openaiProvider)
fallback := vex.NewService(cohereProvider)
resilient := vex.NewService(openaiProvider, vex.WithFallback(fallback))
```

## Ecosystem

Vex depends on:
- **pipz** — reliability pipeline composition
- **capitan** — observability signals

Vex is consumed by:
- Applications for embedding generation in RAG/search pipelines
