# Mission: lucene

Type-safe search query builder for Elasticsearch and OpenSearch with schema validation.

## Purpose

Build Elasticsearch/OpenSearch Query DSL as type-safe Go with schema validation. A generic Builder[T] extracts field metadata from structs via sentinel, validates field references at query creation time, and renders to engine-specific JSON via pluggable renderers.

Lucene exists because building search queries as raw JSON is error-prone — wrong field names, type mismatches, and dialect differences should be caught at construction time, not at query execution.

## What This Package Contains

- Generic `Builder[T]` with schema validation from struct metadata
- 25+ query types: full-text, term-level, compound, nested/join, vector (kNN), geo
- 24+ aggregation types: bucket, metric, and pipeline aggregations
- Search composition: queries, aggregations, sorting, highlighting, source filtering
- Deferred error model — errors attached to objects, checked at the end
- Dialect renderers: Elasticsearch V7/V8, OpenSearch V1/V2
- Highlight builder with per-field configuration
- kNN vector search support
- Geo queries: distance and bounding box

## What This Package Does NOT Contain

- Elasticsearch/OpenSearch client or HTTP transport
- Index management, mapping, or settings
- Result parsing or deserialization
- Scroll or search-after pagination logic

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Struct metadata extraction for field validation |

Lucene is consumed by applications for Elasticsearch/OpenSearch queries.

## Success Criteria

A developer can:
1. Build schema-validated search queries with compile-time field checking
2. Compose queries, aggregations, sorting, and highlighting into a complete search
3. Render the same search to different engine dialects without changing query code
4. Use kNN vector search and geo queries with type safety
5. Check all validation errors with a single Err() call on the search object
