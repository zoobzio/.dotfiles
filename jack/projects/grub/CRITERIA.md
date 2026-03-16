# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- All provider implementations satisfy their provider interface completely
- Typed wrappers serialize/deserialize correctly via codec without data loss
- Lifecycle hooks are called at correct points and abort on error when specified
- Database[T] discovers primary key from struct tags correctly
- Transaction variants pass *sqlx.Tx through to execution correctly
- Vector search returns correctly ranked results with deserialized metadata
- Search execution builds and parses responses correctly

### What This Repo MUST NOT Contain

- Connection pooling or management logic
- Schema migration or DDL generation
- Caching layers
- Cross-storage transactions

## Review Priorities

1. Serialization correctness: codec round-trip must preserve all data across all storage types
2. Provider compliance: every implementation must satisfy interface completely — no partial stubs
3. Lifecycle hook ordering: Before hooks must abort on error, After hooks must run after persistence
4. Primary key discovery: struct tag parsing must correctly identify primary key field
5. Transaction safety: Tx variants must use the provided transaction, not create new ones
6. Vector/Search: query building must produce valid provider-specific requests

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Serialization loses data | Critical |
| Provider implementation missing interface method | Critical |
| BeforeSave error doesn't abort persist | Critical |
| Primary key discovery wrong | High |
| Transaction variant ignores provided Tx | High |
| Vector search returns wrong ranking | High |
| Lifecycle hook called at wrong point | High |
| TTL not honored by provider that supports it | Medium |
| Error type not matching sentinel errors | Medium |
| Codec selection inefficiency | Low |

## Standing Concerns

- 16 provider implementations — verify each handles its error types correctly
- BoltDB doesn't support TTL — verify ErrTTLNotSupported is returned
- Pinecone has limited filter support — verify unsupported operators return ErrOperatorNotSupported
- Database[T] primary key from `constraints:"primarykey"` — verify edge cases with embedded structs
- Atomic wrappers lazy init via sync.Once — verify thread safety of initialization

## Out of Scope

- Provider implementations in submodules is intentional — import only what you need
- sqlx dependency for Database[T] is intentional for SQL execution
- No caching is by design — caller adds caching at the application level
- No schema migration is intentional — grub operates on existing storage
