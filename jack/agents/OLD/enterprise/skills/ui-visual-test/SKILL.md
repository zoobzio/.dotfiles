# Visual Test

Verify visual output using the Playwright MCP browser tools.

## Prerequisites

- Playwright MCP server must be configured
- Dev server must be running (`pnpm dev` or equivalent)

## Execution

1. Start or verify the dev server is running
2. Navigate to the page under test
3. Verify visual output
4. Check for console errors
5. Verify accessibility
6. Report findings

## Browser MCP Tools

### Navigation
```
browser_navigate → load a page by URL
browser_navigate_back → go back
```

### Reading the Page
```
browser_snapshot → accessibility tree (fast, structured, deterministic)
browser_take_screenshot → visual capture
browser_console_messages → runtime errors and warnings
browser_network_requests → API calls and responses
```

### Interaction
```
browser_click → click an element (by ref from snapshot)
browser_type → type text into an input
browser_fill_form → fill multiple form fields
browser_press_key → keyboard interaction
browser_hover → hover state verification
```

### Verification
```
browser_evaluate → run JavaScript on the page
browser_resize → test responsive behaviour
```

## What to Verify

### Visual Correctness
- Components render as expected
- Layout is correct (no overlapping, no overflow)
- Colours match design system tokens
- Typography is correct
- Spacing is consistent

### Accessibility
- Use `browser_snapshot` to read the accessibility tree
- Verify ARIA roles and labels are present
- Check tab order via keyboard navigation
- Verify focus indicators are visible

### Dark/Light Mode
- Navigate to the page
- Toggle theme mode
- Verify colours update correctly
- Check contrast in both modes

### Console Errors
- Use `browser_console_messages` to check for runtime errors
- Any error or warning is worth investigating
- Vue warnings about props, missing components, etc. are bugs

### Network
- Use `browser_network_requests` to verify API calls
- Check that expected requests are made
- Verify error handling for failed requests

## Reporting

When visual issues are found:

- **Token-level problems** (wrong colour, bad contrast) → report to Uhura
- **Component-level problems** (wrong rendering, broken layout) → report to Sulu
- **Data-level problems** (wrong data displayed, API errors) → report to Scotty
- **Configuration problems** (missing module, broken config) → report to Spock

Include the tool output (accessibility tree snapshot, screenshot description, console errors) in your report.
