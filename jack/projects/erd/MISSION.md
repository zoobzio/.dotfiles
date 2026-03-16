# Mission: erd

Entity relationship diagram generation from Go domain models via sentinel metadata.

## Purpose

Generate entity relationship diagrams from Go structs automatically by scanning type metadata, or manually via a fluent builder API. ERD exists because domain models defined in Go structs should be visualizable without maintaining a separate diagram source.

## What This Package Contains

- Automatic diagram generation from sentinel schema metadata (`FromSchema`)
- Relationship inference from struct field types (pointer→one-to-one, slice→one-to-many, map→many-to-many)
- Fluent builder API for manual diagram construction
- `erd` struct tag for marking primary keys, foreign keys, unique keys, and annotations
- Mermaid output for web rendering and documentation
- GraphViz DOT output for print-quality diagrams
- Deterministic rendering with sorted entity names
- Validation for diagrams, entities, attributes, and relationships

## What This Package Does NOT Contain

- Diagram rendering or image generation — produces text formats only (Mermaid, DOT)
- Database schema introspection — works from Go struct metadata only
- Migration or DDL generation
- Interactive diagram editing

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Type scanning and metadata extraction |

ERD is consumed by applications that need visual documentation of their domain models.

## Design Constraints

- Pure data structure manipulation — no shared mutable state
- Sentinel tag registration happens once in `init()`
- Relationship fields are shown as lines, not entity attributes (in automatic mode)
- Output is always deterministic — entities sorted by name before rendering

## Success Criteria

A developer can:
1. Scan Go structs with sentinel and generate an ERD automatically
2. See inferred relationships based on struct field types
3. Annotate fields with `erd` struct tags for keys and notes
4. Build diagrams manually with the fluent builder API
5. Output Mermaid for web embedding or DOT for print-quality rendering
6. Validate diagram completeness before rendering

## Non-Goals

- Image rendering — consumers use Mermaid/GraphViz tools for that
- Database reverse engineering
- Interactive diagram editing or layout control
- Supporting diagram formats beyond Mermaid and DOT
