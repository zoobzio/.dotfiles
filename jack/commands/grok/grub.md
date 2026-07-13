# Grub

Deep understanding of `github.com/zoobzio/grub` — provider-agnostic storage with unified interfaces for key-value, blob, SQL, vector, and search.

## Core Concepts

Grub provides type-safe generic wrappers over five storage categories, each with a provider interface and an atomic (type-erased) counterpart for framework use. Typed wrappers (`Store[T]`, `Database[T]`, `Bucket[T]`, `Index[T]`, `Search[T]`) handle serialization and expose the full provider API with compile-time safety. Atomic wrappers use `atom.Atom` for framework-level operations (scio, cereal).

- **Five storage categories:** Store (key-value), Database (SQL), Bucket (blob), Index (vector), Search (full-text)
- **Provider interfaces** define the raw storage contract per category
- **Typed wrappers** (`Store[T]`, etc.) add serialization and type safety via generics
- **Atomic wrappers** (`AtomicStore`, etc.) use `atom.Atom` for framework integration
- **Lifecycle hooks** — optional interfaces (`BeforeSave`, `AfterSave`, `AfterLoad`, `BeforeDelete`, `AfterDelete`)

**Dependencies:** `atom` (type-agnostic data), `sentinel` (struct metadata), `soy` (SQL query building), `edamame` (query execution), `astql` (SQL rendering), `lucene` (search queries), `vecna` (vector filters), `sqlx`, `uuid`

## Provider Interfaces

### StoreProvider (Key-Value)

```go
type StoreProvider interface {
    Get(ctx context.Context, key string) ([]byte, error)
    Set(ctx context.Context, key string, value []byte, ttl time.Duration) error
    Delete(ctx context.Context, key string) error
    Exists(ctx context.Context, key string) (bool, error)
    List(ctx context.Context, prefix string, limit int) ([]string, error)
    GetBatch(ctx context.Context, keys []string) (map[string][]byte, error)
    SetBatch(ctx context.Context, items map[string][]byte, ttl time.Duration) error
}
```

### BucketProvider (Blob)

```go
type BucketProvider interface {
    Get(ctx context.Context, key string) ([]byte, *ObjectInfo, error)
    Put(ctx context.Context, key string, data []byte, info *ObjectInfo) error
    Delete(ctx context.Context, key string) error
    Exists(ctx context.Context, key string) (bool, error)
    List(ctx context.Context, prefix string, limit int) ([]ObjectInfo, error)
}
```

### VectorProvider (Similarity Search)

```go
type VectorProvider interface {
    Upsert(ctx context.Context, id uuid.UUID, vector []float32, metadata []byte) error
    UpsertBatch(ctx context.Context, vectors []VectorRecord) error
    Get(ctx context.Context, id uuid.UUID) ([]float32, *VectorInfo, error)
    Delete(ctx context.Context, id uuid.UUID) error
    DeleteBatch(ctx context.Context, ids []uuid.UUID) error
    Search(ctx context.Context, vector []float32, k int, filter map[string]any) ([]VectorResult, error)
    Query(ctx context.Context, vector []float32, k int, filter *vecna.Filter) ([]VectorResult, error)
    Filter(ctx context.Context, filter *vecna.Filter, limit int) ([]VectorResult, error)
    List(ctx context.Context, limit int) ([]uuid.UUID, error)
    Exists(ctx context.Context, id uuid.UUID) (bool, error)
}
```

### SearchProvider (Full-Text)

```go
type SearchProvider interface {
    Index(ctx context.Context, index, id string, doc []byte) error
    IndexBatch(ctx context.Context, index string, docs map[string][]byte) error
    Get(ctx context.Context, index, id string) ([]byte, error)
    Delete(ctx context.Context, index, id string) error
    DeleteBatch(ctx context.Context, index string, ids []string) error
    Exists(ctx context.Context, index, id string) (bool, error)
    Search(ctx context.Context, index string, search *lucene.Search) (*SearchResponse, error)
    Count(ctx context.Context, index string, query lucene.Query) (int64, error)
    Refresh(ctx context.Context, index string) error
}
```

