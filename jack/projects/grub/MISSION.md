# Mission: grub

Provider-agnostic storage with unified interfaces for key-value, blob, SQL, vector, and search.

## Purpose

Provide type-safe generic wrappers over five storage categories, each with a provider interface and typed wrappers handling serialization with compile-time safety. Atomic wrappers use atom.Atom for framework-level operations.

Grub exists because applications need multiple storage backends (Redis, S3, PostgreSQL, Pinecone, Elasticsearch) behind consistent interfaces with type safety, lifecycle hooks, and codec-agnostic serialization.

## What This Package Contains

- Five storage categories: Store (key-value), Database (SQL), Bucket (blob), Index (vector), Search (full-text)
- Provider interfaces defining raw storage contracts per category
- Typed wrappers (Store[T], Database[T], Bucket[T], Index[T], Search[T]) with serialization and generics
- Atomic wrappers for framework integration via atom.Atom
- Lifecycle hooks: BeforeSave, AfterSave, AfterLoad, BeforeDelete, AfterDelete
- Codec interface with JSON and Gob built-in implementations
- Value types: Object[T], Vector[T], Document[T], SearchResult[T]
- Database[T] with soy query building, edamame execution, and transaction variants
- Index[T] with vecna filter support for vector similarity search
- Search[T] with lucene query building for full-text search
- 16 provider implementations across key-value, blob, vector, search, and SQL

## What This Package Does NOT Contain

- Connection pooling or management — delegated to underlying client libraries
- Schema migration — Database[T] operates on existing tables
- Caching layers — caller adds caching if needed
- Cross-storage transactions

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `atom` | Type-agnostic data for atomic interfaces |
| `sentinel` | Struct metadata for primary key discovery |
| `soy` | SQL query building |
| `edamame` | Query execution |
| `astql` | SQL rendering |
| `lucene` | Search query building |
| `vecna` | Vector filter building |

Grub is consumed by:
- `scio` — URI-based data catalog wrapping grub providers
- `sum` — application framework data helpers
- Applications for direct storage access

## Provider Implementations

### Key-Value
Redis, BadgerDB, BoltDB

### Blob
AWS S3, Google Cloud Storage, Azure Blob Storage, MinIO

### Vector
Pinecone, Weaviate, Milvus, Qdrant

### Search
Elasticsearch, OpenSearch

### SQL
PostgreSQL, SQLite

## Design Constraints

- Primary key discovered via struct tag `constraints:"primarykey"` on db field tag
- Database[T] transaction methods accept *sqlx.Tx for ACID isolation
- Lifecycle hooks abort on BeforeSave/BeforeDelete error
- Typed wrappers use sync.Once for lazy atomic wrapper initialization
- Thread safety delegated to underlying provider client libraries

## Success Criteria

A developer can:
1. Use key-value, blob, SQL, vector, and search storage through consistent typed interfaces
2. Switch storage providers without changing application code
3. Build SQL queries with soy, search queries with lucene, vector filters with vecna
4. Hook into entity lifecycle for validation, auditing, or transformation
5. Use atomic wrappers for framework-level operations (scio, cereal)
6. Execute SQL queries within transactions for ACID guarantees

## Non-Goals

- Connection pool management
- Schema migration or DDL
- Cross-storage distributed transactions
- Caching or query result memoization
