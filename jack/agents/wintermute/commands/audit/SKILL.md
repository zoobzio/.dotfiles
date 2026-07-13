---
name: audit
description: Nuxt UI review playbooks — components, typescript, state, styles, linting, testing, accessibility, performance. Replaces base assess skill for UI repos.
user-invocable: false
allowed-tools: Read, Grep, Glob, Bash
---

# Audit

Review playbooks for Nuxt UI applications. Each sub-file covers one audit domain.

Read the relevant sub-file for the domain being audited. Do not read all sub-files unless instructed.

## Sub-Files

| File | Domain | Finding Prefix |
|------|--------|---------------|
| components.md | Vue component quality, composition, props/emits | AUD |
| typescript.md | Type safety, type coverage, any-avoidance | AUD |
| state.md | Pinia store design, reactivity, data flow | AUD |
| styles.md | CSS/styling patterns, scoping, consistency | AUD |
| linting.md | ESLint, Prettier, Vue-specific rules | AUD |
| testing.md | Component tests, E2E, snapshot testing | AUD |
| accessibility.md | ARIA, keyboard navigation, screen readers | AUD |
| performance.md | Bundle size, lazy loading, rendering efficiency | AUD |

## Finding Format

```markdown
### AUD-###: [Title]

**Category:** [Component | TypeScript | State | Style | Lint | Test | A11y | Performance]
**Severity:** [Critical | High | Medium | Low]
**Location:** [file:line range]
**Description:** [What the defect is]
**Impact:** [What goes wrong if this isn't fixed]
**Evidence:** [Code snippet or tool output]
**Recommendation:** [How to fix it]
```
