# Mission: sctx

Certificate-based security contexts — mTLS certs to typed authorization tokens.

## Purpose

Transform X.509 certificates into typed security contexts with RBAC, signed tokens, and replay protection. An Admin[M] is the singleton authority that generates SignedToken values from certificates after verifying proof of private key possession. Guard instances enforce permission checks.

Sctx exists because mTLS provides identity (who you are) but not authorization (what you can do). This package bridges the gap with typed contexts, composable policies, and tamper-proof tokens.

## What This Package Contains

- Context[M] generic security context with metadata, permissions, and certificate info
- Admin[M] singleton authority for token generation, guard creation, and revocation
- SignedToken as opaque, tamper-proof authorization token (base64 payload:signature)
- SignedAssertion proving private key possession before token generation
- Guard for validating tokens against required permissions
- Principal for authenticated in-process consumers with token injection into context
- Three-level resolution: assertion, token, guard
- ContextPolicy[M] for certificate-to-context mapping with composable guards
- Built-in guards: RequireCertField, RequireCertPattern, GrantPermissions, SetContext
- Cryptography: Ed25519 (default, faster) and ECDSA-P256 (FIPS 140-2 compliant)
- Memory cache with LRU eviction and configurable cleanup
- Nonce cache for replay protection
- Capitan signals for complete token, guard, context, principal, assertion, and cache lifecycle

## What This Package Does NOT Contain

- OAuth or OIDC integration
- JWT token format (uses custom signed tokens)
- Session management
- User authentication (works with certificate identity)

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `capitan` | Observability signals for security lifecycle |

Sctx is consumed by:
- `aegis` — mTLS authorization in the service mesh

## Design Constraints

- Admin is a singleton — one per application instance
- SignedAssertion must prove private key possession before token generation
- SignedToken is tamper-proof — base64(payload):base64(signature)
- Context[M] is generic — metadata type is application-defined
- Ed25519 is default (30% faster), ECDSA-P256 for FIPS compliance
- Cache cleanup runs in background goroutine via Start()
- All public components are thread-safe

## Success Criteria

A developer can:
1. Generate typed security contexts from X.509 certificates
2. Create tamper-proof authorization tokens with RBAC permissions
3. Enforce permission checks via guards at service boundaries
4. Compose certificate-to-context policies with field requirements and permission grants
5. Inject tokens into context for transparent propagation
6. Revoke contexts by certificate fingerprint

## Non-Goals

- OAuth/OIDC integration
- JWT format compatibility
- Session management or cookie handling
- User authentication workflows
