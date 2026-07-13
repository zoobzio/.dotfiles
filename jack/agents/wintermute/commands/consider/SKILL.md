---
name: consider
description: Variant-specific review concerns — Go API, Go package, or Nuxt UI. Layers on top of base assess/audit with domain-specific checks.
user-invocable: false
allowed-tools: Read, Grep, Glob
---

# Consider

Variant-specific review concerns that layer on top of the base review. Every repo is exactly one variant. Determine which, then run the applicable checklist.

## Checklist

- [ ] Determine variant
- [ ] Execute variant checklist
- [ ] Record findings

### Determine Variant

| Signal | Variant |
|--------|---------|
| go.mod, main package, HTTP server, multiple API surfaces | Go API |
| go.mod, no main package, library consumed by others | Go Package |
| nuxt.config, package.json, Vue components | Nuxt UI |

## Go API

Built on sum. Multiple surfaces (api/, admin/) sharing stores and models but separating contracts, wire types, handlers, and transformers.

### Naming

- [ ] Models singular (`User`), stores plural struct (`Users`), contracts plural interface (`Users`)
- [ ] Wire types entity+suffix (`UserResponse`, `CreateUserRequest`), handlers verb+singular (`GetUser`)
- [ ] Store files plural (`users.go`), model files singular (`user.go`)

### Surface Architecture

- [ ] Shared layers (models, stores) truly shared — no surface-specific logic
- [ ] Surface-specific layers (contracts, wire, handlers, transformers) truly separate
- [ ] Same store implementation satisfies different contracts per surface
- [ ] Wire types differ appropriately between surfaces (api/ masks, admin/ exposes)

### Entity Completeness

- [ ] Every entity has all links: model, migration, contract, store, wire types, transformers, handlers
- [ ] Each artifact references correct types from adjacent layers
- [ ] No partial entities — missing any link is a structural defect

### Registration

- [ ] All components registered at wiring points before `sum.Freeze()`
- [ ] Stores in `stores/stores.go`, handlers in `{surface}/handlers/handlers.go`
- [ ] Error mapping in `{surface}/handlers/errors.go`, boundaries in `{surface}/wire/boundary.go`
- [ ] Unregistered components are invisible to runtime

### Migration Ordering

- [ ] Migrations respect entity dependency order
- [ ] Foreign key references point to tables created in earlier migrations
- [ ] No circular migration dependencies

### Boundary Processing

- [ ] Sensitive fields registered with cereal boundaries
- [ ] Processing happens before data crosses system edges
- [ ] Direction correct — encrypt before storage, decrypt after retrieval, mask before response
- [ ] Masked fields do not leak unmasked values through errors or logs

### Surface Isolation

- [ ] Admin endpoints not reachable from public surface
- [ ] Public surface data masked; admin may expose full data
- [ ] Auth models differ per surface (customer vs internal identity)
- [ ] Bulk operations and impersonation restricted to admin surface

## Go Package

Standalone library consumed by others. The exported API is a contract — additions are easy, removals break consumers.

### API Surface

- [ ] Minimal export surface — only what consumers need
- [ ] Internal implementation in unexported types or `internal/`
- [ ] Public types constructable via `New[Type]`, not struct literals

### Dependency Footprint

A package's dependencies become its consumers' dependencies.

- [ ] Zero or near-zero external dependencies
- [ ] Every external dependency justified against stdlib alternatives
- [ ] Provider-specific code isolated in submodules (e.g., `pkg/foopgx`)
- [ ] Transitive dependency weight assessed

### Consumer Experience

- [ ] Usable from README and godoc alone
- [ ] Constructors obvious and discoverable
- [ ] Options pattern used where configuration is complex
- [ ] Error types and sentinels well-defined and documented
- [ ] Zero value useful or clearly documented as unusable

### Breaking Changes

- [ ] No removed or renamed exported symbols
- [ ] No changed function signatures
- [ ] No added interface methods (breaks implementors)
- [ ] No changed behavior of existing functions
- [ ] No changed error types or sentinels consumers may match on

### Testing for Consumers

- [ ] `testing/` directory with helpers for consumer use
- [ ] Helpers have build tag `//go:build testing`
- [ ] Example tests serve as documentation and verification

### Versioning

- [ ] Version matches actual API stability (v0.x vs v1.x+)
- [ ] Breaking changes in non-major versions flagged
- [ ] CHANGELOG documents what changed

## Nuxt UI

Frontend applications inheriting from shared layers. Run the `/audit` skill as the base review, then apply these zoobzio-specific concerns.

### Layer Architecture

Changes to a layer affect everything downstream.

- [ ] Layer boundaries respected — no reaching into parent layer internals
- [ ] Component or composable overrides deliberate, not accidental shadowing
- [ ] Template and site inheritance chains correct

### Design Token System

Styling uses tokens with CSS custom properties, not utility classes.

- [ ] Components use system tokens, not reference tokens directly
- [ ] No hardcoded values bypassing the token system
- [ ] Token consistency across related components

### Theming

- [ ] Visual changes work across all themes
- [ ] Dark and light mode variants both considered
- [ ] Theme definitions complete — no missing or mistyped tokens

### Component Composition

- [ ] Headless primitives handle behavior; wrappers handle styling
- [ ] Props typed via separate type files mirroring component names
- [ ] Class prefix convention followed consistently
- [ ] Slot patterns expose appropriate composition points

### Monorepo Boundaries

- [ ] Shared dependencies use workspace catalog — no version mismatches
- [ ] Code in correct project type (app vs layer vs package vs template)
- [ ] Cross-project imports through published package boundaries

### API Integration

- [ ] Types generated from backend schema, not hand-written duplicates
- [ ] API calls through typed client composables
- [ ] Type safety chain unbroken from schema to component — no `any` casts

### Content Architecture

- [ ] Content files conform to collection schema
- [ ] Frontmatter fields match declared types
- [ ] Content sources correctly configured

### Auto-Import Conventions

- [ ] No redundant manual imports of auto-imported symbols
- [ ] Custom composables in expected directories
- [ ] Components in expected directories for auto-registration

## Finding Format

```markdown
### [PREFIX]-###: [Title]

**Category:** [Domain]
**Severity:** [Critical | High | Medium | Low]
**Location:** [file:line range]
**Description:** [What the defect is]
**Impact:** [What goes wrong if this isn't fixed]
**Evidence:** [Code snippet or structural observation]
**Recommendation:** [How to fix it]
```
