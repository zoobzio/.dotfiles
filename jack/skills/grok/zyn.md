# Zyn

Deep understanding of `github.com/zoobzio/zyn` — typed, composable LLM interactions built on pipz pipelines.

## Core Concepts

Zyn provides **synapses** — typed LLM interactions that wrap a specific task (classification, extraction, binary decision, etc.) with type-safe input/output, structured prompt generation, JSON schema enforcement, and composable reliability.

- **Synapse** is a typed LLM interaction (Binary, Classification, Extraction, Transform, Analyze, Convert, Ranking, Sentiment)
- **Session** is a conversation context maintaining message history and token usage across multi-turn workflows
- **Provider** is the LLM backend abstraction (one method: `Call`)
- **Service[T]** is the generic foundation — all synapses wrap a `Service[ResponseType]`
- **Options** compose pipz reliability patterns (retry, timeout, circuit breaker, rate limiter) onto the pipeline

Mental model: each synapse constructs a pipz pipeline with a terminal processor (the provider call) wrapped in optional reliability layers. The service executes requests through the pipeline, parses JSON responses into typed structs, validates them, and updates the session.

**Dependencies:** `pipz` (pipeline composition), `capitan` (signal emission), `sentinel` (type-to-JSON-schema), `clockz` (indirect via capitan), `google/uuid` (session/request IDs)

## Public API

### Provider Interface

```go
type Provider interface {
    Call(ctx context.Context, messages []Message, temperature float32) (*ProviderResponse, error)
    Name() string
}
```

Single method for LLM calls. Implementations handle authentication, API details, prompt caching.

### Validator Interface

```go
type Validator interface {
    Validate() error
}
```

All synapse response types must implement this. Called after JSON parsing to enforce domain constraints.

### Message

```go
type Message struct {
    Role    string
    Content string
}

const (
    RoleUser      = "user"
    RoleAssistant = "assistant"
    RoleSystem    = "system"
)
```

### ProviderResponse

```go
type ProviderResponse struct {
    Content string
    Usage   TokenUsage
}

type TokenUsage struct {
    Prompt     int
    Completion int
    Total      int
}
```

### Temperature Constants

```go
const (
    TemperatureUnset                float32 = -1
    TemperatureZero                 float32 = 0.0001
    DefaultTemperatureDeterministic float32 = 0.1   // binary, extraction, conversion
    DefaultTemperatureAnalytical    float32 = 0.2   // sentiment, ranking, analyze
    DefaultTemperatureCreative      float32 = 0.3   // classification, transform
)
```

Temperature 0 is treated as "unset" for ergonomic struct initialisation — use `TemperatureZero` for actual zero.

## Service[T] (Generic Foundation)

```go
type Service[T Validator] struct { ... }

func NewService[T Validator](pipeline pipz.Chainable[*SynapseRequest],
    synapseType string, provider Provider, defaultTemperature float32) *Service[T]

func NewTerminal(provider Provider) pipz.Chainable[*SynapseRequest]
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Execute` | `Execute(ctx, *Session, *Prompt, float32) (T, error)` | Run pipeline, parse JSON, validate, update session |
| `GetPipeline` | `GetPipeline() pipz.Chainable[*SynapseRequest]` | Access underlying pipz pipeline |

All synapses delegate to `Service.Execute`. The service:
1. Builds `SynapseRequest` with prompt, session messages, metadata
2. Processes through pipz pipeline (terminal processor calls provider)
3. Parses JSON response into type T
4. Calls `T.Validate()`
5. Updates session with conversation history and token usage
6. Emits capitan signals at each lifecycle point

### SynapseRequest

```go
type SynapseRequest struct {
    Prompt       *Prompt
    Temperature  float32
    SessionID    string
    Messages     []Message
    RequestID    string
    SynapseType  string
    ProviderName string
    Response     string      // Populated by pipeline
    Usage        *TokenUsage // Populated by pipeline
    Error        error       // Populated by pipeline
}
```

The data type flowing through the pipz pipeline. Modified by pipeline stages.

## Options (Composable Reliability)

```go
type Option func(pipz.Chainable[*SynapseRequest]) pipz.Chainable[*SynapseRequest]
```

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `WithRetry` | `WithRetry(maxAttempts int) Option` | Immediate retry on failure |
| `WithBackoff` | `WithBackoff(maxAttempts int, baseDelay time.Duration) Option` | Exponential backoff retry |
| `WithTimeout` | `WithTimeout(duration time.Duration) Option` | Enforce time limit |
| `WithCircuitBreaker` | `WithCircuitBreaker(failures int, recovery time.Duration) Option` | Prevent cascading failures |
| `WithRateLimit` | `WithRateLimit(rps float64, burst int) Option` | Token bucket rate limiting |
| `WithErrorHandler` | `WithErrorHandler(handler pipz.Chainable[*pipz.Error[*SynapseRequest]]) Option` | Error observation (logging, metrics) |
| `WithFallback` | `WithFallback(fallback ServiceProvider) Option` | Fallback to alternative synapse |

