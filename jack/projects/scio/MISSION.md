# Mission: scio

URI-based data catalog with atomic operations across storage types.

## Purpose

Provide logical addressing for data across multiple storage backends. Resources are registered with URI schemes (db://, kv://, bcs://, idx://), and operations route to the correct grub backend based on the URI. All data flows through atom.Atom for type-agnostic access. Topology intelligence enables discovering related resources by shared type.

Scio exists because applications with multiple storage backends need a unified addressing scheme, type-agnostic operations, and the ability to discover relationships between data sources.

## What This Package Contains

- URI-based addressing: variant://resource/key with four variants (db, kv, bcs, idx)
- Resource registration with metadata (description, version, tags)
- Catalog introspection: sources, filter by variant, spec lookup
- Topology discovery: find related resources by spec, find resources by field name
- Key-value operations (Get, Set, Delete, Exists) for db:// and kv:// resources
- Database query operations (Query, Select) for db:// resources
- Blob operations (Put) for bcs:// resources
- Vector operations (Upsert, Search, Query, Filter) for idx:// resources
- All data as atom.Atom for framework-level type-agnostic access
- Thread-safe registry with RWMutex protection

## What This Package Does NOT Contain

- Storage provider implementations — uses grub's atomic interfaces
- Data transformation or serialization — atom.Atom is the interchange format
- Cross-resource transactions
- Resource lifecycle management (creation, deletion of backends)

## Ecosystem Position

| Dependency | Role |
|------------|------|
| `grub` | Storage backend interfaces (AtomicDatabase, AtomicStore, AtomicBucket, AtomicIndex) |
| `atom` | Type-agnostic data representation |
| `edamame` | Query statement types |
| `vecna` | Vector filter types |

Scio is consumed by applications for unified data access across storage types.

## Design Constraints

- All operations are type-agnostic via atom.Atom
- URI parsing validates variant, resource name, and key presence
- Variant mismatch (e.g., kv:// operation on db:// resource) produces clear error
- Registration requires grub's atomic interfaces, not typed wrappers
- Thread-safe via RWMutex with minimal lock scope (held during state access, not I/O)

## Success Criteria

A developer can:
1. Register storage backends under logical URIs and access them uniformly
2. Route operations to correct backends based on URI scheme
3. Discover related resources by shared type or field name
4. Access all storage types through type-agnostic atom.Atom interface
5. Introspect the catalog to understand available resources and their metadata

## Non-Goals

- Replacing grub's typed wrappers for type-safe access
- Cross-resource transactions
- Storage backend provisioning or lifecycle management
- Data migration between resources
