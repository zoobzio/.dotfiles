---
name: triage
description: Evaluate a new issue — understand what is being asked, consult Dixie for context, accept or RFI. You do not build what you do not understand.
allowed-tools: Read, Grep, Glob, Bash
---

# Triage

A new issue. Before you build anything, you need to know exactly what you are building, how it should work, and why it needs to exist. If the ticket does not give you that, you do not accept it — you ask.

**Argument:** `$ARGUMENTS` — issue number.

## Checklist

- [ ] Read the issue
- [ ] Read the code it touches
- [ ] Consult Dixie
- [ ] Decide: accept or RFI

## Read

```bash
gh issue view $0 --json number,title,body,labels,comments,assignees
```

Understand what is being asked:

| Question | Clear? |
|----------|--------|
| What needs to change? | |
| Why does it need to change? | |
| How should it work when done? | |
| What are the acceptance criteria? | |
| What code does this touch? | |

If every question has a clear answer from the ticket, skip to **Decide**.

## Code

Read the code the issue touches. Trace the boundaries — what calls in, what calls out, what tests cover it.

```bash
# Use Grep, Glob, Read to find and trace affected code
```

Run `/grok` if the issue involves ecosystem packages you do not fully understand.

## Consult Dixie

DM Dixie to discuss the issue and your understanding of the approach:

```bash
jack msg dm send <dixie-username> "<repo> | triaging #$0 — <your summary of the issue and what you think needs to happen>" --check --check-timeout 120
jack msg dm read <dixie-username> --limit 5
```

Dixie knows the repo history, the patterns, and the ecosystem. If the issue touches cross-repo dependencies, Dixie routes through the construct network.

> **Tip:** tell Dixie what you think the approach is, not just what the issue says. His job is to tell you if you are wrong before you start building.

## Decide

| Condition | Action |
|-----------|--------|
| You know what to build, how it works, and why | **Accept** |
| The ticket is missing information you need | **RFI** |
| The issue is unclear, contradictory, or underspecified | **RFI** |

### Accept

```bash
gh issue edit $0 --add-label accepted
gh issue edit $0 --add-assignee @me
jack msg repo post <repo> "building:#$0 — <issue title>"
```

Proceed to `/build $0`.

### RFI

Post your questions directly on the issue. Be specific — state what you know, what you do not know, and what you need answered before you can build.

```bash
gh issue comment $0 --body "$(cat <<'EOF'
## RFI

<What you understand about the issue>

**Questions:**
- <Specific question 1>
- <Specific question 2>

Labeling `rfi` — will pick this up once the above is clarified.
EOF
)"
gh issue edit $0 --add-label rfi
```

Return to the loop. The issue will come back through when someone answers.

> **Tip:** a good RFI makes it easy for the author to unblock you. State what you know so they can see where the gap is.

> **Tip:** do not accept an issue you have questions about. An accepted issue is a commitment to deliver. Do not commit to delivering something you do not understand.
