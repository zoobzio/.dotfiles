# TypeScript Review

Type safety, type coverage, and avoidance of type escape hatches.

## What to Find

### Type Safety
- `any` usage — every instance is a finding unless explicitly justified
- Type assertions (`as`) that bypass the type system — each is suspect
- `@ts-ignore` or `@ts-expect-error` without explanation
- Implicit `any` from untyped imports or missing declarations
- Non-null assertions (`!`) that mask potential runtime errors

### Type Coverage
- Untyped function parameters or return values
- Missing interface definitions for API responses
- Props without TypeScript type definitions
- Event handlers without typed payloads
- Composable return types not explicitly declared

### Type Design
- Overly broad union types that lose specificity
- Enums vs const objects vs literal unions — inconsistent choices
- Utility types not used where applicable (Partial, Pick, Omit, Record)
- Duplicated type definitions that should share a base