## Typed Wrappers

### Store[T]

```go
func NewStore[T any](provider StoreProvider) *Store[T]
func NewStoreWithCodec[T any](provider StoreProvider, codec Codec) *Store[T]
```

| Method | Signature |
|--------|-----------|
| `Get` | `Get(ctx, key) (*T, error)` |
| `Set` | `Set(ctx, key, *T, ttl) error` |
| `Delete` | `Delete(ctx, key) error` |
| `Exists` | `Exists(ctx, key) (bool, error)` |
| `List` | `List(ctx, prefix, limit) ([]string, error)` |
| `GetBatch` | `GetBatch(ctx, keys) (map[string]*T, error)` |
| `SetBatch` | `SetBatch(ctx, map[string]*T, ttl) error` |
| `Atomic` | `Atomic() *atomix.Store[T]` |

### Database[T]

```go
func NewDatabase[T any](db *sqlx.DB, table string, renderer astql.Renderer) (*Database[T], error)
```

Primary key discovered via struct tag `constraints:"primarykey"` on the `db` field tag.

| Method | Signature |
|--------|-----------|
| `Get` | `Get(ctx, key) (*T, error)` |
| `Set` | `Set(ctx, _, *T) error` |
| `Delete` | `Delete(ctx, key) error` |
| `Exists` | `Exists(ctx, key) (bool, error)` |
| `Query` | `Query() *soy.Query[T]` |
| `Select` | `Select() *soy.Select[T]` |
| `Insert` | `Insert() *soy.Create[T]` |
| `InsertFull` | `InsertFull() *soy.Create[T]` |
| `Modify` | `Modify() *soy.Update[T]` |
| `Remove` | `Remove() *soy.Delete[T]` |
| `Count` | `Count() *soy.Aggregate[T]` |
| `ExecQuery` | `ExecQuery(ctx, stmt, params) ([]*T, error)` |
| `ExecSelect` | `ExecSelect(ctx, stmt, params) (*T, error)` |
| `ExecUpdate` | `ExecUpdate(ctx, stmt, params) (*T, error)` |
| `ExecAggregate` | `ExecAggregate(ctx, stmt, params) (float64, error)` |

Transaction variants: `GetTx`, `SetTx`, `DeleteTx`, `ExistsTx`, `ExecQueryTx`, `ExecSelectTx`, `ExecUpdateTx`, `ExecAggregateTx` — all accept `*sqlx.Tx` as second parameter.

### Bucket[T]

```go
func NewBucket[T any](provider BucketProvider) *Bucket[T]
func NewBucketWithCodec[T any](provider BucketProvider, codec Codec) *Bucket[T]
```

| Method | Signature |
|--------|-----------|
| `Get` | `Get(ctx, key) (*Object[T], error)` |
| `Put` | `Put(ctx, *Object[T]) error` |
| `Delete` | `Delete(ctx, key) error` |
| `Exists` | `Exists(ctx, key) (bool, error)` |
| `List` | `List(ctx, prefix, limit) ([]ObjectInfo, error)` |
| `Atomic` | `Atomic() *atomix.Bucket[T]` |

### Index[T]

```go
func NewIndex[T any](provider VectorProvider) *Index[T]
func NewIndexWithCodec[T any](provider VectorProvider, codec Codec) *Index[T]
```

| Method | Signature |
|--------|-----------|
| `Upsert` | `Upsert(ctx, id, vector, *T) error` |
| `UpsertBatch` | `UpsertBatch(ctx, []Vector[T]) error` |
| `Get` | `Get(ctx, id) (*Vector[T], error)` |
| `Delete` | `Delete(ctx, id) error` |
| `DeleteBatch` | `DeleteBatch(ctx, ids) error` |
| `Search` | `Search(ctx, vector, k, *T) ([]*Vector[T], error)` |
| `Query` | `Query(ctx, vector, k, *vecna.Filter) ([]*Vector[T], error)` |
| `Filter` | `Filter(ctx, *vecna.Filter, limit) ([]*Vector[T], error)` |
| `List` | `List(ctx, limit) ([]uuid.UUID, error)` |
| `Exists` | `Exists(ctx, id) (bool, error)` |
| `Atomic` | `Atomic() *atomix.Index[T]` |

