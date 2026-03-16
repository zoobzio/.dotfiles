# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Key is unforgeable — no path to construct a valid Key outside Start()
- Register[T] rejects invalid key, frozen registry, and unstarted registry
- Use[T] evaluates all guards in order and returns ErrAccessDenied on first failure
- Freeze prevents further registration permanently
- Guard evaluation is copy-on-write — concurrent guard modification and Use[T] don't race
- Panics for programming mistakes, errors for runtime conditions

### What This Repo MUST NOT Contain

- Dependency injection with automatic wiring
- Constructor functions or factory registration
- Scope management
- Service lifecycle management

## Review Priorities

1. Key unforgeability: no external construction of valid Key — this is the security boundary
2. Guard evaluation: all guards must run in order, first error must stop and return ErrAccessDenied
3. Freeze enforcement: registration after freeze must panic — no exceptions
4. Thread safety: concurrent Use[T] with guard modification must not race
5. Type safety: Register[T] and Use[T] must resolve by exact type — no subtype matching

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Key forged externally | Critical |
| Guard bypassed during Use[T] | Critical |
| Registration accepted after Freeze | Critical |
| Race condition in guard evaluation | High |
| Use[T] returns wrong service type | High |
| ErrAccessDenied wraps wrong guard error | Medium |
| Capitan signal missing for security event | Medium |
| ServiceInfo metadata incomplete | Low |

## Standing Concerns

- Global singleton — verify double Start() panics reliably
- Copy-on-write guard slices — verify snapshot is taken under RLock before evaluation outside lock
- Same type registered twice overwrites — verify this is documented and intentional
- Reset/Unregister behind build tag — verify not accessible in production builds

## Out of Scope

- Global singleton is intentional — one registry per process
- Panics for programming mistakes is by design — these are unrecoverable
- No automatic wiring is intentional — explicit registration only
- Same type overwrite is intentional — allows test setup flexibility
