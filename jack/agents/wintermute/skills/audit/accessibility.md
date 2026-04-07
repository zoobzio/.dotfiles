# Accessibility Review

ARIA compliance, keyboard navigation, and screen reader support.

## What to Find

### Semantic HTML
- `div` and `span` used where semantic elements exist (nav, main, article, section, button)
- Missing heading hierarchy (skipped levels, multiple h1)
- Interactive elements without appropriate roles
- Images without alt text

### Keyboard Navigation
- Interactive elements not focusable
- Focus traps in modals/dialogs not implemented
- Focus not returned after modal close
- Tab order not logical
- Custom components missing keyboard event handlers

### ARIA
- Missing `aria-label` on icon-only buttons
- Missing `aria-live` regions for dynamic content
- `aria-hidden` misused — hiding content that should be accessible
- Form inputs without associated labels

### Color & Contrast
- Insufficient contrast ratios (WCAG AA minimum)
- Information conveyed by color alone without alternative indicators
- Focus indicators removed or invisible
