# Commit

Review staged changes, flag anomalies, and create a conventional commit.

## Execution

1. Complete anomaly scan — DO NOT skip this phase
2. Summarize changes and propose commit message
3. Confirm with user before committing

## Conventional Commit Format

All commits MUST follow this format: type(scope): description

| Type | When to Use | Version Bump |
|------|-------------|--------------|
| `feat` | New feature | minor |
| `fix` | Bug fix | patch |
| `docs` | Documentation only | none |
| `test` | Adding/updating tests | none |
| `refactor` | Code change that neither fixes nor adds | none |
| `perf` | Performance improvement | patch |
| `chore` | Maintenance, deps, tooling | none |
| `build` | Build system or external deps | none |

### Message Requirements

The commit message MUST:
- Use imperative mood ("add" not "added")
- Start with lowercase letter
- Have no period at end
- Be under 72 characters
- Describe what changed and imply why

### Scope

Scope MUST reflect the affected area:
- Package/module name: `feat(cache):`
- Component: `fix(auth):`
- File type: `docs:`, `test:`
- OMIT scope if change is broad: `chore: update dependencies`

## Anomaly Flags

STOP and confirm with user if ANY of these are detected:

| Category | Red Flags |
|----------|-----------|
| Secrets | API keys, tokens, credentials, .env files, private keys (.pem, .key) |
| Large Files | Any file >1MB |
| Binary Files | Unless explicitly expected |
| Generated Files | node_modules/, dist/, vendor/, *.min.js |
| IDE/OS Files | .idea/, .vscode/settings.json, *.swp, .DS_Store |
| Code Quality | Debug statements (console.log, fmt.Println), commented-out code |
| Scope | Unrelated changes mixed together |

## Prohibitions

DO NOT:
- Skip the anomaly scan
- Commit without user confirmation
- Add Co-Authored-By trailer (keep git log clean)
- Add GPG signing unless user has configured it
- Use multi-line message body unless truly necessary
- Commit unrelated changes in single commit

## Checklist

### Gather State
- [ ] Run `git status` to see staged and unstaged changes
- [ ] Run `git diff --cached --stat` to see staged change summary
- [ ] Run `git diff --cached` to review actual staged changes
- [ ] If nothing staged, ask user what to stage

### Anomaly Scan
- [ ] No secrets, API keys, tokens, credentials, private keys
- [ ] No files >1MB, unexpected binaries, generated files, IDE/OS files
- [ ] No debug statements, commented-out code blocks
- [ ] Changes are related (single logical unit)

### Classify and Draft
- [ ] Commit type determined (feat, fix, docs, test, refactor, perf, chore, build)
- [ ] Scope identified (lowercase, no spaces, omit if broad)
- [ ] Message drafted: type(scope): description
- [ ] Imperative mood, lowercase, no period, under 72 chars

### Confirm and Commit
- [ ] Summary presented to user (files, type, scope, message, anomalies)
- [ ] User confirmation received
- [ ] `git commit -m "<message>"`
- [ ] Result verified with `git log -1 --oneline`

## Output

A single focused commit with:
- Conventional commit message matching format above
- Scope reflecting the affected area
- Clear description of what changed
- Clean trailer (no co-author attribution)
