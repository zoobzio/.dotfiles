# README

Create or update a package README that captures the package's essence through clarity, not marketing.

## Philosophy

The README is the package's front door. A consumer decides in 60 seconds whether this package solves their problem. Lead with what it does, show the core capability in action, and provide clear paths to deeper documentation. Purpose over marketing. Show, don't frame.

## Execution

1. Read the package source to understand what it does
2. Complete discovery — purpose, capabilities, distinguishing qualities
3. Draft tagline and overview name, confirm with user
4. Write README per specifications
5. Verify badges, structure, and links

## Specifications

### Badges

The README MUST include exactly these 6 badges immediately after the title. Replace `[pkg]` with the actual package name. DO NOT modify URLs, colours, styles, or badge providers.

| # | Badge | Markdown |
|---|-------|----------|
| 1 | CI Status | `[![CI Status](https://github.com/zoobzio/[pkg]/workflows/CI/badge.svg)](https://github.com/zoobzio/[pkg]/actions/workflows/ci.yml)` |
| 2 | Coverage | `[![codecov](https://codecov.io/gh/zoobzio/[pkg]/graph/badge.svg?branch=main)](https://codecov.io/gh/zoobzio/[pkg])` |
| 3 | CodeQL | `[![CodeQL](https://github.com/zoobzio/[pkg]/workflows/CodeQL/badge.svg)](https://github.com/zoobzio/[pkg]/security/code-scanning)` |
| 4 | Go Reference | `[![Go Reference](https://pkg.go.dev/badge/github.com/zoobzio/[pkg].svg)](https://pkg.go.dev/github.com/zoobzio/[pkg])` |
| 5 | License | `[![License](https://img.shields.io/github/license/zoobzio/[pkg])](LICENSE)` |
| 6 | Release | `[![Release](https://img.shields.io/github/v/release/zoobzio/[pkg])](https://github.com/zoobzio/[pkg]/releases)` |

### Structure

The README MUST contain these sections in this order:

| # | Section | Requirements |
|---|---------|--------------|
| 1 | Header | Title, all 6 badges, tagline + one supporting sentence |
| 2 | Overview | Package-specific name, what it does, core capability shown in code |
| 3 | Installation | `go get` command with Go version requirement |
| 4 | Quick Start | Complete working example — zero to first result |
| 5 | Capabilities | Feature table: Feature, Description, Docs link |
| 6 | Why [Package]? | Bullet points — what distinguishes this, philosophy |
| 7 | Documentation | Links organised as Learn / Guides / Cookbook / Reference |
| 8 | Contributing | One sentence + link to CONTRIBUTING.md |
| 9 | License | Single line: "MIT License - see [LICENSE](LICENSE)" |

### Overview Section Naming

The overview section MUST have a package-specific name that captures the core concept.

PROHIBITED names: "Overview", "Introduction", "About", "What Is This"

Examples from zoobzio packages:
- "Type Intelligence" (sentinel — struct introspection)
- "Event Coordination" (capitan — signal-based events)
- "Pipeline Processing" (pipz — composable data pipelines)
- "Structured LLM Interactions" (zyn — typed AI synapses)

### Core Example

The overview section includes a code block showing the package's core capability in action. This is not a full tutorial — it's the "aha" moment. One concept, complete and runnable.

```go
// sentinel — the core capability in ~5 lines
type User struct {
    Name  string `json:"name"`
    Email string `json:"email"`
}

meta := sentinel.Inspect[User]()
fmt.Println(meta.FQDN)      // github.com/example/app.User
fmt.Println(meta.Fields[0])  // {Name string json:"name"}
```

### Capabilities Table

Map features to documentation:

```markdown
| Feature | Description | Docs |
|---------|-------------|------|
| Type Inspection | Extract metadata from any struct | [Concepts](docs/1.learn/3.concepts.md) |
| Relationship Discovery | Map type references automatically | [Guide](docs/2.guides/1.relationships.md) |
```

### Why [Package]? Section

Bullet points explaining what makes this package worth using. Focus on what it enables, not features:

- "Type-safe at the edges. Async in between."
- "Zero external dependencies."
- "Generics over reflection — compile-time safety, not runtime surprises."

### Documentation Index

Organise links by category:

```markdown
## Documentation

### Learn
- [Overview](docs/1.learn/1.overview.md) — What it is and why
- [Quickstart](docs/1.learn/2.quickstart.md) — Zero to working code
- [Concepts](docs/1.learn/3.concepts.md) — Mental models
- [Architecture](docs/1.learn/4.architecture.md) — How it works

### Guides
- [Configuration](docs/2.guides/1.configuration.md) — Options and tuning

### Cookbook
- [Building Pipelines](docs/4.cookbook/1.building-pipelines.md) — Real-world recipes

### Reference
- [Cheatsheet](docs/5.reference/1.cheatsheet.md) — Quick lookup
```

## Prohibitions

DO NOT:
- Use alternative badge providers or styles
- Omit any of the 6 required badges
- Use generic overview section names
- Frame with "The Problem / The Solution"
- Write in template voice — the README MUST feel unique to THIS package
- Include full API reference (belongs in docs/reference)

## Checklist

### Discovery
- [ ] Read package source — what does it do?
- [ ] Identify core capability (one sentence)
- [ ] Identify distinguishing qualities
- [ ] Identify target consumer

### Synthesis
- [ ] Draft tagline — confirm with user
- [ ] Draft overview section name — confirm with user
- [ ] Draft capabilities table — confirm with user

### Writing
- [ ] All 6 badges present with exact URLs
- [ ] Header: title, badges, tagline + supporting sentence
- [ ] Overview: package-specific name, core example in code
- [ ] Installation: `go get` with Go version
- [ ] Quick Start: complete working example
- [ ] Capabilities: feature table with doc links
- [ ] Why section: distinguishing bullet points
- [ ] Documentation: links organised by category
- [ ] Contributing: one sentence + link
- [ ] License: single line

### Verification
- [ ] Core example compiles against current API
- [ ] Documentation links resolve to existing files
- [ ] README could only describe THIS package
- [ ] No generic overview names
- [ ] No template voice
