# Errors

Error handling patterns observed across zoobzio packages. Three mechanisms — sentinel errors, custom types, and wrapping — each with a specific purpose.

## Sentinel Errors

Package-level variables for conditions that callers check with `errors.Is`:

```go
// sentinel
var ErrNotStruct = errors.New("sentinel: only struct types are supported")

// pipz
var (
    ErrIndexOutOfBounds = errors.New("index out of bounds")
    ErrEmptySequence    = errors.New("sequence is empty")
    ErrInvalidRange     = errors.New("invalid range")
)
```

### Conventions

- Prefixed with `Err`
- Created with `errors.New` — no `fmt.Errorf` for sentinels
- Package-prefixed message when the error may propagate far from its origin (`"sentinel: ..."`)
- Grouped in a `var` block at the top of the file that owns the concern

### Exported vs Unexported

Export when callers outside the package need to check for the condition. Keep unexported when the error is internal control flow.

```go
// Exported — callers branch on this
var ErrNotStruct = errors.New("sentinel: only struct types are supported")

// Unexported — only used internally
var errPoolExhausted = errors.New("pool exhausted")
```

The test: does a consumer of this package need to distinguish this condition from a generic failure? If yes, export. If no, it's an implementation detail.

### When to Use

Sentinel errors represent **conditions the caller can reasonably check for and handle**. If the caller would only ever log the error and fail, a sentinel is unnecessary — just return `fmt.Errorf`.

## Custom Error Types

Struct types that implement `error` when the error needs to carry structured context:

```go
// pipz — error with processing context
type Error[T any] struct {
    Timestamp time.Time
    InputData T
    Err       error
    Path      []Identity
    Duration  time.Duration
    Timeout   bool
    Canceled  bool
}

func (e *Error[T]) Error() string {
    if e.Timeout {
        return fmt.Sprintf("%s timed out after %v: %v", path, e.Duration, e.Err)
    }
    // ...
}

func (e *Error[T]) Unwrap() error {
    return e.Err
}

// capitan — configuration validation error
type ConfigError struct {
    Pattern string
    Field   string
    Reason  string
}

func (e *ConfigError) Error() string {
    return "config error for " + e.Pattern + ": " + e.Field + " " + e.Reason
}
```

### Conventions

- Always implement `Unwrap() error` when wrapping a cause
- Callers check with `errors.As`
- Placed in `error.go` or the file owning the concern (e.g., `config.go` for `ConfigError`)
- Generic when carrying input data (see `Error[T]` in pipz)

### When to Use

Custom error types are for **errors the caller needs to inspect structurally** — extracting the field that failed, the path that errored, the input that triggered it.

## Wrapping with fmt.Errorf

For adding context to errors as they propagate up the call stack:

```go
return Data{}, fmt.Errorf("invalid JSON: %w", err)
return result, fmt.Errorf("invalid prompt: %w", err)
return nil, fmt.Errorf("analyze synapse: %w", err)
```

### Conventions

- Always use `%w` (not `%v`) to preserve the error chain
- Context message is the operation that failed, not the error that occurred
- Format: `"<operation>: %w"` — short, lowercase, no trailing punctuation

### When to Use

Wrapping is the default. Every error that crosses a function boundary gets wrapped with the operation that was attempted. This creates readable error chains:

```
analyze synapse: invalid prompt: missing required field "what"
```

## Error Checking

```go
// Sentinel errors — errors.Is
if errors.Is(err, context.DeadlineExceeded) { }
if errors.Is(err, ErrNotStruct) { }

// Custom error types — errors.As
var pipeErr *pipz.Error[MyData]
if errors.As(err, &pipeErr) {
    // inspect pipeErr.Path, pipeErr.InputData, etc.
}

var configErr *ConfigError
if errors.As(lastErr, &configErr) {
    // inspect configErr.Field, configErr.Reason
}
```

**Never** use direct type assertions (`err.(*Type)`) — always `errors.Is` or `errors.As`.

## Anti-Patterns

| Anti-pattern | Zoobzio approach |
|-------------|-----------------|
| `fmt.Errorf` for sentinel errors | `errors.New` for checkable conditions |
| Sentinel for every error | Only for conditions the caller can handle differently |
| `%v` for wrapping | `%w` to preserve the chain |
| Type assertion on errors | `errors.Is` / `errors.As` |
| Generic error messages | Operation-prefixed: `"operation: %w"` |

## Checklist

- [ ] Sentinel errors use `errors.New` with `Err`/`err` prefix
- [ ] Exported only when callers outside the package need to check for the condition
- [ ] Sentinel errors are only for conditions callers will check
- [ ] Custom error types implement `Unwrap()` when wrapping a cause
- [ ] Custom error types placed in the file owning the concern
- [ ] `fmt.Errorf` uses `%w` for wrapping, not `%v`
- [ ] Wrap messages describe the operation, not the error
- [ ] Error checking uses `errors.Is` and `errors.As`, never type assertions
