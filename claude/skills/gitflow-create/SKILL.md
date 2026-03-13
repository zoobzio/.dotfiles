# Gitflow Create

Set up a two-branch development strategy with automated versioning and releases.

## Branch Strategy

```
main     ←── releases only (protected, from develop only)
  ↑
develop  ←── PRs land here (protected)
  ↑
feature/ ←── feature branches
```

## Flow

1. PRs target `develop`
2. `/release` skill merges `develop` → `main`
3. Merge to `main` triggers auto-version workflow
4. Auto-version calculates next version and pushes tag
5. Tag triggers release workflow

## Execution

1. Read `checklist.md` in this skill directory
2. Ask user for code owner(s)
3. Create configuration files per specifications
4. Instruct user on GitHub settings sync

## Specifications

### Files to Create

| File | Purpose |
|------|---------|
| `.github/CODEOWNERS` | Code ownership for review requirements |
| `.github/settings.yml` | Repository settings + branch protection |
| `.github/workflows/auto-version.yml` | Calculate version on main merge, push tag |
| `.github/workflows/version-preview.yml` | Comment next version on PRs |

### CODEOWNERS Format

```
# Code ownership for [package]
# See: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners

* @[owner]
```

### settings.yml

MUST include exactly:

```yaml
repository:
  name: [package]
  description: [one-line description]
  homepage: https://github.com/zoobzio/[package]
  has_wiki: true
  has_downloads: true
  default_branch: main
  allow_squash_merge: true
  allow_merge_commit: false
  allow_rebase_merge: false
  delete_branch_on_merge: true

branches:
  - name: main
    protection:
      required_pull_request_reviews:
        required_approving_review_count: 1
        dismiss_stale_reviews: true
        require_code_owner_reviews: true
      required_status_checks:
        strict: true
        contexts:
          - CI Complete
      enforce_admins: true
      required_linear_history: true
      restrictions: null

  - name: develop
    protection:
      required_pull_request_reviews:
        required_approving_review_count: 1
        dismiss_stale_reviews: true
        require_code_owner_reviews: true
      required_status_checks:
        strict: true
        contexts:
          - CI Complete
      enforce_admins: false
      required_linear_history: true
      restrictions: null
```

### auto-version.yml

See checklist for exact workflow content.

### version-preview.yml

See checklist for exact workflow content.

### Auto-Versioning Rules

Uses `svu` (semantic version utility):
- `feat:` → minor bump
- `fix:` → patch bump
- `feat!:` or `BREAKING CHANGE:` → major bump

## Prohibitions

DO NOT:
- Modify the settings.yml structure
- Skip branch protection configuration
- Use alternative versioning tools without user confirmation

## Output

A complete gitflow setup that:
- Protects main and develop branches
- Enforces code review via CODEOWNERS
- Auto-calculates version on release
- Previews version on PRs
