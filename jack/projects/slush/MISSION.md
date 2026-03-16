# Mission: slush

Type-safe service locator with composable access checks.

## Purpose

Provide a minimal service locator using Go generics for compile-time type safety. Services are registered by type via Register[T], retrieved via Use[T], and optionally gated by composable Guard functions. Registration requires an unforgeable Key capability token.

Slush exists because dependency management in Go applications needs type-safe service retrieval with composable access control, without the complexity of full DI frameworks.

## What This Package Contains

- Key as unforgeable capability token for registration (unexported inner pointer prevents forgery)
- Register[T] for type-safe service registration with key validation
- Use[T] and MustUse[T] for service retrieval with guard evaluation
- Handle[T] returned from Register for chainable guard attachment
- Guard functions (func(context.Context) error) for composable access checks
- Freeze(key) to prevent runtime registration mutations
- Services(key) for registry introspection with sentinel metadata
- Copy-on-write guard lists for thread-safe concurrent guard modification and evaluation
- Capitan signals for registration, access, denial, and not-found events
- Lifecycle: Start() > Register[T]() > Freeze() > Use[T]()

## What This Package Does NOT Contain

- Dependency injection with automatic wiring
- Constructor functions or factory registration
- Scope management (request, session, singleton)
- Service lifecycle management (start, stop, health)

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `capitan` | Observability signals for registry events |
| `sentinel` | Type metadata for ServiceInfo introspection |

Slush is consumed by:
- `sum` — application framework wraps slush for service registration
- Applications for dependency management with access control

## Design Constraints

- Global singleton registry — one per process
- Key is unforgeable — unexported inner pointer prevents construction outside Start()
- Panics for programming mistakes: double Start, invalid Key, Register when frozen
- Errors for runtime conditions: ErrNotFound, ErrAccessDenied
- Guard evaluation order is registration order — first error stops evaluation
- Copy-on-write guard slices — safe to modify guards concurrently with Use[T]()
- Registry freezable to prevent runtime mutations after initialization

## Success Criteria

A developer can:
1. Register services by type with compile-time safety
2. Retrieve services with automatic guard evaluation
3. Chain composable access checks on service registration
4. Freeze the registry to prevent runtime mutations
5. Introspect the registry for available services and their metadata

## Non-Goals

- Full dependency injection framework
- Automatic wiring or constructor injection
- Scope management (request-scoped, session-scoped)
- Service lifecycle management
