# Generics

Type parameter usage patterns observed across zoobzio packages. Generics are used extensively — they are the primary mechanism for type safety.

## Core Pattern: Parameterise on Data

Every type and function that processes data is generic over that data type. No `interface{}` in public APIs.

```go
// pipz — processor parameterised on T
type Processor[T any] struct {
    fn       func(context.Context, T) (T, error)
    identity Identity
}

// pipz — interface parameterised on T
type Chainable[T any] interface {
    Process(context.Context, T) (T, error)
    Identity() Identity
    Schema() Node
    Close() error
}

// zyn — service parameterised on response type
type Service[T Validator] struct {
    pipeline           pipz.Chainable[*SynapseRequest]
    synapseType        string
    providerName       string
    defaultTemperature float32
}
```

**Principle:** If a function accepts data, transforms data, or returns data — parameterise it. The type parameter flows through the entire call chain.

## Generic Functions

Functions that operate on parameterised data accept and return the same type parameter:

```go
// pipz — constructors return Processor[T]
func Apply[T any](identity Identity, fn func(context.Context, T) (T, error)) Processor[T]
func Transform[T any](identity Identity, fn func(context.Context, T) T) Processor[T]
func Effect[T any](identity Identity, fn func(context.Context, T)) Processor[T]

// pipz — connectors accept and compose Chainable[T]
func NewSequence[T any](identity Identity, processors ...Chainable[T]) *Sequence[T]
func NewFallback[T any](identity Identity, primary, fallback Chainable[T]) *Fallback[T]

// sentinel — inspection parameterised on struct type
func Inspect[T any]() Metadata
func TryInspect[T any]() (Metadata, error)

// zyn — synapses parameterised on output type
func Analyze[T any](what string, provider Provider, opts ...Option) (*AnalyzeSynapse[T], error)
```

## Type Aliases for Common Instantiations

When a generic type is frequently used with specific type parameters, create aliases:

```go
// capitan — GenericKey instantiated for common types
type GenericKey[T any] struct {
    name    string
    variant Variant
}

type StringKey = GenericKey[string]
type IntKey = GenericKey[int]
type Int32Key = GenericKey[int32]
type Int64Key = GenericKey[int64]
type Float32Key = GenericKey[float32]
type Float64Key = GenericKey[float64]
type BoolKey = GenericKey[bool]
type TimeKey = GenericKey[time.Time]
type DurationKey = GenericKey[time.Duration]
```

**Principle:** Aliases are convenience, not abstraction. The generic type remains the source of truth. Consumers can instantiate `GenericKey[CustomType]` directly.

## Constraints

Use `any` for unconstrained type parameters. Use named constraints when behaviour is required:

```go
// zyn — T must implement Validate()
type Service[T Validator] struct { ... }

type Validator interface {
    Validate() error
}

// pipz — T must be clonable for retry/fallback
type Cloner[T any] interface {
    Clone() T
}
```

**Principle:** Constrain only when the implementation calls methods on T. If T is only stored, passed, or returned — `any` is correct.

## Generic Error Types

Error types carry the input data type for debugging:

```go
// pipz — error wraps the input that caused the failure
type Error[T any] struct {
    Timestamp time.Time
    InputData T
    Err       error
    Path      []Identity
    Duration  time.Duration
    Timeout   bool
    Canceled  bool
}

func (e *Error[T]) Error() string { ... }
func (e *Error[T]) Unwrap() error { return e.Err }
```

**Principle:** When an error needs to carry context about the data that triggered it, parameterise the error type on the input type.

## Anti-Patterns

| Anti-pattern | Zoobzio approach |
|-------------|-----------------|
| `interface{}` in public APIs | Generics with `any` constraint |
| Type assertions at runtime | Type safety at compile time via generics |
| Reflection for type inspection | Only in sentinel (its explicit purpose) — nowhere else |
| Unconstrained generic with method calls | Named constraint interface |

## Checklist

- [ ] Types that process data are parameterised on that data type
- [ ] Functions accept and return consistent type parameters
- [ ] `any` used for unconstrained parameters; named constraints when methods are called
- [ ] No `interface{}` in public APIs
- [ ] Type aliases provided for common instantiations
- [ ] Error types parameterised when they carry input data
- [ ] Reflection avoided unless it is the package's purpose
