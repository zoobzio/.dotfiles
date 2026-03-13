# Sctx

Deep understanding of `github.com/zoobzio/sctx` — certificate-based security contexts with mTLS certs to typed authorization tokens.

## Core Concepts

Sctx transforms X.509 certificates into typed security contexts with RBAC, signed tokens, and replay protection. An `Admin[M]` is the singleton authority that generates `SignedToken` values from certificates (after verifying a `SignedAssertion` proving private key possession). `Guard` instances enforce permission checks. `Principal` represents an authenticated in-process consumer. All operations emit capitan signals for observability.

- **Context[M]** — generic security context with metadata, permissions, and certificate info
- **Admin[M]** — singleton authority for token generation, guard creation, and revocation
- **SignedToken** — opaque, tamper-proof token (`base64(payload):base64(signature)`)
- **SignedAssertion** — proves private key possession before token generation
- **Guard** — validates tokens against required permissions
- **Principal** — authenticated consumer with token injection into context
- **Three-level resolution:** assertion → token → guard

**Dependencies:** `capitan` (observability)

## Public API

### Context[M]

```go
type Context[M any] struct {
    IssuedAt               time.Time
    ExpiresAt              time.Time
    Metadata               M
    CertificateInfo        CertificateInfo
    CertificateFingerprint string
    Permissions            []string
}
```

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `HasPermission` | `HasPermission(scope string) bool` | Check permission |
| `IsExpired` | `IsExpired() bool` | Check expiration |
| `Clone` | `Clone() *Context[M]` | Deep copy |

### CertificateInfo

```go
type CertificateInfo struct {
    CommonName, SerialNumber, Issuer, Country, Province, Locality string
    Organization, OrganizationalUnit, StreetAddress, PostalCode   []string
    IssuerOrganization, KeyUsage, DNSNames, EmailAddresses        []string
    URIs, IPAddresses                                             []string
    NotBefore, NotAfter                                           time.Time
}
```

### Admin[M]

```go
func NewAdminService[M any](privateKey crypto.PrivateKey, trustedCAs *x509.CertPool) (Admin[M], error)
```

Only one Admin per application instance.

```go
type Admin[M any] interface {
    Generate(ctx context.Context, cert *x509.Certificate, assertion SignedAssertion) (SignedToken, error)
    CreateGuard(ctx context.Context, token SignedToken, requiredPermissions ...string) (Guard, error)
    SetGuardCreationPermissions(perms []string)
    SetPolicy(policy ContextPolicy[M]) error
    SetCache(cache ContextCache[M]) error
    RevokeByFingerprint(ctx context.Context, fingerprint string) error
    GetContext(ctx context.Context, fingerprint string) (*Context[M], bool)
    ActiveCount() int
}
```

### Guard

```go
type Guard interface {
    ID() string
    Validate(ctx context.Context, tokens ...SignedToken) error
    Permissions() []string
}
```

### Principal

```go
func NewPrincipal[M any](ctx context.Context, admin Admin[M], privateKey crypto.PrivateKey, cert *x509.Certificate) (Principal, error)
```

```go
type Principal interface {
    Token() SignedToken
    Inject(ctx context.Context) context.Context
    Guard(ctx context.Context, requiredPermissions ...string) (Guard, error)
}
```

### Tokens and Assertions

```go
type SignedToken string
type SignedAssertion struct {
    Claims    AssertionClaims
    Signature []byte
}
type AssertionClaims struct {
    IssuedAt, ExpiresAt time.Time
    Nonce, Purpose, Fingerprint string
}

func CreateAssertion(privateKey crypto.PrivateKey, cert *x509.Certificate) (SignedAssertion, error)
func TokenFromContext(ctx context.Context) (SignedToken, bool)
```

### Policy and Guards

```go
type ContextPolicy[M any] func(cert *x509.Certificate) (*Context[M], error)
type ContextGuard[M any] func(context.Context, *Context[M]) (*Context[M], error)

func DefaultContextPolicy[M any]() ContextPolicy[M]
```

**Validation guards:**

| Function | Signature | Purpose |
|----------|-----------|---------|
| `RequireCertField` | `RequireCertField[M](field, expected) ContextGuard[M]` | Exact match on cert field |
| `RequireCertPattern` | `RequireCertPattern[M](field, pattern) ContextGuard[M]` | Regex match on cert field |
| `GrantPermissions` | `GrantPermissions[M](permissions...) ContextGuard[M]` | Add permissions |
| `SetContext` | `SetContext[M](opts ContextOptions) ContextGuard[M]` | Set expiry/permissions |

Supported fields: CN, O, OU, C, ST, L, STREET, POSTALCODE, ISSUER, ISSUERORG, SERIAL, DNS, EMAILS, URIS, IPS, KEYUSAGE, NOTBEFORE, NOTAFTER.

### Cryptography

