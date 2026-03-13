# Mission: sentinel

Zero-dependency struct introspection for Go.

## Purpose

Provide a single extraction point for Go struct metadata — fields, types, struct tags, and inter-type relationships — so that downstream tools can generate schemas, documentation, queries, and diagrams from struct definitions alone.

Sentinel exists because every tool that needs struct metadata reimplements the same reflection logic. This package normalizes that into a consistent, cached, queryable API.

## What This Package Contains

- Generic struct metadata extraction (`Inspect[T]()`, `Scan[T]()`)
- Permanent caching — types are immutable at runtime, extracted once
- Relationship discovery between struct types within module boundaries
- Custom struct tag registration
- Cache query API (`Browse`, `Lookup`, `Schema`)
- Testing support with cache reset behind build tag

## What This Package Does NOT Contain

- Code generation tooling — sentinel provides metadata, generators are separate packages
- Non-struct type support — only structs are introspectable
- Cross-module scanning — intentionally limited to module boundaries
- Runtime type mutation or dynamic field injection

## Ecosystem Position

Sentinel is the foundation layer. Downstream zoobzio packages consume its metadata:

| Consumer | Purpose |
|----------|---------|
| `erd` | Entity relationship diagrams from type relationships |
| `soy` | SQL query generation from struct tags |
| `rocco` | OpenAPI specification generation from request/response types |

## Success Criteria

A developer can:
1. Call `Scan[T]()` on any struct and get complete metadata for T and all related types
2. Query the cache by FQDN and get consistent, normalized results
3. Register custom struct tags before extraction
4. Traverse type relationships to build graphs of their domain model
5. Use sentinel in concurrent code without synchronization concerns

## Design Constraints

- Zero external dependencies — stdlib only
- Go 1.24+ required (generics)
- Global singleton — one type system, one cache
- Thread-safe after initial extraction

## Non-Goals

- Replacing reflect — sentinel normalizes reflection output, it does not abstract it away
- Supporting non-struct types
- Cross-module recursive scanning
- Cache invalidation or expiration
