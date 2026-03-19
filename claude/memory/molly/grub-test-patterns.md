---
type: discovery
description: grub test patterns — what's expected to be uncovered, how providers are tested, hook test conventions
created: 2026-03-17
updated: 2026-03-17
---

## Provider tests use httptest, not mocks

Provider submodules (elasticsearch/, opensearch/, minio/, etc.) test with real httptest.NewServer() setups. Tests construct live HTTP handlers and point the official client library at them. This is correct — it tests the actual HTTP behavior, headers, response parsing. Don't flag this as "not testing real calls" — it's the right approach for provider-level tests.

## Coverage gaps that are expected and acceptable

These show up in every grub wrapper review. Don't flag them:

- `Atomic()` panic branch: `atom.Use[T]()` returns error → panic. Programmer error guard — T must be atomizable. If T isn't, this panics immediately in dev. Can't be triggered with valid T.
- `atom.Use[T]()` error returns in atomix wrappers (contentToAtom, atomToContent, etc.) — same category.
- These show as uncovered lines in Codecov patch reports. They're deliberate. Expected.

## Hook test conventions in grub

Lifecycle hook tests follow a consistent naming pattern:
- `TestFoo_Hooks` — verifies hooks fire (BeforeSave, AfterSave, AfterLoad)
- `TestFoo_FailingBeforeSaveHook`, `TestFoo_FailingAfterSaveHook`, etc. — one test per hook failure type

What the tests do NOT document: the per-method hook map (which methods fire which hooks). You have to read the code to know that Delete fires BeforeDelete+AfterDelete but not BeforeSave. The test names confirm hooks exist and failures abort — not the complete sequence.

## Two-phase batch hook structure

All grub batch operations (SetBatch, IndexBatch, UpsertBatch, etc.) follow this pattern:
1. Loop: BeforeSave + encode each item
2. Provider batch call
3. Loop: AfterSave each item

If AfterSave fails mid-loop in phase 3, data is already committed to the provider. Hooks are informational, not transactional — this is deliberate. Don't flag partial AfterSave as a bug. It's the design.

Single-doc tests for FailingAfterSaveHook don't expose this partial-failure behavior, but the design is intentional.

## atomix import cycle — error sentinels

The internal/atomix package cannot import grub (that's why it exists — to break the cycle where grub wrappers needed atomic types). atomix test files define local error sentinels (`errSearchNotFound`, etc.) instead of using `grub.ErrNotFound`. This is intentional, not an oversight.

The atomix wrappers are pure passthroughs on errors — `return nil, err`. The ErrNotFound contract holds as long as nobody wraps errors in atomix. Worth flagging if error wrapping is ever added, but not flaggable in its current state.