### Search[T]

```go
func NewSearch[T any](provider SearchProvider, index string) (*Search[T], error)
func NewSearchWithCodec[T any](provider SearchProvider, index string, codec Codec) (*Search[T], error)
```

| Method | Signature |
|--------|-----------|
| `Index` | `Index(ctx, id, *T) error` |
| `IndexBatch` | `IndexBatch(ctx, map[string]*T) error` |
| `Get` | `Get(ctx, id) (*Document[T], error)` |
| `Delete` | `Delete(ctx, id) error` |
| `DeleteBatch` | `DeleteBatch(ctx, ids) error` |
| `Exists` | `Exists(ctx, id) (bool, error)` |
| `Query` | `Query() *lucene.Builder[T]` |
| `Execute` | `Execute(ctx, *lucene.Search) (*SearchResult[T], error)` |
| `Count` | `Count(ctx, lucene.Query) (int64, error)` |
| `Refresh` | `Refresh(ctx) error` |
| `Atomic` | `Atomic() *atomix.Search[T]` |

## Value Types

```go
type Object[T any] struct {
    Key, ContentType, ETag string
    Size                   int64
    Metadata               map[string]string
    Data                   T
}

type Vector[T any] struct {
    ID       uuid.UUID
    Vector   []float32
    Score    float32
    Metadata T
}

type Document[T any] struct {
    ID      string
    Content T
    Score   float64
}

type SearchResult[T any] struct {
    Hits         []*Document[T]
    Total        int64
    MaxScore     float64
    Aggregations map[string]any
}
```

## Lifecycle Hooks

Optional interfaces on T — called automatically during CRUD:

| Interface | Method | When |
|-----------|--------|------|
| `BeforeSave` | `BeforeSave(ctx) error` | Before persist (abort on error) |
| `AfterSave` | `AfterSave(ctx) error` | After successful persist |
| `AfterLoad` | `AfterLoad(ctx) error` | After decode |
| `BeforeDelete` | `BeforeDelete(ctx) error` | Before delete (abort on error) |
| `AfterDelete` | `AfterDelete(ctx) error` | After successful delete |

## Codec

```go
type Codec interface {
    Encode(v any) ([]byte, error)
    Decode(data []byte, v any) error
}
```

Built-in: `JSONCodec` (default), `GobCodec`.

## Error Types

| Error | Purpose |
|-------|---------|
| `ErrNotFound` | Record not found |
| `ErrDuplicate` | Duplicate record |
| `ErrConflict` | Conflict |
| `ErrConstraint` | Constraint violation |
| `ErrInvalidKey` | Invalid key |
| `ErrReadOnly` | Read-only |
| `ErrTableExists` | Table already registered |
| `ErrTableNotFound` | Table not registered |
| `ErrTTLNotSupported` | Provider doesn't support TTL |
| `ErrDimensionMismatch` | Vector dimension mismatch |
| `ErrInvalidVector` | Invalid vector |
| `ErrIndexNotReady` | Index not ready |
| `ErrInvalidQuery` | Invalid query filter |
| `ErrOperatorNotSupported` | Operator not supported by provider |
| `ErrFilterNotSupported` | Filter not supported by provider |
| `ErrNoPrimaryKey` | No primary key in struct tags |
| `ErrMultiplePrimaryKeys` | Multiple primary keys not supported |

## Provider Implementations

### Store Providers

| Provider | Package | TTL Support |
|----------|---------|-------------|
| Redis | `redis` | Yes |
| BadgerDB | `badger` | Yes |
| BoltDB | `bolt` | No (`ErrTTLNotSupported`) |

