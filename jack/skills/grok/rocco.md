# Rocco

Deep understanding of `github.com/zoobzio/rocco` — type-safe HTTP framework with automatic OpenAPI 3.1.0 specification generation.

## Core Concepts

Rocco's central philosophy is **"types become endpoints"** — Go structs defining request and response payloads automatically generate validation rules, OpenAPI schemas, error contracts, and documentation. Define types once, derive everything else.

- **Handler[In, Out]** is a generic, type-safe request handler
- **StreamHandler[In, Out]** handles Server-Sent Events (SSE)
- **Engine** manages routing, middleware, and OpenAPI generation
- **Error[D]** is a generic error type with typed details
- **Sentinel** scans types at handler creation for schema generation

**Dependencies:** `sentinel` (type metadata), `capitan` (observability), `check` (validation), `openapi` (OpenAPI types)

## Public API

### Engine

| Function/Method | Signature | Behaviour |
|-----------------|-----------|-----------|
| `NewEngine` | `NewEngine() *Engine` | Create engine with default config |
| `WithMiddleware` | `WithMiddleware(mw...) *Engine` | Add global middleware |
| `WithAuthenticator` | `WithAuthenticator(extractor) *Engine` | Set identity extractor |
| `WithCodec` | `WithCodec(codec Codec) *Engine` | Set default codec |
| `WithSpec` | `WithSpec(spec *EngineSpec) *Engine` | Set OpenAPI metadata |
| `WithOpenAPIInfo` | `WithOpenAPIInfo(info) *Engine` | Set API info |
| `WithTag` | `WithTag(name, desc string) *Engine` | Add API tag |
| `WithTagGroup` | `WithTagGroup(name string, tags...) *Engine` | Group tags |
| `WithHandlers` | `WithHandlers(handlers...) *Engine` | Register handlers |
| `Router` | `Router() *http.ServeMux` | Access underlying mux |
| `Start` | `Start(host string, port int) error` | Start HTTP server |
| `Shutdown` | `Shutdown(ctx) error` | Graceful shutdown |
| `GenerateOpenAPI` | `GenerateOpenAPI(identity) *openapi.OpenAPI` | Generate spec (filtered by permissions) |

### Handler Constructors

| Function | Signature |
|----------|-----------|
| `NewHandler` | `NewHandler[In, Out](name, method, path string, fn func(*Request[In]) (Out, error)) *Handler[In, Out]` |
| `GET` | `GET[In, Out](path, fn) *Handler[In, Out]` |
| `POST` | `POST[In, Out](path, fn) *Handler[In, Out]` |
| `PUT` | `PUT[In, Out](path, fn) *Handler[In, Out]` |
| `PATCH` | `PATCH[In, Out](path, fn) *Handler[In, Out]` |
| `DELETE` | `DELETE[In, Out](path, fn) *Handler[In, Out]` |
| `NewStreamHandler` | `NewStreamHandler[In, Out](name, method, path, fn) *StreamHandler[In, Out]` |

### Handler Builder Methods

| Category | Methods |
|----------|---------|
| Metadata | `WithName()`, `WithSummary()`, `WithDescription()`, `WithTags()` |
| Routing | `WithPathParams()`, `WithQueryParams()` |
| Response | `WithSuccessStatus()`, `WithResponseHeaders()` |
| Errors | `WithErrors(errs ...ErrorDefinition)` |
| Request | `WithMaxBodySize()`, `WithCodec()`, `WithOutputValidation()` |
| Middleware | `WithMiddleware()` |
| Auth | `WithAuthentication()`, `WithScopes()`, `WithRoles()`, `WithUsageLimit()` |

### Error Constructors

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `NewError` | `NewError[D](code string, status int, message string) *Error[D]` | Create typed error |
| `NewValidationError` | `NewValidationError(fields []ValidationFieldError) error` | Field-level validation error |

Builder methods (return new instances — immutable): `WithMessage()`, `WithDetails()`, `WithCause()`

## Types

### Request[In]

```go
type Request[In any] struct {
    context.Context
    *http.Request
    Params   *Params
    Body     In
    Identity Identity
}

type Params struct {
    Path  map[string]string
    Query map[string]string
}
```

### Identity

```go
type Identity interface {
    ID() string
    TenantID() string
    Email() string
    Scopes() []string
    Roles() []string
    HasScope(scope string) bool
    HasRole(role string) bool
    Stats() map[string]int
}
```

`NoIdentity` struct for unauthenticated requests. `NoBody` struct for handlers without request body.

### Stream[T]

```go
type Stream[T any] interface {
    Send(data T) error
    SendEvent(event string, data T) error
    SendComment(comment string) error
    Done() <-chan struct{}
}
```

### Codec

```go
type Codec interface {
    ContentType() string
    Marshal(v any) ([]byte, error)
    Unmarshal(data []byte, v any) error
}
```

`JSONCodec` is the default implementation.

### Lifecycle Hooks

| Interface | Method | Purpose |
|-----------|--------|---------|
| `Validatable` | `Validate() error` | Input/output self-validation |
| `Entryable` | `OnEntry(ctx) error` | Input transformation before handler |
| `Sendable` | `OnSend(ctx) error` | Output transformation before marshaling |

### Endpoint

```go
type Endpoint interface {
    Process(ctx, *http.Request, http.ResponseWriter) (int, error)
    Spec() HandlerSpec
    ErrorDefs() []ErrorDefinition
    Middleware() []func(http.Handler) http.Handler
    Close() error
}
```

## Pre-defined Errors

### Client Errors (4xx)

