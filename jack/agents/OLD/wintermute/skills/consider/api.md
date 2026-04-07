# API Considerations

Additional review concerns for Go API applications built on sum. These layer on top of the base `review` skill — run the base review first, then apply these.

## Naming Conventions

Beyond Go naming conventions, API applications follow domain naming:
- Models are singular (`User`)
- Stores are plural struct (`Users`)
- Contracts are plural interface (`Users`)
- Wire types use entity+suffix (`UserResponse`, `CreateUserRequest`)
- Handlers use verb+singular (`GetUser`, `CreateUser`)
- Store files are plural (`users.go`)
- Model files are singular (`user.go`)

## Cross-Surface Consistency

Same patterns used across all surfaces:
- Handlers structured identically across surfaces
- Transformers follow the same mapping approach across surfaces
- Contracts use consistent method signatures for shared operations
- Wire types follow the same structure (differing only in field exposure/masking)

## Surface Architecture

Multiple API surfaces (api/, admin/) share stores and models but separate contracts, wire types, handlers, and transformers:
- Shared layers must be truly shared — no surface-specific logic leaking into models or stores
- Surface-specific layers must be truly separate — no cross-surface handler or transformer leakage
- Same store implementation satisfies different contracts per surface
- Wire types differ appropriately (api/ masks, admin/ exposes)

## Entity Completeness

An entity spans multiple artifacts: model, migration, contract, store, wire types, transformers, handlers, plus registrations:
- Missing any link in the chain is a structural defect
- Each artifact references the correct types from adjacent layers
- Partial entities (model exists but no store, or handler with no contract) are findings

## Registration/Wiring

Components must be registered at their wiring points:
- `stores/stores.go` — store registration
- `{surface}/handlers/handlers.go` — handler registration
- `{surface}/handlers/errors.go` — domain error mapping
- `{surface}/wire/boundary.go` — wire boundary registration
- Unregistered components are invisible to the runtime
- Registration must happen before `sum.Freeze()` (ordering matters)

## Migration Ordering

Migrations must respect entity dependency order:
- A migration referencing a table that doesn't exist yet is a build-time failure
- Foreign key references must point to tables created in earlier migrations
- No circular migration dependencies

## Boundary Processing

Cereal handles field-level encryption, hashing, and masking:
- Sensitive fields must be registered with cereal boundaries
- Boundaries must process before data crosses system edges
- Processing must happen in correct direction (encrypt before storage, decrypt after retrieval, mask before API response)
- Masked fields must not leak unmasked values through error messages or logs

## Surface Isolation

Public and admin surfaces have different security postures:
- Admin endpoints must not be reachable from the public surface
- Public surface data must be masked; admin surface may expose full data
- Auth models differ per surface (customer identity vs internal identity)
- Bulk operations and impersonation restricted to admin surface
