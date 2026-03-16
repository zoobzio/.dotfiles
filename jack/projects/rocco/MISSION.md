# Mission: rocco

Type-safe HTTP framework with automatic OpenAPI 3.1 generation.

## Purpose

Provide an HTTP framework where types become endpoints — Go structs defining request and response payloads automatically generate validation rules, OpenAPI schemas, error contracts, and documentation. Define types once, derive everything else.

Rocco exists because API development requires tight coupling between types, validation, documentation, and error handling. By generating OpenAPI specs from the same types that handle requests, documentation is always accurate and validation is always present.

## What This Package Contains

- `Handler[In, Out]` generic type-safe request handler with automatic OpenAPI schema generation
- `StreamHandler[In, Out]` for Server-Sent Events (SSE)
- `Engine` for routing, middleware, OpenAPI generation, and HTTP server lifecycle
- Convenience constructors: GET, POST, PUT, PATCH, DELETE
- Identity-based authentication with scope and role authorization
- Handler builder methods for metadata, routing, responses, errors, auth, middleware
- Pre-defined typed errors (400-503) with generic details types
- Lifecycle hooks: Validatable, Entryable, Sendable
- Automatic validation via check integration
- Permission-filtered OpenAPI spec generation
- Capitan signals for comprehensive lifecycle observability
- Subpackages: session management, OAuth 2.0, Auth0 integration

## What This Package Does NOT Contain

- Database or storage integration
- Business logic — handlers delegate to services
- Frontend rendering or templating
- WebSocket support (SSE only for streaming)
- Rate limiting implementation (signals only — implementation is application-level)

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Type metadata for OpenAPI schema generation |
| `capitan` | Lifecycle event signals |
| `check` | Struct validation |
| `openapi` | OpenAPI 3.1 type definitions |

Rocco is consumed by applications as their HTTP framework, and by sum as the HTTP engine.

## Design Constraints

- Types become endpoints — OpenAPI generated from Go struct definitions at handler creation
- Handler registration is not thread-safe — complete before Start()
- Errors are immutable — builder methods return new instances
- OpenAPI spec cached via sync.Once after first generation
- Identity interface abstracts authentication — rocco does not implement auth providers

## Success Criteria

A developer can:
1. Define a handler with typed request/response and get automatic OpenAPI documentation
2. Add validation, authentication, and error contracts through builder methods
3. Stream SSE events with type safety
4. Generate a complete OpenAPI 3.1 spec filtered by caller permissions
5. Observe all request lifecycle events via capitan signals
6. Use pre-defined error types with typed details for consistent API error responses

## Non-Goals

- Implementing authentication providers — rocco defines the Identity interface
- Database or storage integration
- Frontend rendering
- WebSocket support
- Rate limiting implementation (observability only)
