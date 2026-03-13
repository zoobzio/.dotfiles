# Sum

Deep understanding of `github.com/zoobzio/sum` — application framework unifying HTTP, data, configuration, and services.

## Core Concepts

Sum is the top-level application framework that wires together rocco (HTTP), scio (data catalog), slush (service registry), cereal (serialization), and fig (configuration) into a single coherent API. `Service` is a singleton that provides unified lifecycle management (Start/Run/Shutdown), data wrappers that auto-register with scio, boundary processors that inherit shared crypto, and a typed event system.

- **Service** — singleton wrapping rocco.Engine + scio.Scio + cereal crypto configuration
- **Token** — unforgeable capability for service access control (UUID-based)
- **Event[T]** — typed bidirectional event with capitan signals
- **Boundary[T]** — cereal.Processor wrapper with auto-registration and shared crypto
- **Database[M] / Store[M] / Bucket[M]** — grub wrappers with auto scio registration

**Dependencies:** `rocco` (HTTP), `scio` (data catalog), `slush` (service registry), `cereal` (serialization), `fig` (configuration), `grub` (storage), `capitan` (events), `sentinel` (type metadata), `astql` (SQL rendering), `sqlx`, `uuid`

## Public API

### Service (Singleton)

```go
func New() *Service
```

Returns existing instance on subsequent calls.

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Engine` | `Engine() *rocco.Engine` | Underlying rocco engine |
| `Catalog` | `Catalog() *scio.Scio` | Underlying scio catalog |
| `Handle` | `Handle(endpoints ...rocco.Endpoint)` | Register HTTP endpoints |
| `Tag` | `Tag(name, description string)` | Register OpenAPI tag |
| `WithEncryptor` | `WithEncryptor(algo, enc) *Service` | Register encryptor (chainable) |
| `WithHasher` | `WithHasher(algo, h) *Service` | Register hasher (chainable) |
| `WithMasker` | `WithMasker(mt, m) *Service` | Register masker (chainable) |
| `WithCodec` | `WithCodec(codec) *Service` | Set default codec (chainable) |
| `Start` | `Start(host string, port int) error` | Begin serving (blocks) |
| `Shutdown` | `Shutdown(ctx) error` | Graceful shutdown |
| `Run` | `Run(host string, port int) error` | Start + signal handling (SIGINT/SIGTERM, 30s timeout) |

### Service Registry

Re-exports from slush with sum-specific additions:

| Function | Signature |
|----------|-----------|
| `Start` | `Start() Key` |
| `Freeze` | `Freeze(k Key)` |
| `Register` | `Register[T any](k Key, impl T) *Handle[T]` |
| `Use` | `Use[T any](ctx context.Context) (T, error)` |
| `MustUse` | `MustUse[T any](ctx context.Context) T` |
| `Services` | `Services(k Key) ([]ServiceInfo, error)` |

### Handle[T]

```go
type Handle[T any] struct {
    *slush.Handle[T]
}
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Guard` | `Guard(g Guard) *Handle[T]` | Add access check |
| `For` | `For(tokens ...Token) *Handle[T]` | Restrict to token holders (shorthand for `Guard(Require(tokens...))`) |

### Token

```go
func NewToken(name string) Token

func WithToken(ctx context.Context, t Token) context.Context
func Require(tokens ...Token) Guard
```

Token is unforgeable — UUID generated at creation, unexported fields.

### Event[T]

```go
func NewEvent[T any](signal capitan.Signal, level capitan.Severity) Event[T]
func NewDebugEvent[T any](signal capitan.Signal) Event[T]
func NewInfoEvent[T any](signal capitan.Signal) Event[T]
func NewWarnEvent[T any](signal capitan.Signal) Event[T]
func NewErrorEvent[T any](signal capitan.Signal) Event[T]
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Emit` | `Emit(ctx, data T)` | Dispatch event |
| `Listen` | `Listen(func(ctx, T)) *capitan.Listener` | Register callback |
| `ListenOnce` | `ListenOnce(func(ctx, T)) *capitan.Listener` | Fire once, auto-unregister |

### Boundary[T]

```go
func NewBoundary[T cereal.Cloner[T]](k Key) (*Boundary[T], error)
```

Wraps `cereal.Processor[T]`. Automatically applies all encryptors, hashers, maskers, and codec from Service. Auto-registers with service locator.

### Data Wrappers

All auto-register with the scio catalog on creation.

```go
func NewDatabase[M any](db *sqlx.DB, table string, renderer astql.Renderer) (*Database[M], error)
func NewStore[M any](provider grub.StoreProvider, name string) (*Store[M], error)
func NewBucket[M any](provider grub.BucketProvider, name string) (*Bucket[M], error)
```

Each wraps the corresponding grub type and inherits all its methods.

### Configuration

```go
func Config[T any](ctx context.Context, k Key, provider fig.SecretProvider) error
```

Loads configuration via fig, registers with service locator. Retrieve later with `Use[T](ctx)`.

### Re-exported Event Helpers

```go
var Emit  = capitan.Emit
var Debug = capitan.Debug
var Info  = capitan.Info
var Warn  = capitan.Warn
var Error = capitan.Error

