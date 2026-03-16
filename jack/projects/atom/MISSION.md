# Mission: atom

Type-segregated struct decomposition into typed maps for infrastructure code.

## Purpose

Decompose arbitrary Go structs into categorized typed maps so that libraries can work with field-level data without importing or knowing the original struct types. Reflection happens once during registration — the hot path is reflection-free.

Atom exists because infrastructure packages like query builders need to read struct fields generically without coupling to concrete types or paying repeated reflection costs.

## What This Package Contains

- `Atomizer[T]` generic entry point for decomposing and reconstructing structs
- `Use[T]()` for one-time type registration with cached singleton
- `Atom` storage with 29 typed maps across scalar, pointer, slice, and map categories
- Nested composition support for embedded structs, recursive types, and circular references
- Width normalization (int8→int64, float32→float64) with overflow checking on reconstruction
- `Atomizable`/`Deatomizable` interfaces for codegen bypass of reflection
- Field-to-table mapping for introspection by consumers

## What This Package Does NOT Contain

- Serialization to any wire format — atom is an in-memory decomposition
- Database or storage integration — consumers build that on top
- Code generation tooling — interfaces are provided, generators are separate
- Support for non-string-keyed maps, channels, functions, or interfaces

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Struct metadata extraction for field planning |

| Consumer | Role |
|----------|------|
| `soy` | Type-erased row scanning from database queries |

## Design Constraints

- Reflection happens once at registration — hot path is reflection-free
- Width normalization is mandatory — narrow integers widen to int64/uint64, floats to float64
- Overflow checked on deatomization — narrowing back to original width fails with ErrOverflow
- String-keyed maps only — non-string map keys are unsupported by design

## Success Criteria

A developer can:
1. Register any struct type once and get a cached Atomizer
2. Decompose a struct into typed maps without reflection on every call
3. Reconstruct the original struct from an Atom with type safety
4. Introspect field-to-table mappings for building generic infrastructure
5. Bypass reflection entirely by implementing Atomizable/Deatomizable

## Non-Goals

- Wire format serialization (JSON, protobuf, etc.)
- Supporting all Go types — channels, functions, and interfaces are excluded
- Code generation — atom provides the interface, generators are separate packages
- Thread-safe mutation of Atom instances — atoms are single-owner
