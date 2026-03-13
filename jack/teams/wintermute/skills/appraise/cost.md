# Cost

What this dependency actually brings with it.

## Assessment

- **Transitive dependencies** — What does this package pull in? One direct dependency with forty transitive deps is forty-one suppliers. List the full tree.
- **Weight** — Total added modules. A lightweight package that imports half of the Go ecosystem is not lightweight.
- **License** — MIT, Apache, BSD are straightforward. Copyleft (GPL, AGPL) has implications for distribution. Unusual licenses need legal review.
- **License consistency** — Do transitive dependencies carry compatible licenses? A MIT project with an AGPL transitive dep has a problem.
- **Build impact** — Does this dependency increase build time, binary size, or compilation complexity meaningfully?

## Finding Format

```markdown
### SUP-###: [Title]

**Dependency:** [module path]
**Concern:** [Transitive weight | License risk | Build impact]
**Evidence:** [Dependency tree, license list, size data]
**Recommendation:** [Accept | Reduce scope | Find lighter alternative]
```
