---
name: evaluate
description: Core review workflow — recon a PR, scope against CRITERIA.md, assess domains in parallel, submit structured GitHub review with inline comments and verdict.
argument-hint: "[PR number or URL]"
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# Evaluate

A PR exists that has not been fully assessed. That changes now. The code goes in, a verdict comes out, and everything between is systematic.

Target PR: $ARGUMENTS

Read the relevant sub-file based on what the PR needs.

| File | Purpose | When |
|------|---------|------|
| initial.md | First review of a PR — recon, scope, parallel assessment, submit | A PR that has not been reviewed |
| re-review.md | Follow-up review after author response — classify, verify, assess delta, submit | A PR labeled `re-review` |
