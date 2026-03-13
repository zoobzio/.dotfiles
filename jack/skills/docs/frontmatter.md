# Frontmatter

Site conventions for documentation structure — numbering, cross-references, metadata, and directory organisation. These rules apply to all docs/ files across all packages.

## Philosophy

Documentation is built into a site. Consistent structure, metadata, and cross-references make the site navigable and the docs discoverable. These conventions are mechanical — follow them exactly.

## Specifications

### Directory Naming

All directories use numeric prefixes for ordering:

```
docs/
├── 1.learn/
├── 2.guides/
├── 3.integrations/    (when applicable)
├── 4.cookbook/
└── 5.reference/
```

Not all packages need all directories. Use what's warranted. Numbering adjusts accordingly — no gaps:

```
docs/
├── 1.learn/
├── 2.guides/
├── 3.cookbook/         (no integrations — cookbook becomes 3)
└── 4.reference/
```

### File Naming

Format: `[number].[name].md`

```
1.learn/
├── 1.overview.md
├── 2.quickstart.md
├── 3.concepts.md
└── 4.architecture.md
```

- Numbers control order and MUST be sequential with no gaps
- Names describe content in lowercase, hyphenated
- Single-file directories may use a top-level file instead: `1.overview.md` at the docs root

### Required Frontmatter

Every documentation file MUST have this frontmatter:

```yaml
---
title: Article Title
description: One-line description of what this page covers
author: zoobzio
published: YYYY-MM-DD
updated: YYYY-MM-DD
tags:
  - PrimaryCategory
  - SecondaryCategory
---
```

| Field | Requirements |
|-------|-------------|
| `title` | Human-readable page title |
| `description` | One sentence — used for SEO and link previews |
| `author` | Always `zoobzio` |
| `published` | Date first published |
| `updated` | Date last updated — MUST reflect actual content changes |
| `tags` | At least one tag; primary category first |

Optional fields:

| Field | When to include |
|-------|----------------|
| `readtime` | Learn section — helps reader estimate commitment (`5 mins`) |

### Cross-References

All internal links MUST use full numbered paths:

```markdown
<!-- Correct -->
[Quickstart](../1.learn/2.quickstart.md)
[Configuration Guide](../2.guides/1.configuration.md)

<!-- Wrong -->
[Quickstart](../learn/quickstart.md)
[Configuration Guide](../guides/configuration.md)
```

### Next Steps

Every doc ends with links to the logical next read:

```markdown
## Next Steps

- [Concepts](3.concepts.md) — Mental models and terminology
- [Configuration Guide](../2.guides/1.configuration.md) — Tuning options
```

Next Steps links should be contextual — what would this reader want after finishing this page?

### GitHub-Flavoured Markdown

Docs are built with full GFM support. Use freely:

- Tables
- Task lists (`- [ ]`)
- Footnotes
- Alerts (`> [!NOTE]`, `> [!WARNING]`, `> [!TIP]`)
- Fenced code blocks with language identifiers
- Heading anchors for deep linking

### Tone

- Clear, direct, technical but accessible
- Focus on usage and practical examples
- Explain the "why" alongside the "how"
- No first person ("I", "we") in documentation prose
- Confident statements: "Capitan offers..." not "Capitan is a library that provides..."

## Checklist

- [ ] All directories use numeric prefixes
- [ ] All files use `[number].[name].md` format
- [ ] Sequential numbering with no gaps in each directory
- [ ] Every file has complete frontmatter with all required fields
- [ ] `updated` field reflects actual content change date
- [ ] Cross-references use full numbered paths
- [ ] Every doc ends with contextual Next Steps
- [ ] GFM features used appropriately
- [ ] Tone is consistent — direct, technical, accessible
