# Chit

Deep understanding of `github.com/zoobzio/chit` — conversation lifecycle controller for LLM-powered applications.

## Core Concepts

Chit manages multi-turn chat interactions, separating conversation lifecycle management from reasoning logic. The Chat controller handles sessions, history, continuation, and reliability — your Processor handles the brain.

- **Chat** orchestrates the conversation lifecycle
- **Processor** is the pluggable reasoning engine (LLM, agent, tool, anything)
- **Emitter** is the dual-channel output (streaming text + structured resources)
- **Result** is either a **Response** (complete) or a **Yield** (awaiting input)
- **Continuation** enables multi-step workflows without state machines
- Reliability patterns (retry, timeout, circuit breaker) applied via pipz

**Dependencies:** `pipz` (pipeline composition for reliability), `capitan` (lifecycle observability), `uuid` (chat/request IDs)

## Public API

### Chat

**Constructor:**

```go
func New(processor Processor, emitter Emitter, opts ...Option) *Chat
```

**Methods:**

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `ID` | `ID() string` | Unique chat ID (UUID) |
| `History` | `History() []Message` | Read-only snapshot of conversation history |
| `Config` | `Config() *Config` | Chat configuration |
| `HasContinuation` | `HasContinuation() bool` | True if awaiting input to resume |
| `Handle` | `Handle(ctx, input string) error` | Process user input through lifecycle |
| `GetPipeline` | `GetPipeline() pipz.Chainable[*ChatRequest]` | Internal pipeline (for fallback composition) |

### Processor

```go
type Processor interface {
    Process(ctx context.Context, input string, history []Message) (Result, error)
}

type ProcessorFunc func(ctx context.Context, input string, history []Message) (Result, error)
```

`ProcessorFunc` is an adapter — functions implement Processor directly.

### Emitter

```go
type Emitter interface {
    Emit(ctx context.Context, msg Message) error      // Stream conversational content
    Push(ctx context.Context, resource Resource) error // Push structured data
    Close() error                                       // Signal end of output
}
```

### Result Types

```go
type Result interface {
    IsComplete() bool
    IsYielded() bool
}
```

**Response** — processing complete:

```go
type Response struct {
    Content  string
    Metadata map[string]any
}
```

**Yield** — processing paused, awaiting input:

```go
type Yield struct {
    Prompt       string
    Continuation Continuation
    Metadata     map[string]any
}

type Continuation func(ctx context.Context, input string, history []Message) (Result, error)
```

Continuations run through the same reliability pipeline as fresh processor calls. Can chain indefinitely.

### Message and Resource

```go
type Message struct {
    Role     string         // "assistant", "system", "user"
    Content  string
    Metadata map[string]any
}

type Resource struct {
    Type     string // "data", "context", "tool_result"
    URI      string // scio URI if from a data source
    Payload  any
    Metadata map[string]any
}
```

### ChatRequest (pipeline payload)

```go
type ChatRequest struct {
    Input     string
    History   []Message
    ChatID    string
    RequestID string
    Result    Result
}
```

Implements `pipz.Cloner[*ChatRequest]` for concurrent middleware.

### Options

**Configuration:**

| Option | Purpose |
|--------|---------|
| `WithConfig(config)` | Set entire configuration |
| `WithSystemPrompt(prompt)` | Set system message |
| `WithHistory(history)` | Set initial conversation history |
| `WithMetadata(metadata)` | Set configuration metadata |

**Reliability (via pipz):**

| Option | Purpose |
|--------|---------|
| `WithRetry(maxAttempts)` | Retry failed requests |
| `WithBackoff(maxAttempts, baseDelay)` | Retry with exponential backoff |
| `WithTimeout(duration)` | Cancel operations exceeding duration |
| `WithCircuitBreaker(failures, recovery)` | Open circuit after N consecutive failures |
| `WithRateLimit(rps, burst)` | Rate limit requests per second |
| `WithErrorHandler(handler)` | Custom error handling |

**Composition:**

| Option | Purpose |
|--------|---------|
| `WithFallback(ChatProvider)` | Fallback processor on primary failure |
| `WithMiddleware(processors...)` | Pre-processing steps before terminal |

`ChatProvider` — interface for types that provide a pipeline. `Chat` implements this, enabling `WithFallback(anotherChat)`.

### Context Injection

```go
func WithEmitter(ctx context.Context, e Emitter) context.Context
func EmitterFromContext(ctx context.Context) Emitter
```

Chat auto-injects emitter before calling processor. Processors access emitter via context.

### Middleware Helper

```go
func NewMiddleware(fn func(context.Context, *ChatRequest) (*ChatRequest, error)) pipz.Chainable[*ChatRequest]
```

