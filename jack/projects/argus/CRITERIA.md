# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Multi-tenant isolation enforced at the store layer — no cross-tenant data leakage in any query path
- Provider interface abstraction — all cloud storage providers implement a common interface, no provider-specific logic in core
- Document versioning with clear separation: thin metadata in PostgreSQL, raw files in MinIO, searchable content in OpenSearch
- User-defined extraction pipelines composed from an admin-managed processor type catalog
- AI summarization via zyn and vector embedding via vex per document version
- Full-text search, semantic search (kNN), and related document discovery via OpenSearch
- Webhook event delivery and audit logging via capitan signals
- Both automatic (watcher-triggered) and manual (API-triggered) ingestion paths

### What This Repo MUST NOT Contain

- Content stored in PostgreSQL — PostgreSQL holds metadata only, content lives in OpenSearch
- Chunked embeddings or RAG patterns — one embedding per document version by design
- Direct file serving or streaming — Argus provides references to MinIO objects, not file streams
- Provider-specific business logic in core packages — all providers satisfy the common interface
- Cross-tenant queries or shared document access
- Document editing or rendering capabilities
- Write-back to storage providers — Argus reads, it does not write back

## Review Priorities

Ordered by importance. When findings conflict, higher-priority items take precedence.

1. Tenant isolation: any path where tenant A can access tenant B's data is critical
2. Data boundary correctness: content in OpenSearch, metadata in PostgreSQL, files in MinIO — no duplication, no misplacement
3. Provider interface compliance: implementations must satisfy the common interface without leaking provider-specific types
4. Pipeline correctness: extraction → summarization + embedding flow must handle failures gracefully without data loss
5. Ecosystem integration: sum, flux, zyn, vex, capitan must be used through their intended APIs — no workarounds or reimplementations
6. API surface: HTTP endpoints via rocco must validate input (check), respect tenant context, and return consistent error shapes
7. Search correctness: OpenSearch queries must respect tenant boundaries and return relevant results across full-text, semantic, and similarity modes

## Severity Calibration

Guidance for how Armitage classifies finding severity for this specific repo.

| Condition | Severity |
|-----------|----------|
| Cross-tenant data access possible | Critical |
| Content stored in PostgreSQL instead of OpenSearch | Critical |
| Raw SQL without tenant scoping | Critical |
| Provider-specific logic in core pipeline | High |
| Missing error handling in ingestion pipeline step | High |
| Embedding or summary generated without version association | High |
| OpenSearch index missing tenant field or filter | High |
| Webhook delivery without tenant context | High |
| Missing input validation on API endpoint | Medium |
| Extraction pipeline step ordering not enforced | Medium |
| Cache key missing tenant prefix | Medium |
| Rate limit check missing or bypassable | Medium |
| Missing test for a store-layer tenant filter | Medium |
| Inconsistent error response shape | Low |
| Internal naming inconsistency | Low |

## Standing Concerns

Persistent issues or areas of known weakness that should always be checked.

- Tenant ID must flow through every store query — verify tenant scoping is not optional or bypassable
- Document version lifecycle spans multiple stores (PostgreSQL, MinIO, OpenSearch) — verify consistency across partial failures
- Provider watchers via flux run continuously — verify they handle disconnects, rate limits, and credential expiry
- OpenSearch indices are per-tenant — verify index creation, mapping updates, and deletion respect tenant boundaries
- Extraction pipelines are user-defined — verify processor type validation prevents injection of invalid or dangerous pipeline steps
- AI calls to zyn and vex can fail or timeout — verify pipeline handles these gracefully without blocking ingestion

## Out of Scope

Things the red team should NOT flag for this repo, even if they look wrong.

- One embedding per document version (no chunking) is intentional — this is document-level intelligence, not RAG
- No write-back to providers — Argus is read-only by design
- No cross-tenant search — tenant isolation is a hard constraint, not a missing feature
- Global processor type catalog shared across tenants — processor types are admin-managed, not tenant-specific
- PostgreSQL document version rows contain no content — they are bookkeeping only, content is in OpenSearch
