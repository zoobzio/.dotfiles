# Fig

Deep understanding of `github.com/zoobzio/fig` — configuration loading from environment variables, secret providers, and defaults via struct tags.

## Core Concepts

Fig populates Go structs from multiple sources using struct tags. Resolution follows a strict priority order: **secret → env → default → zero value**. A single generic entry point handles all configuration loading with optional validation.

- **Load[T]** / **LoadContext[T]** are the only entry points
- **SecretProvider** interface enables pluggable secret backends
- **Validator** interface enables post-load validation
- Resolution is per-field, priority-ordered, with recursive nested struct support

**Dependencies:** `sentinel` (struct tag scanning)

## Public API

### Entry Points

| Function | Signature | Behaviour |
|----------|-----------|-----------|
| `Load[T]` | `Load[T any](cfg *T, provider ...SecretProvider) error` | Populate struct (uses context.Background) |
| `LoadContext[T]` | `LoadContext[T any](ctx context.Context, cfg *T, provider ...SecretProvider) error` | Populate struct with context |

### Interfaces

```go
type SecretProvider interface {
    Get(ctx context.Context, key string) (string, error)
}

type Validator interface {
    Validate() error
}
```

If T implements `Validator`, `Validate()` is called after loading. Validation errors are NOT wrapped in `FieldError`.

## Struct Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `env` | Environment variable name | `env:"DB_HOST"` |
| `secret` | Secret provider key | `secret:"db/password"` |
| `default` | Fallback value | `default:"localhost"` |
| `required` | Field is mandatory | `required:"true"` |

### Resolution Order

1. **Secret** — if provider passed, try `provider.Get(ctx, key)`; if returns `ErrSecretNotFound`, continue
2. **Environment** — `os.Getenv(tag value)`
3. **Default** — tag literal value
4. **Zero value** — if none found and not required

If field is `required:"true"` and no value found → `ErrRequired`.

## Supported Types

| Type | Conversion |
|------|-----------|
| `string` | Direct |
| `int`, `int8`–`int64` | `strconv.ParseInt` |
| `uint`, `uint8`–`uint64` | `strconv.ParseUint` |
| `float32`, `float64` | `strconv.ParseFloat` |
| `bool` | true/false, 1/0, t/f (case-insensitive) |
| `time.Duration` | `time.ParseDuration` (ns, us, ms, s, m, h) |
| `[]string` | Comma-separated, trimmed |
| `*T` | Pointer to any supported type |
| `encoding.TextUnmarshaler` | Delegates to `UnmarshalText` |
| Nested structs | Recursive loading |

## Error Types

### Sentinel Errors

| Error | Purpose |
|-------|---------|
| `ErrRequired` | Required field has no value |
| `ErrInvalidType` | Type conversion failed |
| `ErrNotStruct` | Load called with non-struct type |
| `ErrSecretNotFound` | Secret doesn't exist (provider returns this to fall through) |

### Custom Error Type

```go
type FieldError struct {
    Err   error
    Field string
}
```

Implements `Error()` and `Unwrap()`. Most load errors are wrapped in `FieldError` with the field name.

## Secret Provider Implementations

### Vault (`fig/vault`)

HashiCorp Vault KV v2.

| Factory | Options |
|---------|---------|
| `New() (SecretProvider, error)` | Reads `VAULT_ADDR`, `VAULT_TOKEN`, `VAULT_CACERT` |

Options: `WithMount()`, `WithAddress()`, `WithToken()`, `WithHTTPClient()`

Key format: `path/to/secret:field` (field defaults to `"value"`)

### AWS Secrets Manager (`fig/awssm`)

| Factory | Options |
|---------|---------|
| `New() (SecretProvider, error)` | Uses default AWS credential chain |
| `NewWithClient(client) SecretProvider` | Pre-configured client |

Key format: `secret-name:json-field` (field optional for string secrets)

### GCP Secret Manager (`fig/gcpsm`)

| Factory | Options |
|---------|---------|
| `New(ctx) (SecretProvider, error)` | Uses Application Default Credentials |

Options: `WithHTTPClient()`

Key format: `secret-name:json-field`

## Sentinel Integration

Tags registered in `init()`:
```go
sentinel.Tag("env")
sentinel.Tag("secret")
sentinel.Tag("default")
sentinel.Tag("required")
```

Uses `sentinel.TryScan[T]()` for metadata extraction. Sentinel caches metadata per type — repeated `Load` calls avoid reflection.

## Thread Safety

Fig itself is thread-safe:
- No global mutable state (sentinel cache is write-once-read-many)
- `Load`/`LoadContext` use only local variables
- No synchronization primitives in fig code

Custom providers may need their own synchronization.

## File Layout

```
fig/
├── api.go         # Load, LoadContext, Validator interface
├── provider.go    # SecretProvider interface
├── resolve.go     # Resolution logic, nested struct handling
├── convert.go     # Type conversion (string → target type)
├── errors.go      # Error types and sentinels
├── vault/         # HashiCorp Vault provider
├── awssm/         # AWS Secrets Manager provider
├── gcpsm/         # GCP Secret Manager provider
└── testing/
    └── helpers.go # MockProvider, SetEnv (//go:build testing)
```

## Common Patterns

**Basic loading:**

```go
type Config struct {
    Host string `env:"DB_HOST" default:"localhost"`
    Port int    `env:"DB_PORT" default:"5432"`
    Pass string `secret:"db/password" required:"true"`
}

var cfg Config
err := fig.Load(&cfg, vaultProvider)
```

**Nested configuration:**

```go
type Database struct {
    Host string `env:"DB_HOST" default:"localhost"`
    Port int    `env:"DB_PORT" default:"5432"`
}

type Config struct {
    Database Database  // Recursively loaded
    Name     string    `env:"APP_NAME"`
}
```

**With validation:**

```go
func (c *Config) Validate() error {
    if c.Port < 1 || c.Port > 65535 {
        return fmt.Errorf("invalid port: %d", c.Port)
    }
    return nil
}
```

## Testing Helpers

Require `//go:build testing` tag.

| Helper | Purpose |
|--------|---------|
| `NewMockProvider(t, secrets map[string]string)` | In-memory secret provider |
| `SetEnv(t, key, value)` | Convenience wrapper for `t.Setenv` |

## Ecosystem

Fig depends on:
- **sentinel** — struct tag scanning and metadata caching

Fig is consumed by:
- Applications for configuration loading
