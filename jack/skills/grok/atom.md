# Atom

Deep understanding of `github.com/zoobzio/atom` — type-segregated struct decomposition into typed maps for infrastructure code.

## Core Concepts

Atom decomposes arbitrary Go structs into typed maps by category. This enables libraries to work with field-level data without importing or knowing the original struct types. Reflection happens once during registration — the hot path is reflection-free.

- **Atom** is the decomposed storage — 29 typed maps plus metadata
- **Atomizer[T]** is the generic entry point — atomise (decompose) and deatomise (reconstruct)
- **Use[T]()** registers a type and returns its Atomizer (cached singleton)
- **Atomizable/Deatomizable** interfaces enable codegen bypass of reflection

**Dependencies:** `sentinel` (struct metadata extraction)

## Public API

### Registration

```go
func Use[T any]() (*Atomizer[T], error)
```

Primary entry point. Registers type T (cached via singleton), scans metadata with sentinel, builds field plans. Recursive — handles nested structs automatically.

### Atomizer[T]

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Atomize` | `Atomize(obj *T) *Atom` | Decompose struct into typed maps |
| `Deatomize` | `Deatomize(atom *Atom) (*T, error)` | Reconstruct struct from Atom |
| `NewAtom` | `NewAtom() *Atom` | Pre-sized Atom (only needed tables allocated) |
| `Spec` | `Spec() Spec` | Sentinel metadata |
| `Fields` | `Fields() []Field` | All field-to-table mappings |
| `FieldsIn` | `FieldsIn(table Table) []string` | Fields in specific table |
| `TableFor` | `TableFor(field string) (Table, bool)` | Field → table lookup |

### Global Functions

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `TableForField` | `TableForField(spec Spec, field string) (Table, bool)` | Global field → table lookup |
| `FieldsFor` | `FieldsFor(spec Spec) ([]Field, bool)` | Global field-table mappings |
| `AllTables` | `AllTables() []Table` | All 29 table constants |

### Custom Implementation Interfaces

```go
type Atomizable interface {
    Atomize(*Atom)
}

type Deatomizable interface {
    Deatomize(*Atom) error
}
```

If T implements these, reflection is bypassed entirely. Enables code generation.

## Atom Structure

29 typed maps organised in four categories:

| Category | Tables (7 each) | Key Type |
|----------|-----------------|----------|
| Scalar | Strings, Ints, Uints, Floats, Bools, Times, Bytes | `map[string]T` |
| Pointer | StringPtrs, IntPtrs, UintPtrs, FloatPtrs, BoolPtrs, TimePtrs, BytePtrs | `map[string]*T` |
| Slice | StringSlices, IntSlices, UintSlices, FloatSlices, BoolSlices, TimeSlices, ByteSlices | `map[string][]T` |
| Map | StringMaps, IntMaps, UintMaps, FloatMaps, BoolMaps, TimeMaps, ByteMaps | `map[string]map[string]T` |

Plus nested composition: `Nested map[string]Atom`, `NestedSlices map[string][]Atom`, `NestedMaps map[string]map[string]Atom`

All maps keyed by field name. Values stored in normalised widths (int8→int64, float32→float64).

## Type Support

| Category | Supported Types |
|----------|----------------|
| Scalars | string, int/int8-64, uint/uint8-64, float32/64, bool, time.Time, []byte, [N]byte |
| Pointers | Pointer to any scalar type, pointer to struct (nested) |
| Slices | Slice of any scalar, slice of structs |
| Maps | `map[string]V` where V is scalar or struct (string keys only) |
| Nested | Embedded structs, recursive composition, circular references |

**Width normalisation:** int8/16/32 → int64, uint8/16/32 → uint64, float32 → float64. Overflow checked on deatomisation.

**Unsupported:** Non-string-keyed maps, channels, functions, interfaces.

## Sentinel Errors

```go
var (
    ErrOverflow        = errors.New("numeric overflow")      // Narrowing int64→int8 fails
    ErrUnsupportedType = errors.New("unsupported type")      // Field type cannot be atomised
    ErrSizeMismatch    = errors.New("size mismatch")         // []byte len != [N]byte size
)
```

## File Layout

```
atom/
├── api.go        # Atom struct, Table constants, Atomizable/Deatomizable interfaces
├── atomizer.go   # Atomizer[T] generic wrapper
├── registry.go   # Use[T](), type registration, global functions
├── planning.go   # Field planning, type classification
├── encoding.go   # Atomise/deatomise field implementations
├── resolver.go   # Reflection backend, allocation
├── errors.go     # Sentinel errors
└── testing/
```

## Common Patterns

```go
atomizer, _ := atom.Use[User]()
a := atomizer.Atomize(&user)
// a.Strings["name"] == "Alice", a.Ints["age"] == 30

reconstructed, _ := atomizer.Deatomize(a)
```

## Ecosystem

Atom depends on:
- **sentinel** — struct metadata extraction

Atom is consumed by:
- **soy** — type-erased row scanning from database queries
