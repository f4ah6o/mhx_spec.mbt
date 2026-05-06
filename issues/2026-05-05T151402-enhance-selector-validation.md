# Add selector validation mode for empty and malformed selectors

Created: 2026-05-05
Model: N/A

## Summary

Add selector validation modes to detect empty or malformed selector values without turning this package into a full CSS parser.

## Motivation

Selectors are currently parsed into typed variants such as `This`, `Body`, `Window`, `Document`, `Closest`, `Find`, `Next`, `Previous`, and `Css`. Treating unknown values as CSS selectors is useful, but empty values or incomplete extended selectors should be detectable in strict tooling contexts.

## Proposed API

```moonbit
pub enum SelectorValidation {
  None
  NonEmpty
  KnownExtendedSelector
}
```

Potential validation entry point:

```moonbit
pub fn validate_selector(selector : Selector, mode : SelectorValidation) -> Array[Diagnostic]
```

## Examples

Should report diagnostics in strict mode:

```text
from:
target:
from:closest
from:find
from:next
from:previous
```

Should pass:

```text
from:body
target:#result
from:closest .item
from:find .child
from:next .row
from:previous .row
```

## Non-goals

- Full CSS selector grammar validation
- DOM lookup behavior
- Browser-specific selector compatibility checks

## Acceptance criteria

- Selector validation mode is added
- Empty selectors are detected
- Incomplete extended selectors are detected
- Tests cover valid and invalid selector values
- README documents validation scope and non-goals
