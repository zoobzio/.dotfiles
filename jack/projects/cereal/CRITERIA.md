# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- Every boundary operation clones before transforming — original never mutated
- Encryption round-trip (encrypt then decrypt) produces identical plaintext
- Hashing is one-way — no path from hash back to plaintext
- Masking preserves format while hiding sensitive data
- Struct tags correctly drive which fields are processed at each boundary
- Validation catches missing encryptor/hasher/masker before first operation
- Nested struct fields are processed recursively with nil-checking
- Override interfaces take precedence over tag-driven processing

### What This Repo MUST NOT Contain

- Key management or rotation logic
- Certificate management
- Transport-level encryption
- Access control or authorization

## Review Priorities

1. Clone safety: original data must never be mutated — every boundary creates a clone
2. Encryption correctness: AES-GCM, RSA-OAEP, Envelope must produce correct ciphertext and round-trip cleanly
3. Hash correctness: Argon2 and Bcrypt must follow OWASP recommendations, SHA must be deterministic
4. Masking correctness: masked output must preserve format while hiding sensitive portions
5. Tag parsing: compound tag format must be parsed correctly for all boundary/action combinations
6. Validation: missing capabilities must error before processing, not produce partial results

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Original data mutated during transformation | Critical |
| Encryption round-trip produces different plaintext | Critical |
| Sensitive field not processed at declared boundary | Critical |
| AES key validation accepts invalid key length | High |
| Nested struct field skipped during processing | High |
| Masking reveals more data than expected | High |
| Validation misses a required capability | High |
| Override interface not called when implemented | Medium |
| Codec-aware method applies wrong boundary | Medium |
| Capitan signal missing timing data | Low |

## Standing Concerns

- Cloner[T] is caller-implemented — verify deep clone actually copies all sensitive fields
- Argon2 defaults (64MiB memory) — verify reasonable for high-throughput scenarios
- Field plan caching uses double-checked locking — verify no race conditions
- ResetPlansCache exists for tests — verify not accessible in production
- Envelope encryption generates per-message keys — verify randomness source

## Out of Scope

- Cloner[T] requirement is intentional — ensures deep copy correctness
- golang.org/x/crypto dependency is intentional for cryptographic primitives
- Five codec subpackages is intentional — import only what you need
- No key rotation is by design — caller manages key lifecycle
