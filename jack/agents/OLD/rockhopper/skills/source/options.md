# Options

Constructor and configuration patterns observed across zoobzio packages. Functional options are the standard mechanism for configurable types.

## Constructors

Every exported type has a constructor. The pattern depends on complexity:

### Simple Types — Direct Construction

Types with no configuration return a ready-to-use value:

```go
// sentinel
func NewCache() *Cache {
    return &Cache{
        store: make(map[string]Metadata),
    }
}
```

### Configurable Types — Functional Options

Types with optional configuration accept variadic options:

```go
// capitan
type Option func(*Capitan)

func New(opts ...Option) *Capitan {
    c := &Capitan{
        registry:   make(map[Signal][]*Listener),
        workers:    make(map[Signal]*workerState),
        shutdown:   make(chan struct{}),
        bufferSize: 16,
    }
    for _, opt := range opts {
        opt(c)
    }
    return c
}
```

### Generic Types — Type Parameters in Constructor

Generic types take the type parameter at construction:

```go
// pipz
func NewSequence[T any](identity Identity, processors ...Chainable[T]) *Sequence[T] {
    return &Sequence[T]{
        identity:   identity,
        processors: slices.Clone(processors),
    }
}
```

## Functional Options

### The Option Type

Always a function that mutates the target type:

```go
type Option func(*Capitan)
```

### With-Prefixed Option Functions

Each option is a `With*` function that returns an `Option`:

```go
// capitan
func WithBufferSize(size int) Option {
    return func(c *Capitan) {
        if size > 0 {
            c.bufferSize = size
        }
    }
}

func WithPanicHandler(handler PanicHandler) Option {
    return func(c *Capitan) {
        c.panicHandler = handler
    }
}
```

### Composing Options

Options that wrap or compose other components:

```go
// zyn — options that wrap pipelines
type Option func(pipz.Chainable[*SynapseRequest]) pipz.Chainable[*SynapseRequest]

func WithRetry(maxAttempts int) Option {
    return func(pipeline pipz.Chainable[*SynapseRequest]) pipz.Chainable[*SynapseRequest] {
        return pipz.NewRetry(retryID, pipeline, maxAttempts)
    }
}
```

### Deferred Application

Options can be stored and applied later:

```go
// capitan — Configure stores options for later application
func Configure(opts ...Option) {
    defaultOptMu.Lock()
    defaultOptions = opts
    defaultOptMu.Unlock()
}
```

## Constructor Naming

| Pattern | When to use | Example |
|---------|------------|---------|
| `New` | Primary constructor for the package's main type | `capitan.New()` |
| `New[Type]` | Constructor for a named type | `NewCache()`, `NewSequence[T]()` |
| `[Type]From[Source]` | Constructor that derives from existing data | Not yet observed — reserved |

## Conventions

- Defaults are set in the constructor body, not in global state
- Options are applied in order; last write wins
- Validation happens inside options (e.g., `if size > 0`)
- Constructor returns a fully initialised value — no lazy setup, no `Init()` methods
- Immutable data (slices, maps) is cloned at construction: `slices.Clone(processors)`

## Anti-Patterns

| Anti-pattern | Zoobzio approach |
|-------------|-----------------|
| Required parameters as options | Required parameters are positional arguments |
| `Init()` / `Setup()` after construction | Constructor returns ready-to-use value |
| Config struct with many fields | Functional options for optional configuration |
| Global defaults via package vars | `Configure()` with mutex for deferred option storage |
| Builder pattern with method chaining | Functional options — simpler, composable |

## Checklist

- [ ] Every exported type has a constructor
- [ ] Configurable types use functional options (`Option func(*Type)`)
- [ ] Option functions are `With*`-prefixed
- [ ] Required parameters are positional; optional parameters are options
- [ ] Defaults are set in the constructor body
- [ ] Constructor returns a fully initialised, ready-to-use value
- [ ] Immutable data is cloned at construction
- [ ] Options validate their own inputs
