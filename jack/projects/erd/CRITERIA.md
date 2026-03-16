# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- `FromSchema` correctly converts sentinel metadata to diagram with entities and relationships
- Cardinality inference from field types is accurate (pointer→1:1, slice→1:N, embedded→1:1, map→N:M)
- `erd` struct tag parsing correctly identifies pk, fk, uk, and note annotations
- Mermaid output is valid erDiagram syntax
- DOT output is valid GraphViz digraph syntax
- Builder API produces valid, complete diagrams
- Validation catches incomplete diagrams (empty titles, entities without attributes, dangling relationships)
- Output is deterministic — same input always produces same output

### What This Repo MUST NOT Contain

- Image rendering or layout computation
- Database introspection or connection logic
- DDL or migration generation
- Non-deterministic output ordering

## Review Priorities

1. Cardinality correctness: wrong relationship type produces a misleading diagram
2. Output validity: Mermaid and DOT must be parseable by their respective tools
3. Determinism: same input must produce byte-identical output
4. Tag parsing: `erd` struct tag must handle all combinations correctly
5. Validation: incomplete diagrams must be caught before rendering
6. Sentinel integration: FromSchema must handle edge cases (circular refs, embedded structs)

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Wrong cardinality inferred from field type | Critical |
| Mermaid output rejected by parser | High |
| DOT output rejected by GraphViz | High |
| Non-deterministic entity ordering in output | High |
| Struct tag parsed incorrectly | High |
| Relationship between non-existent entities not caught by validation | Medium |
| Nullable not detected from pointer type | Medium |
| Missing test for a cardinality inference case | Medium |
| Entity note or description not rendered | Low |

## Standing Concerns

- Sentinel init() tag registration must happen before any scanning — verify no import-order issues
- FromSchema filters relationship fields from entity attributes — verify filtering is complete
- Circular struct references could cause infinite loops in scanning — verify sentinel handles this
- Mermaid erDiagram syntax is sensitive to special characters — verify escaping

## Out of Scope

- No image rendering is intentional — consumers use Mermaid/DOT tools
- Only Mermaid and DOT formats — no PlantUML, no custom formats
- No layout control — that's the rendering tool's job
- sentinel dependency is intentional — ERD reads metadata, sentinel provides it
