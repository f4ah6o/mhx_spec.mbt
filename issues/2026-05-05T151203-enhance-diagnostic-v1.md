# Introduce Diagnostic v1 for parse and validation errors

Created: 2026-05-05
Model: N/A

## Summary

Introduce a stable Diagnostic v1 representation for parse and validation errors.

## Motivation

`ParseError` currently carries structured information such as position, expected value, modifier name, and selector value. That is useful inside the library, but downstream tools need a stable diagnostic format that can be emitted as JSON, rendered in CLI output, and consumed by editors or compilers without message parsing.

## Proposed shape

```moonbit
pub struct Diagnostic {
  code : String
  message : String
  target : String
  position : Position
  hint : String?
  context : String?
}
```

## Suggested diagnostic codes

- `MHX_PARSE_UNEXPECTED_CHAR`
- `MHX_PARSE_UNEXPECTED_END`
- `MHX_PARSE_INVALID_NUMBER`
- `MHX_PARSE_INVALID_MODIFIER`
- `MHX_PARSE_INVALID_SELECTOR`
- `MHX_PARSE_UNKNOWN_SWAP_MODIFIER`
- `MHX_PARSE_UNKNOWN_SWAP_STRATEGY`
- `MHX_PARSE_UNKNOWN_SYNC_STRATEGY`
- `MHX_PARSE_EMPTY_SELECTOR`
- `MHX_PARSE_MALFORMED_DURATION`

## Requirements

- Diagnostics must be deterministic
- Codes must be stable once documented
- Diagnostics should include enough context for users to fix the input
- Downstream consumers should not need to infer target or hint from message text

## Acceptance criteria

- Diagnostic type is added
- Parse errors can be converted into diagnostics
- At least trigger/swap/sync errors have stable codes
- Tests assert diagnostic codes and positions
- README documents the diagnostic contract
