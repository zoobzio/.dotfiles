# Lint Review

ESLint, Prettier, and Vue-specific linting compliance.

## What to Find

### ESLint
- Run `npx eslint .` — record findings
- Disabled rules without justification (`// eslint-disable`)
- Missing Vue-specific plugin rules (`eslint-plugin-vue`)
- TypeScript-specific rules not enabled (`@typescript-eslint`)
- Inconsistent rule configuration across the project

### Prettier
- Run `npx prettier --check .` — record formatting violations
- Prettier and ESLint conflicts (missing `eslint-config-prettier`)
- Files excluded from formatting that shouldn't be

### Vue-Specific
- `vue/multi-word-component-names` violations
- `vue/no-unused-vars` in templates
- `vue/require-default-prop` missing defaults
- `vue/no-mutating-props` violations
- `vue/component-name-in-template-casing` inconsistencies
