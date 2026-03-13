# Check

Deep understanding of `github.com/zoobzio/check` — zero-reflection fluent validation for Go with struct tag verification.

## Core Concepts

Check provides explicit, function-based validation with no runtime reflection on the validation hot path. Validators are composed via fluent builders or standalone functions, aggregated with `All()`/`First()`, and optionally verified against struct tags with `Check[T]()`.

- **Validators** are standalone functions returning `*Validation`
- **Fluent builders** chain validators: `Str(v, "field").Required().Email().V()`
- **All()** collects all errors; **First()** fails fast
- **Check[T]()** verifies all fields with `validate` tags were actually validated
- **160+ built-in validators** across 8 categories

**Dependencies:** `sentinel` (struct tag inspection), `golang.org/x/exp` (constraints)

## Public API

### Aggregation

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `All` | `All(validations ...*Validation) *Result` | Collect all errors |
| `First` | `First(validations ...*Validation) *Result` | Stop at first error |
| `Merge` | `Merge(results ...*Result) *Result` | Combine multiple Results |
| `Check[T]` | `Check[T any](validations ...*Validation) *Result` | Validate + verify all tagged fields checked |

### Result Methods

| Method | Behaviour |
|--------|-----------|
| `Err()` | Combined error (nil if valid) |
| `Error()` | Error string |
| `Applied()` | `map[string][]string` — field → validator names |
| `HasValidator(field, validator)` | Check if validator ran on field |
| `ValidatorsFor(field)` | Validators applied to field |
| `Fields()` | All validated field names |

### Result Helpers

`GetFieldErrors(r)`, `FieldNames(r)`, `HasField(r, field)`, `HasErrors(r)`

### Error Types

| Type | Purpose |
|------|---------|
| `FieldError` | Single field error: `{Field, Message}` |
| `Errors` | Slice of errors implementing `error` and `Unwrap() []error` |
| `UncheckedFieldError` | Field with `validate` tag was not validated |

### Fluent Builders

| Builder | Constructor | For Type |
|---------|-------------|----------|
| `StrBuilder` | `Str(v, field)` | string |
| `OptStrBuilder` | `OptStr(v, field)` | *string (skip if nil) |
| `StrSliceBuilder` | `StrSlice(v, field)` | []string |
| `OptStrSliceBuilder` | `OptStrSlice(v, field)` | *[]string |
| `NumBuilder[T]` | `Num[T](v, field)` | any ordered type |
| `IntBuilder[T]` | `Int[T](v, field)` | integer types (adds Even, Odd, MultipleOf) |
| `OptNumBuilder[T]` | `OptNum[T](v, field)` | *ordered (skip if nil) |
| `OptIntBuilder[T]` | `OptInt[T](v, field)` | *integer (skip if nil) |
| `SliceBuilder[T]` | `Slice[T](v, field)` | []T |
| `OptSliceBuilder[T]` | `OptSlice[T](v, field)` | *[]T |

All builders end with `.V()` returning `*Validation`.

## Built-in Validators

### String (28)

`Required`, `NotBlank`, `MinLen`, `MaxLen`, `Len`, `LenBetween`, `Match`, `NotMatch`, `Prefix`, `Suffix`, `Contains`, `NotContains`, `OneOf`, `NotOneOf`, `Alpha`, `AlphaNumeric`, `Numeric`, `AlphaUnicode`, `AlphaNumericUnicode`, `ASCII`, `PrintableASCII`, `LowerCase`, `UpperCase`, `NoWhitespace`, `Trimmed`, `SingleLine`, `Identifier`, `Slug`

### Format (32)

`Email`, `URL`, `URLWithScheme`, `HTTPOrHTTPS`, `UUID`, `UUID4`, `IP`, `IPv4`, `IPv6`, `CIDR`, `MAC`, `Hostname`, `Port`, `HostPort`, `HexColor`, `HexColorFull`, `Base64`, `Base64URL`, `JSON`, `Semver`, `E164`, `CreditCard`, `Latitude`, `Longitude`, `CountryCode2`, `CountryCode3`, `LanguageCode`, `CurrencyCode`, `Hex`, `DataURI`, `FilePath`, `UnixPath`

### Numeric (20)

