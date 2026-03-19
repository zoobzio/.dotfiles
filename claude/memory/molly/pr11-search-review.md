---
type: project
description: PR #11 feat/search review (2026-03-17) — Search storage category, 5 TST findings confirmed, SEC-005 elevated to Medium
created: 2026-03-17
updated: 2026-03-17
---

Reviewed PR #11 (feat/search) on 2026-03-17. Added the fifth grub storage category: Search[T] typed wrapper, atomix.Search[T] atomic wrapper, elasticsearch/ and opensearch/ provider submodules, internal/shared/search.go types, SearchProvider + AtomicSearch interfaces in api.go. Also included internal/atomic/ → internal/atomix/ rename (mechanical, touches all existing wrappers).

## Findings confirmed and streamed

**TST-001** (Low): Both ES and OS provider `Exists()` has a third error branch for non-200/non-404 — untested. Code correct, test gap.

**TST-002** (Low): Both providers' `Get()` have a `!resp.Found` guard for 200+found:false responses (some ES/OS versions/proxies do this). Untested. Code correct, test gap.

**TST-003** (Low): Count() and Refresh() error paths untested in both providers. Consolidated with TST-001 by Armitage.

**TST-004** (Low, informational): atomix mock uses local `errSearchNotFound`, not `grub.ErrNotFound`. Import cycle constraint — atomix can't import grub. Wrapper is pure passthrough (`return nil, err`). Future risk: if anyone adds error wrapping in atomix, ErrNotFound propagation breaks silently. No test would catch it.

**TST-005** (Low, pattern-level): IndexBatch has two-phase AfterSave loop. Single-doc tests don't expose partial-failure across multi-doc batches. Pattern is deliberate and consistent across ALL FIVE grub categories (Store.SetBatch, Index.UpsertBatch, Database, Bucket has no batch, Search). Hooks are informational, not transactional — data commits first, AfterSave fires after.

**SEC-005** (Medium, from Riviera): DeleteBatch in both providers only checks HTTP status, not bulk response body. IndexBatch correctly checks the `errors` boolean; DeleteBatch doesn't. Silently swallows all item-level errors (version conflict, permission denial, locked index), not just not_found. Contract says "non-existent IDs silently ignored" but implementation is broader. Armitage elevated to Medium for the asymmetry with IndexBatch.

## Dropped findings

**TST-006**: Tests that call `q.Match("nonexistent_field", "value")` and expect query.Err() to be non-nil ARE valid Search[T] tests — they exercise the guard before forwarding to the provider. The error origin (lucene) is expected. Don't flag this pattern again.

**COV-001/COV-002**: The uncovered lines in search.go (Atomic() panic) and atomix/search.go (atom.Use[T]() error returns) are programmer error guards for invalid type instantiation. Compile-time safe. Expected to be uncovered. Don't flag these in future reviews.

## Key codebase patterns learned

- Provider tests use real httptest servers, not in-memory mocks. Good pattern, tests HTTP behavior correctly.
- atomix package exists specifically to break the import cycle — it can't import grub. Local error sentinels in atomix tests are intentional, not sloppiness.
- All grub constructors skip resource name validation (empty string, etc.) — Database precedent. NewSearch follows this.
- CreateIndex/DeleteIndex are on concrete providers only, not SearchProvider interface. Design choice — interface is document CRUD, lifecycle is separate.
