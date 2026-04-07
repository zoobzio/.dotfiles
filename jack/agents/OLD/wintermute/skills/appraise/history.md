# History

How this supplier handles releases, versioning, and breaking changes.

## Assessment

- **Release cadence** — Regular releases indicate active maintenance. Long gaps indicate abandonment or stability — determine which.
- **Semver discipline** — Do they respect semantic versioning? Breaking changes in patches are a red flag. Check the changelog against actual API changes.
- **Breaking change history** — How often do major versions ship? What do migration paths look like? A package on v12 tells a different story than one on v2.
- **Changelog quality** — Maintained, detailed, and honest? Or abandoned after the first release? A changelog is a supplier's communication discipline.
- **Deprecation handling** — When they remove things, do they deprecate first? Do they provide migration guides? Or do things just disappear between versions?

## Finding Format

```markdown
### SUP-###: [Title]

**Dependency:** [module path]
**Concern:** [What the release history indicates]
**Evidence:** [Release dates, version jumps, breaking change examples]
**Recommendation:** [Accept risk | Find alternative | Monitor]
```
