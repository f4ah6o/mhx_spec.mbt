# Add shared duration parser with strict error handling

Created: 2026-05-05
Model: N/A

## Summary

Add a shared duration parser used by trigger, swap, and future mhx attribute parsers.

## Motivation

Duration parsing currently appears in multiple places with slightly different behavior. Trigger parsing supports integer values with `ms` and `s`, while swap parsing also accepts decimal seconds such as `1.5s`.

A shared parser will make behavior consistent across the spec package.

## Proposed API

```moonbit
pub fn parse_duration_ms(input : String) -> Int!ParseError
pub fn format_duration_ms(ms : Int) -> String
```

## Supported input

- `100`
- `100ms`
- `1s`
- `1.5s`

## Strict errors

- empty value
- missing numeric component
- malformed decimal
- unknown unit
- negative value, unless explicitly supported
- overflow, if detectable

## Acceptance criteria

- Shared duration parser exists
- Trigger parser uses the shared parser
- Swap parser uses the shared parser
- Tests cover integer ms, integer seconds, decimal seconds, unknown units, empty values, and malformed values
- README documents accepted duration syntax
