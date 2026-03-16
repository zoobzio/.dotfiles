# Mission: check

Zero-reflection fluent validation for Go with struct tag verification.

## Purpose

Provide explicit, function-based validation with no runtime reflection on the validation hot path. Validators are composed via fluent builders or standalone functions, aggregated with All()/First(), and optionally verified against struct tags with Check[T]().

Check exists because validation must be both expressive and fast — struct tag magic hides validation rules, while manual checks scatter validation across handler code. Check makes validation explicit, composable, and verifiable.

## What This Package Contains

- 160+ built-in validators across 8 categories: string, format, numeric, slice, map, pointer, comparison, time
- Fluent builders for string, numeric, integer, slice, and optional variants
- `All()` (collect all errors) and `First()` (fail-fast) aggregation
- `Check[T]()` struct tag verification ensuring all tagged fields were actually validated
- `Result` type with field-error introspection (Applied, HasValidator, ValidatorsFor)
- Typed errors: FieldError, Errors (multi-error with Unwrap), UncheckedFieldError
- Generic constraints for numeric types (Signed, Unsigned, Float, Integer, Number)
- Optional pointer variants that skip validation when nil

## What This Package Does NOT Contain

- Struct tag-based auto-validation (no reflection on the hot path)
- Schema generation from validation rules — that's rocco's domain
- Internationalization or localized error messages
- Async or deferred validation

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Struct tag inspection for Check[T] verification |

| Consumer | Role |
|----------|------|
| `rocco` | Request/response validation in HTTP handlers |

## Design Constraints

- Zero reflection on the validation hot path — sentinel used only by Check[T]() for tag verification
- Fluent builders end with `.V()` returning *Validation — composable with All/First
- Check[T]() verifies all fields with `validate` tags were validated — catches missing validations at call site
- Error types implement standard error interface with Unwrap support

## Success Criteria

A developer can:
1. Validate any struct field using fluent builder chains
2. Compose validations with All() or First() for different error collection strategies
3. Use Check[T]() to verify no tagged field was forgotten
4. Get structured field-level errors suitable for API responses
5. Use 160+ built-in validators without writing custom regex or parsing

## Non-Goals

- Automatic validation from struct tags alone
- Error message localization
- Validation rule serialization or schema export
- Async or concurrent validation
