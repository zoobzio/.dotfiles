# Adoption

How many people trust this with their production traffic.

## Assessment

- **Dependents** — How many packages import this? Check `pkg.go.dev` importers, not GitHub stars. Stars are vanity. Imports are commitment.
- **Production signals** — Is this used by known projects, companies, or infrastructure? A package used by Kubernetes carries different weight than one used by three tutorials.
- **Download trends** — Growing, stable, or declining? A declining trend on a package you're about to adopt is a warning.
- **Community** — Active issues, discussions, Stack Overflow presence. A package with zero community activity either works perfectly or nobody uses it. Determine which.

## Finding Format

```markdown
### SUP-###: [Title]

**Dependency:** [module path]
**Concern:** [What the adoption signal indicates]
**Evidence:** [Dependent count, notable users, trend data]
**Recommendation:** [Accept risk | Find alternative | Monitor]
```