var NewSignal     = capitan.NewSignal
var NewStringKey  = capitan.NewStringKey
var NewIntKey     = capitan.NewIntKey
var NewInt64Key   = capitan.NewInt64Key
var NewFloat64Key = capitan.NewFloat64Key
var NewBoolKey    = capitan.NewBoolKey
var NewTimeKey    = capitan.NewTimeKey
var NewDurationKey = capitan.NewDurationKey
var NewErrorKey   = capitan.NewErrorKey
```

### Type Aliases

```go
type Guard = slush.Guard
type ServiceInfo = slush.ServiceInfo
type Key = slush.Key
type Signal = capitan.Signal
type Severity = capitan.Severity
type Codec = cereal.Codec
type Encryptor = cereal.Encryptor
type Hasher = cereal.Hasher
type Masker = cereal.Masker
type EncryptAlgo = cereal.EncryptAlgo
type HashAlgo = cereal.HashAlgo
type MaskType = cereal.MaskType
```

## Error Types

| Error | Source | Purpose |
|-------|--------|---------|
| `ErrNotFound` | slush | Service not registered |
| `ErrAccessDenied` | slush | Guard validation failed |
| `ErrInvalidKey` | slush | Invalid key |
| `ErrTokenRequired` | sum | No token in context |

## Capitan Signals

Re-exports from slush: `SignalRegistered`, `SignalAccessed`, `SignalDenied`, `SignalNotFound`.

**Field keys:** `KeyInterface`, `KeyImpl`, `KeyError`.

## Thread Safety

- **Service** — `sync.RWMutex` protects encryptors, hashers, maskers, codec maps
- **Token** — immutable after creation
- **Event[T]** — read-only after creation; emission delegates to capitan
- **Registry** — delegates to slush (thread-safe)
- **Data wrappers** — delegates to grub (thread-safe)

## File Layout

```
sum/
├── service.go    # Singleton Service, lifecycle (Start/Run/Shutdown)
├── registry.go   # Service registry (Start/Freeze/Register/Use), re-exports
├── event.go      # Event[T], capitan re-exports
├── boundary.go   # Boundary[T], cereal type aliases
├── token.go      # Token, WithToken, Require
├── data.go       # Database[M], Store[M], Bucket[M]
├── config.go     # Config[T] — fig + service locator
└── reset.go      # Test-only: Reset(), Unregister[T]() (build tag: testing || integration)
```

## Common Patterns

**Application bootstrap:**

```go
svc := sum.New()
k := sum.Start()

// Configuration
sum.Config[AppConfig](ctx, k, nil)

// Data
db, _ := sum.NewDatabase[User](sqlxDB, "users", astql.PostgresRenderer())
store, _ := sum.NewStore[Session](redisProvider, "sessions")

// Services with token-based access
adminToken := sum.NewToken("admin")
sum.Register[AdminService](k, &adminSvc{}).For(adminToken)

// HTTP
svc.Handle(userEndpoints...)
sum.Freeze(k)
svc.Run("0.0.0.0", 8080)
```

**Typed events:**

```go
var UserCreated = sum.NewInfoEvent[User](sum.NewSignal("user.created", "New user"))
UserCreated.Emit(ctx, newUser)
UserCreated.Listen(func(ctx context.Context, u User) {
    // Handle event
})
```

**Token-gated access:**

```go
ctx = sum.WithToken(ctx, adminToken)
svc, _ := sum.Use[AdminService](ctx)  // Passes Require guard
```

## Ecosystem

Sum depends on:
- **rocco** — HTTP engine with OpenAPI
- **scio** — URI-based data catalog
- **slush** — service locator
- **cereal** — boundary serialization
- **fig** — configuration loading
- **grub** — storage abstractions
- **capitan** — observability
- **sentinel** — type metadata
- **astql** — SQL rendering

Sum is consumed by:
- Applications as the top-level framework
