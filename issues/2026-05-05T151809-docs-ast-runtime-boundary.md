# Document AST and runtime boundary for mhx_spec

Created: 2026-05-05
Model: N/A

## Summary

Document and preserve the boundary between parsed mhx specs and runtime execution behavior.

## Motivation

`mhx_spec.mbt` is most valuable as a low-level, reusable source of truth for mhx attribute syntax and typed representations. It should not grow into a DOM runtime, request scheduler, or renderer-specific package.

Clear boundaries make it easier for other packages such as runtime, HTML builders, documentation systems, compilers, and linters to depend on this package safely.

## Proposed boundary

This package may own:

- attribute grammar
- parser APIs
- typed AST/spec data structures
- canonical serialization
- diagnostics
- semantic validation
- compatibility fixtures

This package should not own:

- DOM execution
- fetch behavior
- browser event listener lifecycle
- request scheduling implementation
- renderer-specific integration
- tmpx/papyr/mhx runtime coupling

## Suggested doc section

Add a section such as:

```markdown
## Package boundary

`mhx_spec` defines and validates mhx attribute specifications. It does not execute them.
Runtime packages consume the parsed spec and map it to concrete browser or server behavior.
```

## Acceptance criteria

- README documents the package boundary
- Public API naming reflects spec/AST responsibilities
- Runtime behavior is not introduced into this package
- Future issues can refer to this boundary when evaluating scope