### Bucket Providers

| Provider | Package |
|----------|---------|
| AWS S3 | `s3` |
| Google Cloud Storage | `gcs` |
| Azure Blob Storage | `azure` |
| MinIO | `minio` |

### Vector Providers

| Provider | Package | Filter Support |
|----------|---------|----------------|
| Pinecone | `pinecone` | Eq, Ne, In, Nin, And, Or, Not |
| Weaviate | `weaviate` | Full vecna filter support |
| Milvus | `milvus` | Full vecna filter support |
| Qdrant | `qdrant` | Full vecna filter support |

### Search Providers

| Provider | Package | Renderer |
|----------|---------|----------|
| Elasticsearch | `elasticsearch` | ES V7/V8 |
| OpenSearch | `opensearch` | OS V1/V2 |

### Database Drivers

| Database | Package | Registration |
|----------|---------|--------------|
| PostgreSQL | `postgres` | Blank import |
| SQLite | `sqlite` | Blank import |

## Thread Safety

- **Typed wrappers** — `sync.Once` for lazy atomic wrapper initialization; safe for concurrent use
- **Database[T]** — transaction methods (`*Tx`) for ACID isolation
- **Provider thread safety** — delegated to underlying client libraries

## File Layout

```
grub/
├── api.go             # Provider + Atomic interfaces, errors
├── store.go           # Store[T]
├── database.go        # Database[T]
├── bucket.go          # Bucket[T]
├── index.go           # Index[T]
├── search.go          # Search[T], Document[T], SearchResult[T]
├── object.go          # Object[T], ObjectInfo
├── vector.go          # Vector[T], VectorInfo, VectorRecord, VectorResult
├── hooks.go           # Lifecycle hook interfaces
├── codec.go           # Codec interface, JSONCodec, GobCodec
├── redis/             # Redis StoreProvider
├── badger/            # BadgerDB StoreProvider
├── bolt/              # BoltDB StoreProvider
├── s3/                # AWS S3 BucketProvider
├── gcs/               # GCS BucketProvider
├── azure/             # Azure BucketProvider
├── minio/             # MinIO BucketProvider
├── pinecone/          # Pinecone VectorProvider
├── weaviate/          # Weaviate VectorProvider
├── milvus/            # Milvus VectorProvider
├── qdrant/            # Qdrant VectorProvider
├── elasticsearch/     # Elasticsearch SearchProvider
├── opensearch/        # OpenSearch SearchProvider
├── postgres/          # PostgreSQL driver
├── sqlite/            # SQLite driver
├── internal/          # Shared types, atomix wrappers
└── testing/           # Test utilities
```

## Common Patterns

**Key-value store:**

```go
store := grub.NewStore[Session](redisProvider)
store.Set(ctx, "sess-123", &session, 30*time.Minute)
sess, _ := store.Get(ctx, "sess-123")
```

**SQL database with queries:**

```go
db, _ := grub.NewDatabase[User](sqlxDB, "users", astql.PostgresRenderer())
users, _ := db.Query().Where(soy.Eq("active", true)).Exec(ctx)
```

**Vector search:**

```go
idx := grub.NewIndex[DocMeta](qdrantProvider)
idx.Upsert(ctx, docID, embedding, &meta)
results, _ := idx.Query(ctx, queryVec, 10, filter)
```

**Blob storage:**

```go
bucket := grub.NewBucket[Report](s3Provider)
bucket.Put(ctx, &grub.Object[Report]{Key: "q1.pdf", Data: report})
```

## Ecosystem

Grub depends on:
- **atom** — type-agnostic data for atomic interfaces
- **sentinel** — struct metadata for primary key discovery
- **soy** — SQL query building
- **edamame** — query execution
- **astql** — SQL rendering
- **lucene** — search query building
- **vecna** — vector filter building

Grub is consumed by:
- **scio** — URI-based data catalog wrapping grub providers
- **sum** — application framework data helpers
- Applications for direct storage access