### Terminal Processors

```go
func NewTerminal(processor Processor) pipz.Chainable[*ChatRequest]
func NewContinuationTerminal(cont Continuation) pipz.Chainable[*ChatRequest]
```

## Handle Lifecycle

1. Emit `InputReceived` signal
2. Inject emitter into context
3. Append user message to history
4. Create `ChatRequest` with history snapshot
5. If continuation exists → emit `TurnResumed`, process through continuation pipeline
6. Otherwise → process through main pipeline
7. On error → emit `ProcessingFailed`, return error
8. On success → emit `ProcessingCompleted`, handle result:
   - **Response** → append to history, emit `ResponseEmitted`, call `emitter.Emit()`
   - **Yield** → append prompt, store continuation, emit `TurnYielded`, call `emitter.Emit()`

## Capitan Signals

| Signal | Fields |
|--------|--------|
| `ChatCreated` | `FieldChatID` |
| `InputReceived` | `FieldChatID`, `FieldInput`, `FieldInputSize` |
| `ProcessingStarted` | `FieldChatID` |
| `ProcessingCompleted` | `FieldChatID`, `FieldProcessingDuration` |
| `ProcessingFailed` | `FieldChatID`, `FieldProcessingDuration`, `FieldError` |
| `ResponseEmitted` | `FieldChatID`, `FieldRole`, `FieldContentSize` |
| `TurnYielded` | `FieldChatID`, `FieldPrompt` |
| `TurnResumed` | `FieldChatID` |
| `ResourcePushed` | `FieldChatID`, `FieldResourceType`, `FieldResourceURI` |

## Sentinel Errors

```go
var (
    ErrUnknownResultType = errors.New("chit: unknown result type")
    ErrNilProcessor      = errors.New("chit: processor is required")
    ErrNilEmitter        = errors.New("chit: emitter is required")
    ErrEmitterClosed     = errors.New("chit: emitter is closed")
)
```

## Thread Safety

- Chat uses `sync.Mutex` protecting mutable state (continuation, history)
- Lock held briefly at start of Handle; released before processor call
- Safe for concurrent `Handle()` calls (serialised on mutex)
- For truly parallel conversations, use separate Chat instances

## File Layout

```
chit/
├── chat.go        # Chat controller, Handle lifecycle
├── processor.go   # Processor interface and ProcessorFunc adapter
├── emitter.go     # Emitter interface, Message, Resource
├── result.go      # Result interface, Response, Yield, Continuation
├── request.go     # ChatRequest (pipeline payload)
├── context.go     # Context injection for Emitter
├── signals.go     # Capitan signal definitions
├── errors.go      # Sentinel errors
├── options.go     # Functional options
├── middleware.go   # Middleware helper
├── terminal.go    # Terminal processors
└── testing/
    └── helpers.go # MockProcessor, MockEmitter, CollectingEmitter
```

## Common Patterns

**Basic chat:**

```go
processor := chit.ProcessorFunc(func(ctx context.Context, input string, history []chit.Message) (chit.Result, error) {
    // Call LLM, return response
    return &chit.Response{Content: reply}, nil
})

chat := chit.New(processor, emitter,
    chit.WithSystemPrompt("You are helpful."),
    chit.WithRetry(3),
    chit.WithTimeout(30*time.Second),
)

chat.Handle(ctx, "Hello")
```

**Multi-turn with yield:**

```go
processor := chit.ProcessorFunc(func(ctx context.Context, input string, history []chit.Message) (chit.Result, error) {
    return &chit.Yield{
        Prompt: "What's your name?",
        Continuation: func(ctx context.Context, name string, _ []chit.Message) (chit.Result, error) {
            return &chit.Response{Content: "Hello, " + name}, nil
        },
    }, nil
})

chat.Handle(ctx, "Hi")      // Yields "What's your name?"
chat.Handle(ctx, "Alice")   // Resumes → "Hello, Alice"
```

**Push structured data from processor:**

```go
emitter := chit.EmitterFromContext(ctx)
emitter.Push(ctx, chit.Resource{
    Type:    "context",
    Payload: searchResults,
})
```

**Fallback processor:**

```go
primary := chit.New(gpt4Processor, emitter)
fallback := chit.New(gpt35Processor, emitter)

chat := chit.New(gpt4Processor, emitter,
    chit.WithFallback(fallback),
)
```

## Ecosystem

Chit depends on:
- **pipz** — reliability patterns (retry, timeout, circuit breaker)
- **capitan** — lifecycle observability

Chit is consumed by:
- Applications for conversational AI interfaces
