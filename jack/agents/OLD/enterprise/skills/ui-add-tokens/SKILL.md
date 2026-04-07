# Add Tokens

Add or modify design tokens in the untheme package.

## Execution

1. Determine what tokens are needed and why
2. Decide the token tier (reference, system, or mode)
3. Add to the appropriate file
4. Verify mode mappings are complete

## Token Architecture

Tokens live in `packages/untheme/src/tokens/`:

```
tokens/
├── reference/
│   └── index.ts        — hard values (colours, fonts, spacing)
├── modes/
│   ├── light.ts        — light mode: system → reference mappings
│   └── dark.ts         — dark mode: system → reference mappings
└── index.ts            — exports
```

## Token Tiers

### Reference Tokens (`ref-*`)

Raw values. The palette.

```typescript
"ref-blue-600": "#2563eb",
"ref-font-sans": "'Inter', sans-serif",
"ref-spacing-md": "1rem",
```

Add reference tokens when you need a new colour, font, or spacing value that doesn't exist in the palette.

### System Tokens (`sys-*`)

Semantic meaning. What a value is used for.

```typescript
"sys-surface": "ref-slate-50",
"sys-primary": "ref-blue-600",
"sys-primary-hover": "ref-blue-700",
"sys-error": "ref-red-600",
```

Add system tokens when you need a new semantic concept (e.g., a new feedback state, a new surface variant).

### Mode Tokens

Light and dark mappings. Same system token name, different reference values.

```typescript
// light.ts
"sys-surface": "ref-slate-50",

// dark.ts
"sys-surface": "ref-slate-900",
```

**Every system token MUST have both light and dark mappings.** If you add a system token to light mode, add it to dark mode too.

## Rules

- Components consume `var(--sys-*)` tokens, never `var(--ref-*)` directly (unless intentionally bypassing the semantic layer)
- System tokens carry meaning — name them for their purpose, not their value (`sys-error` not `sys-red`)
- Reference tokens are the raw palette — name them for their value (`ref-blue-600`)
- Mode completeness is mandatory — every system token must appear in both light and dark
- Token changes cascade — modifying a system token affects every component that uses it. Verify impact.

## Verification

After adding tokens:
1. Verify both light and dark modes have the new system tokens
2. Check that the module generates the CSS custom properties correctly
3. If possible, use the browser MCP to verify rendering in both modes
