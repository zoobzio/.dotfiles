# Dependency Security

Every external package is someone else's code running with your privileges.

## What to Find

- Known vulnerabilities via `govulncheck`
- Supply chain concerns (typosquatting, abandoned packages)
- Transitive dependency risk
- Dependency freshness and maintenance status

## How to Look

`govulncheck ./...` finds what is catalogued. Necessary, but the interesting vulnerabilities are never in a database.

Check dependency age, maintenance status, ownership changes. An abandoned package with known issues that will never be patched is a risk. A recently-transferred package is a supply chain concern.
