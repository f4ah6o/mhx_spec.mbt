# Add strict parser APIs for swap and sync

Created: 2026-05-05
Model: N/A

## Summary

Add strict parse APIs for swap and sync specs, while keeping the current permissive/defaulting behavior available through explicitly named helper APIs.

## Motivation

`mhx_spec.mbt` should be usable as a low-level spec parser and validator. In that role, silent fallback to defaults makes typos hard to detect in compilers, linters, fixtures, and editor integrations.

Current behavior is convenient for runtime usage, but strict parsing is needed for tooling and contract validation.

## Proposed API

```moonbit
pub fn parse_swap(input : String) -> SwapOptions!ParseError
pub fn parse_sync(input : String) -> SyncStrategy!ParseError
```

Keep permissive behavior under explicit names:

```moonbit
pub fn parse_swap_or_default(input : String) -> SwapOptions
pub fn parse_sync_or_default(input : String) -> SyncStrategy
```

## Expected behavior

Strict APIs should report errors for:

- unknown swap strategy
- unknown swap modifier
- malformed modifier syntax
- unknown sync strategy
- empty required values
- malformed duration values

Permissive APIs may continue to default unknown values, but the behavior should be documented.

## Acceptance criteria

- Strict swap parser exists and is covered by tests
- Strict sync parser exists and is covered by tests
- Existing permissive behavior remains available
- README documents strict vs permissive APIs
- No runtime-specific behavior is introduced into this package
