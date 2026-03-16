# Mission: argus

Multi-tenant document ingestion platform. Watch cloud storage, extract content, build searchable knowledge bases.

## Purpose

Provide a document intelligence layer that sits between cloud storage providers and the teams that need to search, understand, and act on their documents. Argus watches files across multiple storage platforms, extracts content (including OCR for scanned documents), generates AI summaries and vector embeddings, and indexes everything into a per-tenant search engine.

Argus exists because teams store documents across many platforms and have no unified way to search, monitor, or extract intelligence from them. This platform normalizes that into a single searchable knowledge base per tenant.

## What This Application Contains

- Cloud storage provider integrations (Google Drive, OneDrive/SharePoint, Dropbox) via a common provider interface
- File watching via flux capacitors that monitor registered paths for changes
- Document versioning with thin PostgreSQL metadata and raw file storage in MinIO
- User-defined extraction pipelines composed from an admin-managed processor type catalog
- AI summarization per document version via zyn
- Vector embedding per document version via vex (one embedding per document, not chunked)
- Full-text and semantic search via OpenSearch with kNN support
- Related document discovery using vector similarity
- OCR via Tesseract gRPC sidecar for scanned documents and images
- Multi-tenant isolation at the store layer
- Webhook event delivery and audit logging via capitan signals

## What This Application Does NOT Contain

- A document editor or viewer — Argus indexes and searches, it does not render
- A RAG pipeline — embeddings are for document-level intelligence and similarity, not passage retrieval
- Direct file serving — raw documents are in MinIO, Argus provides references not streams
- Provider-specific business logic in the core — all providers satisfy a common interface

## Data Storage Responsibilities

| Store | Owns |
|-------|------|
| PostgreSQL | Tenants, providers, watched paths, documents, document versions (metadata only), extraction pipelines, processor types, users, subscriptions |
| MinIO | Raw document files |
| OpenSearch | Extracted content, AI summaries, vector embeddings, searchable metadata |
| Redis | Cache, rate limit counters, real-time usage tracking |

No content is duplicated across stores. Each system owns what it is good at.

## Ecosystem Position

Argus is a product application built on the zoobzio framework:

| Dependency | Role |
|------------|------|
| `sum` | Service registry, dependency injection, boundary management |
| `flux` | Reactive file watching for provider change detection |
| `zyn` | LLM orchestration for AI summaries |
| `vex` | Vector embedding generation |
| `capitan` | Event system driving webhooks, audit logging, observability |
| `aperture` | Capitan-to-OpenTelemetry bridge |
| `rocco` | HTTP routing with OpenAPI support |
| `grub` | Object storage abstraction (MinIO) |
| `astql` | SQL query builder |
| `fig` | Configuration management |
| `check` | Request validation |

## Success Criteria

A tenant can:
1. Connect a cloud storage provider and register paths to watch
2. See documents automatically ingested when changes are detected
3. Trigger manual ingestion on demand
4. Define custom extraction pipelines from available processor types
5. Search their entire document corpus by keyword, semantic meaning, or metadata filters
6. Discover related documents from any document they are viewing
7. Receive webhook notifications for ingestion events
8. View version history for any tracked document

## Design Constraints

- Multi-tenant from day one — tenant isolation enforced at the store layer
- Horizontally scalable — pipelines are queue-driven and stateless
- Provider-agnostic — common interface, individual implementations
- Content lives in OpenSearch, metadata in PostgreSQL, files in MinIO — no duplication
- One embedding per document version — document-level intelligence, not chunked

## Non-Goals

- Real-time collaboration or document editing
- Replacing the storage providers — Argus reads, it does not write back
- Building a general-purpose workflow engine — extraction pipelines are scoped to document processing
- Cross-tenant search or document sharing
