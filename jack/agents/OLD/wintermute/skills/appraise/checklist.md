# Appraise Checklist

## Phase 1: Identify Target

- [ ] Dependency identified by Molly
- [ ] Module path and version noted
- [ ] Context understood — why this dependency is in the diff (new addition, upgrade, transitive)

## Phase 2: Provenance

- [ ] Read appraise/provenance.md
- [ ] Maintainer count assessed — bus factor
- [ ] Organizational backing identified — personal, company, foundation
- [ ] Activity checked — last commit, last release, issue response time
- [ ] Contributor health assessed — broad base or narrow
- [ ] Succession plan evaluated — co-maintainer, org, or single point of failure

## Phase 3: Adoption

- [ ] Read appraise/adoption.md
- [ ] Dependents checked via pkg.go.dev importers (not GitHub stars)
- [ ] Production trust signals identified — known projects, companies, infrastructure
- [ ] Download trends assessed — growing, stable, or declining
- [ ] Community presence evaluated — issues, discussions, ecosystem presence

## Phase 4: History

- [ ] Read appraise/history.md
- [ ] Release cadence assessed — active maintenance or abandonment signals
- [ ] Semver discipline reviewed — breaking changes in patches are red flags
- [ ] Breaking change history assessed — frequency and migration path quality
- [ ] Changelog quality reviewed — maintained, detailed, honest
- [ ] Deprecation handling evaluated — deprecation notices with migration guides

## Phase 5: Alternatives

- [ ] Read appraise/alternatives.md
- [ ] Competing packages identified
- [ ] Single-supplier risk assessed — is there a fallback?
- [ ] Alternatives compared on provenance, adoption, and cost dimensions
- [ ] Standard library alternative evaluated — could stdlib solve this?
- [ ] Internal ecosystem checked — does zoobzio already have a package for this?

## Phase 6: Cost

- [ ] Read appraise/cost.md
- [ ] Transitive dependencies enumerated
- [ ] Total added module weight assessed
- [ ] License identified and compatibility confirmed
- [ ] License consistency with existing dependencies verified
- [ ] Build impact assessed — build time, binary size, compilation cost

## Phase 7: Compile Assessment

- [ ] All five domains assessed
- [ ] Each finding has SUP prefix, severity, description, impact, evidence, recommendation
- [ ] Overall assessment states: adopt, caution, or reject with reasoning
- [ ] Assessment sent to Molly via SendMessage