```go
type ServiceProvider interface {
    GetPipeline() pipz.Chainable[*SynapseRequest]
}
```

Options wrap the terminal processor with pipz reliability patterns. Applied at construction:

```go
synapse, _ := zyn.Binary("question", provider,
    zyn.WithRetry(3),
    zyn.WithTimeout(10*time.Second),
    zyn.WithCircuitBreaker(5, 30*time.Second),
)
```

## Session (Conversation Context)

```go
func NewSession() *Session
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `ID()` | `ID() string` | Session UUID |
| `Messages()` | `Messages() []Message` | Defensive copy of history |
| `Append(role, content)` | `Append(role, content string)` | Add message |
| `Clear()` | `Clear()` | Reset history |
| `Prune(n)` | `Prune(n int) error` | Remove last n message pairs |
| `Len()` | `Len() int` | Message count |
| `LastUsage()` | `LastUsage() *TokenUsage` | Copy of last token usage |
| `At(index)` | `At(index int) (Message, error)` | Get by index |
| `Remove(index)` | `Remove(index int) error` | Remove by index |
| `Replace(index, msg)` | `Replace(index int, msg Message) error` | Replace by index |
| `Insert(index, msg)` | `Insert(index int, msg Message) error` | Insert at index |
| `SetMessages(msgs)` | `SetMessages(msgs []Message)` | Replace all |
| `Truncate(keepFirst, keepLast)` | `Truncate(keepFirst, keepLast int) error` | Keep first N + last M messages |

Thread-safe via `sync.RWMutex`. Updated transactionally — only after successful synapse execution.

## Prompt (Structured Template)

```go
type Prompt struct {
    Task        string              // Required: what to do
    Input       string              // Required: main content
    Context     string              // Optional: background
    Categories  []string            // For classification
    Items       []string            // For ranking
    Aspects     []string            // For sentiment
    Examples    map[string][]string // Category/type → examples
    Schema      string              // Required: JSON schema
    Constraints []string            // Required: rules
}
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Render()` | `Render() string` | Canonical prompt string with sections in consistent order |
| `Validate()` | `Validate() error` | Enforce required fields (Task, Input or Items, Schema) |

## Eight Synapse Types

Each synapse follows a consistent pattern:
- Constructor accepting task description, provider, and options
- `WithDefaults()` for rich input merging
- `Fire()` — simple input, simple output
- `FireWithDetails()` — simple input, full response struct
- `FireWithInput()` — rich input struct, full response struct
- `GetPipeline()` — implements `ServiceProvider`

### Binary

Yes/no decisions with confidence and reasoning.

| Constructor | `Binary(question string, provider Provider, opts ...Option) (*BinarySynapse, error)` |
|-------------|----------------------------------------------------------------------------------------|

```go
type BinaryResponse struct {
    Decision   bool     `json:"decision"`
    Confidence float64  `json:"confidence"`
    Reasoning  []string `json:"reasoning"`
}

type BinaryInput struct {
    Subject, Context string
    Criteria, Examples, Constraints []string
    Temperature float32
}
```

| Method | Returns | Behaviour |
|--------|---------|-----------|
| `Fire(ctx, session, input)` | `bool, error` | Simple decision |
| `FireWithDetails(ctx, session, input)` | `BinaryResponse, error` | Full response |
| `FireWithInput(ctx, session, BinaryInput)` | `BinaryResponse, error` | Rich input |

Default temperature: `DefaultTemperatureDeterministic` (0.1)

### Classification

Categorise input into predefined categories.

| Constructor | `Classification(question string, categories []string, provider Provider, opts ...Option) (*ClassificationSynapse, error)` |
|-------------|-----------------------------------------------------------------------------------------------------------------------------|

```go
type ClassificationResponse struct {
    Primary, Secondary string
    Confidence         float64
    Reasoning          []string
}

