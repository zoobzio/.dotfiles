# Gitflow Create Checklist

## Phase 1: Discovery

- [ ] Ask: "Who are the code owners?" (GitHub usernames)
- [ ] Ask: "Should develop allow direct pushes from maintainers?"
- [ ] Confirm repository name for settings.yml

## Phase 2: Create develop Branch

If develop doesn't exist:
```bash
git checkout main
git checkout -b develop
git push -u origin develop
```

- [ ] develop branch exists
- [ ] develop is pushed to origin

## Phase 3: CODEOWNERS

Create `.github/CODEOWNERS`:

```
# Code ownership for [package]
# See: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners

* @[owner]
```

For multiple owners or path-specific ownership:
```
# Default owners
* @zoobzio

# Specific paths (optional)
/docs/ @zoobzio @docs-team
/.github/ @zoobzio
```

- [ ] `.github/CODEOWNERS` created
- [ ] Owners listed correctly

## Phase 4: Repository Settings

Create `.github/settings.yml`:

```yaml
repository:
  name: [package]
  description: [one-line description]
  homepage: https://github.com/zoobzio/[package]
  has_wiki: true
  has_downloads: true
  default_branch: main

  # Merge strategy: squash only for clean history
  allow_squash_merge: true
  allow_merge_commit: false
  allow_rebase_merge: false
  delete_branch_on_merge: true

branches:
  # Main branch: releases only
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

  # Develop branch: integration
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

- [ ] `.github/settings.yml` created
- [ ] Repository name correct
- [ ] Both branches have protection rules

## Phase 5: Auto-Version Workflow

Create `.github/workflows/auto-version.yml`:

```yaml
name: Auto Version

on:
  push:
    branches: [ main ]

permissions:
  contents: write

jobs:
  version:
    name: Calculate and Tag Version
    runs-on: ubuntu-latest
    # Only run on merge commits (PRs), not direct pushes
    if: github.event.head_commit.message != '' && contains(github.event.head_commit.message, 'Merge pull request')

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Setup svu
        run: |
          go install github.com/caarlos0/svu@latest
          echo "$HOME/go/bin" >> $GITHUB_PATH

      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.25'

      - name: Calculate next version
        id: version
        run: |
          CURRENT=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
          NEXT=$(svu next)
          echo "current=$CURRENT" >> $GITHUB_OUTPUT
          echo "next=$NEXT" >> $GITHUB_OUTPUT
          echo "Current: $CURRENT"
          echo "Next: $NEXT"

      - name: Create and push tag
        if: steps.version.outputs.current != steps.version.outputs.next
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git tag -a "${{ steps.version.outputs.next }}" -m "Release ${{ steps.version.outputs.next }}"
          git push origin "${{ steps.version.outputs.next }}"

      - name: Summary
        run: |
          echo "### Version Tagged" >> $GITHUB_STEP_SUMMARY
          echo "**Previous:** ${{ steps.version.outputs.current }}" >> $GITHUB_STEP_SUMMARY
          echo "**New:** ${{ steps.version.outputs.next }}" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "Release workflow will be triggered by the new tag." >> $GITHUB_STEP_SUMMARY
```

- [ ] `.github/workflows/auto-version.yml` created
- [ ] Only triggers on merge commits to main
- [ ] Uses svu for version calculation

## Phase 6: Version Preview Workflow

Create `.github/workflows/version-preview.yml`:

```yaml
name: Version Preview

on:
  pull_request:
    branches: [ main, develop ]
    types: [opened, synchronize]

permissions:
  pull-requests: write
  contents: read

jobs:
  preview:
    name: Preview Next Version
    runs-on: ubuntu-latest
    # Only preview for PRs to main (releases)
    if: github.base_ref == 'main'

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.25'

      - name: Setup svu
        run: |
          go install github.com/caarlos0/svu@latest
          echo "$HOME/go/bin" >> $GITHUB_PATH

      - name: Calculate versions
        id: calc
        run: |
          CURRENT=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
          NEXT=$(svu next)
          echo "current=$CURRENT" >> $GITHUB_OUTPUT
          echo "next=$NEXT" >> $GITHUB_OUTPUT

      - name: Post PR comment
        uses: actions/github-script@v7
        with:
          script: |
            const body = `## 📋 Version Preview

            **Current:** \`${{ steps.calc.outputs.current }}\`
            **Next:** \`${{ steps.calc.outputs.next }}\`

            *Version will be tagged automatically when this PR is merged.*`;

            const { data: comments } = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
            });

            const botComment = comments.find(c =>
              c.user.type === 'Bot' && c.body.includes('Version Preview'));

            if (botComment) {
              await github.rest.issues.updateComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: botComment.id,
                body
              });
            } else {
              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                body
              });
            }
```

- [ ] `.github/workflows/version-preview.yml` created
- [ ] Only runs on PRs to main
- [ ] Posts/updates comment with version preview

## Phase 7: Update CI Workflow

Update `.github/workflows/ci.yml` to run on both branches:

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
```

- [ ] CI triggers on both main and develop

## Phase 8: Update PR Skill Default

Note: The `/pr` skill should default to `develop` as base branch.

When creating PRs:
```bash
gh pr create --base develop --title "..." --body "..."
```

## Phase 9: GitHub Settings Sync

**Important:** `.github/settings.yml` requires the [Settings app](https://github.com/apps/settings) to be installed on the repository.

- [ ] Install Settings app on repository (or org)
- [ ] Or manually configure branch protection in GitHub UI

Manual setup if not using Settings app:
1. Go to Settings → Branches
2. Add rule for `main` with protections from Phase 4
3. Add rule for `develop` with protections from Phase 4

## Phase 10: Verification

- [ ] `develop` branch exists
- [ ] CODEOWNERS file present
- [ ] settings.yml present
- [ ] auto-version.yml present
- [ ] version-preview.yml present
- [ ] CI runs on both branches
- [ ] Branch protection rules active (after Settings app sync)
