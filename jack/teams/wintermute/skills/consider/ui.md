# UI Considerations

Additional review concerns for Nuxt UI applications. These layer on top of the `audit` skill — run the audit first, then apply these.

The `audit` skill covers generic Nuxt UI fundamentals — components, TypeScript, state, styles, linting, testing, accessibility, performance. This file adds what's unique to zoobzio's UI architecture.

## Layer Architecture

Applications inherit from shared layers. The design system layer is the foundation — all templates, sites, and apps extend from it.

- Changes to a layer affect everything downstream. A component change in the design system layer propagates to every application that extends it.
- Templates inherit layers and add structural opinions. Sites and apps extend templates.
- Layer boundaries are real boundaries. A layer should not reach into internals of the layer it extends.
- Overriding a parent layer's component, composable, or configuration is intentional — verify the override is deliberate and not accidental shadowing.

## Design Token System

Styling uses a token-based system with CSS custom properties, not utility classes.

- Reference tokens define the raw palette — color scales, type scales, spacing values. These are theme-specific.
- System tokens map reference tokens to semantic meanings — surface, primary, on-surface, etc. These are what components consume.
- Components use system tokens via CSS custom properties. Hardcoded values bypass the token system and break theming.
- Token consistency matters more than individual correctness. A component using the right value from the wrong token level is a finding.

## Theming

Multiple themes exist with runtime switching.

- Every visual change must work across all themes. A color that looks correct in one theme may be invisible in another.
- Theme definitions are TypeScript objects exporting token values. A missing or mistyped token in a theme definition breaks that theme silently.
- Dark and light mode variants exist per theme. Both must be considered.

## Component Composition

Components wrap headless primitives with styled implementations.

- Headless primitives handle behavior (accessibility, keyboard, state). The wrapper handles styling and layout.
- Props are typed via separate type files that mirror component names. Missing or incomplete type definitions are findings.
- Component class prefixes follow a consistent convention. Deviations from the established prefix pattern are findings.
- Slot patterns (prepend, append, default) provide composition points. Components that accept children but don't expose appropriate slots limit consumer flexibility.

## Monorepo Boundaries

The workspace uses a monorepo with multiple project types — apps, sites, templates, layers, packages.

- Shared dependencies are managed via a workspace catalog. A package adding a dependency that already exists at a different version in the catalog is a finding.
- Each project type has a clear purpose. An app containing reusable components that belong in a layer, or a layer containing app-specific logic, is a structural defect.
- Cross-project imports must go through published package boundaries, not relative paths into sibling directories.

## API Integration

Frontend applications consume typed API clients generated from backend specifications.

- Types are generated from the backend's published schema. Hand-written types that duplicate or contradict generated types are findings.
- Client composables wrap the generated client. API calls should flow through these composables, not through raw fetch or ad-hoc clients.
- Type safety flows from schema to client to component. A break in the chain — an `any` cast, a manual type override, an untyped response — is a finding.

## Content Architecture

Content-driven sites use structured content with defined collections and frontmatter schemas.

- Content collections define the shape of content. Content files that violate their collection schema are findings.
- Frontmatter fields must match their declared types. Missing required fields or mistyped values are findings.
- Content sources (local, remote, GitHub) must be correctly configured. Broken source references fail silently at build time.

## Auto-Import Conventions

Nuxt auto-imports composables, components, and utilities.

- Auto-imported symbols should not be manually imported. Redundant imports create confusion about where a symbol originates.
- Custom composables in the composables directory are auto-imported. Composables placed elsewhere require explicit import and should justify their placement.
- Component auto-registration follows directory conventions. Components outside the expected directories are invisible to the auto-import system.