type ClassificationInput struct {
    Subject, Context string
    Examples         map[string][]string
    Temperature      float32
}
```

| Method | Returns |
|--------|---------|
| `Fire(ctx, session, input)` | `string, error` (primary category) |
| `FireWithDetails(ctx, session, input)` | `ClassificationResponse, error` |
| `FireWithInput(ctx, session, ClassificationInput)` | `ClassificationResponse, error` |

Default temperature: `DefaultTemperatureCreative` (0.3)

### Extraction (Generic)

Extract structured data from text.

| Constructor | `Extract[T Validator](what string, provider Provider, opts ...Option) (*ExtractionSynapse[T], error)` |
|-------------|--------------------------------------------------------------------------------------------------------|

```go
type ExtractionInput struct {
    Text, Context, Examples string
    Temperature             float32
}
```

| Method | Returns |
|--------|---------|
| `Fire(ctx, session, text)` | `T, error` |
| `FireWithInput(ctx, session, ExtractionInput)` | `T, error` |

Type parameter T must implement `Validator`. JSON schema generated automatically via sentinel.

Default temperature: `DefaultTemperatureDeterministic` (0.1)

### Transform

Text-to-text transformation with change tracking.

| Constructor | `Transform(instruction string, provider Provider, opts ...Option) (*TransformSynapse, error)` |
|-------------|-----------------------------------------------------------------------------------------------|

```go
type TransformResponse struct {
    Output     string
    Confidence float64
    Changes    []string
    Reasoning  []string
}

type TransformInput struct {
    Text, Context, Style string
    Examples             map[string]string
    MaxLength            int
    Temperature          float32
}
```

| Method | Returns |
|--------|---------|
| `Fire(ctx, session, text)` | `string, error` (output) |
| `FireWithDetails(ctx, session, text)` | `*TransformResponse, error` |
| `FireWithInput(ctx, session, TransformInput)` | `string, error` |
| `FireWithInputDetails(ctx, session, TransformInput)` | `*TransformResponse, error` |

Default temperature: `DefaultTemperatureCreative` (0.3)

### Analyze (Generic Input)

Structured analysis of any data type.

| Constructor | `Analyze[T any](what string, provider Provider, opts ...Option) (*AnalyzeSynapse[T], error)` |
|-------------|-----------------------------------------------------------------------------------------------|

```go
type AnalyzeResponse struct {
    Analysis   string
    Confidence float64
    Findings   []string
    Reasoning  []string
}

type AnalyzeInput[T any] struct {
    Data        T
    Context     string
    Focus       string
    Temperature float32
}
```

| Method | Returns |
|--------|---------|
| `Fire(ctx, session, data)` | `string, error` (analysis) |
| `FireWithDetails(ctx, session, data)` | `*AnalyzeResponse, error` |
| `FireWithInput(ctx, session, AnalyzeInput[T])` | `string, error` |
| `FireWithInputDetails(ctx, session, AnalyzeInput[T])` | `*AnalyzeResponse, error` |

Type parameter T can be any Go type (no constraint). Input data marshaled to JSON for the prompt.

Default temperature: `DefaultTemperatureAnalytical` (0.2)

### Convert (Generic Input → Output)

Transform structured data between types.

| Constructor | `Convert[TInput any, TOutput Validator](instruction string, provider Provider, opts ...Option) (*ConvertSynapse[TInput, TOutput], error)` |
|-------------|---------------------------------------------------------------------------------------------------------------------------------------------|

```go
type ConvertInput[T any] struct {
    Data        T
    Context     string
    Temperature float32
}
```

| Method | Returns |
|--------|---------|
| `Fire(ctx, session, data)` | `TOutput, error` |
| `FireWithInput(ctx, session, ConvertInput[TInput])` | `TOutput, error` |

TInput is unconstrained. TOutput must implement `Validator`. JSON schemas generated for both types.

Default temperature: `DefaultTemperatureDeterministic` (0.1)

### Ranking

Order items by criteria.

| Constructor | `Ranking(criteria string, provider Provider, opts ...Option) (*RankingSynapse, error)` |
|-------------|-----------------------------------------------------------------------------------------|

```go
type RankingResponse struct {
    Ranked     []string
    Confidence float64
    Reasoning  []string
}

type RankingInput struct {
    Items       []string
    Context     string
    Examples    []string
    TopN        int
    Temperature float32
}
```

| Method | Returns |
|--------|---------|
| `Fire(ctx, session, items)` | `[]string, error` (ordered) |
| `FireWithDetails(ctx, session, items)` | `RankingResponse, error` |
| `FireWithInput(ctx, session, RankingInput)` | `RankingResponse, error` |

Default temperature: `DefaultTemperatureAnalytical` (0.2)

### Sentiment

Analyse sentiment with aspect-level granularity.

| Constructor | `Sentiment(analysisType string, provider Provider, opts ...Option) (*SentimentSynapse, error)` |
|-------------|------------------------------------------------------------------------------------------------|

```go
type SentimentScores struct {
    Positive, Negative, Neutral float64 // Must sum to ~1.0
}

