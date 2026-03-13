# Reference

Write lookup documentation — cheatsheets, API tables, type catalogs. These are docs the reader returns to repeatedly, not reads once.

## Philosophy

Reference docs are for the consumer who already knows what they want and needs to find it fast. No narrative. No progressive disclosure. Tables, signatures, and concise descriptions organised for scanning. The cheatsheet is the most valuable reference doc — it's the one engineers bookmark.

## Execution

1. Inventory the package's public API surface
2. Determine which reference docs are needed
3. Write each reference doc per specifications
4. Verify completeness against current exports

## Specifications

### Directory Structure

```
docs/
└── 5.reference/          (or 3.reference/ if no cookbook)
    ├── 1.cheatsheet.md
    └── 2.[category].md   (continue numbering per category)
```

### Cheatsheet (`1.cheatsheet.md`)

The fast-reference doc. Copy-paste patterns for every common operation.

**Structure:**

```markdown
## Quick Reference

### Creating [Things]

| Pattern | Code |
|---------|------|
| Basic constructor | `thing := pkg.NewThing()` |
| With options | `thing := pkg.NewThing(pkg.WithSize(64))` |

### Processing

| Operation | Code |
|-----------|------|
| Simple transform | `pipz.Transform(id, func(ctx, data) data { ... })` |
| With error handling | `pipz.Apply(id, func(ctx, data) (data, error) { ... })` |

### Error Handling

| Check | Code |
|-------|------|
| Sentinel error | `errors.Is(err, pkg.ErrNotFound)` |
| Custom error type | `errors.As(err, &customErr)` |
```

Every row should be directly copy-pasteable. Minimal explanation — the code speaks.

### API Tables

For packages with many types, organise by category:

```markdown
## Processors

| Name | Signature | Purpose |
|------|-----------|---------|
| Apply | `Apply[T](id, fn) Processor[T]` | Transform with errors |
| Transform | `Transform[T](id, fn) Processor[T]` | Pure transform |
| Effect | `Effect[T](id, fn) Processor[T]` | Side effect, no change |

## Connectors

| Name | Signature | Purpose |
|------|-----------|---------|
| Sequence | `NewSequence[T](id, ...Chainable[T]) *Sequence[T]` | Serial execution |
| Fallback | `NewFallback[T](id, primary, fallback) *Fallback[T]` | Try primary, then fallback |
```

### Type Catalog

For packages with many related types:

```markdown
## Key Types

| Type | Alias | Description |
|------|-------|-------------|
| `GenericKey[T]` | — | Type-safe event field key |
| `StringKey` | `GenericKey[string]` | String field key |
| `IntKey` | `GenericKey[int]` | Integer field key |
```

### Decision Tables

Help the reader pick the right tool:

```markdown
## Which Processor?

| If you need to... | Use | Can fail? |
|---|---|---|
| Transform and might error | `Apply` | Yes |
| Transform, no errors possible | `Transform` | No |
| Produce a side effect | `Effect` | No |
| Add data from external source | `Enrich` | Yes |
| Modify in place | `Mutate` | No |
```

### Sentinel Errors Catalog

```markdown
## Errors

| Error | Returned when |
|-------|---------------|
| `ErrNotStruct` | Type parameter is not a struct |
| `ErrIndexOutOfBounds` | Sequence index exceeds length |
```

## Anti-Patterns

| Anti-pattern | Approach |
|-------------|----------|
| Narrative in reference docs | Tables and signatures — no stories |
| Incomplete API surface | Every exported symbol appears somewhere |
| Examples that need context | Copy-pasteable, self-contained snippets |
| Single monolithic reference page | Organised by category — one page per concern |
| Stale signatures | Cross-reference against current source |

## Checklist

- [ ] Cheatsheet covers every common operation with copy-paste code
- [ ] API tables cover all exported types, functions, and methods
- [ ] Decision tables help the reader pick the right tool
- [ ] Sentinel errors catalogued with their trigger conditions
- [ ] Every exported symbol appears in at least one reference doc
- [ ] Signatures match current source
- [ ] All frontmatter present (see `frontmatter.md`)
- [ ] Cross-references use numbered paths
