# Gitflow Audit

Evaluate existing branch strategy, protection rules, and release automation.

## Scope

| Category | Files/Settings |
|----------|----------------|
| Branches | main, develop existence |
| CODEOWNERS | `.github/CODEOWNERS` |
| Settings | `.github/settings.yml` |
| Auto-Version | `.github/workflows/auto-version.yml` |
| Version Preview | `.github/workflows/version-preview.yml` |
| Branch Protection | GitHub branch rules |

## Execution

1. Read `checklist.md` in this skill directory
2. Work through each phase systematically
3. Compile findings into structured report

## Specifications

### Required Branch Structure

- `main` branch MUST exist
- `develop` branch MUST exist
- Default branch MUST be `main`
- `develop` MUST be ahead of or equal to `main`
- No direct commits to `main` (only merges from develop)

### Required CODEOWNERS

`.github/CODEOWNERS` MUST exist with:
- Default owner line: `* @[owner]`
- Valid GitHub usernames

### Required Settings

`.github/settings.yml` MUST configure:

Repository:
- `default_branch: main`
- `allow_squash_merge: true`
- `allow_merge_commit: false`
- `allow_rebase_merge: false`
- `delete_branch_on_merge: true`

Main branch protection:
- `required_approving_review_count: 1`
- `require_code_owner_reviews: true`
- `required_status_checks` includes "CI Complete"
- `required_linear_history: true`

Develop branch protection:
- `required_approving_review_count: 1`
- `required_status_checks` includes "CI Complete"

### Required Workflows

#### auto-version.yml
- Triggers on push to `main`
- Only runs on merge commits
- Uses `svu` for version calculation
- Creates and pushes annotated tag
- Has `contents: write` permission

#### version-preview.yml
- Triggers on pull_request to `main`
- Has `pull-requests: write` permission
- Posts/updates comment with version preview

## Output

### Report Structure

```markdown
## Summary
[Overall gitflow health and primary recommendation]

## Coverage Matrix

| Category | Status | Issue |
|----------|--------|-------|
| Branch Structure | [✓/~/✗] | |
| CODEOWNERS | [✓/~/✗] | |
| Settings | [✓/~/✗] | |
| Auto-Version | [✓/~/✗] | |
| Version Preview | [✓/~/✗] | |
| Branch Protection | [✓/~/✗] | |

## Issues
[Prioritized list with recommendations]

## Quick Wins
[Easy fixes]
```

Status legend: ✓ Compliant, ~ Partial, ✗ Missing/Non-compliant
