# Mission: openapi

OpenAPI 3.1 specification as native Go types.

## Purpose

Provide a comprehensive Go type implementation of the OpenAPI 3.1 specification so that specs can be built, read, and written with full type safety. No code generation — just Go structs with JSON/YAML serialization and lossless roundtripping.

OpenAPI exists because downstream packages like rocco need a typed Go representation of OpenAPI specs to generate documentation from handler metadata.

## What This Package Contains

- Complete OpenAPI 3.1 type model (~47 exported types)
- Root document type with paths, components, servers, security, tags
- Full JSON Schema support including AllOf/OneOf/AnyOf/Not, validation constraints, discriminator
- SchemaType handling for 3.1's flexible type field (string or array of strings)
- JSON and YAML serialization with lossless roundtripping
- Redoc TagGroup extension support

## What This Package Does NOT Contain

- OpenAPI spec validation or linting
- Code generation from specs
- HTTP client or server generation
- Spec diffing or migration between versions
- Parsing of OpenAPI 2.x (Swagger) format

## Ecosystem Position

| Consumer | Role |
|----------|------|
| `rocco` | Generates OpenAPI specs from handler type metadata |

## Design Constraints

- Pure type definitions with serialization — no behavior beyond marshal/unmarshal
- SchemaType custom marshalling normalizes single-element arrays to strings
- All types have both `json:` and `yaml:` struct tags

## Success Criteria

A developer can:
1. Build an OpenAPI 3.1 spec programmatically using Go structs
2. Serialize to JSON or YAML with valid output
3. Deserialize from JSON or YAML without data loss
4. Roundtrip specs through JSON/YAML serialization losslessly
5. Use the type model as a foundation for spec generation tools

## Non-Goals

- Spec validation or linting
- Code generation from OpenAPI specs
- HTTP server/client scaffolding
- OpenAPI 2.x compatibility
