---
name: appraise
description: Dependency supply chain assessment — provenance, adoption, history, alternatives, cost. Invoked when a PR introduces or upgrades a dependency.
argument-hint: "[module path]"
allowed-tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
---

# Appraise

Assess a dependency for supply chain risk. Every external package is code you did not audit running in your process.

**Argument:** `$ARGUMENTS` — module path to assess.

## Checklist

- [ ] Identify target dependency and context (new addition, upgrade, transitive)
- [ ] Assess all five domains
- [ ] Compile assessment with verdict

## Domains

### Provenance

Who built this, who maintains it, and are they still here.

- [ ] Maintainer count assessed — single maintainer is bus factor of one. Check contributor graph, not org name.
- [ ] Organizational backing identified — personal, company, or foundation. Each carries different risk.
- [ ] Activity checked — last commit, last release, open issue response time. Green CI on a year-old repo is a corpse with good makeup.
- [ ] Contributor health — broad base or one person doing all the work
- [ ] Succession — if the maintainer disappears, what happens

### Adoption

How many people trust this with their production traffic.

- [ ] Dependents checked via pkg.go.dev importers — not GitHub stars. Stars are vanity. Imports are commitment.
- [ ] Production trust signals — used by known projects, companies, infrastructure
- [ ] Download trends — growing, stable, or declining. Declining on a package you are about to adopt is a warning.
- [ ] Community presence — active issues, discussions. Zero activity means it either works perfectly or nobody uses it. Determine which.

### History

How this supplier handles releases, versioning, and breaking changes.

- [ ] Release cadence — regular releases indicate maintenance. Long gaps indicate abandonment or stability. Determine which.
- [ ] Semver discipline — breaking changes in patches are a red flag. Check changelog against actual API changes.
- [ ] Breaking change history — frequency and migration path quality. v12 tells a different story than v2.
- [ ] Changelog quality — maintained, detailed, honest. Or abandoned after first release.
- [ ] Deprecation handling — deprecate first with migration guides, or things just disappear

### Alternatives

Is this the only option, and if not, why this one.

- [ ] Competing packages identified with comparable feature sets
- [ ] Single-supplier risk assessed — no fallback is a supply chain risk regardless of quality
- [ ] Alternatives compared on provenance, adoption, and cost
- [ ] Standard library alternative evaluated — dependency replacing stdlib needs strong justification
- [ ] Internal ecosystem checked — does zoobzio already have a package for this. Run `/grok`.

### Cost

What this dependency actually brings with it.

- [ ] Transitive dependencies enumerated — one direct dep with forty transitive is forty-one suppliers
- [ ] Total added module weight assessed
- [ ] License identified — MIT/Apache/BSD straightforward, copyleft has implications, unusual needs review
- [ ] License consistency — transitive deps carry compatible licenses
- [ ] Build impact — build time, binary size, compilation complexity

## Verdict

| Assessment | When |
|------------|------|
| **Adopt** | Strong provenance, broad adoption, clean history, acceptable cost |
| **Caution** | Mixed signals — adopt with documented risk acceptance |
| **Reject** | Weak provenance, no adoption, better alternatives exist, or unacceptable cost |

## Finding Format

```markdown
### SUP-###: [Title]

**Dependency:** [module path]
**Concern:** [What the supply chain risk is]
**Evidence:** [Data supporting the concern]
**Recommendation:** [Adopt | Caution | Reject | Replace with X]
```
