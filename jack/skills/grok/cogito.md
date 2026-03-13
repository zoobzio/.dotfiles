# Cogito

Deep understanding of `github.com/zoobzio/cogito` — structured reasoning and LLM orchestration via the Thought-Note pattern.

## Core Concepts

Cogito implements a **Thought-Note architecture** for building autonomous reasoning systems. A `Thought` is a rolling context accumulating `Note` objects as reasoning progresses. Primitives (Decide, Analyze, Categorize, etc.) implement `pipz.Chainable[*Thought]` — they read context from notes, call LLM synapses via zyn, and store results as new notes. All primitives compose into pipz pipelines.

- **Thought** is the primary context object — holds intent, notes, session, trace ID
- **Note** is an atomic information unit — key, content, metadata, source
- **Provider** interface abstracts LLM access with three-level resolution (step → context → global)
- **Introspection** — optional semantic summarisation after each step (Transform synapse)
- All primitives implement `pipz.Chainable[*Thought]` for pipeline composition

**Dependencies:** `zyn` (LLM synapses), `pipz` (pipeline composition), `capitan` (observability), `uuid` (IDs)

## Public API

### Thought

**Constructors:**

```go
func New(ctx context.Context, intent string) *Thought
func NewWithTrace(ctx context.Context, intent, traceID string) *Thought
```

**Adding Content:**

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `AddNote` | `AddNote(ctx, Note)` | Add with full metadata |
| `SetContent` | `SetContent(ctx, key, content, source)` | Add simple note |
| `SetNote` | `SetNote(ctx, key, content, source, metadata)` | Add with metadata |

**Retrieving Content:**

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `GetNote` | `GetNote(key) *Note` | Most recent note by key |
| `GetContent` | `GetContent(key) string` | Content string by key |
| `GetMetadata` | `GetMetadata(key, field) string` | Specific metadata field |
| `GetLatestNote` | `GetLatestNote() *Note` | Most recently added |
| `AllNotes` | `AllNotes() []Note` | Chronological order |
| `GetBool` | `GetBool(key) bool` | Parse as boolean |
| `GetFloat` | `GetFloat(key) float64` | Parse as float |
| `GetInt` | `GetInt(key) int` | Parse as integer |

**Session Management:**

| Method | Behaviour |
|--------|-----------|
| `PublishedCount()` | Count of notes sent to LLM |
| `SetPublishedCount(count)` | Restore published state |
| `GetUnpublishedNotes()` | Notes not yet sent to LLM |
| `MarkNotesPublished(ctx)` | Mark current notes as published |

**Utilities:**

| Method | Behaviour |
|--------|-----------|
| `Clone()` | Deep copy for concurrent processing |
| `RenderNotesToContext([]Note) string` | Format notes for LLM: `"key: content\n..."` |

### Note

```go
type Note struct {
    ID, ThoughtID, Key, Content, Source string
    Metadata                            map[string]string
    Created                             time.Time
}
```

### Provider

```go
type Provider interface {
    Call(ctx context.Context, messages []zyn.Message, temperature float32) (*zyn.ProviderResponse, error)
    Name() string
}
```

**Resolution order:** step-level → context → global default.

| Function | Behaviour |
|----------|-----------|
| `SetProvider(p)` | Set global fallback |
| `GetProvider()` | Get global provider |
| `WithProvider(ctx, p)` | Add to context |
| `ProviderFromContext(ctx)` | Retrieve from context |
| `ResolveProvider(ctx, stepProvider)` | Determine which to use |

## Reasoning Primitives

All implement `pipz.Chainable[*Thought]`. All support `.WithProvider(p)`, `.WithTemperature(t)`, `.WithIntrospection()`.

### Decide (Binary Decision)

```go
NewDecide(key, question string) *Decide
```

Uses Binary synapse → yes/no with confidence and reasoning. Optional Transform synapse for summary.

Notes: `{key}` (JSON `zyn.BinaryResponse`), `{key}_summary` (if introspection enabled).

`Scan(t) (*zyn.BinaryResponse, error)`

### Analyze (Structured Extraction)

```go
NewAnalyze[T zyn.Validator](key, what string) *Analyze[T]
```

Uses Extract synapse → typed data of T. Optional Transform for summary.

Notes: `{key}` (JSON T), `{key}_summary`.

`Scan(t) (T, error)`

### Categorize (Classification)

