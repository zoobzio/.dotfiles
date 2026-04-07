# Add Godoc Checklist

## Phase 1: Inventory Exported Symbols

- [ ] Read the source file thoroughly
- [ ] List all exported types (structs, interfaces, aliases)
- [ ] List all exported functions
- [ ] List all exported methods (grouped by type)
- [ ] List all exported constants and constant groups
- [ ] List all exported variables and sentinel errors
- [ ] Check for existing package comment

## Phase 2: Assess Existing Documentation

- [ ] Identify exported symbols missing godoc comments
- [ ] Identify parrot comments (restate signature without adding value)
- [ ] Identify stale comments (don't match current behaviour)
- [ ] Identify comments missing error condition documentation
- [ ] Identify comments missing concurrency safety notes
- [ ] Note unexported symbols with non-obvious logic

## Phase 3: Write Package Comment

- [ ] Package comment present (primary file or `doc.go`)
- [ ] First sentence: what the package provides
- [ ] Key concepts or types mentioned
- [ ] Usage context clear (when to import this package)
- [ ] Starts with `// Package <name>`

## Phase 4: Write Symbol Comments

### For Each Exported Type
- [ ] Comment starts with type name
- [ ] Purpose and usage explained
- [ ] Construction method referenced (how to create one)
- [ ] Zero-value behaviour documented if relevant
- [ ] Concurrency safety stated if relevant
- [ ] Non-obvious fields documented

### For Each Exported Function/Method
- [ ] Comment starts with function/method name
- [ ] What it does (first sentence)
- [ ] Return value meaning documented
- [ ] Error conditions documented (when, what kind)
- [ ] Side effects noted if any
- [ ] Nil behaviour documented if relevant
- [ ] Concurrency safety stated if relevant

### For Each Sentinel Error
- [ ] When the error is returned
- [ ] How callers should check for it (`errors.Is`)
- [ ] Related errors or conditions noted

### For Each Constant Group
- [ ] Group comment explains the category
- [ ] Individual constants documented when non-obvious

## Phase 5: Quality Check

### Convention Compliance
- [ ] Every comment starts with the symbol name
- [ ] No Javadoc-style annotations (`@param`, `@return`)
- [ ] No parrot comments (restating the signature)
- [ ] No implementation details (behaviour only)
- [ ] No empty or placeholder comments

### Completeness
- [ ] Every exported symbol has a godoc comment
- [ ] Error-returning functions document their error conditions
- [ ] Concurrent types document their safety guarantees
- [ ] Deprecated symbols use `Deprecated:` convention

## Phase 6: Verify

- [ ] `go doc .` produces clean package summary
- [ ] `go doc -all .` shows complete, readable documentation
- [ ] Documentation reads well for a consumer unfamiliar with the source
- [ ] No build errors introduced by comment changes
