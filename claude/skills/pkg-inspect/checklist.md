# Package Inspect Checklist

Orchestrates all audit skills against a package and synthesizes findings.

## Phase 1: Discovery

### Package Identification
- [ ] Identify package name from go.mod
- [ ] Note package description if available

### Structure Analysis
- [ ] List top-level directories
- [ ] Check for provider directories (multiple go.mod files)
- [ ] Check for go.work file
- [ ] Check for docs/ directory
- [ ] Check for testing/ directory

### Audit Selection
Based on discovery:

| Condition | Audits |
|-----------|--------|
| No go.work, single go.mod | bedrock → testing → pkg-readme → pkg-docs |
| Has go.work or provider go.mods | bedrock → testing → workspace → pkg-readme → pkg-docs |

## Phase 2: Bedrock Audit

**Skill:** `pkg-bedrock-audit`

Reference: `~/.claude/skills/pkg-bedrock-audit/checklist.md`

Capture status for:
- [ ] Go Module: [✓/~/✗]
- [ ] Repository Files: [✓/~/✗]
- [ ] GitHub Templates: [✓/~/✗]
- [ ] Tooling Config: [✓/~/✗]
- [ ] Makefile: [✓/~/✗]
- [ ] CI Workflows: [✓/~/✗]

Note issues found:
```
- [Issue 1]
- [Issue 2]
```

## Phase 3: Testing Audit

**Skill:** `pkg-testing-audit`

Reference: `~/.claude/skills/pkg-testing-audit/checklist.md`

Capture status for:
- [ ] 1:1 Test Mapping: [✓/~/✗]
- [ ] testing/ Directory: [✓/~/✗]
- [ ] Test Helpers: [✓/~/✗]
- [ ] Benchmarks: [✓/~/✗]
- [ ] Integration Tests: [✓/~/✗]
- [ ] CI Coverage Config: [✓/~/✗]

Note issues found:
```
- [Issue 1]
- [Issue 2]
```

## Phase 4: Workspace Audit (Conditional)

**Condition:** go.work exists OR multiple go.mod files found

**Skill:** `pkg-workspace-audit`

Reference: `~/.claude/skills/pkg-workspace-audit/checklist.md`

Capture status for:
- [ ] Root Module: [✓/~/✗]
- [ ] Go Workspace: [✓/~/✗]
- [ ] Provider Modules: [✓/~/✗]
- [ ] Dependency Isolation: [✓/~/✗]
- [ ] CI/Release Config: [✓/~/✗]

Note issues found:
```
- [Issue 1]
- [Issue 2]
```

## Phase 5: README Audit

**Skill:** `pkg-readme-audit`

Reference: `~/.claude/skills/pkg-readme-audit/checklist.md`

Capture status for:
- [ ] Header + Essence: [✓/~/✗]
- [ ] Hook Section: [✓/~/✗]
- [ ] Install: [✓/~/✗]
- [ ] Quick Start: [✓/~/✗]
- [ ] Capabilities: [✓/~/✗]
- [ ] Why [Name]?: [✓/~/✗]
- [ ] Documentation Links: [✓/~/✗]

Note issues found:
```
- [Issue 1]
- [Issue 2]
```

## Phase 6: Docs Audit

**Skill:** `pkg-docs-audit`

Reference: `~/.claude/skills/pkg-docs-audit/checklist.md`

Capture status for:
- [ ] Directory Structure: [✓/~/✗]
- [ ] Numbering Convention: [✓/~/✗]
- [ ] Frontmatter: [✓/~/✗]
- [ ] Overview: [✓/~/✗]
- [ ] Quickstart: [✓/~/✗]
- [ ] Concepts: [✓/~/✗]
- [ ] Architecture: [✓/~/✗]
- [ ] Guides: [✓/~/✗]
- [ ] Reference: [✓/~/✗]
- [ ] Cross-References: [✓/~/✗]

Note issues found:
```
- [Issue 1]
- [Issue 2]
```

## Phase 7: Synthesis

### Combined Status Matrix

| Category | Status | Issues |
|----------|--------|--------|
| Bedrock | | |
| Testing | | |
| Workspace | | |
| README | | |
| Documentation | | |

### Priority Classification

**Critical** (blocks release):
- [ ] List critical issues

**High** (should fix soon):
- [ ] List high-priority issues

**Medium** (improvement):
- [ ] List medium-priority issues

**Low** (nice to have):
- [ ] List low-priority issues

### Quick Wins

Issues that can be fixed in <30 minutes:
- [ ] List quick wins

## Phase 8: Report

Generate final report:

```markdown
# Package Inspection: [name]

## Executive Summary

[1-2 paragraphs: overall health, primary concerns, recommendation]

## Status Overview

| Category | Status |
|----------|--------|
| Bedrock | ✓/~/✗ |
| Testing | ✓/~/✗ |
| Workspace | ✓/~/✗/N/A |
| README | ✓/~/✗ |
| Documentation | ✓/~/✗ |

## Findings by Category

### Bedrock
[Findings from bedrock-audit]

### Testing
[Findings from testing-audit]

### Workspace (if applicable)
[Findings from workspace-audit]

### README
[Findings from readme-audit]

### Documentation
[Findings from docs-audit]

## Prioritized Issues

### Critical
1. [Issue + recommendation]

### High
1. [Issue + recommendation]

### Medium
1. [Issue + recommendation]

## Quick Wins
1. [Easy fix 1]
2. [Easy fix 2]

## Recommended Action Plan

1. [First step]
2. [Second step]
3. [Third step]
```