type SentimentResponse struct {
    Overall    string            // positive, negative, neutral, mixed
    Confidence float64
    Scores     SentimentScores
    Aspects    map[string]string // Per-aspect sentiment
    Emotions   []string
    Reasoning  []string
}

type SentimentInput struct {
    Text, Context string
    Aspects       []string
    Temperature   float32
}
```

| Method | Returns |
|--------|---------|
| `Fire(ctx, session, text)` | `string, error` (overall) |
| `FireWithDetails(ctx, session, text)` | `SentimentResponse, error` |
| `FireWithInput(ctx, session, SentimentInput)` | `SentimentResponse, error` |

Default temperature: `DefaultTemperatureAnalytical` (0.2)

## Schema Generation

Zyn uses sentinel to convert Go types to JSON Schema automatically:

```go
// Internal — called during synapse construction
func generateJSONSchema[T any]() (string, error)
```

Uses `sentinel.Scan[T]()` to extract type metadata, then recursively builds JSON Schema. Handles structs, nested structs, arrays, maps, pointers, and all primitive types. Root objects disallow additional properties.

## Capitan Signals

All synapse executions emit typed signals via capitan.

| Signal | Name | Emitted When |
|--------|------|-------------|
| `RequestStarted` | `llm.request.started` | Before pipeline execution |
| `RequestCompleted` | `llm.request.completed` | After successful execution |
| `RequestFailed` | `llm.request.failed` | Provider or pipeline error |
| `ProviderCallStarted` | `llm.provider.call.started` | Before provider.Call |
| `ProviderCallCompleted` | `llm.provider.call.completed` | After successful provider.Call |
| `ProviderCallFailed` | `llm.provider.call.failed` | Provider.Call error |
| `ResponseParseFailed` | `llm.response.failed` | JSON parse or validation error |

**Field Keys:**

| Category | Keys |
|----------|------|
| Request | `RequestIDKey`, `SynapseTypeKey`, `PromptTaskKey`, `TemperatureKey` |
| Input/Output | `InputKey`, `OutputKey`, `ResponseKey` |
| Errors | `ErrorKey`, `ErrorTypeKey` |
| Provider | `ProviderKey`, `ModelKey` |
| Metrics | `PromptTokensKey`, `CompletionTokensKey`, `TotalTokensKey`, `DurationMsKey` |
| HTTP/API | `HTTPStatusCodeKey`, `APIErrorTypeKey`, `APIErrorCodeKey` |
| Response | `ResponseIDKey`, `ResponseFinishReasonKey`, `ResponseCreatedKey` |

## Thread Safety

| Component | Model |
|-----------|-------|
| Synapses | Immutable after construction. Safe to share across goroutines. |
| Service | Stateless pipeline executor. Safe to share. |
| Session | Thread-safe via `sync.RWMutex`. All methods concurrent-safe. |
| Providers | Implementation-dependent. Mock providers are thread-safe. |

## Error Handling

| Error Source | Behaviour |
|-------------|-----------|
| Provider error | Propagated through pipeline, emits `RequestFailed` |
| JSON parse failure | Returns `"failed to parse response: {error}"`, emits `ResponseParseFailed` |
| Validation failure | Returns `"invalid response: {error}"`, emits `ResponseParseFailed` |
| Prompt validation | Returns `"invalid prompt: {error}"` before pipeline execution |
| Pipeline errors | Retry exhaustion, timeout, circuit breaker — all propagate from pipz |

Session is only updated after successful execution (transactional).

## File Layout

```
zyn/
├── api.go              # Provider, Validator, Message, ProviderResponse, TokenUsage, constants
├── service.go          # Service[T], NewService, NewTerminal, Execute
├── options.go          # Option type, With* functions, ServiceProvider
├── session.go          # Session with thread-safe message management
├── prompt.go           # Prompt struct, Render, Validate
├── schema.go           # JSON Schema generation via sentinel
├── hooks.go            # Capitan signals and field keys
├── mock.go             # MockProvider with pattern-matched responses
├── binary.go           # BinarySynapse
├── classification.go   # ClassificationSynapse
├── extraction.go       # ExtractionSynapse[T Validator]
├── transform.go        # TransformSynapse
├── analyze.go          # AnalyzeSynapse[T any]
├── convert.go          # ConvertSynapse[TInput any, TOutput Validator]
├── ranking.go          # RankingSynapse
├── sentiment.go        # SentimentSynapse
└── testing/
    ├── helpers.go       # ResponseBuilder, SequencedProvider, FailingProvider, CallRecorder, etc.
    ├── integration/
    └── benchmarks/
