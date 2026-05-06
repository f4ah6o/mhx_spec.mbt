# Add element-level mhx attribute bundle parser

Created: 2026-05-05
Model: N/A

## Summary

Add an element-level parser that can parse and validate a bundle of mhx-related attributes together.

## Motivation

Real usage is rarely limited to a single attribute. An element may combine trigger, swap, sync, target, and request attributes. A bundle parser gives higher-level tools one stable entry point for parsing an element's mhx behavior without depending on runtime code.

## Proposed type

```moonbit
pub struct MhxAttributes {
  trigger : Array[TriggerDef]?
  swap : SwapOptions?
  sync : SyncStrategy?
  target : Selector?
  get : String?
  post : String?
  put : String?
  patch : String?
  delete : String?
}
```

## Proposed API

```moonbit
pub fn parse_attributes(attrs : Map[String, String]) -> MhxAttributes!Array[Diagnostic]
```

## Validation opportunities

- parse multiple attributes in one pass
- detect unknown mhx attributes
- detect conflicting request method attributes
- detect malformed trigger/swap/sync/target values
- provide stable diagnostics with attribute-level targets

## Non-goals

- DOM execution
- HTTP request execution
- runtime scheduling
- integration with any specific renderer

## Acceptance criteria

- `MhxAttributes` or equivalent type exists
- Bundle parser covers trigger/swap/sync/target/request attrs
- Diagnostics include the source attribute name as target
- Tests cover valid bundles and invalid/conflicting bundles
- README includes an element-level example
