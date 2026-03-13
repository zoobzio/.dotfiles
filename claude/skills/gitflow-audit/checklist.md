# Gitflow Audit Checklist

## Phase 1: Branch Structure

### Branch Existence
- [ ] `main` branch exists
- [ ] `develop` branch exists
- [ ] Default branch is `main`

### Branch Relationship
- [ ] `develop` is ahead of or equal to `main`
- [ ] No direct commits to `main` (only merges from develop)

Check with:
```bash
git log main..develop --oneline  # Should show develop-only commits
git log develop..main --oneline  # Should be empty (main shouldn't be ahead)
```

## Phase 2: CODEOWNERS

### File Presence
- [ ] `.github/CODEOWNERS` exists

### Content
- [ ] Has default owner (`* @owner`)
- [ ] Owners are valid GitHub usernames
- [ ] Path-specific rules if needed

### Format
```
* @zoobzio
```

## Phase 3: Repository Settings

### File Presence
- [ ] `.github/settings.yml` exists

### Repository Settings
- [ ] `name` matches repository
- [ ] `description` present
- [ ] `default_branch: main`
- [ ] `allow_squash_merge: true`
- [ ] `allow_merge_commit: false`
- [ ] `allow_rebase_merge: false`
- [ ] `delete_branch_on_merge: true`

### Main Branch Protection
- [ ] `required_approving_review_count: 1`
- [ ] `dismiss_stale_reviews: true`
- [ ] `require_code_owner_reviews: true`
- [ ] `required_status_checks` includes "CI Complete"
- [ ] `required_linear_history: true`

### Develop Branch Protection
- [ ] `required_approving_review_count: 1`
- [ ] `require_code_owner_reviews: true`
- [ ] `required_status_checks` includes "CI Complete"

## Phase 4: Auto-Version Workflow

### File Presence
- [ ] `.github/workflows/auto-version.yml` exists

### Trigger Configuration
- [ ] Triggers on push to `main`
- [ ] Only runs on merge commits (not direct pushes)

### Version Calculation
- [ ] Uses `svu` or similar tool
- [ ] Fetches full history (`fetch-depth: 0`)
- [ ] Calculates from conventional commits

### Tag Creation
- [ ] Creates annotated tag
- [ ] Pushes tag to origin
- [ ] Has proper permissions (`contents: write`)

### Conditional Logic
- [ ] Only tags if version changed
- [ ] Doesn't tag on no-op merges

## Phase 5: Version Preview Workflow

### File Presence
- [ ] `.github/workflows/version-preview.yml` exists

### Trigger Configuration
- [ ] Triggers on pull_request to `main`
- [ ] Triggers on opened and synchronize events

### Permissions
- [ ] `pull-requests: write`
- [ ] `contents: read`

### Functionality
- [ ] Calculates current and next version
- [ ] Posts comment to PR
- [ ] Updates existing comment (doesn't spam)

## Phase 6: CI Configuration

### Trigger Branches
- [ ] CI runs on push to `main`
- [ ] CI runs on push to `develop`
- [ ] CI runs on PRs to both branches

Check ci.yml:
```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
```

### Release Workflow
- [ ] Triggers on version tags (`v*.*.*`)
- [ ] Doesn't trigger on submodule tags (if workspace)

## Phase 7: GitHub Settings Sync

### Settings App
- [ ] Settings app installed (if using settings.yml)
- [ ] Or branch protection configured manually

### Actual Branch Protection (verify in GitHub UI)
- [ ] main: PR required
- [ ] main: Reviews required
- [ ] main: Status checks required
- [ ] main: Linear history required
- [ ] develop: PR required (for non-maintainers)
- [ ] develop: Status checks required

## Phase 8: Workflow Integration

### PR to Develop Flow
- [ ] PRs can target develop
- [ ] CI runs on PR
- [ ] Merge creates squash commit

### Release Flow (develop → main)
- [ ] PR from develop to main works
- [ ] Version preview shows on PR
- [ ] Merge triggers auto-version
- [ ] Tag triggers release workflow

### Version Calculation
Test by checking recent releases:
```bash
git log --oneline main | head -5
git tag --sort=-version:refname | head -5
```

- [ ] Tags follow semver (v1.2.3)
- [ ] Version bumps match conventional commits

## Phase 9: Cross-Cutting

### Consistency
- [ ] All workflows use same Go version
- [ ] All workflows use same checkout action version
- [ ] Branch names consistent everywhere

### Documentation
- [ ] README mentions branching strategy (optional)
- [ ] CONTRIBUTING.md mentions PR target branch

### Security
- [ ] No secrets in workflow files
- [ ] Proper token permissions (minimal)
- [ ] No workflow_dispatch without protection

## Phase 10: Report

### Status Matrix

| Category | Status | Notes |
|----------|--------|-------|
| Branch Structure | [✓/~/✗] | |
| CODEOWNERS | [✓/~/✗] | |
| settings.yml | [✓/~/✗] | |
| Auto-Version | [✓/~/✗] | |
| Version Preview | [✓/~/✗] | |
| CI Config | [✓/~/✗] | |
| Branch Protection | [✓/~/✗] | |

### Issues Found
```
1. [Issue + recommendation]
2. [Issue + recommendation]
```

### Quick Wins
```
1. [Easy fix]
2. [Easy fix]
```
