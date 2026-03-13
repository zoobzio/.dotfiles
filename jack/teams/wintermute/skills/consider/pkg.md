# Package Considerations

Additional review concerns for standalone Go packages. These layer on top of the base `review` skill — run the base review first, then apply these.

## API Surface

Packages are consumed by others. The exported API is a contract:
- Every exported symbol is a commitment — additions are easy, removals break consumers
- Minimal export surface — only expose what consumers need
- Internal implementation belongs in unexported types or `internal/`
- Public types should be constructable via `New[Type]` — not by direct struct literal

## Dependency Footprint

A package's dependencies become its consumers' dependencies:
- Zero or near-zero external dependencies is the goal
- Every external dependency must justify itself against stdlib alternatives
- Provider-specific code must be isolated in submodules (e.g., `pkg/foopgx`)
- Transitive dependency weight matters — a package that pulls in 50 transitive deps is a liability

## Consumer Experience

The package exists to be used. Review from the consumer's perspective:
- Can someone use this package from the README and godoc alone?
- Are constructors obvious and discoverable?
- Is the options pattern used where configuration is complex?
- Are error types and sentinels well-defined and documented?
- Is the zero value useful or does it panic?

## Breaking Changes

Changes to exported API are breaking changes:
- Removed or renamed exported symbols
- Changed function signatures (parameters, returns)
- Changed interface contracts (added methods)
- Changed behavior of existing functions (semantic breaks)
- Changed error types or sentinel values consumers may be matching on

## Testing for Consumers

Beyond the base test review, packages need consumer-facing test infrastructure:
- `testing/` directory with helpers consumers can use in their own tests
- Helpers must have build tag `//go:build testing` to avoid production inclusion
- Helpers should make it easy to construct package types for integration testing
- Example tests (`Example[Function]`) serve as both documentation and verification

## Versioning

Module versioning reflects API stability:
- `v0.x` — no stability guarantee, breaking changes expected
- `v1.x+` — breaking changes require major version bump
- Version must match the actual stability of the API
- CHANGELOG or release notes should document what changed and why
