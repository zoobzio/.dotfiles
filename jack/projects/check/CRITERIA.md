# Review Criteria

Secret, repo-specific review criteria. Only Armitage reads this file.

## Mission Criteria

### What This Repo MUST Achieve

- All 160+ validators produce correct results for valid and invalid inputs
- Fluent builders chain correctly and produce *Validation via .V()
- All() collects every error; First() stops at the first
- Check[T]() detects all fields with `validate` tags that were not validated
- Result provides accurate field→validator mapping via Applied()
- FieldError, Errors, and UncheckedFieldError implement standard error interface
- Zero reflection on the validation hot path — sentinel only in Check[T]()

### What This Repo MUST NOT Contain

- Reflection-based auto-validation from struct tags
- Validation logic that touches sentinel outside of Check[T]()
- Validators that silently pass on invalid input
- Error types that don't implement standard error interface

## Review Priorities

1. Validator correctness: every validator must correctly accept valid input and reject invalid input
2. Format validators: email, URL, UUID, IP, etc. must handle edge cases (not just simple regex)
3. Check[T] completeness: must catch every field with a validate tag that was not validated
4. Builder chain safety: fluent chains must not panic on any combination
5. Error structure: FieldError must carry field name and message for API consumers
6. Optional variants: OptStr, OptNum, etc. must correctly skip nil pointers

## Severity Calibration

| Condition | Severity |
|-----------|----------|
| Validator accepts invalid input (false negative) | Critical |
| Validator rejects valid input (false positive) | High |
| Check[T] misses unvalidated tagged field | High |
| Reflection on hot path (not in Check[T]) | High |
| Builder chain panics | High |
| FieldError missing field name | Medium |
| UncheckedFieldError missing field context | Medium |
| Missing test for a built-in validator | Medium |
| Optional variant doesn't skip nil | Medium |
| Error message not actionable | Low |

## Standing Concerns

- Format validators (email, URL, credit card, etc.) have complex edge cases — verify against RFC specs where applicable
- Check[T] field matching uses json tag or lowercase name — verify both paths work
- validate:"-" must explicitly skip — verify it's not treated as a required field
- Numeric constraint generics span many types — verify no overflow in comparisons
- Slice validators with Each/AllSatisfy compose with other validators — verify composition works

## Out of Scope

- No auto-validation from tags is intentional — explicit validation is the design philosophy
- sentinel dependency is only for Check[T] — not used in hot path
- golang.org/x/exp dependency for constraints is intentional
- No error message localization — structured FieldErrors are language-agnostic
