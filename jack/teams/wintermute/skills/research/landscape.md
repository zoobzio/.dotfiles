# Landscape

What do other people do for this.

## Research

- **Community packages** — Search GitHub, pkg.go.dev, and documentation for established packages that solve the same problem. Look at stars, dependents, maintenance activity, and approach. Multiple well-maintained options means this is a solved problem. Zero options means it isn't.
- **Common patterns** — Is the approach in the PR a common pattern in the broader ecosystem, or is it novel? If everybody else does it one way and zoobzio does it another, that's not automatically wrong — but it's worth knowing and worth explaining to Case.
- **Standards and conventions** — Are there RFCs, Go proposals, or community guidelines that cover this domain? If the PR implements something that has an established standard, does it follow the standard or diverge?
- **Trade-off landscape** — If multiple approaches exist, what are the trade-offs between them? Performance vs simplicity, flexibility vs safety, standard library vs external dependency. Map the decision space so Case can evaluate the PR's choice in context.

## Report Format

Report back to Case with what the landscape looks like. What packages exist, how they approach the problem, how the PR compares. If the PR's approach is common, say so. If it's unusual, explain what's different and what the alternatives look like. Case decides whether different is wrong. The research just makes sure he decides with context.
