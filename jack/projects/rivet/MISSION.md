# Mission: rivet

Screenwriting platform — structured screenplay data management with version control and AI-powered analysis.

## Purpose

Provide screenwriters with a relational database of structured screenplay metadata — characters, locations, scenes, elements, and their relationships — as the foundation for a version-controlled writing platform. Think "GitHub for scripts" with a proper domain model under the hood.

The first milestone is the **pre-writing data layer**: everything a screenwriter establishes before and during writing that gives a screenplay its structure. The editor and AI features build on top of this foundation.

## Domain Model

### Core Entities

**Project** — top-level container for a screenplay or series.
- Title, logline, genre
- Format: feature, pilot, episodic, short
- Status: draft, in development, in production, archived
- For episodic: series > season > episode hierarchy

**Script** — a document within a project.
- Fountain source text (the actual screenplay content)
- Page count (derived)
- Working draft + versioned snapshots

**Character** — a person in the screenplay.
- Name, aliases/nicknames
- Gender, age range
- Role type: lead, supporting, featured, background
- Description / bio
- First appearance (scene reference)
- Arc notes (free text, per version — how the character changes)

**Scene** — a dramatic unit within a script.
- Scene number (auto or manual)
- Slugline components: INT/EXT, location, time of day
- Synopsis (short description of what happens)
- Page length (derived)
- Characters present (derived from dialogue + action, editable)

**Location** — a place where scenes occur.
- Name (as it appears in sluglines)
- INT/EXT/both
- Description
- Normalised grouping — "MARCUS'S APARTMENT" and "MARCUS'S APARTMENT - KITCHEN" roll up to one location

**Version** — an immutable snapshot of a script at a point in time.
- Label (e.g., "First Draft," "Studio Notes Pass," "Table Read Draft")
- Revision colour (industry convention: white, blue, pink, yellow, green, goldenrod)
- Timestamp, author
- Diff summary from previous version

### Supporting Entities

**Note** — feedback anchored to any entity.
- Anchor: scene, character, line range, or project-level
- Author, timestamp
- Type: general, continuity, performance, production, story

**Element** — a production breakdown item.
- Name, category (prop, wardrobe, vehicle, SFX, VFX, stunt, animal, music)
- Scenes where it appears
- Notes

**Relationship** — a connection between two characters.
- Character A, Character B
- Type: family, romantic, professional, antagonistic, etc.
- Description

**Tag** — flexible categorisation across any entity.
- Polymorphic tagging for cross-cutting concerns

### Relational Shape

```
projects
  ├── scripts
  │     ├── versions
  │     └── scenes
  │           ├── scene_characters  (join)
  │           ├── scene_elements    (join)
  │           └── notes
  ├── characters
  │     ├── character_relationships (self-join)
  │     └── notes
  ├── locations
  │     └── notes
  ├── elements
  │     └── notes
  └── tags (polymorphic)
```

Scenes are the join point for nearly everything. A scene has characters, happens at a location, involves elements, and belongs to a script. Most useful queries run through scenes.

### Derived / Computed Data

Computed from script and scene data, cached as needed:
- **Scene breakdown** — characters, locations, elements per scene
- **Character page count** — screen time in pages per character
- **Dialogue line count** — per character
- **Scene order / structure map** — act breaks, sequence groupings
- **Location schedule** — which scenes share locations

## The Stack

| Package | Purpose |
|---------|---------|
| `sum` | Service registry, dependency injection, boundaries |
| `rocco` | HTTP handlers, OpenAPI generation, SSE streaming |
| `grub` | Storage abstraction (Database, Bucket, Store, Index) |
| `soy` | Type-safe SQL query builder |
| `pipz` | Composable pipeline workflows |
| `flux` | Hot-reload runtime configuration (capacitors) |
| `cereal` | Field-level encryption, hashing, masking |
| `capitan` | Events and observability signals |
| `check` | Request validation |

## API Surfaces

| Surface | Binary | Consumer | Characteristics |
|---------|--------|----------|-----------------|
| `api` | `cmd/app/` | Screenwriters | User-scoped, masked data, conservative exposure |
| `admin` | `cmd/admin/` | Internal team | System-wide, full visibility, bulk operations |

### Layer Organization

**Shared layers** (used by all surfaces):
- `models/` — Domain models
- `stores/` — Data access implementations (same store satisfies multiple contracts)
- `migrations/` — Database schema
- `events/` — Domain events
- `config/` — Configuration

**Surface-specific layers** (each surface has its own):
- `{surface}/contracts/` — Interface definitions
- `{surface}/wire/` — Request/response types (different masking per surface)
- `{surface}/handlers/` — HTTP handlers
- `{surface}/transformers/` — Model <-> wire mapping

### Surface Differences

| Aspect | Public (api/) | Admin (admin/) |
|--------|---------------|----------------|
| Auth | Screenwriter identity | Admin/internal identity |
| Scope | User's own projects | System-wide access |
| Operations | Standard CRUD | Bulk ops, impersonation, audit |
| Data exposure | Masked, minimal | Full visibility |

## Conventions

### Naming

| Layer | File | Type | Example |
|-------|------|------|---------|
| Model | `models/project.go` | `Project` (singular) | `type Project struct` |
| Store | `stores/projects.go` | `Projects` (plural struct) | `type Projects struct` |
| Contract | `{surface}/contracts/projects.go` | `Projects` (plural interface) | `type Projects interface` |
| Wire | `{surface}/wire/projects.go` | Singular + suffix | `ProjectResponse`, `AdminProjectResponse` |
| Handler | `{surface}/handlers/projects.go` | Verb+Singular | `var GetProject`, `var CreateProject` |

### Registration Points

**Shared:**
- `stores/stores.go` — aggregate factory (all stores)
- `models/boundary.go` — model boundaries

**Surface-specific (replace `{surface}` with `api` or `admin`):**
- `{surface}/handlers/handlers.go` — `All()` function
- `{surface}/handlers/errors.go` — domain errors
- `{surface}/wire/boundary.go` — wire boundaries

### Testing

- 1:1 relationship: `project.go` -> `project_test.go`
- Helpers in `testing/` call `t.Helper()`
- Mocks use function-field pattern
- Fixtures return test data with sensible defaults

## Roadmap

### Phase 1: Relational Foundation (current)
Build the structured data layer — projects, characters, locations, scenes, elements, relationships. Full CRUD via both API surfaces. This is the "database of everything you know about your screenplay before you write it."

### Phase 2: Script & Version Control
Fountain-native script storage, version snapshots, branching (alternate drafts), screenplay-aware diffing.

### Phase 3: AI Analysis API
Coverage reports, character analysis, continuity checking, structure analysis — powered by Claude, operating on the rich relational data from Phases 1-2.

### Phase 4: Editor & Collaboration
Web-based Fountain editor, real-time co-editing, inline comments, scene locking for writers' rooms.

## Non-Goals

- Building a general-purpose text editor
- AI-powered writing/autocompletion (AI is for analysis, not generation)
- Production management (scheduling, budgeting) — though the data model supports future integration
- Mobile-native applications (web-first)
