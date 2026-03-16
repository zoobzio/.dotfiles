# Mission: cereal

Boundary-aware serialization — encrypt for storage, mask for APIs, hash on receive.

## Purpose

Implement a four-boundary model for data transformation driven by struct tags. Struct tags declare sensitivity; the generic Processor[T] enforces transformations at each boundary crossing. Original values are never mutated — clones are created before every transformation.

Cereal exists because sensitive data handling (encryption, hashing, masking, redaction) is spread across application code, easily missed, and hard to audit. This package makes sensitivity a declaration on the struct, not scattered logic.

## What This Package Contains

- Processor[T] generic type handling all four boundaries (Receive, Load, Store, Send)
- Four boundary operations: hash on receive, decrypt on load, encrypt on store, mask/redact on send
- Struct tag system: receive.hash, load.decrypt, store.encrypt, send.mask, send.redact
- Encryption: AES-GCM, RSA-OAEP, Envelope (per-message data keys)
- Hashing: Argon2 (OWASP recommended), Bcrypt, SHA-256, SHA-512
- Masking: SSN, email, phone, card, IP, UUID, IBAN, name (8 types)
- Redaction: complete value replacement with configurable string
- Codec-aware operations: Decode, Read, Write, Encode combining serialization with boundary transforms
- Codec implementations: JSON, YAML, XML, MessagePack, BSON
- Override interfaces: Encryptable, Decryptable, Hashable, Maskable, Redactable for custom logic
- Cloner[T] requirement — deep clone before every transformation
- Capitan signals for all boundary crossing events with timing and counts
- Nested struct support with recursive field scanning and nil-checking

## What This Package Does NOT Contain

- Key management or rotation — caller provides keys
- Certificate management
- Transport-level encryption (TLS)
- Access control or authorization

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `sentinel` | Struct tag scanning for field metadata |
| `capitan` | Observable boundary crossing events |

Cereal is consumed by:
- `rocco` — automatic request/response boundary transformations
- Applications for data sensitivity enforcement

## Design Constraints

- All types used with Processor must implement Cloner[T] (deep clone via Clone() T)
- Original values are NEVER mutated — clones created before every transformation
- Field plans are immutable after creation, cached per type
- Supported field types: string, []byte, []string, map[K]string
- Validation runs once via sync.Once — catches missing encryptor/hasher/masker at first use
- Processor[T] is safe for concurrent use

## Success Criteria

A developer can:
1. Declare field sensitivity via struct tags and have it enforced at every boundary
2. Process data through all four boundaries with a single Processor instance
3. Combine serialization with boundary transforms via codec-aware methods
4. Use custom encryption, hashing, or masking implementations via override interfaces
5. Audit boundary crossings via capitan signals with timing and field counts
6. Trust that original data is never mutated during transformation

## Non-Goals

- Key management, rotation, or distribution
- Certificate lifecycle management
- Transport encryption (TLS/mTLS)
- Access control or authorization decisions
