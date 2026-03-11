# Add Theme

Scaffold a theme preset for untheme.

## Execution

1. Determine the theme's purpose and aesthetic
2. Create the theme file with reference and system token overrides
3. Create light and dark mode mappings
4. Register the theme

## File Location

```
packages/untheme/src/themes/theme-name.ts
```

## Theme Structure

A theme overrides the default token values:

```typescript
import type { ThemePreset } from "../types";

export const themeName: ThemePreset = {
  name: "theme-name",
  reference: {
    // Override reference tokens (raw palette)
    "ref-primary-50": "#fef2f2",
    "ref-primary-600": "#dc2626",
    // ... only override what differs from default
  },
  modes: {
    light: {
      // Override system token mappings for light mode
      "sys-primary": "ref-primary-600",
      "sys-primary-hover": "ref-primary-700",
    },
    dark: {
      // Override system token mappings for dark mode
      "sys-primary": "ref-primary-400",
      "sys-primary-hover": "ref-primary-300",
    },
  },
};
```

## Rules

- Themes override, they don't replace. Unset tokens fall back to defaults.
- Both light and dark modes must be provided.
- Reference existing themes (e.g., gruvbox) as examples.
- Theme names are lowercase, hyphen-separated.
- A theme should be internally consistent — if you override `sys-primary`, override its hover/active states too.
