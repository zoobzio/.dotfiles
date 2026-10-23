---
name: pull-request
description: Open a GitHub pull request for the current branch with a Conventional Commits title and a structured Why/What description. Use this skill whenever the user asks to open, create, submit, or raise a PR, says "PR this", or "push this up for review". Use it for every pull request, including small ones.
---

# Pull request

A pull request presents one change to a reviewer. The title follows Conventional Commits. The description tells the reviewer why the change exists and what it contains.

## Description

Use this exact template:

```markdown
## Why

<one to three sentences>

## What

- <one change, one or two sentences>
- <one change, one or two sentences>

Closes #<n>
```

- `## Why` states the problem or the need that the change resolves. One to three sentences.
- `## What` lists every change in the diff. One change per line. One or two sentences per line. Present tense.
- Add `Closes #<n>` as the last line when the branch resolves a tracked issue. Omit the line otherwise.

## Readiness check

The pull request is ready for review when every item is true:

- The test suite passes on the branch.
- Every change in the diff serves the `## Why`.
- `## What` lists every change in the diff.
- Every behavior named in `## What` was verified by a test or by running it.
- Every decision in the change was confirmed by the user or stated in the issue.
- The branch depends on no unmerged pull request.

When one item is false, the pull request opens as a draft. Record each false item as one concern. The reviewer's job is the code, so a concern is resolved with the user before review starts, and the draft state holds the pull request until then.

## Procedure

1. Inspect the branch.

   ```sh
   git status --short
   git log --oneline main..HEAD
   git diff main...HEAD --stat
   ```

2. Push the branch.

   ```sh
   git push -u origin HEAD
   ```

3. Write the title with the format `<type>(<scope>)!: <description>`.

   - Select the type with the highest version effect among the commits on the branch: `feat` above `fix`, `fix` above the rest.
   - Add `!` when any commit on the branch is a breaking change.
   - Write the description in the imperative mood, lowercase, with no final period.
   - When the branch has one commit, reuse its subject line.

4. Write the description with the template in **Description**.

5. Apply the **Readiness check**.

6. Create the pull request.

   With no concerns:

   ```sh
   gh pr create --title "<title>" --body "$(cat <<'BODY'
   <description>
   BODY
   )"
   ```

   With one or more concerns, append this section to the description and open as a draft:

   ```markdown
   ## Concerns

   - <one concern, with the decision or information needed to resolve it>
   ```

   ```sh
   gh pr create --draft --title "<title>" --body "$(cat <<'BODY'
   <description>
   BODY
   )"
   ```

7. Report to the user: the pull request URL, its state (draft or ready), and each concern on its own line.

## Examples

**Ready**

Title:

```
feat(store): add TTL eviction for cached entries
```

Description:

```markdown
## Why

Cached entries live until the process exits. Long-running processes grow without bound.

## What

- Add a `TTL` option to `store.New`. Entries older than the TTL are evicted on read.
- Add a background sweep that runs every TTL interval and removes expired entries.
- Add tests for eviction on read and for the sweep.

Closes #41
```

**Draft**

Title:

```
fix(pipeline): flush the buffer before close
```

Description:

```markdown
## Why

Events in the buffer are lost when the pipeline closes. Callers see counts lower than the events they sent.

## What

- Flush the buffer in `Pipeline.Close` before the output channel closes.
- Add a test that sends events and closes the pipeline, then asserts the count.

## Concerns

- The flush blocks `Close` until the output drains. Confirm whether `Close` needs a timeout, and the value.

Closes #38
```