```go
type CryptoAlgorithm string
const (
    CryptoEd25519   CryptoAlgorithm = "ed25519"     // Default, 30% faster
    CryptoECDSAP256 CryptoAlgorithm = "ecdsa-p256"  // FIPS 140-2 compliant
)

type CryptoSigner interface {
    Sign(data []byte) ([]byte, error)
    Verify(data, signature []byte, publicKey crypto.PublicKey) bool
    Algorithm() CryptoAlgorithm
    PublicKey() crypto.PublicKey
    KeyType() string
}

func NewCryptoSigner(algorithm CryptoAlgorithm, privateKey crypto.PrivateKey) (CryptoSigner, error)
func GenerateKeyPair(algorithm CryptoAlgorithm) (crypto.PublicKey, crypto.PrivateKey, error)
func DetectAlgorithmFromPublicKey(publicKey crypto.PublicKey) (CryptoAlgorithm, error)
func DetectAlgorithmFromPrivateKey(privateKey crypto.PrivateKey) (CryptoAlgorithm, error)
func GetFingerprint(cert *x509.Certificate) string
```

### Cache

```go
type ContextCache[M any] interface {
    Get(ctx context.Context, fingerprint string) (*Context[M], bool)
    Store(ctx context.Context, fingerprint string, sctx *Context[M])
    Delete(ctx context.Context, fingerprint string) error
    Start(shutdown chan struct{}, wg *sync.WaitGroup)
    Count() int
}

func NewMemoryContextCache[M any](cleanupInterval time.Duration) ContextCache[M]
func NewBoundedMemoryCache[M any](opts CacheOptions) ContextCache[M]

type CacheOptions struct {
    MaxSize         int           // 0 = unbounded
    CleanupInterval time.Duration // Default: 5 minutes
}
```

## Error Types

| Error | Purpose |
|-------|---------|
| `ErrInvalidSignature` | Signature verification failed |
| `ErrExpiredContext` | Context has expired |
| `ErrInvalidContext` | Invalid context format |
| `ErrInvalidKey` | Invalid private key |
| `ErrAdminAlreadyCreated` | Singleton violation |
| `ErrNoPolicy` | No context policy configured |

## Capitan Signals

### Token Lifecycle
| Signal | Purpose |
|--------|---------|
| `TokenGenerated` | Token created from certificate |
| `TokenVerified` | Token successfully verified |
| `TokenRejected` | Token verification failed |

### Guard Lifecycle
| Signal | Purpose |
|--------|---------|
| `GuardCreated` | Permission guard created |
| `GuardValidated` | Guard validation succeeded |
| `GuardRejected` | Guard validation failed |

### Context / Principal / Assertion
| Signal | Purpose |
|--------|---------|
| `ContextRevoked` | Context manually revoked |
| `PrincipalCreated` | Principal established |
| `AssertionValidated` | Assertion passed |
| `AssertionRejected` | Assertion failed |
| `CertificateRejected` | Certificate verification failed |

### Cache Operations
| Signal | Purpose |
|--------|---------|
| `CacheStored` / `CacheHit` / `CacheMiss` | Cache CRUD |
| `CacheDeleted` / `CacheExpired` / `CacheEvicted` | Cache cleanup |

**Field keys:** `FingerprintKey`, `CommonNameKey`, `PermissionsKey`, `RequiredPermsKey`, `GuardIDKey`, `ErrorKey`, `ExpiresAtKey`, `DurationMsKey`

## Thread Safety

- **adminService[M]** — `sync.RWMutex` for policy, `sync.Mutex` for nonce operations
- **memoryContextCache[M]** — `sync.RWMutex` for all operations
- **boundedMemoryCache[M]** — `sync.RWMutex` with LRU eviction
- Cache cleanup runs in background goroutine via `Start()`

## File Layout

```
sctx/
├── api.go          # Interfaces: Admin, Guard, Principal
├── context.go      # Context[M], CertificateInfo, token encoding/verification
├── admin.go        # Admin service implementation
├── principal.go    # Principal implementation, context integration
├── assertion.go    # Assertion creation and validation
├── guards.go       # ContextGuard functions, Guard implementation
├── crypto.go       # CryptoSigner, Ed25519, ECDSA-P256
├── cache.go        # Memory cache implementation
├── lru.go          # LRU bounded cache
├── nonce_cache.go  # Bounded nonce cache for replay protection
├── events.go       # Capitan signal definitions
└── testing/        # Test helpers, cert generation, integration tests
```

## Common Patterns

**Bootstrap admin and principal:**

```go
admin, _ := sctx.NewAdminService[AppMeta](privateKey, caPool)
admin.SetPolicy(sctx.DefaultContextPolicy[AppMeta]())
principal, _ := sctx.NewPrincipal(ctx, admin, clientKey, clientCert)
```

**Token-based guard:**

```go
guard, _ := admin.CreateGuard(ctx, principal.Token(), "read:users", "write:users")
err := guard.Validate(ctx, principal.Token())
```

**Context enrichment pipeline:**

```go
admin.SetPolicy(func(cert *x509.Certificate) (*sctx.Context[AppMeta], error) {
    ctx := sctx.DefaultContextPolicy[AppMeta]()(cert)
    ctx = sctx.RequireCertField[AppMeta]("O", "MyOrg")(context.Background(), ctx)
    ctx = sctx.GrantPermissions[AppMeta]("read:*")(context.Background(), ctx)
    return ctx, nil
})
```

**Inject token into context:**

```go
ctx = principal.Inject(ctx)
// Later, in a handler:
token, ok := sctx.TokenFromContext(ctx)
```

## Ecosystem

Sctx depends on:
- **capitan** — observability signals

Sctx is consumed by:
- **aegis** — mTLS authorization in the service mesh
