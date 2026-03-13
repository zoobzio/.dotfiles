# Package Inspect

Run all audit skills against an existing Go package and synthesize findings into a single report.

## Execution Order

```
1. Discovery            → Detect package structure
2. pkg-bedrock-audit    → CI/config/structure
3. pkg-testing-audit    → Test infrastructure
4. pkg-workspace-audit  → Multi-module setup (if applicable)
5. pkg-readme-audit     → README quality
6. pkg-docs-audit       → Documentation coverage
7. Synthesis            → Combined report
```

## Execution

1. Read `checklist.md` in this skill directory
2. Detect package structure (discovery phase)
3. Run applicable audits in sequence
4. Synthesize findings into combined report

## Specifications

### Discovery Requirements

MUST detect before auditing:
- Package name from go.mod
- Provider directories (multiple go.mod files)
- go.work file existence
- docs/ directory existence
- testing/ directory existence

### Audit Selection

| Condition | Audits to Run |
|-----------|---------------|
| No go.work, single go.mod | bedrock → testing → readme → docs |
| Has go.work or provider go.mods | bedrock → testing → workspace → readme → docs |

### Report Requirements

Final report MUST include:
- Executive summary
- Status matrix for all categories
- Findings by category
- Prioritized issues (Critical / High / Medium / Low)
- Quick wins
- Recommended action plan

## Output

### Report Structure

```markdown
# Package Inspection: [name]

## Executive Summary
[1-2 paragraphs: overall health, primary concerns, recommendation]

## Status Overview

| Category | Status |
|----------|--------|
| Bedrock | [✓/~/✗] |
| Testing | [✓/~/✗] |
| Workspace | [✓/~/✗/N/A] |
| README | [✓/~/✗] |
| Documentation | [✓/~/✗] |

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
[Issues that block release]

### High
[Issues that should fix soon]

### Medium
[Improvements]

### Low
[Nice to have]

## Quick Wins
[Easy fixes with high impact]

## Recommended Action Plan
1. [First step]
2. [Second step]
3. [Third step]
```

Status legend: ✓ Compliant, ~ Partial, ✗ Missing/Non-compliant, N/A Not Applicable
