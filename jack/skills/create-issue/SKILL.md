---
name: create-issue
description: Create one or more GitHub issues of type task, story, or epic, with the user supplying every detail through a short interview. Use this skill whenever the user asks to create, file, open, cut, or write an issue, ticket, task, story, or epic, or describes a feature or bug and asks to track it. Use it even when the user gives a one-line request.
---

# Create issue

Create one or more GitHub issues from a request. Interview the user, propose a breakdown into tasks, stories, and epics, confirm each issue, and create it.

## Ownership

The user owns the content of every issue. Every value in an issue comes from the user or from the conversation. When a value is absent, tell the user it is absent and ask for it. The user fills the gap, in every case.

## Issue types

| Type  | Label   | Describes                                         | Reference             |
| ----- | ------- | ------------------------------------------------- | --------------------- |
| Task  | `task`  | One unit of work with a defined result            | `references/task.md`  |
| Story | `story` | A problem or request from the user's perspective  | `references/story.md` |
| Epic  | `epic`  | A technical feature that groups stories and tasks | `references/epic.md`  |

Each reference file holds the title rule, the body template, and one example for its type. Read a reference file when the confirmed set contains an issue of its type.

## Readiness check

An issue is ready to create when every item is true for its type:

| Item                                                                        | Task     | Story                            | Epic     |
| --------------------------------------------------------------------------- | -------- | -------------------------------- | -------- |
| Every section in the template has content from the user or the conversation | required | required                         | required |
| Every acceptance criterion is verifiable                                    | required | required                         | required |
| No open question remains                                                    | required | permitted in `## Open questions` | required |
| Every blocker raised in the interview is resolved or recorded by the user   | required | required                         | required |

When an item is false, return to the interview and ask the user for what is missing.

## Procedure

1. Interview the user.

   - Read the request and the conversation. Record what the user wants, who it is for, and why.
   - Ask the user for every value that is absent. Ask the open values in one message when they are independent.
   - Identify each blocker: a decision, a dependency, or missing information that stops the work from starting. Raise each blocker with the user when found.
   - Give a recommendation about the content of an issue only when the user asks for one.

2. Propose the breakdown.

   - List each proposed issue as `<type>: <title>`, in creation order, with one sentence on why it has that type. An epic comes before the issues that link to it.
   - Ask the user to confirm the set or state changes. Repeat until the user confirms.

3. Fill each issue from its reference file. Return to step 1 for any value the template needs that the user has not given.

4. Apply the **Readiness check** to each issue.

5. Create the issues one at a time, with at least thirty seconds between one creation and the next. When the set holds more than ten issues, create the first ten, tell the user the rest are pending, and continue after the user confirms. GitHub flags accounts that create content in bursts, so pacing keeps the account in good standing. For each issue:

   a. Confirm the type label exists.

   ```sh
   gh label list --search <label>
   ```

   When the label is absent, run the `configure-repo` skill, then continue.

   b. Show the user the full title and body in a fenced block. Ask the user to confirm the content or state changes.

   c. Apply the changes and show the result again. Repeat until the user confirms.

   d. Create the issue.

   ```sh
   gh issue create --label <label> --title "<title>" --body "$(cat <<'BODY'
   <body>
   BODY
   )"
   ```

   e. When the issue has a `Part of #<epic>` line, add it to the epic's task list.

   ```sh
   gh issue view <epic> --json body --jq .body
   gh issue edit <epic> --body "$(cat <<'BODY'
   <epic body with the new line>
   BODY
   )"
   ```

   f. Report the issue URL to the user, then continue with the next issue.

6. Report the full list of created issues as `<type>: <title> <url>`, one per line.
