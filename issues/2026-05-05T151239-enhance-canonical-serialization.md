# Add canonical serialization for trigger, swap, and sync specs

Created: 2026-05-05
Model: N/A

## Summary

Add stable canonical string rendering APIs for parsed mhx specs.

## Motivation

`mhx_spec.mbt` should not only parse attribute strings into typed values, but also render parsed specs back into deterministic canonical strings. This enables formatters, golden fixtures, snapshot testing, stable diffs, and safe attribute generation from higher-level builders.

## Proposed API

```moonbit
pub fn TriggerDef::to_spec_string(self) -> String
pub fn SwapOptions::to_spec_string(self) -> String
pub fn SyncStrategy::to_spec_string(self) -> String
```

## Canonicalization rules

- stable modifier order
- normalized duration output
- normalized queue spelling as `queue:<mode>`
- normalized swap strategy spelling
- stable selector rendering
- no implicit defaults unless explicitly requested

## Examples

```text
click delay:1s once
=> click once delay:1000ms

queue last
=> queue:last

outerhtml swap:1.5s
=> outerHTML swap:1500ms
```

## Acceptance criteria

- Trigger spec serialization exists
- Swap spec serialization exists
- Sync spec serialization exists
- Round-trip tests are added
- Canonical output is covered by golden tests or snapshots
- README documents the canonical form
