# Concerns

Separation of concerns, interface design, and composition patterns observed across zoobzio packages.

## Interface Design

### Small Interfaces

Interfaces are small — typically 1 to 4 methods:

```go
// capitan — 2 methods
type Key interface {
    Name() string
    Variant() Variant
}

// pipz — 1 method
type Cloner[T any] interface {
    Clone() T
}

// zyn — 1 method
type Validator interface {
    Validate() error
}

// pipz — 4 methods (the largest observed)
type Chainable[T any] interface {
    Process(context.Context, T) (T, error)
    Identity() Identity
    Schema() Node
    Close() error
}
```

**Principle:** An interface describes one role. If an interface has many methods, it likely describes multiple roles that should be separate interfaces.

### Consumer-Side Interfaces

Interfaces are defined where they are *consumed*, not where they are *implemented*:

```go
// pipz/api.go — defines Chainable (the consumer contract)
type Chainable[T any] interface { ... }

// pipz/sequence.go — Sequence implements Chainable (but doesn't define it)
type Sequence[T any] struct { ... }
func (c *Sequence[T]) Process(ctx context.Context, data T) (T, error) { ... }
```

Interfaces go in `api.go`. Implementations go in their own files.

### Interface Placement

| Location | Contains |
|----------|----------|
| `api.go` | Public interfaces — the contracts consumers depend on |
| `schema.go` | Schema-related interfaces and types |
| Implementation file | No interface definitions (unless internal-only) |

## Composition

### Struct Composition via Fields

Types compose by holding references to their dependencies, not by embedding:

```go
// pipz — Handle composes a processor and an error handler
type Handle[T any] struct {
    processor    Chainable[T]
    errorHandler Chainable[*Error[T]]
    identity     Identity
    mu           sync.RWMutex
    closeOnce    sync.Once
    closeErr     error
}

// capitan — Capitan contains registered listeners and workers
type Capitan struct {
    registry     map[Signal][]*Listener
    workers      map[Signal]*workerState
    observers    []*Observer
    shutdown     chan struct{}
    shutdownOnce sync.Once
    wg           sync.WaitGroup
    mu           sync.RWMutex
    bufferSize   int
    config       Config
}
```

**Principle:** Composition over embedding. Dependencies are explicit fields, not anonymous embeds. This makes the dependency graph visible in the struct definition.

### Containers are Pointers, Data is Values

```go
// Mutable containers with state → pointer receivers
func (c *Sequence[T]) Process(ctx context.Context, data T) (T, error) { ... }
func (l *Listener) Close() { ... }

// Immutable data types → value receivers
func (k GenericKey[T]) Name() string { return k.name }
func (k GenericKey[T]) Variant() Variant { return k.variant }
```

### Concurrency Infrastructure

Types that manage state include their own synchronisation:

```go
type Sequence[T any] struct {
    processors []Chainable[T]
    mu         sync.RWMutex   // Protects processors
    closeOnce  sync.Once      // Ensures single close
    closeErr   error
}

type Capitan struct {
    registry map[Signal][]*Listener
    mu       sync.RWMutex    // Protects registry
    shutdown chan struct{}    // Signals shutdown
    wg       sync.WaitGroup  // Tracks goroutines
}
```

**Principle:** Each type owns its own concurrency. No external locking. Mutexes, channels, and WaitGroups are fields of the type they protect.

## Observability

Types that need external observability emit signals through capitan rather than exposing internal state:

```go
// pipz/signals.go — signal definitions
var (
    RetryAttemptStart = capitan.NewSignal("retry.attempt-start")
    RetryAttemptEnd   = capitan.NewSignal("retry.attempt-end")
    TimeoutExceeded   = capitan.NewSignal("timeout.exceeded")
)

// pipz/retry.go — emit signal during processing
capitan.Emit(RetryAttemptStart, capitan.WithField(attemptKey, attempt))
```

**Principle:** Observability through signals, not through exported fields or getter methods. Internal state stays internal.

## Singleton Pattern

Foundation packages use a package-level singleton when there should be exactly one instance:

```go
// sentinel — global instance initialised at package init
var instance = &Sentinel{
    cache: NewCache(),
}

// capitan — default instance with sync.Once
var (
    defaultCapitan *Capitan
    defaultOnce    sync.Once
)
```

## Anti-Patterns

| Anti-pattern | Zoobzio approach |
|-------------|-----------------|
| Large interfaces (>4 methods) | Small, role-based interfaces |
| Interface defined with implementation | Interface in `api.go`, implementation in its own file |
| Struct embedding for composition | Explicit field composition |
| External locking of shared state | Types own their own concurrency primitives |
| Exposing internal state via getters | Signal-based observability |

## Checklist

- [ ] Interfaces are small (1-4 methods) and describe one role
- [ ] Interfaces defined in `api.go`, implementations in separate files
- [ ] Types compose via explicit fields, not embedding
- [ ] Mutable containers use pointer receivers; immutable data uses value receivers
- [ ] Each type owns its own concurrency primitives
- [ ] Observability via capitan signals, not exposed state
- [ ] Dependencies are visible in the struct definition