| Error | Status | Details Type |
|-------|--------|-------------|
| `ErrBadRequest` | 400 | `BadRequestDetails` |
| `ErrUnauthorized` | 401 | `UnauthorizedDetails` |
| `ErrForbidden` | 403 | `ForbiddenDetails` |
| `ErrNotFound` | 404 | `NotFoundDetails` |
| `ErrConflict` | 409 | `ConflictDetails` |
| `ErrPayloadTooLarge` | 413 | `PayloadTooLargeDetails` |
| `ErrUnprocessableEntity` | 422 | `UnprocessableEntityDetails` |
| `ErrValidationFailed` | 422 | `ValidationDetails` |
| `ErrTooManyRequests` | 429 | `TooManyRequestsDetails` |

### Server Errors (5xx)

| Error | Status | Details Type |
|-------|--------|-------------|
| `ErrInternalServer` | 500 | `InternalServerDetails` |
| `ErrNotImplemented` | 501 | `NotImplementedDetails` |
| `ErrBadGateway` | 502 | `BadGatewayDetails` |
| `ErrServiceUnavailable` | 503 | `ServiceUnavailableDetails` |

## OpenAPI Generation

Fully automatic from type definitions:

1. `NewHandler[In, Out]()` calls `sentinel.Scan[In]()` and `sentinel.Scan[Out]()` at creation
2. Field metadata extracted: Go type, json tag, `validate` tag, `description` tag, `example` tag
3. Validation rules converted to OpenAPI constraints (`min` → `minimum`, `email` → `format`, `oneof` → `enum`)
4. Schemas generated recursively for nested types via sentinel relationships
5. Error schemas include typed details fields
6. `GenerateOpenAPI(identity)` assembles full spec, filtering handlers by identity permissions

**Supported OpenAPI 3.1.0 features:** Component schemas, security schemes (bearer token), path/query parameters, request bodies, multiple response codes, tags, tag groups (`x-tagGroups`), external docs.

### Authorization in Spec

| Builder | Behaviour |
|---------|-----------|
| `WithScopes(scopes...)` | OR within call, AND across calls |
| `WithRoles(roles...)` | OR within call, AND across calls |

Handlers filtered from spec if identity lacks required permissions.

## Capitan Signals

Comprehensive lifecycle signals:

| Category | Signals |
|----------|---------|
| Engine | created, starting, shutdown.started, shutdown.complete |
| Handlers | registered, executing, success, error |
| Requests | received, completed, failed |
| Validation | input.failed, output.failed |
| Auth | authentication.failed/succeeded |
| AuthZ | scope.denied, role.denied, authorization.succeeded |
| Rate Limiting | ratelimit.exceeded |
| Streams | executing, started, ended, client.disconnected, error |
| I/O | body.read/parse/close.error, response.write/marshal.error, params.invalid |

## Subpackages

| Package | Purpose |
|---------|---------|
| `session/` | Cookie-based session management with OAuth integration |
| `oauth/` | OAuth 2.0 authorization code flow (GitHub, GitHub Enterprise) |
| `auth0/` | Auth0 integration |
| `testing/` | Test helpers and benchmarks |

## Thread Safety

- **Engine:** Handler registration NOT thread-safe — complete before `Start()`
- **Handlers:** Safe for concurrent use once registered
- **Streams:** Internal mutex protects concurrent event sends
- **OpenAPI Spec:** Cached via `sync.Once` after first generation

## File Layout

```
rocco/
├── api.go          # Package documentation
├── engine.go       # Engine (HTTP server, routing, OpenAPI)
├── handler.go      # Handler[In, Out]
├── stream.go       # StreamHandler[In, Out], Stream[T]
├── errors.go       # Error[D], pre-defined errors
├── request.go      # Request[In], Params, NoBody
├── identity.go     # Identity interface, NoIdentity
├── docs.go         # OpenAPI schema generation from sentinel
├── spec.go         # HandlerSpec, EngineSpec
├── events.go       # Lifecycle signals and field keys
├── codec.go        # Codec interface, JSONCodec
├── config.go       # EngineConfig
├── redirect.go     # Redirect type
├── validator.go    # Validatable interface
├── hooks.go        # Entryable, Sendable interfaces
├── interfaces.go   # Endpoint interface
├── session/        # Session management
├── oauth/          # OAuth 2.0
├── auth0/          # Auth0 integration
└── testing/        # Test helpers, benchmarks
```

## Common Patterns

**Type-Safe Handler:**

```go
handler := rocco.POST[CreateUserRequest, User]("/users", func(r *rocco.Request[CreateUserRequest]) (User, error) {
    return createUser(r.Context(), r.Body)
}).
    WithSummary("Create user").
    WithTags("users").
    WithErrors(rocco.ErrValidationFailed, rocco.ErrConflict)
```

**SSE Streaming:**

```go
stream := rocco.NewStreamHandler[NoBody, Event]("events", "GET", "/events",
    func(r *rocco.Request[NoBody], s rocco.Stream[Event]) error {
        for event := range events {
            if err := s.Send(event); err != nil { return err }
        }
        return nil
    })
```

**Authenticated Endpoint:**

```go
handler.WithAuthentication().WithScopes("users:write").WithRoles("admin")
```

## Anti-Patterns

- **Registering handlers after Start()** — handler registration is not thread-safe
- **Retaining Request beyond handler scope** — request is recycled after handler returns
- **Implementing Provider without context cancellation** — all I/O must respect context
- **Omitting WithErrors()** — undeclared errors appear as generic 500 in OpenAPI spec

## Ecosystem

Rocco depends on:
- **sentinel** — type metadata for OpenAPI schema generation
- **capitan** — lifecycle event signals
- **check** — struct validation
- **openapi** — OpenAPI type definitions

Rocco is consumed by applications with HTTP API needs.
