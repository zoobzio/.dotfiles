# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Handler[In, Out] correctly deserializes request, validates, calls handler, serializes response
- OpenAPI schema generated from struct metadata matches actual handler behavior
- Validation rules from check integrate correctly — invalid input returns 422 with field errors
- Authentication/authorization gates handlers correctly based on Identity scopes and roles
- Pre-defined errors produce consistent JSON response structure with typed details
- SSE streaming handles client disconnection gracefully
- Lifecycle hooks (Validatable, Entryable, Sendable) fire in correct order
- All lifecycle events emit correct capitan signals

### What This Repo MUST NOT Contain

- Business logic in the framework
- Authentication provider implementations (Identity interface only)
- Database or storage integration
- Handler registration after Start() — must complete during setup

## Review Priorities

1. Request handling correctness: deserialize→validate→handle→serialize pipeline must be correct
2. Security: authentication and authorization checks must not be bypassable
3. OpenAPI accuracy: generated spec must match actual handler behavior exactly
4. Error consistency: all error responses must follow the same structure
5. SSE reliability: stream must handle client disconnection without goroutine leaks
6. Validation integration: check errors must map correctly to API error responses
7. Lifecycle ordering: hooks must fire in documented order

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Authentication check bypassable | Critical |
| Authorization (scope/role) check bypassable | Critical |
| Request body not validated before handler execution | Critical |
| OpenAPI spec shows endpoints the caller shouldn't see | High |
| Pre-defined error produces wrong HTTP status code | High |
| SSE goroutine leak on client disconnect | High |
| Lifecycle hook fires in wrong order | High |
| OpenAPI schema doesn't match actual validation rules | High |
| Handler panics not recovered | Medium |
| Capitan signal not emitted for lifecycle event | Medium |
| WithErrors declarations don't appear in OpenAPI spec | Medium |
| Body size limit not enforced | Medium |
| Error details type doesn't match declared type | Low |

## Standing Concerns

- Handler registration thread safety — verify no race if handlers registered concurrently during setup
- OpenAPI cached via sync.Once — verify cache invalidation is not needed (handlers are fixed after Start)
- sentinel.Scan called at handler creation — verify it handles all Go types including nested structs
- Permission-filtered spec generation — verify filtering is complete (no leaked endpoints)
- Session/OAuth/Auth0 subpackages add complexity — verify they integrate cleanly with Identity interface

## Out of Scope

- No auth provider implementation is intentional — Identity interface is the contract
- Handler registration not thread-safe is by design — register before Start()
- No WebSocket support — SSE covers streaming use cases
- No rate limiting implementation — signals enable application-level implementation
- JSONCodec as default is intentional — Codec interface allows custom serialization
