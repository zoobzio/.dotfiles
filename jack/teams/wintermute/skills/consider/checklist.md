# Consider Checklist

## Phase 1: Determine Variant

- [ ] Examine repo root for variant signals
- [ ] Go API — go.mod present, main package, HTTP server, multiple API surfaces
- [ ] Go Package — go.mod present, no main package, library consumed by others
- [ ] Nuxt UI — nuxt.config present, package.json, Vue components
- [ ] Exactly one variant selected
- [ ] Read the relevant sub-file for the selected variant

## Phase 2: Go API Considerations

Skip if variant is not Go API.

### Naming
- [ ] Models are singular, stores are plural struct, contracts are plural interface
- [ ] Wire types use entity+suffix, handlers use verb+singular
- [ ] Store files are plural, model files are singular

### Surface Architecture
- [ ] Shared layers (models, stores) are truly shared — no surface-specific logic
- [ ] Surface-specific layers (contracts, wire, handlers, transformers) are truly separate
- [ ] Same store implementation satisfies different contracts per surface
- [ ] Wire types differ appropriately between surfaces

### Entity Completeness
- [ ] Every entity has all links: model, migration, contract, store, wire types, transformers, handlers
- [ ] Each artifact references correct types from adjacent layers
- [ ] No partial entities — missing any link is a structural defect

### Registration
- [ ] All components registered at their wiring points
- [ ] Registration happens before the application freezes
- [ ] Unregistered components flagged — invisible to runtime

### Migration Ordering
- [ ] Migrations respect entity dependency order
- [ ] Foreign key references point to tables created in earlier migrations
- [ ] No circular migration dependencies

### Boundary Processing
- [ ] Sensitive fields registered with boundary processing
- [ ] Processing happens before data crosses system edges
- [ ] Direction is correct — encrypt before storage, decrypt after retrieval, mask before response
- [ ] Masked fields do not leak unmasked values through errors or logs

### Surface Isolation
- [ ] Admin endpoints not reachable from public surface
- [ ] Public surface data is masked; admin may expose full data
- [ ] Auth models differ per surface
- [ ] Bulk operations and impersonation restricted to admin surface

## Phase 3: Go Package Considerations

Skip if variant is not Go Package.

### API Surface
- [ ] Minimal export surface — only what consumers need
- [ ] Internal implementation in unexported types or internal/
- [ ] Public types constructable via constructors, not struct literals

### Dependency Footprint
- [ ] Zero or near-zero external dependencies
- [ ] Every external dependency justified against stdlib alternatives
- [ ] Provider-specific code isolated in submodules
- [ ] Transitive dependency weight assessed

### Consumer Experience
- [ ] Usable from README and godoc alone
- [ ] Constructors obvious and discoverable
- [ ] Options pattern used where configuration is complex
- [ ] Error types and sentinels well-defined and documented
- [ ] Zero value is useful or clearly documented as unusable

### Breaking Changes
- [ ] No removed or renamed exported symbols
- [ ] No changed function signatures
- [ ] No added interface methods (breaks implementors)
- [ ] No changed behavior of existing functions
- [ ] No changed error types or sentinels consumers may match on

### Testing for Consumers
- [ ] testing/ directory with helpers for consumer use
- [ ] Helpers have appropriate build tags
- [ ] Example tests serve as documentation and verification

### Versioning
- [ ] Version matches actual API stability
- [ ] Breaking changes in non-major versions flagged
- [ ] CHANGELOG or release notes document what changed

## Phase 4: Nuxt UI Considerations

Skip if variant is not Nuxt UI.

- [ ] Read consider/ui.md for zoobzio-specific concerns
- [ ] Run the `audit` skill as the base review (replaces `review` for this variant)

### Layer Architecture
- [ ] Changes to shared layers assessed for downstream impact
- [ ] Layer boundaries respected — no reaching into parent layer internals
- [ ] Component or composable overrides are deliberate, not accidental shadowing
- [ ] Template and site inheritance chains are correct

### Design Token System
- [ ] Components use system tokens via CSS custom properties, not hardcoded values
- [ ] Token level is correct — components consume system tokens, not reference tokens directly
- [ ] Token consistency across related components verified

### Theming
- [ ] Visual changes work across all themes
- [ ] Dark and light mode variants both considered
- [ ] Theme definitions complete — no missing or mistyped tokens

### Component Composition
- [ ] Headless primitives handle behavior; wrappers handle styling
- [ ] Props typed via separate type files
- [ ] Class prefix convention followed consistently
- [ ] Slot patterns expose appropriate composition points

### Monorepo Boundaries
- [ ] Shared dependencies use workspace catalog — no version mismatches
- [ ] Code is in the correct project type (app vs layer vs package vs template)
- [ ] Cross-project imports go through published package boundaries

### API Integration
- [ ] Types generated from backend schema, not hand-written duplicates
- [ ] API calls flow through typed client composables
- [ ] Type safety chain unbroken from schema to component — no any casts or manual overrides

### Content Architecture
- [ ] Content files conform to their collection schema
- [ ] Frontmatter fields match declared types
- [ ] Content sources correctly configured

### Auto-Import Conventions
- [ ] No redundant manual imports of auto-imported symbols
- [ ] Custom composables in expected directories for auto-import
- [ ] Components in expected directories for auto-registration
