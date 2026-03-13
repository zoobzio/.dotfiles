# Manage Checklist

## Phase 1: Disposition Incoming Finding

For each finding received from Case or Molly:

- [ ] Read manage/disposition.md
- [ ] Evaluate finding against CRITERIA.md

### Classify Disposition
- [ ] Comment — inline feedback, post immediately
- [ ] Summary — broad observation or pre-existing problem, record for final summary
- [ ] Noted — valid but not worth a comment, record for final summary
- [ ] Dismissed — does not meet CRITERIA.md threshold, dropped

### Filtration Findings
- [ ] Confirmed findings from filtration — treat as normal findings
- [ ] Plausible findings from filtration — valid but lower confidence, disposition accordingly
- [ ] Dismissed batch from filtration — recorded for awareness only

## Phase 2: Post Inline Comment

For each finding dispositioned as Comment:

- [ ] Read manage/comment.md
- [ ] Verify file path exists in PR diff
- [ ] Verify line number is within diff range
- [ ] If path or line fails verification, demote to summary item

### Compose Comment Body
- [ ] Describe what the issue is
- [ ] Explain why it matters
- [ ] State what to do about it
- [ ] No finding IDs, no severity labels, no internal terminology
- [ ] Reads as a single reviewer's feedback

### WINTERMUTE Check
- [ ] Scan body against WINTERMUTE prohibited terms list
- [ ] No agent names, crew roles, or character voice
- [ ] No internal process references
- [ ] Professional, factual, documentation-grade tone

### Post
- [ ] Post as inline PR comment at correct file and line
- [ ] Confirm comment posted successfully

## Phase 3: Write Summary and Submit Verdict

- [ ] Read manage/summarize.md
- [ ] All inline comments have been posted throughout the review
- [ ] All board tasks marked complete
- [ ] Filtration complete

### Compose Summary Body
- [ ] Opening sentence — what was reviewed and scope of changes
- [ ] Findings section — count of inline comments posted, by category
- [ ] Observations section — summary-level findings not attached to lines (omit if none)
- [ ] Assessment section — overall assessment, one paragraph
- [ ] Clean review template used if no findings exist

### WINTERMUTE Check
- [ ] Scan summary against WINTERMUTE prohibited terms list
- [ ] No internal references
- [ ] Professional tone throughout

### Determine Verdict
- [ ] APPROVE — no High or Critical comments posted
- [ ] REQUEST_CHANGES — one or more High or Critical comments posted

### Submit
- [ ] Submit PR review with verdict and summary body
- [ ] Confirm submission posted successfully
- [ ] If APPROVE — proceed to Sleep
- [ ] If REQUEST_CHANGES — proceed to Watch
