# Boundaries

Data transformation at package edges — parsing, validation, normalisation, and type conversion patterns observed across zoobzio packages.

## Entry Boundaries

Data entering the package gets normalised immediately. No raw external data propagates past the entry point.

### Type Normalisation

```go
// sentinel — normalise pointer types at the boundary
func TryInspect[T any]() (Metadata, error) {
    var zero T
    t := reflect.TypeOf(zero)

    if t != nil && t.Kind() != reflect.Struct {
        if t.Kind() == reflect.Ptr && t.Elem().Kind() == reflect.Struct {
            t = t.Elem()  // Strip pointer — internal code works with struct types
        } else {
            return Metadata{}, ErrNotStruct
        }
    }
    // ...
}
```

### Input Validation

Validate at the boundary, not deep in the call stack:

```go
// zyn — validate before processing
func (s *Service[T]) Execute(ctx context.Context, session *Session, prompt *Prompt, temperature float32) (T, error) {
    // Build and validate at the entry point
    messages := make([]Message, len(req.Messages)+1)
    copy(messages, req.Messages)
    messages[len(messages)-1] = Message{Role: RoleUser, Content: promptStr}

    // Call provider with validated input
    resp, err := provider.Call(ctx, messages, req.Temperature)
    // ...
}
```

### Cache-or-Compute

Check the cache at the boundary, before doing expensive work:

```go
// sentinel — check cache before extraction
fqdn := getFQDN(t)
if cached, exists := instance.cache.Get(fqdn); exists {
    return cached, nil
}
metadata := instance.extractMetadata(t)
instance.cache.Set(fqdn, metadata)
return metadata, nil
```

## Exit Boundaries

Data leaving the package gets transformed into the consumer's expected form.

### Parse and Validate Response

```go
// zyn — parse and validate LLM response at exit
resp, err := provider.Call(ctx, messages, req.Temperature)
if err != nil {
    return result, fmt.Errorf("provider call: %w", err)
}

var result T
if err := json.Unmarshal([]byte(resp.Content), &result); err != nil {
    return result, fmt.Errorf("response parse: %w", err)
}

if err := result.Validate(); err != nil {
    return result, err
}
return result, nil
```

**Pattern:** Parse → Validate → Return. Never return unparsed or unvalidated data to the caller.

### Schema Generation at Construction

When output must conform to a schema, generate the schema once at construction time:

```go
// zyn — generate JSON schema for LLM response constraint
func Analyze[T any](what string, provider Provider, opts ...Option) (*AnalyzeSynapse[T], error) {
    schema, err := generateJSONSchema[AnalyzeResponse]()
    if err != nil {
        return nil, fmt.Errorf("analyze synapse: %w", err)
    }
    // Schema used for every subsequent call — not regenerated
}
```

## Defensive Copying

Data crossing boundaries gets cloned to prevent aliasing:

```go
// pipz — clone processor slice at construction
func NewSequence[T any](identity Identity, processors ...Chainable[T]) *Sequence[T] {
    return &Sequence[T]{
        identity:   identity,
        processors: slices.Clone(processors),  // Defensive copy
    }
}
```

**Principle:** Slices and maps passed into a constructor are cloned. The type owns its data — callers cannot mutate internal state through retained references.

## Context at Boundaries

Context flows through boundaries for cancellation, timeouts, and tracing — not for passing business data between functions:

```go
// Context for cancellation and timeout
func (h *Handle[T]) Process(ctx context.Context, input T) (result T, err error) {
    result, err = processor.Process(ctx, input)
}

// pipz checks context errors at processing boundaries
if !errors.Is(err, context.DeadlineExceeded) { }
if errors.Is(err, context.Canceled) { }
```

Context values are appropriate for cross-cutting concerns like trace IDs, request IDs, and correlation metadata — things that need to flow through the call chain without polluting function signatures. Business data belongs in parameters.

## Anti-Patterns

| Anti-pattern | Zoobzio approach |
|-------------|-----------------|
| Validating deep in the call stack | Validate at entry boundary |
| Returning unparsed external data | Parse and validate at exit boundary |
| Sharing mutable references across boundary | Defensive copy at construction |
| Regenerating schemas per call | Generate once at construction |
| Passing business data through context values | Context for cancellation, timeouts, and tracing; business data as parameters |

## Checklist

- [ ] External data normalised at entry — no raw data propagates internally
- [ ] Input validation happens at the boundary, not deep in the stack
- [ ] Cache checks happen at the boundary, before expensive computation
- [ ] Response data parsed and validated before returning to caller
- [ ] Schemas and constraints generated once at construction
- [ ] Slices and maps cloned at construction boundaries
- [ ] Context used for cancellation, timeouts, and tracing — not business data
