# Cereal

Deep understanding of `github.com/zoobzio/cereal` — boundary-aware serialization: encrypt for storage, mask for APIs, hash on receive.

## Core Concepts

Cereal implements a **four-boundary model** for data transformation. Struct tags declare sensitivity; the generic `Processor[T]` enforces transformations at each boundary crossing. Original values are never mutated — clones are created before every transformation.

- **Receive** — ingress from external sources (API requests, events) → applies hashing
- **Load** — ingress from storage (database, cache) → applies decryption
- **Store** — egress to storage → applies encryption
- **Send** — egress to external destinations (API responses, events) → applies masking/redaction

All types used with Processor must implement `Cloner[T]` (deep clone via `Clone() T`).

**Dependencies:** `sentinel` (struct tag scanning), `capitan` (observable events), `golang.org/x/crypto` (cryptographic primitives)

## Public API

### Factory

```go
func NewProcessor[T Cloner[T]]() (*Processor[T], error)
```

### Processor[T] Methods

#### Boundary Crossing (T → T)

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Receive` | `Receive(ctx, obj T) (T, error)` | Clone + hash tagged fields |
| `Load` | `Load(ctx, obj T) (T, error)` | Clone + decrypt tagged fields |
| `Store` | `Store(ctx, obj T) (T, error)` | Clone + encrypt tagged fields |
| `Send` | `Send(ctx, obj T) (T, error)` | Clone + mask/redact tagged fields |

#### Codec-Aware (requires SetCodec)

| Method | Signature | Behaviour |
|--------|-----------|-----------|
| `Decode` | `Decode(ctx, data []byte) (*T, error)` | Unmarshal + hash |
| `Read` | `Read(ctx, data []byte) (*T, error)` | Unmarshal + decrypt |
| `Write` | `Write(ctx, obj *T) ([]byte, error)` | Encrypt + marshal |
| `Encode` | `Encode(ctx, obj *T) ([]byte, error)` | Mask/redact + marshal |

#### Configuration (fluent, all return `*Processor[T]`)

| Method | Signature |
|--------|-----------|
| `SetCodec` | `SetCodec(codec Codec) *Processor[T]` |
| `SetEncryptor` | `SetEncryptor(algo EncryptAlgo, enc Encryptor) *Processor[T]` |
| `SetHasher` | `SetHasher(algo HashAlgo, h Hasher) *Processor[T]` |
| `SetMasker` | `SetMasker(mt MaskType, m Masker) *Processor[T]` |
| `Validate` | `Validate() error` |

### Core Interfaces

```go
type Cloner[T any] interface {
    Clone() T
}

