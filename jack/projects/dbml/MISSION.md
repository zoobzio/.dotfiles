# Mission: dbml

Programmatic DBML generation from Go with fluent builders.

## Purpose

Provide a type-safe Go API for building database schema definitions as DBML (Database Markup Language). Users construct schemas with fluent builder chains, validate them, and generate DBML text output for visualization tools or downstream consumption by astql for query validation.

DBML exists because schema definitions need to be expressible in code — not just in migration files or diagram tools — so that other packages can validate queries and generate documentation from the same source of truth.

## What This Package Contains

- Fluent builders for Project, Table, Column, Index, Ref, Enum, and TableGroup
- DBML text generation via `Generate()` on every type
- Validation via `Validate()` returning structured `ValidationError`
- JSON and YAML serialization for schema storage and transport
- Relationship types: one-to-many, many-to-one, one-to-one, many-to-many
- Referential actions: cascade, restrict, set null, set default, no action
- Column settings: primary key, nullable, unique, auto-increment, default, check constraints
- Index support: column-based and expression-based, with unique and primary key options

## What This Package Does NOT Contain

- DBML parsing — this package generates DBML, it does not read it
- SQL DDL generation — DBML output is for visualization and downstream tooling
- Migration management or schema diffing
- Database connection or execution

## Ecosystem Position

| Consumer | Role |
|----------|------|
| `astql` | Schema validation for SQL query building |
| `soy` | Generates DBML from struct tags for astql integration |

## Design Constraints

- Fluent builder pattern — all methods return self for chaining
- Default schema is "public" and omitted from generated output
- Validation is explicit — call `Validate()` before trusting the schema

## Success Criteria

A developer can:
1. Define a complete database schema using fluent Go builders
2. Generate valid DBML text output for visualization tools
3. Validate schema definitions with clear, structured error messages
4. Serialize schemas to JSON or YAML for storage
5. Pass schema definitions to astql for compile-time query validation

## Non-Goals

- Parsing DBML text back into Go types
- Generating SQL DDL or migrations
- Database introspection or reverse engineering
- Runtime schema modification or versioning
