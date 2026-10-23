---
name: commit
description: Write and create a git commit that follows Conventional Commits and semantic versioning. Use this skill whenever the user asks to commit, says "commit this", "check this in", "save my work", or whenever a task ends with uncommitted changes that are ready to record. Use it for every commit, including small ones.
argument-hint: "[scope or intent]"
---

# Commit

Record one logical change as one commit. The message states what the code adds, in the words a reader of `git log` needs.

If `$ARGUMENTS` is present, use it as the scope or the intent of the change.

## Procedure

1. Inspect the working tree.

   ```sh
   git status --short
   git diff
   git diff --cached
   ```

2. Group the changes into logical units. One unit is one commit. Repeat steps 3 to 7 for each unit.

3. Stage the files for this unit.

   ```sh
   git add <paths>
   ```

4. Classify the unit with the type table below. Mark a breaking change with `!` after the type or scope.

5. Write the subject line.

6. Write the body and footers when the subject line cannot carry the full change.

7. Create the commit.

   ```sh
   git commit -m "$(cat <<'MSG'
   <subject>

   <body>

   <footers>
   MSG
   )"
   ```

8. Verify the result.

   ```sh
   git log -1 --stat
   ```

## Type table

| Type       | Use for                                              | Version effect              |
| ---------- | ---------------------------------------------------- | --------------------------- |
| `feat`     | New behavior a user of the code can observe          | minor                       |
| `fix`      | Corrected behavior                                   | patch                       |
| `perf`     | Faster or smaller behavior with the same result      | patch                       |
| `refactor` | Changed structure with the same behavior             | none                        |
| `test`     | Added or changed tests only                          | none                        |
| `docs`     | Changed documentation only                           | none                        |
| `build`    | Changed build system, dependencies, or versions      | none                        |
| `ci`       | Changed CI configuration or scripts                  | none                        |
| `chore`    | Maintenance with no change to source, tests, or docs | none                        |
| `revert`   | Reverted an earlier commit                           | matches the reverted commit |

A breaking change raises the version effect to major, for every type.

## Subject line

Format: `<type>(<scope>)!: <description>`

- Set `<scope>` to the package, module, or directory the unit changes. Omit the parentheses when the unit spans the whole project.
- Add `!` only for a breaking change.
- Write `<description>` in the imperative mood, lowercase, with no final period.
- Keep the full subject line at 72 characters or fewer.
- State what the code does after the commit. The subject is what `git log --oneline` and the changelog show, so it carries the complete change on its own.

## Body

Add a body only when the subject line cannot carry the full change.

- Separate the body from the subject with one blank line.
- Describe what the code adds and the behavior that results. Use the present tense.
- Write one fact per sentence. Wrap lines at 72 characters.
- Use a bullet list when the unit contains several independent facts.

## Footers

Separate footers from the body with one blank line. The footers below are the only trailers in the message.

| Footer          | Format                                                    | Use when                                        |
| --------------- | --------------------------------------------------------- | ----------------------------------------------- |
| Breaking change | `BREAKING CHANGE: <what changed and what callers do now>` | The commit has `!` in the subject               |
| Issue reference | `Closes #<n>` or `Refs #<n>`                              | The unit resolves or relates to a tracked issue |

## Examples

**Subject only**

```
feat(store): add TTL eviction for cached entries
```

```
fix(pipeline): flush the buffer before close
```

```
refactor(handler): extract session lookup into resolve.go
```

**Subject and body**

```
feat(config)!: load secrets from a per-agent env file

Secrets are read from secrets/<agent>.env at container start and
injected into the environment. The file must be mode 600.

BREAKING CHANGE: the `secrets` key in config.yaml is removed. Move
each value into secrets/<agent>.env.
```

**Subject with issue reference**

```
fix(git): resolve the session name when the repo contains a hyphen

Closes #27
```
