# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Singleton Service correctly wires rocco, scio, slush, cereal, fig, grub, and capitan
- Service lifecycle (Start/Run/Shutdown) handles SIGINT/SIGTERM with graceful 30s timeout
- Registry Start/Freeze/Register/Use pattern enforces registration-before-use discipline
- Token-based access control is unforgeable — tokens cannot be constructed without `NewToken`
- `Event[T]` correctly wraps capitan signals with proper type safety
- `Boundary[T]` inherits all encryptors, hashers, maskers, and codec from Service configuration
- Data wrappers (Database, Store, Bucket) auto-register with scio catalog on creation
- `Config[T]` loads via fig and registers the result in the service locator
- Thread safety across all mutable state — Service, Registry, data wrappers

### What This Repo MUST NOT Contain

- HTTP routing logic — rocco owns that
- Storage provider implementations — grub owns that
- Serialization algorithms — cereal owns that
- Configuration file parsing — fig owns that
- Event dispatch internals — capitan owns that
- Multiple Service instances — singleton by design
- Direct database drivers or connection management beyond what grub/sqlx provide

## Review Priorities

Ordered by importance. When findings conflict, higher-priority items take precedence.

1. Lifecycle correctness: Start/Run/Shutdown must not leak goroutines, leave connections open, or ignore shutdown signals
2. Token security: tokens must be unforgeable — verify UUID generation, unexported fields, no reflection bypass
3. Thread safety: Service singleton and registry accessed concurrently — races are critical
4. Wiring correctness: boundaries must inherit crypto config, data wrappers must register with catalog, config must land in locator
5. Registry discipline: Freeze must actually prevent further registrations, Use before Register must fail clearly
6. API ergonomics: exported surface must be minimal, type aliases must match underlying packages exactly
7. Delegation purity: sum must compose, never reimplement — verify no duplicated logic from underlying packages

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Goroutine leak on shutdown | Critical |
| Data race in Service or Registry | Critical |
| Token forgeable via reflection or construction | Critical |
| Boundary missing crypto configuration from Service | High |
| Data wrapper not registered with scio catalog | High |
| Freeze does not prevent further registration | High |
| Signal handling misses SIGINT or SIGTERM | High |
| Re-exported type alias diverges from source package | High |
| Config[T] silently fails without error | Medium |
| Missing test for a public API function | Medium |
| Error message without actionable context | Medium |
| Shutdown timeout not configurable or documented | Low |
| Internal naming inconsistency | Low |

## Standing Concerns

- Singleton pattern means initialization order matters — verify Service is created before registry operations
- Freeze is a one-way gate — verify no path allows registration after freeze
- Boundary crypto config is copied at creation time — verify later WithEncryptor/WithHasher calls don't affect existing boundaries
- Data wrappers delegate to grub — verify no method shadowing that changes grub behavior
- Re-exported vars and type aliases create coupling — verify they stay in sync with upstream packages across versions

## Out of Scope

Things the red team should NOT flag for this repo, even if they look wrong.

- Singleton is intentional — one Service per process, by design
- Heavy dependency list (rocco, scio, slush, cereal, fig, grub, capitan, sentinel, astql) is intentional — sum is the composition layer
- Re-exported type aliases are intentional — ergonomic consumer API without requiring direct imports of underlying packages
- No support for multiple service instances — this is a design constraint, not a gap
- Test-only Reset() and Unregister[T]() behind build tags — necessary for test isolation, not production API
