# Add htmx compatibility fixture set

Created: 2026-05-05
Model: N/A

## Summary

Add a fixture set that documents the htmx-compatible subset supported by `mhx_spec.mbt`.

## Motivation

The README positions this package as parsing hypermedia attributes similar to htmx. To make that relationship useful and safe, the repository should explicitly document which examples are compatible, which are intentionally unsupported, and which are mhx-specific extensions.

## Proposed fixture groups

```text
fixtures/compat/htmx/
  trigger-compatible/
  swap-compatible/
  sync-compatible/
  unsupported/
  mhx-extensions/
```

## Suggested coverage

- common `hx-trigger` examples
- common `hx-swap` examples
- common `hx-sync` examples
- unsupported examples with diagnostics
- mhx-specific additions or intentional differences

## Documentation requirements

The README should clearly state:

- this package is htmx-like, not a full htmx implementation
- compatibility is fixture-backed
- unsupported syntax should be explicit rather than silently accepted
- mhx extensions should be documented separately from compatibility behavior

## Acceptance criteria

- htmx compatibility fixture directory is added
- compatible examples pass parser and canonicalization tests
- unsupported examples produce deterministic diagnostics
- README documents compatibility policy
- No browser/runtime behavior is introduced into this package
