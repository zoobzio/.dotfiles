# Initial Review

A pull request I have not seen before. Every assumption is unverified. Every line is unread. That is the starting position — I work from there.

## Phase 1: Recon

Ground truth first. I do not evaluate what I do not understand.

```bash
gh pr view --json number,title,body,baseRefName,headRefName,files,additions,deletions
git diff main...HEAD --stat
git diff main...HEAD
```

After recon, you should know:
- [ ] What repo and branch this is
- [ ] What files changed and in which packages
- [ ] What the apparent intent is — new feature, refactor, bugfix, infrastructure
- [ ] Anything surprising about the scope or contents

## Phase 2: Scope

Read `.claude/CRITERIA.md`. Determine the repo variant — Go API, Go Package, or Nuxt UI. Map the changes to review domains and build the plan.

### Determine applicable domains

| Domain | Skill | Include when |
|--------|-------|-------------|
| Code | assess/code | Source files modified or added |
| Architecture | assess/architecture | Structural changes, new packages, interface changes |
| Tests | assess/tests | Test files modified or added |
| Coverage | assess/coverage | Code changed without corresponding test changes |
| Documentation | assess/docs | Docs, README, or godoc changes |
| Security | security/* | Always — every review includes security |
| Variant | consider/api, consider/pkg, or audit/* | Always — one variant per repo |

Skip domains where the diff has nothing relevant. When in doubt, include at lower priority.

### Prioritize

Order domains by CRITERIA.md severity calibration. Higher-priority domains first.

## Phase 3: Review

Work the plan. Findings accumulate as you go — do not wait until the end to record them.

### Parallel tracks

These domains are independent and can run concurrently via subagents:

**Track A — Structure:**
- Architecture (read assess/architecture.md)
- Code (read assess/code.md, run linters)

**Track B — Verification:**
- Tests (read assess/tests.md, run `go test -race ./...`)
- Coverage (read assess/coverage.md, run `go test -coverprofile=coverage.out ./...`)

**Track C — Security:**
- Run `govulncheck ./...` and `gosec ./...`
- Manual review per applicable security/* sub-files

**Track D — Variant:**
- Go API → read consider/api.md
- Go Package → read consider/pkg.md
- Nuxt UI → read audit/* sub-files and consider/ui.md

**Track E — Documentation:**
- Read assess/docs.md

After all tracks complete, review findings holistically. A test gap in Track B may compound a security concern from Track C. Cross-reference before posting.

### For each finding

Use the domain's finding format (ARC-###, COD-###, TST-###, COV-###, DOC-###, SEC-###, AUD-###, SUP-###). Record:
- Location (file:line)
- Severity (Critical, High, Medium, Low)
- What is wrong
- Why it matters
- How to fix it

### Dependency appraisal

When the diff introduces or upgrades a dependency that warrants deeper analysis, run `/appraise` inline. The appraisal produces SUP-### findings that join the review.

### Ecosystem context

When the diff touches cross-repo boundaries — calling into a zoobzio dependency, implementing an interface from another package — consult the relevant Dixie via `/consult`. Do not guess what a dependency guarantees.

## Phase 4: Submit

Use `/review` for the mechanics of posting the review to GitHub — inline comments and summary submitted as a single review.

### Summary structure

```
## Review

[One sentence — what was reviewed and the scope of changes.]

### Findings

[Count by domain — e.g., "3 code quality, 2 architecture, 1 security." Omit domains with no findings.]

### Observations

[Broad observations that don't attach to a specific line — patterns, structural concerns, things worth noting that aren't individual findings. Omit if none.]

### Assessment

[One paragraph — overall assessment. What is the state of this PR relative to merge readiness.]
```

### Verdict

- **APPROVE** — no High or Critical findings remain. All comments are informational or low severity.
- **REQUEST_CHANGES** — one or more High or Critical findings. Label the PR `re-review`.

### Post-review

- Post the result to the repo channel: `jack msg repo post <repo> "review:#<number> <verdict> — <one line summary>" --check --check-timeout 600`
- Write a memory if this review produced patterns worth keeping
- The check loop is already running — when it returns, you are back in the cycle

## Checklist

- [ ] Recon complete — branch, diff, shape, surprises
- [ ] Scope complete — variant determined, domains identified, priorities set
- [ ] All applicable domain reviews complete
- [ ] Security analysis complete
- [ ] Variant review complete
- [ ] Findings cross-referenced across domains
- [ ] Inline comments posted for all file:line findings
- [ ] Out-of-diff findings promoted to summary
- [ ] Summary written with findings, observations, assessment
- [ ] Verdict submitted — APPROVE or REQUEST_CHANGES
- [ ] PR labeled `re-review` if REQUEST_CHANGES
- [ ] Result posted to repo channel
- [ ] Memory written if warranted
