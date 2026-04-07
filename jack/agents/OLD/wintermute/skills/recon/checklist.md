# Recon Checklist

## Phase 1: Identify Environment

- [ ] Run `git branch --show-current`
- [ ] Run `git remote get-url origin`
- [ ] Confirm branch and repo identity

## Phase 2: Establish Diff

- [ ] Run `git log main..HEAD --oneline` for commit history
- [ ] Run `git diff main...HEAD --stat` for file change summary
- [ ] Run `git diff main...HEAD` for actual changes
- [ ] Note total commit count on this branch

## Phase 3: Understand Shape

### Scope
- [ ] Identify which packages are touched
- [ ] Classify intent — new feature, refactor, bugfix, infrastructure
- [ ] Classify scope — narrow (one package) or broad (cross-cutting)
- [ ] Note new files, deleted files, and modifications separately

### Surprises
- [ ] Flag files changed that seem unrelated to apparent intent
- [ ] Flag large diffs in unexpected places
- [ ] Flag changes to configuration, dependencies, or build infrastructure
- [ ] Flag changes to CI/CD or deployment files

## Phase 4: Hold Understanding

- [ ] Can state what branch and repo this is
- [ ] Can state how many commits are on this branch
- [ ] Can state what files changed and in which packages
- [ ] Can state the apparent intent of the changes
- [ ] Can state anything surprising about scope or contents
- [ ] Understanding held — ready for review phase
