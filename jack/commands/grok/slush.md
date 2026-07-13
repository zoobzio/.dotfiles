# Slush

Deep understanding of `github.com/zoobzio/slush` — type-safe service locator with composable access checks.

## Core Concepts

Slush is a minimal service locator using Go generics for compile-time type safety. Services are registered by type via `Register[T]`, retrieved via `Use[T]`, and optionally gated by composable `Guard` functions. Registration requires a `Key` obtained from `Start()` — an unforgeable capability token. The registry can be frozen to prevent runtime mutations.

- **Key** — unforgeable capability for registration (unexported inner pointer prevents forgery)
- **Guard** — `func(context.Context) error` — composable access check
- **Handle[T]** — configuration handle returned from Register, supports guard chaining
- **Lifecycle:** `Start()` → `Register[T]()` → `Freeze()` → `Use[T]()`
- **Copy-on-write guards** — guard list modifications allocate new slices to avoid races with concurrent readers

**Dependencies:** `capitan` (observability), `sentinel` (type metadata)

## Public API

### Lifecycle

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Start` | `Start() Key` | Initialize registry, return registration key. Panics if called twice |
| `Freeze` | `Freeze(k Key)` | Prevent further registration. Panics if key invalid |

### Registration

```go
func Register[T any](k Key, impl T) *Handle[T]
```

Panics if: Start not called, key invalid, or registry frozen. Same type registered again overwrites previous.

### Retrieval

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Use` | `Use[T any](ctx context.Context) (T, error)` | Retrieve service, run guards. Returns `ErrNotFound` or `ErrAccessDenied` |
| `MustUse` | `MustUse[T any](ctx context.Context) T` | Panics on error |

### Introspection

```go
func Services(k Key) ([]ServiceInfo, error)
```

```go
type ServiceInfo struct {
    Interface  string            // Interface FQDN
    Impl       string            // Implementation FQDN
    Metadata   sentinel.Metadata // From sentinel cache
    GuardCount int
}
```

### Handle[T]

```go
func (h *Handle[T]) Guard(g Guard) *Handle[T]
```

Chainable. Guards evaluated in order; first error stops evaluation. Copy-on-write for thread safety.

### Guard

```go
type Guard func(ctx context.Context) error
```

### Key

```go
type Key struct {
    k *key  // Unexported inner pointer — unforgeable
}
```

## Error Types

| Error | Purpose |
|-------|---------|
| `ErrNotFound` | Service not registered |
| `ErrAccessDenied` | Guard validation failed (wraps guard error via `errors.Join`) |
| `ErrInvalidKey` | Invalid key |

## Capitan Signals

| Signal | Severity | Purpose |
|--------|----------|---------|
| `SignalRegistered` | — | Service registered |
| `SignalAccessed` | Debug | Service retrieved |
| `SignalDenied` | Warn | Guard rejected access |
| `SignalNotFound` | Warn | Service not found |

**Field keys:** `KeyInterface`, `KeyImpl`, `KeyError`

## Thread Safety

- **Global registry** — `sync.RWMutex` protects services map, started/frozen state, guard lists
- **Guard evaluation** — guards snapshotted under RLock, evaluated outside lock
- **Handle[T].Guard()** — copy-on-write guard slice, safe to call concurrently with `Use[T]()`
- **Panics** (not errors) for programming mistakes: double Start, invalid Key, Register when frozen

## File Layout

```
slush/
├── slush.go    # Complete implementation — registry, Key, Handle[T], Guard
└── reset.go    # Test-only: Reset(), Unregister[T]() (build tag: testing || integration)
```

## Common Patterns

**Basic registration:**

```go
k := slush.Start()
slush.Register[UserService](k, &userServiceImpl{})
slush.Register[AuthService](k, &authServiceImpl{})
slush.Freeze(k)

svc, _ := slush.Use[UserService](ctx)
```

**Guarded access:**

```go
slush.Register[AdminService](k, &adminImpl{}).
    Guard(requireAdmin).
    Guard(requireMFA)
```

**Error handling:**

```go
svc, err := slush.Use[MyService](ctx)
if errors.Is(err, slush.ErrNotFound) {
    // Not registered
}
if errors.Is(err, slush.ErrAccessDenied) {
    // Guard failed
}
```

## Ecosystem

Slush depends on:
- **capitan** — observability signals
- **sentinel** — type metadata for ServiceInfo

Slush is consumed by:
- **sum** — application framework wraps slush for service registration
- Applications for dependency management with access control
