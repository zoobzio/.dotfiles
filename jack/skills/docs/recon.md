# Recon

Survey the documentation landscape for the target package before writing or updating. Understand what exists, what's missing, and what's stale.

## Philosophy

Before writing a single line of documentation, understand what's already there for this package. The existing docs tell you what's been communicated — and more importantly, what hasn't. Writing docs without surveying the landscape is how you end up with duplicate explanations, contradictory guidance, and gaps nobody notices until a consumer hits them.

This maps the documentation landscape for the target package: what exists, how it's organised, what's accurate, what's stale, and where the gaps are.

## Package Documentation Survey

Check for the existence and completeness of:

| Element | Location | What to check |
|---------|----------|---------------|
| README | `README.md` | Exists? Current? Covers installation, usage, API? |
| Docs directory | `docs/` | Exists? How is it organised? |
| Godoc comments | Source files | Exported symbols documented? Package comment present? |
| Examples | `example_test.go` or docs | Exist? Compile? Produce stated output? |

## Accuracy Check

For each piece of existing documentation:

| Check | What to verify |
|-------|----------------|
| Signatures | Do documented function signatures match the code? |
| Behaviour | Does documented behaviour match actual behaviour? |
| Examples | Do examples compile and produce the stated output? |
| Imports | Are import paths correct? |
| Types | Are type names, field names, and method names accurate? |
| Removed APIs | Are there references to functions or types that no longer exist? |

## Gap Analysis

Compare the package's API surface (from `source/recon`) against its documentation:

| Gap type | How to detect |
|----------|---------------|
| Undocumented exports | Exported symbols with no godoc or README coverage |
| Missing usage examples | Complex APIs with no example code |
| Missing error documentation | Error returns with no guidance on what triggers them or how to handle them |
| Missing configuration docs | Options or config types with no documentation of defaults or valid ranges |
| Missing quickstart | No obvious entry point for a new consumer of this package |

## Consumer Experience

Evaluate from the perspective of someone using this specific package:

- Can someone use this package from its docs alone?
- Is the most common use case covered?
- Are error messages documented — does a consumer know what went wrong and how to fix it?
- Are configuration options documented with defaults and valid ranges?
- Is the documentation discoverable within the package?

## Output

Structured report containing:
- **Existing documentation** — what exists and where
- **Accuracy issues** — stale, incorrect, or misleading documentation
- **Gaps** — undocumented exports, missing examples, missing guides
- **Consumer experience** — assessment of usability from docs alone
- **Recommendations** — prioritised list of documentation work for this package

## Checklist

### Phase 1: Survey

- [ ] README.md exists and location noted
- [ ] docs/ directory exists and layout mapped
- [ ] Godoc coverage assessed (exported symbols with comments)
- [ ] Example code locations identified
- [ ] Package comment present in source

### Phase 2: Accuracy

- [ ] Function signatures in docs match code
- [ ] Documented behaviour matches actual behaviour
- [ ] Examples compile and produce stated output
- [ ] Import paths correct
- [ ] No references to removed or renamed APIs

### Phase 3: Gaps

- [ ] API surface compared to documentation coverage
- [ ] Undocumented exports listed
- [ ] Missing examples identified
- [ ] Missing error documentation identified
- [ ] Missing configuration documentation identified

### Phase 4: Consumer Experience

- [ ] Package usable from docs alone assessed
- [ ] Common use case coverage assessed
- [ ] Error documentation assessed
- [ ] Configuration documentation assessed

### Phase 5: Report

- [ ] Existing documentation catalogued
- [ ] Accuracy issues listed
- [ ] Gaps prioritised
- [ ] Consumer experience assessed
- [ ] Recommendations stated
