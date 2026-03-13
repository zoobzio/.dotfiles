# Package Scaffold

Orchestrate the creation of a development-ready Go package skeleton by running infrastructure skills in sequence.

## Philosophy

This skill creates the **wiring**, not the **implementation**. The output is a package where `make check` passes and a developer can immediately start writing business logic.

**This skill DOES:**
- Set up CI/CD infrastructure
- Configure tooling (linting, security, coverage)
- Create test harness and helpers
- Establish documentation structure
- Wire up the development workflow

**This skill does NOT:**
- Write package business logic
- Implement features or functions
- Create bespoke tests for domain logic
- Fill in documentation content beyond structure

## Execution

1. Read `checklist.md` in this skill directory
2. Complete discovery phase
3. Run skills in sequence (see Execution Order)
4. Verify final output

## Execution Order

```
1. Discovery            → Understand package scope
2. pkg-bedrock-create   → CI/config/structure
3. pkg-testing-create   → Test infrastructure
4. pkg-workspace-create → Multi-module setup (if providers)
5. pkg-readme-create    → README
6. pkg-docs-create      → Documentation structure
```

## Specifications

### Discovery Requirements

MUST determine before proceeding:
- Package name
- One-sentence description
- Whether providers exist (multiple go.mod files needed)
- Documentation scope

### Skill Selection

| Has Providers? | Skills to Run |
|----------------|---------------|
| No | bedrock → testing → readme → docs |
| Yes | bedrock → testing → workspace → readme → docs |

### Verification Requirements

After all skills complete, MUST verify:
- `make check` passes
- `make ci` completes
- All required infrastructure files exist
- README renders correctly
- Documentation structure is in place

## Prohibitions

DO NOT:
- Write business logic
- Implement features
- Create domain-specific tests (only test harness)
- Fill in documentation content (only structure)
- Skip any skill in the sequence
- Run skills out of order

## Output

A **development-ready skeleton** with:
- Full CI/CD infrastructure
- Test harness ready for real tests
- Workspace configuration (if applicable)
- README capturing the package's essence
- Documentation structure with placeholders

**Next step:** Use `/feature` to plan and implement actual package functionality.