`Min`, `Max`, `Between`, `BetweenExclusive`, `GreaterThan`, `LessThan`, `GreaterThanOrEqual`, `LessThanOrEqual`, `Positive`, `Negative`, `NonNegative`, `NonPositive`, `Zero`, `NonZero`, `Percentage`, `MultipleOf`, `Even`, `Odd`, `PortNumber`, `HTTPStatusCode`

### Slice/Collection (20)

`NotEmpty`, `Empty`, `MinItems`, `MaxItems`, `ExactItems`, `ItemsBetween`, `Unique`, `SliceContains`, `SliceNotContains`, `ContainsAll`, `ContainsAny`, `ContainsNone`, `Subset`, `Disjoint`, `Each`, `EachValue`, `AllSatisfy`, `AnySatisfies`, `NoneSatisfy`

### Map (16)

`NotEmptyMap`, `EmptyMap`, `MinKeys`, `MaxKeys`, `ExactKeys`, `KeysBetween`, `HasKey`, `HasKeys`, `HasAnyKey`, `NotHasKey`, `NotHasKeys`, `OnlyKeys`, `EachKey`, `EachMapValue`, `EachEntry`, `UniqueValues`

### Pointer (10)

`NotNil`, `Nil`, `NilOr`, `NilOrField`, `RequiredPtr`, `RequiredPtrField`, `DefaultOr`, `Deref`, `DerefOr`, `Ptr`, `NotNilInterface`

### Comparison (8)

`Equal`, `NotEqual`, `EqualField`, `NotEqualField`, `GreaterThanField`, `LessThanField`, `GreaterThanOrEqualField`, `LessThanOrEqualField`

### Time (26)

`Before`, `After`, `BeforeOrEqual`, `AfterOrEqual`, `BeforeNow`, `AfterNow`, `InPast`, `InFuture`, `BetweenTime`, `BetweenTimeExclusive`, `WithinDuration`, `WithinDurationOf`, `SameDay`, `SameMonth`, `SameYear`, `Weekday`, `WeekdayIn`, `NotWeekend`, `IsWeekend`, `NotZeroTime`, `ZeroTime`, `TimeInTimezone`, `DurationMin`, `DurationMax`, `DurationBetween`, `DurationPositive`, `DurationNonNegative`

## Generic Constraints

```go
type Signed interface   { ~int | ~int8 | ~int16 | ~int32 | ~int64 }
type Unsigned interface { ~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 | ~uintptr }
type Float interface    { ~float32 | ~float64 }
type Integer interface  { Signed | Unsigned }
type Number interface   { Integer | Float }
```

## Struct Tag Verification

`Check[T]()` uses sentinel to inspect struct tags:

```go
type Request struct {
    Email string `json:"email" validate:"required,email"`
    Age   int    `json:"age" validate:"required,min=0"`
}

result := check.Check[Request](
    check.Str(r.Email, "email").Required().Email().V(),
    check.Int(r.Age, "age").NonNegative().V(),
)
// If "age" validation were missing, returns UncheckedFieldError
```

Fields matched by json tag name or lowercase struct field name. Tag `validate:"-"` explicitly skips.

## File Layout

```
check/
├── check.go     # FieldError, Errors, Validation, Result, All/First/Merge
├── checked.go   # Check[T], UncheckedFieldError, tag verification
├── builder.go   # All fluent builders
├── strings.go   # String validators
├── numbers.go   # Numeric validators and constraints
├── formats.go   # Format validators
├── slices.go    # Slice validators
├── maps.go      # Map validators
├── pointers.go  # Pointer validators
├── compare.go   # Comparison validators
└── time.go      # Temporal validators
```

## Common Patterns

**Fluent:**

```go
result := check.All(
    check.Str(email, "email").Required().Email().MaxLen(255).V(),
    check.Int(age, "age").Between(0, 150).V(),
    check.Str(role, "role").OneOf([]string{"admin", "user"}).V(),
)
```

**With struct tag verification:**

```go
result := check.Check[CreateUserRequest](
    check.Str(req.Email, "email").Required().Email().V(),
    check.Str(req.Password, "password").Required().MinLen(8).V(),
)
```

## Ecosystem

Check depends on:
- **sentinel** — struct metadata for tag verification

Check is consumed by:
- **rocco** — request/response validation
