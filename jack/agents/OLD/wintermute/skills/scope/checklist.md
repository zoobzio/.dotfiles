# Scope Checklist

## Phase 1: Read Inputs

- [ ] Read `.claude/CRITERIA.md`
- [ ] Read recon output from all agents
- [ ] Confirm recon is complete before proceeding

## Phase 2: Determine Variant

- [ ] Identify repo type: Go API, Go Package, or Nuxt UI
- [ ] Confirm variant with evidence (go.mod, nuxt.config, package structure)
- [ ] Single variant per repo — no ambiguity

## Phase 3: Identify Review Categories

### Map Changes to Categories
- [ ] Determine which categories the changes touch
- [ ] Code category — source files modified or added
- [ ] Architecture category — structural changes, new packages, interface changes
- [ ] Tests category — test files modified or added
- [ ] Coverage category — code changed without corresponding test changes
- [ ] Documentation category — docs, README, or godoc changes

### Assign Ownership
- [ ] Each category has a primary reviewer (Case or Molly)
- [ ] Each category has a cross-validator (the other)
- [ ] Assignments follow standing orders

### Apply Priority
- [ ] Priority for each category derived from CRITERIA.md
- [ ] Higher-priority categories ordered first on the board

## Phase 4: Add Variant Task

- [ ] Go API — add API Review task (consider/api)
- [ ] Go Package — add Package Review task (consider/pkg)
- [ ] Nuxt UI — add UI Audit task (audit) and UI Considerations task (consider/ui)

## Phase 5: Add Filtration Task

- [ ] Filtration task added as final board item
- [ ] Case and Molly assigned as owners
- [ ] Blocked until Riviera's security report is received

## Phase 6: Create Task Board

- [ ] All tasks created with category, priority, owner, and validator
- [ ] Task order reflects priority
- [ ] Variant task included
- [ ] Filtration task included as final item
- [ ] Scoping notes added where context is needed
- [ ] Board is ready for briefing delivery
