# Style Review

CSS/styling patterns, scoping, and consistency.

## What to Find

### Scoping
- Missing `scoped` attribute on component styles — global leakage
- Deep selectors (`:deep()`) overused — sign of component boundary problems
- Global styles that should be scoped to components
- Style conflicts between components from unscoped rules

### Consistency
- Mixed styling approaches (Tailwind + custom CSS + inline styles)
- Inconsistent spacing/sizing values — should use design tokens or CSS variables
- Color values hardcoded instead of using theme variables
- Breakpoints defined ad hoc instead of using shared constants

### Quality
- Unused CSS selectors — dead styles
- Overly specific selectors that resist override
- `!important` usage — each instance is suspect
- Missing responsive design for key layouts