```go
NewCategorize(key, question string, categories []string) *Categorize
```

Uses Classification synapse → primary/secondary category with confidence.

Notes: `{key}` (JSON `zyn.ClassificationResponse`), `{key}_summary`.

`Scan(t) (*zyn.ClassificationResponse, error)`

### Assess (Sentiment Analysis)

```go
NewAssess(key string) *Assess
```

Uses Sentiment synapse → overall tone, confidence, scores, emotions, aspects.

Notes: `{key}` (JSON `zyn.SentimentResponse`), `{key}_summary`.

`Scan(t) (*zyn.SentimentResponse, error)`

### Prioritize (Ranking)

```go
NewPrioritize(key, criteria string, items []string) *Prioritize
NewPrioritizeFrom(key, criteria, itemsKey string) *Prioritize  // Read items from note
```

Uses Ranking synapse → ordered items with confidence.

Notes: `{key}` (JSON `zyn.RankingResponse`), `{key}_summary`.

`Scan(t) (*zyn.RankingResponse, error)`

### Reflect (Self-Consolidation)

```go
NewReflect(key string) *Reflect
```

Summarises current notes into a single consolidated note. No introspection phase.

Options: `WithPrompt(prompt)`, `WithUnpublishedOnly()`.

Notes: `{key}` (summary text).

## Control Flow Primitives

### Sift (Semantic Gate)

```go
NewSift(key, question string, processor pipz.Chainable[*Thought]) *Sift
```

Binary synapse decides whether to execute wrapped processor. If decision is true, processor runs.

Notes: `{key}` (JSON `zyn.BinaryResponse`), `{key}_summary`.

`Scan(t) (*zyn.BinaryResponse, error)`, `SetProcessor(p)`.

### Discern (Semantic Router)

```go
NewDiscern(key, question string, categories []string) *Discern
```

Classification synapse determines route. Executes matching processor.

Route management: `AddRoute(category, processor)`, `RemoveRoute(category)`, `SetFallback(processor)`, `HasRoute(category)`, `Routes()`, `ClearRoutes()`.

Thread-safe with `sync.RWMutex`.

Notes: `{key}` (JSON `zyn.ClassificationResponse`), `{key}_summary`.

`Scan(t) (*zyn.ClassificationResponse, error)`

## Refinement Primitives

### Amplify (Iterative Refinement)

```go
NewAmplify(key, sourceKey, refinementPrompt, completionCriteria string, maxIterations int) *Amplify
```

Loops: Transform synapse refines content → Binary synapse checks completion → repeat until criteria met or max iterations.

```go
type AmplifyResult struct {
    Content    string   `json:"content"`
    Iterations int      `json:"iterations"`
    Completed  bool     `json:"completed"`
    Reasoning  []string `json:"reasoning"`
}
```

Options: `WithRefinementTemperature(t)`, `WithCompletionTemperature(t)`, `WithMaxIterations(n)`.

`Scan(t) (*AmplifyResult, error)`

### Converge (Parallel Synthesis)

```go
NewConverge(key, synthesisPrompt string, processors ...pipz.Chainable[*Thought]) *Converge
```

Runs processors concurrently on cloned thoughts, merges notes, synthesises with Transform synapse.

Processor management: `AddProcessor(p)`, `RemoveProcessor(identity)`, `ClearProcessors()`, `Processors()`.

Thread-safe with `sync.RWMutex`.

`Scan(t) (string, error)` — returns synthesis result.

## Session Management Primitives

### Reset

```go
NewReset(key string) *Reset
```

Clears session entirely. Options: `WithSystemMessage(msg)`, `WithPreserveNote(noteKey)`.

### Truncate

```go
NewTruncate(key string) *Truncate
```

Sliding window trim (no LLM). Options: `WithKeepFirst(n)` (default: 1), `WithKeepLast(n)` (default: 10), `WithThreshold(n)`.

### Compress

```go
NewCompress(key string) *Compress
```

LLM-powered session summarisation. Replaces session with summary. Options: `WithThreshold(n)`, `WithSummaryKey(key)`, `WithTemperature(t)`.

## Pipeline Helpers

All wrap pipz connectors for `*Thought`:

| Category | Functions |
|----------|-----------|
| Adapters | `Do`, `Transform`, `Effect`, `Mutate`, `Enrich` |
| Sequential | `Sequence` |
| Control Flow | `Filter`, `Switch`, `Gate` |
| Error Handling | `Fallback`, `Retry`, `Backoff`, `Timeout`, `Handle` |
| Resource Protection | `RateLimiter`, `CircuitBreaker` |
| Parallel | `Concurrent`, `Race`, `WorkerPool` |

## Configuration

```go
var (
    DefaultIntrospection              = false
    DefaultReasoningTemperature       = zyn.DefaultTemperatureDeterministic
    DefaultIntrospectionTemperature   = zyn.DefaultTemperatureCreative
)
```

## Capitan Signals

| Signal | Purpose |
|--------|---------|
| `ThoughtCreated` | New thought chain |
| `StepStarted/Completed/Failed` | Reasoning step lifecycle |
| `NoteAdded` | New note added |
| `NotesPublished` | Notes marked published |
| `IntrospectionCompleted` | Summary generated |
| `SiftDecided` | Semantic gate decision |
| `AmplifyIterationCompleted/Completed` | Refinement progress |
| `ConvergeBranchStarted/Completed` | Parallel branch lifecycle |
| `ConvergeSynthesisStarted` | Synthesis phase |

**Field keys:** FieldIntent, FieldTraceID, FieldNoteCount, FieldStepName, FieldStepType, FieldTemperature, FieldProvider, FieldNoteKey, FieldNoteSource, FieldContentSize, FieldStepDuration, FieldError, FieldDecision, FieldConfidence, FieldIterationCount, FieldBranchCount, FieldBranchName

## Sentinel Errors

`ErrNoProvider` — no provider configured at any resolution level.

## Thread Safety

- **Thought** — safe for concurrent reads, NOT safe for concurrent writes. Use `Clone()` for parallel processing.
- **Discern/Converge** — route/processor maps protected by `sync.RWMutex`
- **Global provider** — `sync.RWMutex` protected
- **Note index** — `sync.Map` for fast key lookup

## File Layout

```
cogito/
├── thought.go       # Thought & Note types
├── provider.go      # Provider interface & resolution
├── config.go        # Global configuration
├── signals.go       # Signal & field definitions
├── introspection.go # Shared introspection logic
├── decide.go        # Binary decisions
├── analyze.go       # Structured extraction
├── categorize.go    # Classification
├── assess.go        # Sentiment analysis
├── prioritize.go    # Ranking
├── reflect.go       # Self-consolidation
├── sift.go          # Semantic gates
├── discern.go       # Semantic routing
├── amplify.go       # Iterative refinement
├── converge.go      # Parallel synthesis
├── reset.go         # Session clear
├── truncate.go      # Session sliding window
├── compress.go      # Session LLM summarisation
├── helpers.go       # Pipeline adapter functions
└── testing/
    └── helpers.go   # NewTestThought, RequireContent
```

## Common Patterns

**Sequential reasoning:**

```go
thought := cogito.New(ctx, "analyze situation")
thought.SetContent(ctx, "input", inputText, "user")

pipeline := cogito.Sequence(identity,
    cogito.NewAnalyze[Metadata]("metadata", "Extract key data"),
    cogito.NewDecide("escalate", "Should we escalate?"),
    cogito.NewCategorize("priority", "Priority level?", []string{"low", "medium", "high"}),
)
result, _ := pipeline.Process(ctx, thought)
```

**Semantic routing:**

```go
router := cogito.NewDiscern("route", "What type?", []string{"billing", "technical"})
router.AddRoute("billing", billingProcessor)
router.AddRoute("technical", technicalProcessor)
router.SetFallback(generalProcessor)
```

**Parallel synthesis:**

```go
converge := cogito.NewConverge("unified",
    "Synthesise into a recommendation",
    technicalAnalyzer, businessAnalyzer, riskAnalyzer,
)
```

**Session management for long chains:**

```go
pipeline := cogito.Sequence(identity,
    // Many reasoning steps...
    cogito.NewCompress("summary").WithThreshold(20),
    cogito.NewReset("fresh").WithPreserveNote("summary"),
    // Continue with compressed context
)
```

## Ecosystem

Cogito depends on:
- **zyn** — LLM synapses (Binary, Extract, Classification, Sentiment, Transform, Ranking)
- **pipz** — pipeline composition
- **capitan** — observability

Cogito is consumed by:
- Applications for autonomous reasoning and LLM orchestration
