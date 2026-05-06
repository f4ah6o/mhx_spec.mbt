# Add semantic validation pass for cross-attribute conflicts

Created: 2026-05-05
Model: N/A

## Summary

Add semantic validation APIs separate from syntax parsing.

## Motivation

A spec can be syntactically valid but semantically questionable or conflicting. Keeping semantic validation separate from parsing allows the parser to remain focused while enabling stricter tooling modes.

## Proposed APIs

```moonbit
pub fn validate_trigger(trigger : TriggerDef) -> Array[Diagnostic]
pub fn validate_swap(options : SwapOptions) -> Array[Diagnostic]
pub fn validate_sync(sync : SyncStrategy) -> Array[Diagnostic]
pub fn validate_attributes(attrs : MhxAttributes) -> Array[Diagnostic]
```

## Example validation cases

- duplicate modifiers on a trigger
- conflicting trigger queue and sync strategy
- multiple request method attributes on the same element
- `swap:none` combined with scroll/show/settle options
- `delete` strategy combined with options that do not apply
- empty request URL
- invalid target selector in strict mode

## Non-goals

- DOM execution behavior
- runtime request scheduling
- browser compatibility simulation

## Acceptance criteria

- Validation APIs are added
- Syntax parsing and semantic validation remain separate
- Validation returns structured diagnostics
- Tests cover common conflict cases
- README documents parser vs validator responsibilities