```

## Common Patterns

**Simple Binary Decision:**

```go
synapse, _ := zyn.Binary("Is this email spam?", provider, zyn.WithRetry(3))
session := zyn.NewSession()
isSpam, _ := synapse.Fire(ctx, session, emailBody)
```

**Typed Extraction:**

```go
type Contact struct {
    Name  string `json:"name"`
    Email string `json:"email"`
}
func (c Contact) Validate() error {
    if c.Name == "" { return fmt.Errorf("name required") }
    return nil
}

extractor, _ := zyn.Extract[Contact]("contact information", provider)
contact, _ := extractor.Fire(ctx, session, "Email from John at john@example.com")
```

**Multi-Turn Workflow:**

```go
session := zyn.NewSession()
contact, _ := extractor.Fire(ctx, session, rawText)
urgency, _ := classifier.Fire(ctx, session, contact.Name+"'s request")
response, _ := transformer.Fire(ctx, session, fmt.Sprintf("Urgency: %s", urgency))
// session.Messages() contains full conversation history
```

**Resilience Stack:**

```go
synapse, _ := zyn.Binary("question", provider,
    zyn.WithRateLimit(10, 50),
    zyn.WithCircuitBreaker(5, 30*time.Second),
    zyn.WithBackoff(3, time.Second),
    zyn.WithTimeout(10*time.Second),
)
```

**Fallback Provider:**

```go
primary, _ := zyn.Binary("question", providerA)
fallback, _ := zyn.Binary("question", providerB)
synapse, _ := zyn.Binary("question", providerA, zyn.WithFallback(fallback))
```

**Observability:**

```go
capitan.Hook(zyn.RequestCompleted, func(ctx context.Context, e *capitan.Event) {
    reqID, _ := zyn.RequestIDKey.From(e)
    tokens, _ := zyn.TotalTokensKey.From(e)
    duration, _ := zyn.DurationMsKey.From(e)
    log.Printf("Request %s: %d tokens in %dms", reqID, tokens, duration)
})
```

**Defaults for Rich Input:**

```go
synapse, _ := zyn.Classification("ticket type", categories, provider)
synapse.WithDefaults(zyn.ClassificationInput{
    Context:  "Customer support tickets",
    Examples: map[string][]string{"billing": {"charge", "invoice"}, "tech": {"crash", "error"}},
})
result, _ := synapse.Fire(ctx, session, ticketText)
```

## Test Helpers

`zyn/testing/helpers.go` provides:

| Helper | Purpose |
|--------|---------|
| `ResponseBuilder` | Fluent builder for JSON response strings. `WithDecision()`, `WithConfidence()`, `WithPrimary()`, `WithRanked()`, etc. |
| `SequencedProvider` | Return different responses for consecutive calls. `CallCount()`, `Reset()`. |
| `FailingProvider` | Fail N times then succeed. `WithSuccessResponse()`, `WithFailError()`. |
| `CallRecorder` | Wrap a provider, record all calls. `Calls()`, `LastCall()`, `CallCount()`. |
| `LatencyProvider` | Add artificial delay to provider calls. |
| `UsageAccumulator` | Track token usage across multiple calls. `PromptTokens()`, `TotalTokens()`. |

`MockProvider` (in main package) generates pattern-matched responses based on prompt structure — detects JSON schema, classification categories, ranking items, sentiment keywords, etc.

## Anti-Patterns

- **Sharing sessions across independent workflows** — sessions accumulate history. Use separate sessions for independent conversations.
- **Ignoring Validate() implementation** — empty `Validate()` defeats type safety. Validate domain constraints.
- **Creating synapses per-request** — synapse construction builds the pipeline. Create once, reuse with different sessions.
- **Using temperature 0 directly** — treated as "unset". Use `TemperatureZero` (0.0001) for actual zero.
- **Retaining SynapseRequest references** — request objects are modified by the pipeline. Do not hold references.
- **Nesting redundant reliability** — WithRetry inside WithBackoff is redundant. Choose one retry strategy.

## Prohibitions

DO NOT:
- Implement `Provider` without handling context cancellation
- Use `interface{}` for extraction/conversion types — use generics with `Validator`
- Modify sessions from within provider implementations
- Assume provider response format — always validate
- Create synapses per-request (pipeline construction overhead)

## Ecosystem

Zyn depends on:
- **pipz** — pipeline composition for request processing and reliability
- **capitan** — signal emission for observability
- **sentinel** — type metadata for JSON schema generation

Zyn is consumed by applications with AI/LLM integration needs.
