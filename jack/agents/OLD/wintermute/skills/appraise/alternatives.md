# Alternatives

Is this the only option, and if not, why this one.

## Assessment

- **Competing packages** — What else solves this problem? List alternatives with comparable feature sets.
- **Single-supplier risk** — If this is the only package that does this, the project has no fallback. That is a supply chain risk regardless of the package's quality.
- **Comparison** — If alternatives exist, how do they compare on the other supply chain dimensions (provenance, adoption, history)? Is the chosen package the strongest supplier, or was it picked by convenience?
- **Standard library** — Could this be done with stdlib? A dependency that replaces something the standard library provides needs a strong justification for the added supplier.
- **Internal ecosystem** — Does zoobzio already have a package that covers this? Check the workspace and existing modules before assessing external alternatives.

## Finding Format

```markdown
### SUP-###: [Title]

**Dependency:** [module path]
**Concern:** [Single supplier | Stronger alternative exists | stdlib replacement available]
**Evidence:** [Alternative packages, comparison data]
**Recommendation:** [Accept | Replace with X | Implement internally]
```
