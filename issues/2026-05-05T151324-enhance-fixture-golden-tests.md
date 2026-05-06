# Add fixture-first golden tests for spec contracts

Created: 2026-05-05
Model: N/A

## Summary

Add fixture-first golden tests for trigger, swap, and sync spec contracts.

## Motivation

This package is best positioned as the source of truth for mhx attribute syntax and typed representation. Golden fixtures make that contract explicit and reviewable.

## Proposed fixture layout

```text
fixtures/
  trigger/
    valid/*.txt
    invalid/*.txt
    golden/*.json
  swap/
    valid/*.txt
    invalid/*.txt
    golden/*.json
  sync/
    valid/*.txt
    invalid/*.txt
    golden/*.json
```

## Each fixture should verify

- parsed AST
- canonical string output
- diagnostics
- round-trip behavior where applicable

## Suggested fixture categories

- simple valid examples
- complex valid examples
- whitespace normalization
- multiple triggers
- invalid modifier names
- invalid selector syntax
- malformed duration values
- unknown swap strategies
- unknown sync strategies

## Acceptance criteria

- Fixture directory is added
- Test runner covers trigger fixtures
- Test runner covers swap fixtures
- Test runner covers sync fixtures
- Golden output is deterministic
- README documents how to update fixtures
