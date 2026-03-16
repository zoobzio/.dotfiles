# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- All OpenAPI 3.1 spec objects modeled as Go types with correct JSON/YAML tags
- SchemaType correctly handles string and array-of-strings with custom marshalling
- JSON and YAML serialization produce valid OpenAPI 3.1 output
- Roundtrip (serialize→deserialize→serialize) is lossless
- Schema type supports AllOf/OneOf/AnyOf/Not composition

### What This Repo MUST NOT Contain

- Spec validation or linting logic
- Code generation
- HTTP server/client generation
- OpenAPI 2.x types or conversion

## Review Priorities

1. Spec completeness: all OpenAPI 3.1 objects must be modeled
2. Serialization fidelity: JSON/YAML roundtrip must be lossless
3. SchemaType correctness: custom marshalling must handle all edge cases
4. Tag correctness: json/yaml struct tags must match OpenAPI field names exactly
5. Schema composition: AllOf/OneOf/AnyOf/Not must serialize correctly

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Missing OpenAPI 3.1 spec object | High |
| JSON/YAML roundtrip loses data | High |
| SchemaType marshalling produces invalid output | High |
| Struct tag doesn't match OpenAPI field name | High |
| Schema composition (AllOf/OneOf) serializes incorrectly | High |
| Nullable type handling wrong | Medium |
| Missing optional field in type definition | Medium |
| yaml.v3 edge case in complex nested schemas | Low |

## Standing Concerns

- SchemaType single-element array normalization must be bidirectional — verify unmarshal handles both forms
- Components map keys must match OpenAPI naming rules — verify no validation needed at type level
- Pointer vs value types for optional fields — verify consistency across all types
- Redoc TagGroup extension is non-standard — verify it doesn't break standard tooling

## Out of Scope

- No spec validation is intentional — types are structural, not semantic
- yaml.v3 dependency is intentional for YAML support
- No code generation — types are the product, not the input
- Redoc extension (TagGroup) is intentional for documentation tooling support
