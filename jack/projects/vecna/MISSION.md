# Mission: vecna

Schema-validated filter builder for vector database queries.

## Purpose

Build type-safe filters for vector database queries. A generic Builder[T] extracts field metadata from structs via sentinel, validates field names and operator compatibility at construction time, and produces an immutable filter AST with deferred error semantics.

Vecna exists because vector database queries need metadata filters that are validated against the actual schema, not arbitrary string-based conditions.

## What This Package Contains

- Generic `Builder[T]` with schema validation from struct metadata
- `FieldBuilder[T]` with typed operators: Eq, Ne, Gt, Gte, Lt, Lte, In, Nin, Like, Contains
- Logical composition: And, Or, Not
- Immutable Filter AST with deferred error model
- FilterSpec for JSON-serializable filter definitions (LLM-generated or dynamic queries)
- Operator/type compatibility validation (numeric ops on numeric fields, Like on strings, Contains on slices)
- Field name resolution from json tags

## What This Package Does NOT Contain

- Vector database client or transport
- Embedding generation or vector operations
- Query execution or result parsing
- Provider-specific filter format rendering

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Struct metadata extraction for schema validation |

| Consumer | Role |
|----------|------|
| `grub` | Translates Filter AST to provider-specific vector DB queries |

## Success Criteria

A developer can:
1. Build schema-validated filters with compile-time field checking
2. Compose complex nested filters with And/Or/Not
3. Get clear errors for invalid field names or operator/type mismatches
4. Convert JSON filter specs to validated Filter objects for dynamic queries
5. Trust that the filter AST is immutable and safe to share
