# Launch

Create a feature branch from main.

## Branch Naming

```
{type}/{issue-number}-{short-description}
```

Where `type` matches the conventional commit type:
- `feat/4-add-unexported-fields`
- `fix/12-cache-race-condition`
- `refactor/8-simplify-scan-api`

## Execution

```bash
# Create and switch to the feature branch.
git checkout -b {branch-name}
```

## Rules

- Branch from main. Always.
- One branch per issue. No multi-issue branches.
- Preflight must have passed before launch.

## Output

A new feature branch checked out and ready for work.