type Codec interface {
    ContentType() string
    Marshal(any) ([]byte, error)
    Unmarshal([]byte, any) error
}
```

### Override Interfaces

| Interface | Method | Purpose |
|-----------|--------|---------|
| `Encryptable` | `Encrypt(map[EncryptAlgo]Encryptor) error` | Custom encryption logic |
| `Decryptable` | `Decrypt(map[EncryptAlgo]Encryptor) error` | Custom decryption logic |
| `Hashable` | `Hash(map[HashAlgo]Hasher) error` | Custom hashing logic |
| `Maskable` | `Mask(map[MaskType]Masker) error` | Custom masking logic |
| `Redactable` | `Redact() error` | Custom redaction logic |

## Struct Tag System

Tags use compound format: `{context}.{action}:"{capability}"`

| Tag | Values | Purpose |
|-----|--------|---------|
| `receive.hash` | `"argon2"`, `"bcrypt"`, `"sha256"`, `"sha512"` | Hash on ingress |
| `load.decrypt` | `"aes"`, `"rsa"`, `"envelope"` | Decrypt from storage |
| `store.encrypt` | `"aes"`, `"rsa"`, `"envelope"` | Encrypt for storage |
| `send.mask` | `"ssn"`, `"email"`, `"phone"`, `"card"`, `"ip"`, `"uuid"`, `"iban"`, `"name"` | Mask for API response |
| `send.redact` | `"{replacement}"` e.g. `"***"`, `"[REDACTED]"` | Replace entirely |

**Supported field types:** `string`, `[]byte`, `[]string`, `map[K]string`

Nested structs supported recursively including pointer-to-struct with nil-checking.

## Encryption

**`Encryptor` interface:** `Encrypt(plaintext []byte) ([]byte, error)`, `Decrypt(ciphertext []byte) ([]byte, error)`

| Algorithm | Constant | Factory | Notes |
|-----------|----------|---------|-------|
| AES-GCM | `EncryptAES` | `AES(key []byte) (Encryptor, error)` | Key: 16/24/32 bytes |
| RSA-OAEP | `EncryptRSA` | `RSA(pub, priv) Encryptor` | Public/private key pair |
| Envelope | `EncryptEnvelope` | `Envelope(masterKey []byte) (Encryptor, error)` | Per-message data keys |

## Hashing

**`Hasher` interface:** `Hash(plaintext []byte) (string, error)`

| Algorithm | Constant | Factory | Notes |
|-----------|----------|---------|-------|
| Argon2 | `HashArgon2` | `Argon2()` / `Argon2WithParams(Argon2Params)` | OWASP recommended for passwords |
| Bcrypt | `HashBcrypt` | `Bcrypt()` / `BcryptWithCost(BcryptCost)` | Default cost 12 |
| SHA-256 | `HashSHA256` | `SHA256Hasher()` | Deterministic, NOT for passwords |
| SHA-512 | `HashSHA512` | `SHA512Hasher()` | Deterministic, NOT for passwords |

**Argon2 defaults:** Time:1, Memory:64MiB, Threads:4, KeyLen:32, SaltLen:16

## Masking

**`Masker` interface:** `Mask(value string) (string, error)`

| Type | Constant | Factory | Example |
|------|----------|---------|---------|
| SSN | `MaskSSN` | `SSNMasker()` | `123-45-6789` → `***-**-6789` |
| Email | `MaskEmail` | `EmailMasker()` | `alice@example.com` → `a***@example.com` |
| Phone | `MaskPhone` | `PhoneMasker()` | `(555) 123-4567` → `(***) ***-4567` |
| Card | `MaskCard` | `CardMasker()` | `4111111111111111` → `************1111` |
| IP | `MaskIP` | `IPMasker()` | `192.168.1.100` → `192.168.xxx.xxx` |
| UUID | `MaskUUID` | `UUIDMasker()` | `550e8400-e29b-...` → `550e8400-****-...**` |
| IBAN | `MaskIBAN` | `IBANMasker()` | `GB82WEST...5432` → `GB82**...5432` |
| Name | `MaskName` | `NameMasker()` | `John Smith` → `J*** S****` |

## Error Types

### Sentinel Errors

`ErrMissingEncryptor`, `ErrMissingHasher`, `ErrMissingMasker`, `ErrInvalidTag`, `ErrUnmarshal`, `ErrMarshal`, `ErrEncrypt`, `ErrDecrypt`, `ErrHash`, `ErrMask`, `ErrRedact`, `ErrInvalidKey`, `ErrMissingCodec`, `ErrCiphertextShort`

### Custom Error Types

| Type | Fields | Purpose |
|------|--------|---------|
| `ConfigError` | `Err`, `Field`, `Algorithm` | Processor configuration error |
| `TransformError` | `Err`, `Field`, `Operation`, `Cause` | Field transformation error |
| `CodecError` | `Err`, `Cause` | Marshal/unmarshal error |

All implement `Unwrap() error`.

## Capitan Signals

| Signal | Key | Purpose |
|--------|-----|---------|
| `SignalProcessorCreated` | `codec.processor.created` | Processor instantiated |
| `SignalReceiveStart/Complete` | `codec.receive.*` | Hash boundary |
| `SignalLoadStart/Complete` | `codec.load.*` | Decrypt boundary |
| `SignalStoreStart/Complete` | `codec.store.*` | Encrypt boundary |
| `SignalSendStart/Complete` | `codec.send.*` | Mask boundary |

**Event keys:** `KeyContentType`, `KeyTypeName`, `KeySize`, `KeyDuration`, `KeyError`, `KeyEncryptedCount`, `KeyDecryptedCount`, `KeyHashedCount`, `KeyMaskedCount`, `KeyRedactedCount`

## Codec Implementations

| Subpackage | Content Type |
|------------|-------------|
| `cereal/json` | `application/json` |
| `cereal/yaml` | `application/yaml` |
| `cereal/xml` | `application/xml` |
| `cereal/msgpack` | `application/msgpack` |
| `cereal/bson` | `application/bson` |

All constructed via `New() cereal.Codec`.

## Thread Safety

`Processor[T]` is safe for concurrent use:
- Configuration methods use `sync.RWMutex`
- Validation runs once via `sync.Once`
- Operations lock for reading during execution
- Field plans are immutable after creation, cached per type with double-checked locking
- `ResetPlansCache()` clears the cache (primarily for tests)

## File Layout

```
cereal/
├── api.go           # Public interfaces (Cloner, Codec, override interfaces)
├── processor.go     # Core Processor[T] implementation
├── errors.go        # Error types and sentinel errors
├── capability.go    # Algorithm/mask type validation
├── encrypt.go       # AES-GCM, RSA-OAEP, Envelope implementations
├── hash.go          # Argon2, Bcrypt, SHA implementations
├── mask.go          # 8 masking implementations
├── signals.go       # Capitan event emission
├── registry.go      # Type plans caching
├── json/            # JSON codec
├── yaml/            # YAML codec
├── xml/             # XML codec
├── msgpack/         # MessagePack codec
├── bson/            # BSON codec
└── testing/         # Test helpers (TestKey, TestEncryptor, test types)
```

## Common Patterns

**Full boundary pipeline:**

```go
type User struct {
    Name     string `json:"name" send.mask:"name"`
    Email    string `json:"email" send.mask:"email"`
    Password string `json:"password" receive.hash:"argon2"`
    SSN      string `json:"ssn" store.encrypt:"aes" send.mask:"ssn"`
}

proc, _ := cereal.NewProcessor[User]()
enc, _ := cereal.AES(key)
proc.SetEncryptor(cereal.EncryptAES, enc).
    SetHasher(cereal.HashArgon2, cereal.Argon2()).
    SetMasker(cereal.MaskName, cereal.NameMasker()).
    SetMasker(cereal.MaskEmail, cereal.EmailMasker()).
    SetMasker(cereal.MaskSSN, cereal.SSNMasker())

// Receive → Store → Load → Send
received, _ := proc.Receive(ctx, user)     // password hashed
stored, _ := proc.Store(ctx, received)      // SSN encrypted
loaded, _ := proc.Load(ctx, stored)         // SSN decrypted
response, _ := proc.Send(ctx, loaded)       // name, email, SSN masked
```

**Codec-integrated:**

```go
proc.SetCodec(json.New())
user, _ := proc.Decode(ctx, requestBody)   // unmarshal + hash
data, _ := proc.Write(ctx, &user)          // encrypt + marshal
loaded, _ := proc.Read(ctx, data)          // unmarshal + decrypt
response, _ := proc.Encode(ctx, &loaded)   // mask + marshal
```

## Ecosystem

Cereal depends on:
- **sentinel** — struct tag scanning for field metadata
- **capitan** — observable boundary crossing events

Cereal is consumed by:
- **rocco** — automatic request/response boundary transformations
