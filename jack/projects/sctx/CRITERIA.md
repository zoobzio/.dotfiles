# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- SignedToken is tamper-proof — any modification must fail verification
- SignedAssertion correctly proves private key possession
- Guard validates tokens against required permissions without bypass
- Admin is a singleton — second creation must error
- Nonce cache prevents replay attacks
- Context expiration is enforced — expired contexts must be rejected
- Revocation by fingerprint immediately invalidates the context
- Ed25519 and ECDSA-P256 produce correct signatures and verify correctly

### What This Repo MUST NOT Contain

- OAuth or OIDC integration
- JWT token format
- Session management
- User authentication workflows

## Review Priorities

1. Token integrity: signature verification must reject any tampered token
2. Assertion validation: private key possession proof must be cryptographically sound
3. Permission enforcement: guards must check all required permissions without bypass
4. Replay protection: nonce cache must reject replayed assertions
5. Expiration: expired contexts and tokens must be rejected
6. Singleton: admin creation must be enforced — no multiple instances

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Tampered token passes verification | Critical |
| Guard bypassed without valid token | Critical |
| Replay attack succeeds (nonce reuse) | Critical |
| Expired context accepted | Critical |
| Assertion accepted without valid private key proof | Critical |
| Revoked context still accessible | High |
| Permission check skips required permission | High |
| Admin singleton not enforced | High |
| Cache eviction deletes active context | Medium |
| Capitan signal missing for security event | Medium |
| Ed25519/ECDSA key detection wrong | Low |

## Standing Concerns

- Nonce cache is bounded — verify size doesn't allow nonce eviction enabling replay
- Memory cache cleanup goroutine — verify no goroutine leak if Start() not called
- Admin singleton uses sync — verify no race in creation path
- Ed25519 vs ECDSA selection — verify algorithm detection from key type is correct
- Context[M] Clone — verify metadata M is actually deep-copied

## Out of Scope

- Custom token format (not JWT) is intentional — designed for mTLS contexts, not web tokens
- Ed25519 as default over ECDSA is intentional — faster for non-FIPS environments
- No OAuth/OIDC is by design — sctx works with certificate identity, not web identity
- Singleton admin is intentional — one authority per process
