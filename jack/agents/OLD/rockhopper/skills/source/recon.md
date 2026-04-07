# Recon Source

Survey the source landscape before building. Understand what exists, how it's structured, and what patterns are established.

## Philosophy

Before writing a single line of code, understand the terrain. A spec tells you what to build. The existing codebase tells you *how* — what patterns are established, what conventions are followed, what's already there that you'd be building on top of or beside. Building without surveying the source is how you end up with code that works but doesn't belong.

This skill maps the source landscape: what exists, how it's organised, what patterns govern the codebase, and what the spec is asking you to fit into.

## Execution

1. Survey package structure and organisation
2. Inventory each source file
3. Detect established patterns and conventions
4. Map the public API surface
5. Map the dependency graph
6. Identify spec integration points
7. Assess complexity and flag risks
8. Produce a structured assessment

## Specifications

### Package Structure Survey

Map the layout of the package:

| Element | What to check |
|---------|---------------|
| Directory structure | Flat or nested? Subpackages? |
| File organisation | By domain, by type, by layer? |
| `internal/` | What's internal vs exported? Why? |
| `testing/` | Infrastructure present? (`test/recon` covers depth) |
| Build tags | Any conditional compilation? |
| Generated code | Any codegen? What generates it? |

### File Inventory

For each `.go` file in the package:

| Attribute | What to record |
|-----------|----------------|
| Purpose | What domain does this file own? |
| Exports | Types, functions, methods exported |
| Dependencies | What does it import? Internal vs external |
| Size | Rough complexity — is this a thin wrapper or heavy logic? |

### Pattern Detection

Identify established conventions:

#### Naming Conventions
- Type naming patterns (e.g., `FooOption`, `FooConfig`, `FooResult`)
- Constructor patterns (e.g., `New[Thing]`, `Open[Thing]`, `[Thing]From[Source]`)
- Method naming patterns
- File naming patterns (e.g., `foo.go` for type `Foo`)

#### Structural Patterns
- Options pattern (`With[Thing]` functional options)
- Builder pattern
- Interface satisfaction (which types implement which interfaces)
- Error handling style (sentinel errors, custom types, wrapping)
- Context usage

#### Code Style
- Comment density and style
- Import organisation (stdlib, internal, external grouping)
- Receiver naming (single letter, abbreviated, full name)
- Error variable naming (`err`, `fooErr`, etc.)

### Public API Surface

Map the exported API:

| Element | What to document |
|---------|-----------------|
| Types | Structs, interfaces, type aliases |
| Constructors | How types are created |
| Methods | What operations are available |
| Functions | Package-level functions |
| Constants/Vars | Exported constants, sentinel errors |

For each exported element, note:
- Is it documented? (godoc present)
- Is it tested? (corresponding test exists)
- Is it used? (consumers import and call it)

### Dependency Map

Understand what the package depends on and what depends on it:

| Direction | What to check |
|-----------|---------------|
| Imports | What packages does this package import? |
| Importers | What packages import this one? (if discoverable) |
| Internal deps | What internal packages are used? |
| External deps | What third-party packages are used? |

### Spec Integration Points

Given a spec (from Fidgel), identify:

1. **Where new code fits** — which files need modification, which are new
2. **Which patterns apply** — what conventions the new code must follow
3. **What existing code is affected** — interfaces that gain methods, types that change
4. **What's already done** — existing code that partially or fully satisfies spec requirements
5. **What conflicts** — existing patterns or structures that the spec's approach contradicts

### Complexity Assessment

Flag areas that warrant caution:

| Signal | Risk |
|--------|------|
| Large files (>300 lines) | May need decomposition |
| Deep nesting | Logic may be hard to extend |
| Many parameters | API may need options pattern |
| Circular-looking deps | Architecture may need rethinking |
| Commented-out code | Uncertainty about intent |
| TODO/FIXME/HACK markers | Known tech debt |

## Output

Structured report containing:
- **Package structure** — directory layout and file organisation
- **File inventory** — each file's purpose and exports
- **Established patterns** — naming, structural, and style conventions
- **API surface** — exported types, functions, methods
- **Dependency map** — what imports what
- **Spec integration points** — where new work fits into existing code
- **Complexity flags** — areas requiring caution
- **Recommendations** — suggested approach for building within established patterns

## Checklist

### Phase 1: Package Structure Survey

- [ ] Map directory structure (flat, nested, subpackages)
- [ ] Identify file organisation strategy (by domain, type, layer)
- [ ] Check for `internal/` and note its contents
- [ ] Check for `testing/` infrastructure
- [ ] Check for build tags or conditional compilation
- [ ] Check for generated code and its source

### Phase 2: File Inventory

For each `.go` file (excluding `_test.go`):

- [ ] Note the file's purpose and domain
- [ ] List exported types
- [ ] List exported functions and methods
- [ ] List imports (stdlib vs internal vs external)
- [ ] Assess rough complexity

### Phase 3: Pattern Detection

#### Naming Conventions
- [ ] Type naming patterns identified
- [ ] Constructor naming patterns identified
- [ ] Method naming patterns identified
- [ ] File naming patterns identified
- [ ] Error variable naming identified

#### Structural Patterns
- [ ] Options/builder patterns identified
- [ ] Interface satisfaction mapped
- [ ] Error handling style documented
- [ ] Context usage patterns noted
- [ ] Receiver naming convention noted

#### Code Style
- [ ] Import grouping convention noted
- [ ] Comment style and density noted
- [ ] Formatting conventions noted

### Phase 4: Public API Surface

#### Exported Types
- [ ] All exported structs listed
- [ ] All exported interfaces listed
- [ ] All type aliases and definitions listed
- [ ] Constructor for each type identified

#### Exported Functions
- [ ] All package-level functions listed
- [ ] All exported methods listed by type
- [ ] Variadic and optional parameter patterns noted

#### Constants and Variables
- [ ] Exported constants listed
- [ ] Sentinel errors listed
- [ ] Exported variables listed

### Phase 5: Dependency Map

- [ ] Stdlib imports catalogued
- [ ] Internal package imports catalogued
- [ ] External package imports catalogued
- [ ] Downstream consumers identified (if discoverable)
- [ ] Circular or concerning dependency chains noted

### Phase 6: Spec Integration Points

- [ ] Files requiring modification identified
- [ ] New files required identified
- [ ] Applicable patterns for new code documented
- [ ] Existing code affected by changes noted
- [ ] Existing code that partially satisfies spec noted
- [ ] Conflicts between spec and existing patterns flagged

### Phase 7: Complexity Flags

- [ ] Files exceeding 300 lines flagged
- [ ] Deeply nested logic flagged
- [ ] Functions with many parameters flagged
- [ ] Concerning dependency patterns flagged
- [ ] TODO/FIXME/HACK markers catalogued
- [ ] Commented-out code noted

### Phase 8: Report

#### Structure Summary
- [ ] Package layout documented
- [ ] File purposes documented

#### Pattern Summary
- [ ] Naming conventions documented
- [ ] Structural patterns documented
- [ ] Style conventions documented

#### API Summary
- [ ] Full exported API catalogued
- [ ] Documentation gaps noted
- [ ] Test gaps noted

#### Integration Assessment
- [ ] Where new code fits documented
- [ ] Which patterns to follow documented
- [ ] Risks and cautions documented
- [ ] Recommended approach stated
