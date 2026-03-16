# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- URI parsing correctly validates variant, resource name, and key
- Operations route to correct grub backend based on URI variant
- Variant mismatch operations produce clear errors (not silent failures)
- Resource registration validates URI format and prevents duplicates
- Topology discovery correctly finds related resources by spec FQDN
- All data operations use atom.Atom consistently
- Thread-safe registry with RWMutex protection and minimal lock scope

### What This Repo MUST NOT Contain

- Storage provider implementations
- Data transformation or serialization logic
- Cross-resource transactions
- Resource lifecycle management

## Review Priorities

1. URI routing: operations must reach the correct backend — wrong routing is data corruption
2. Variant enforcement: operations on wrong variant must error clearly
3. URI parsing: all edge cases (missing key, invalid variant, malformed URI) must be caught
4. Registration safety: duplicates must error, not silently overwrite
5. Topology discovery: spec matching must be by FQDN, field matching must be accurate
6. Thread safety: RWMutex must protect all mutable state without holding locks during I/O

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Operation routes to wrong backend | Critical |
| URI parsing accepts invalid URI | High |
| Variant mismatch silently succeeds | High |
| Duplicate registration silently overwrites | High |
| Topology discovery returns wrong resources | Medium |
| Lock held during I/O operation | Medium |
| UUID parsing fails for valid UUID key | Medium |
| Error type doesn't match sentinel errors | Low |

## Standing Concerns

- idx:// keys must be valid UUIDs — verify parsing and error messages
- kv:// SetWithTTL only valid for kv:// variant — verify db:// rejects TTL
- Atomic interfaces from grub — verify scio passes through errors without swallowing
- FindBySpec matches by FQDN — verify atom.Spec comparison is correct

## Out of Scope

- Type-agnostic via atom.Atom is intentional — scio is framework-level, typed access is grub
- No cross-resource transactions is by design
- Re-exported grub errors is intentional for consumer convenience
