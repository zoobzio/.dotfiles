# Learn

Write the learn section — overview, quickstart, concepts, architecture. These are the entry points for new consumers.

## Philosophy

The learn section answers "should I use this?" and "how do I start?" Progressive disclosure: overview for the 60-second decision, quickstart for the first working code, concepts for the mental model, architecture for the internals. Each doc has a distinct reader goal — don't blur them.

## Execution

1. Read the package source thoroughly
2. Determine which learn docs are needed
3. Write each doc per specifications
4. Verify frontmatter, cross-references, and examples

## Specifications

### Directory Structure

```
docs/
└── 1.learn/
    ├── 1.overview.md
    ├── 2.quickstart.md
    ├── 3.concepts.md
    └── 4.architecture.md
```

### Overview (`1.overview.md`)

**Reader goal:** "Is this for me?"

| Section | Content |
|---------|---------|
| Opening paragraph | What it is + core value proposition |
| The Idea | The problem this package addresses — not "The Problem / The Solution", but the insight that motivated it |
| What It Enables | Core capabilities, brief |
| Next Steps | Links to quickstart, concepts |

The overview is the README's deeper sibling. The README sells in 60 seconds. The overview explains in 5 minutes.

**Tone:** Confident, direct. "Capitan offers a third path." Not "Capitan is a library that provides..."

### Quickstart (`2.quickstart.md`)

**Reader goal:** "How do I get this working?"

| Section | Content |
|---------|---------|
| Prerequisites | Go version, dependencies |
| Installation | `go get` command |
| First example | Complete, runnable, produces visible output |
| What Just Happened | Brief breakdown of the example |
| Next Steps | Links to concepts, first guide |

**Target:** Zero to working code in under 5 minutes. No configuration, no setup beyond `go get`. The example must compile and produce output the reader can verify.

### Concepts (`3.concepts.md`)

**Reader goal:** "How should I think about this?"

| Section | Content |
|---------|---------|
| Mental model | The core abstraction explained — what it is, not how it works |
| Terminology | Named patterns and their meaning (Processor, Connector, Synapse, Signal) |
| Relationships | How the concepts relate to each other |
| Decision guidance | When to use what — tables, decision trees |
| Next Steps | Links to architecture, guides |

This is where pattern names are established. "Chainable[T] is the foundation of pipz." "A Synapse is a specialized, typed LLM interaction." Give the reader vocabulary.

**Decision guidance example:**

```markdown
| If you need to... | Use... | Can fail? | Example |
|---|---|---|---|
| Transform data | Transform | No | Uppercase a string |
| Transform with errors | Apply | Yes | Parse JSON |
| Side effect only | Effect | No | Log a value |
```

### Architecture (`4.architecture.md`)

**Reader goal:** "How does it work under the hood?"

| Section | Content |
|---------|---------|
| System overview | ASCII diagram showing components and flow |
| Component responsibilities | What each component does |
| Data flow | How data moves through the system |
| Design rationale | Why it's built this way — Q&A format works well |
| Next Steps | Links to guides, reference |

**ASCII diagrams:**

```
Signal → Capitan → [Worker Pool] → Listener Channels
                 → [Observer]   → Observer Channels
```

Keep diagrams focused on one flow each. Multiple simple diagrams over one complex one.

**Design rationale as Q&A:**

```markdown
**Why functional options instead of a config struct?**
Options compose. A config struct forces all-or-nothing...

**Why separate testing modules?**
Dependency isolation. Testing helpers may import...
```

## Anti-Patterns

| Anti-pattern | Approach |
|-------------|----------|
| Overview that's a feature list | Lead with the insight, not the features |
| Quickstart that requires configuration | Zero config to first result |
| Concepts that explain implementation | Mental models, not internals |
| Architecture without rationale | Always explain why, not just what |
| Blurred doc purposes | Each doc answers one reader question |

## Checklist

- [ ] Overview answers "is this for me?" in 5 minutes
- [ ] Quickstart gets to working code in under 5 minutes
- [ ] Concepts establishes vocabulary and mental models
- [ ] Architecture explains the internals with diagrams and rationale
- [ ] Each doc has a distinct reader goal — no blurring
- [ ] Examples are complete and compile against current API
- [ ] All frontmatter present (see `frontmatter.md`)
- [ ] Cross-references use numbered paths
- [ ] Next Steps in each doc link to the logical next read
