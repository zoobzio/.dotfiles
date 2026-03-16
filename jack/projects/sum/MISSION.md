# Mission: sum

Application framework unifying HTTP, data, configuration, and services into a single coherent API.

## Purpose

Provide a top-level framework that wires together rocco (HTTP), scio (data catalog), slush (service registry), cereal (serialization), fig (configuration), grub (storage), and capitan (events) so that applications have a single entry point for lifecycle management, data registration, boundary processing, and typed event coordination.

Sum exists because building a zoobzio application requires coordinating many packages — each excellent at one thing — into a running service. Without sum, every application would reimplement the same bootstrap, wiring, and lifecycle patterns.

## What This Package Contains

- Singleton `Service` with unified lifecycle management (Start/Run/Shutdown with signal handling)
- Typed service registry with token-based access control (`Register`, `Use`, `Freeze`)
- Unforgeable capability tokens for service access gating
- Typed bidirectional events via capitan signals (`Event[T]`)
- Boundary processors that inherit shared crypto configuration from the service
- Auto-registering data wrappers for SQL databases, key-value stores, and blob buckets
- Configuration loading via fig with automatic service locator registration
- Re-exported type aliases and helpers from underlying packages for ergonomic consumer APIs

## What This Package Does NOT Contain

- HTTP routing or endpoint definitions — that is rocco's domain
- Storage provider implementations — grub provides those
- Serialization logic — cereal handles encrypt/hash/mask
- Configuration parsing — fig handles that
- Event dispatch internals — capitan owns the signal system
- Service discovery or mesh networking — aegis handles that

## Ecosystem Position

Sum is the top of the dependency tree. It composes:

| Dependency | Role |
|------------|------|
| `rocco` | HTTP engine with OpenAPI generation |
| `scio` | URI-based data catalog with atomic operations |
| `slush` | Service locator with composable access checks |
| `cereal` | Boundary-aware serialization |
| `fig` | Configuration loading via struct tags |
| `grub` | Provider-agnostic storage abstractions |
| `capitan` | Type-safe event coordination |
| `sentinel` | Struct introspection for type metadata |
| `astql` | SQL rendering for database wrappers |

All zoobzio applications consume sum as their framework entry point.

## Design Constraints

- Singleton pattern — one Service instance per process
- Thread-safe — `sync.RWMutex` protects mutable state, all delegated subsystems are concurrent-safe
- Registry freeze — `Freeze(k)` locks registrations, preventing runtime mutation after bootstrap
- Token unforgability — UUID-based, unexported fields, cannot be constructed outside `NewToken`
- Auto-registration — data wrappers and boundaries register with scio/slush on creation, no manual catalog management

## Success Criteria

A developer can:
1. Bootstrap a complete application with HTTP, data, config, and services in under 20 lines
2. Register and retrieve typed services with compile-time safety
3. Gate service access with unforgeable tokens
4. Emit and listen to typed events without touching capitan directly
5. Create data wrappers that auto-register with the catalog
6. Configure boundary processors with shared crypto from a single service configuration
7. Start, run with signal handling, and gracefully shut down with one method call

## Non-Goals

- Replacing any of the underlying packages — sum composes, it does not reimplement
- Providing default implementations for storage, serialization, or configuration
- Managing multiple service instances — one singleton per process
- Cross-service communication — that is aegis/herald territory
- Opinionated application structure beyond lifecycle and registration
