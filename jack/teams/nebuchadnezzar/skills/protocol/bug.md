# Bug

When Mouse or Trinity discovers a defect during testing.

## Discovery

A bug is a test that fails because the code is wrong — not because the test is wrong. Before creating a bug task, determine which it is:

| Symptom | Likely Cause | Action |
|---------|-------------|--------|
| Test expects behaviour the spec does not guarantee | Test is wrong | Fix the test, message Cypher if the spec is ambiguous |
| Test expects specified behaviour, code does not deliver | Code is wrong | Create a bug task |
| Integration test fails but unit tests pass | Boundary defect | Create a bug task, note the seam |
| Unit test fails | Component defect | Create a bug task, note the function |

## Creating the Bug Task

Create a task with type `bug`:

```
bug: [brief description of the defect]
```

The task description must include:

- **What was tested** — the function, boundary, or scenario
- **What was expected** — the behaviour the spec or contract requires
- **What happened instead** — the actual behaviour observed
- **Where it lives** — file, function, line if known

Precise reports get precise fixes. Ambiguous reports get follow-up questions.

## Routing

After creating the bug task:

1. Set the bug task to block the test task that revealed it
2. Message the responsible builder (Switch or Apoc — whoever built the component)
3. If it is unclear who built it, message both — one of them will claim it
4. If the defect appears architectural (the code matches the spec but the spec is wrong), escalate to Cypher — he determines whether it needs to cross to Neo

## Resolution

The builder claims the bug task, fixes the defect, and marks it complete. The tester's blocked test task unblocks. The tester re-runs and either passes or discovers the fix was incomplete.

If the fix is incomplete, create a new bug task. Do not reopen the old one.

## Boundary Bugs

When Trinity finds a defect at the boundary — integration test fails but unit tests pass — the defect lives at the seam. These are the most important class of bug because they prove the components work alone but not together.

For boundary bugs, Trinity messages Neo in addition to the builder. Neo needs to know because a boundary defect may indicate an architectural assumption that is wrong, not just an implementation mistake.
