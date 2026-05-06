# mhx_spec

A type-safe MoonBit library for parsing hypermedia attribute specifications for Hypermedia-Driven Applications (HDA).

## Overview

`mhx_spec` provides a robust parser for hypermedia attributes similar to htmx, enabling you to parse and work with interactive web application behaviors in a type-safe manner. The library focuses on three main areas:

- **Trigger Parsing**: Parse complex event trigger specifications with modifiers, selectors, and filters
- **Swap Strategies**: Define how content should be replaced in the DOM
- **Sync Strategies**: Control request coordination and queueing behavior

## Installation

Add this package to your MoonBit project:

```bash
moon add f4ah6o/mhx-spec
```

Or add it to your `moon.mod.json`:

```json
{
  "deps": {
    "f4ah6o/mhx-spec": "0.1.0"
  }
}
```

## Quick Start

### Strict parsing for tooling

Use the parser package when you need syntax errors instead of silent defaults:

```moonbit
let triggers = @parser.parse_trigger("click once delay:1s")
let swap = @parser.parse_swap("outerHTML swap:1.5s")
let sync = @parser.parse_sync("queue last")

inspect(triggers[0].to_spec_string()) // "click once delay:1000ms"
inspect(swap.to_spec_string())        // "outerHTML swap:1500ms"
inspect(sync.to_spec_string())        // "queue:last"
```

### Permissive parsing for runtime-facing callers

The existing permissive behavior is still available through explicit helper APIs:

```moonbit
let swap = @parser.parse_swap_or_default("bogus swap:1s") // falls back to defaults
let sync = @parser.parse_sync_or_default("bogus")         // falls back to drop
```

`@swap.SwapOptions::parse(...)` and `@sync.parse_sync_strategy(...)` remain permissive as well.

### Stable diagnostics

Strict parse errors convert into deterministic diagnostics:

```moonbit
let result : Result[_, @parser.ParseError] = try? @parser.parse_swap("bogus")
match result {
  Ok(_) => ()
  Err(err) => {
    let diag = err.to_diagnostic(target="hx-swap")
    inspect(diag.code)     // "MHX_PARSE_UNKNOWN_SWAP_STRATEGY"
    inspect(diag.position) // Position information for editors and CLIs
  }
}
```

### Bundle parsing and semantic validation

```moonbit
let attrs : Map[String, String] = {
  "hx-trigger": "click once",
  "hx-swap": "outerHTML swap:200ms",
  "hx-sync": "queue last",
  "hx-target": "closest .item",
  "hx-get": "/items",
}

let parsed = @parser.parse_attributes(attrs)
match parsed {
  Ok(bundle) => {
    let diags = @parser.validate_attributes(bundle)
    inspect(diags.length()) // 0
  }
  Err(diags) => inspect(diags)
}
```

## Supported syntax

### Trigger specs

- event names such as `click`, `submit`, `keyup`
- modifiers: `once`, `changed`, `consume`, `prevent`
- durations: `delay:500ms`, `throttle:1s`, `debounce:300ms`
- selectors: `from:body`, `target:#result`, `from:closest .item`
- queue modes: `queue:drop`, `queue:replace`, `queue:first`, `queue:last`, `queue:all`
- filters: `keyup[ctrlKey]`

### Swap specs

- strategies: `innerHTML`, `outerHTML`, `beforebegin`, `afterbegin`, `beforeend`, `afterend`, `delete`, `none`
- modifiers: `swap:<duration>`, `settle:<duration>`, `scroll:<value>`, `show:<value>`, `focus-scroll:true|false`

### Sync specs

- `drop`
- `replace`
- `queue:first`
- `queue:last`
- `queue:all`

### Duration syntax

Shared duration parsing accepts:

- `100`
- `100ms`
- `1s`
- `1.5s`

Canonical serialization always renders durations as milliseconds, for example `1500ms`.

## API Reference

### Parser module (`@parser`)

- `parse_trigger(input : String) -> Array[TriggerDef]!ParseError`
- `parse_swap(input : String) -> SwapOptions!ParseError`
- `parse_sync(input : String) -> SyncStrategy!ParseError`
- `parse_swap_or_default(input : String) -> SwapOptions`
- `parse_sync_or_default(input : String) -> SyncStrategy`
- `parse_duration_ms(input : String) -> Int!ParseError`
- `format_duration_ms(ms : Int) -> String`
- `parse_attributes(attrs : Map[String, String]) -> Result[MhxAttributes, Array[Diagnostic]]`
- `validate_selector(selector : Selector, mode : SelectorValidation) -> Array[Diagnostic]`
- `validate_trigger(trigger : TriggerDef) -> Array[Diagnostic]`
- `validate_swap(options : SwapOptions) -> Array[Diagnostic]`
- `validate_sync(sync : SyncStrategy) -> Array[Diagnostic]`
- `validate_attributes(attrs : MhxAttributes) -> Array[Diagnostic]`

### Canonical serialization

- `TriggerDef::to_spec_string() -> String`
- `SwapOptions::to_spec_string() -> String`
- `SyncStrategy::to_spec_string() -> String`
- `Selector::to_spec_string() -> String`

These methods are intended for formatters, golden tests, code generation, and stable diffs.

### Diagnostics contract

`Diagnostic` is the stable v1 error shape:

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

Current stable parse-oriented codes include:

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

Validation currently adds deterministic `MHX_VALIDATE_*` diagnostics for duplicate modifiers, conflicting request methods, unknown mhx attributes, invalid swap combinations, and empty request URLs.

### Selector validation scope

Selector validation intentionally stays lightweight:

- empty selectors are rejected in strict validation modes
- incomplete extended selectors such as `closest`, `find`, `next`, and `previous` are rejected
- full CSS grammar validation is **out of scope**

### Package boundary

`mhx_spec` owns:

- attribute grammar
- typed AST/spec values
- strict and permissive parsing APIs
- canonical serialization
- diagnostics
- semantic validation
- compatibility fixtures

`mhx_spec` does **not** own:

- DOM execution
- fetch behavior
- request scheduling implementations
- renderer-specific integration
- runtime coupling to any MoonBit web framework

Runtime packages should consume parsed specs and map them to concrete browser or server behavior.

## Development

### Validation commands

```bash
just fmt
just info
just check
just test
```

### Fixture workflow

Contract fixtures live under `fixtures/`:

- `fixtures/trigger/{valid,invalid,golden}`
- `fixtures/swap/{valid,invalid,golden}`
- `fixtures/sync/{valid,invalid,golden}`
- `fixtures/compat/htmx/{trigger-compatible,swap-compatible,sync-compatible,unsupported,mhx-extensions}`

The checked-in parser fixture embed can be regenerated with:

```bash
python3 scripts/embed_fixtures.py . src/parser/fixtures_embedded.mbt
```

Run `just test` after updating fixtures so the fixture-backed parser tests and compatibility tests stay in sync.

### Compatibility policy

This package is htmx-like, not a full htmx implementation. Compatibility is backed by fixtures under `fixtures/compat/htmx/`.
Unsupported syntax should produce explicit diagnostics rather than silently defaulting, and mhx-specific behavior is documented separately from the compatibility subset.

### Issue Management

Issues are managed locally in the `issues/` directory as markdown files.  
This approach is inspired by [shiguredo/http3-rs](https://github.com/shiguredo/http3-rs/blob/develop/AGENTS.md).  
See [AGENTS.md](AGENTS.md) for the full workflow.

## Examples

### Complex Trigger Parsing

```moonbit
// Parse a complex trigger with multiple modifiers
let triggers = @parser.parse_trigger(
  "click delay:500ms throttle:1s from:body target:#result [ctrlKey]"
)

let trigger = triggers[0]
trigger.event_name       // "click"
trigger.get_delay()      // Some(500)
trigger.get_throttle()   // Some(1000)
trigger.get_from()       // Some(Selector::Body)
trigger.get_target()     // Some(Selector::Css("#result"))
trigger.get_filter()     // Some("ctrlKey")
```

### Multiple Events

```moonbit
// Parse multiple events separated by commas
let triggers = @parser.parse_trigger("click, keyup delay:100ms, submit prevent")

// triggers[0]: click event
// triggers[1]: keyup with delay
// triggers[2]: submit with prevent default
```

### Swap with Multiple Modifiers

```moonbit
let opts = SwapOptions::parse(
  "outerHTML swap:200ms settle:50ms scroll:bottom show:top focus-scroll:true"
)

opts.strategy         // Strategy::OuterHTML
opts.swap_delay       // 200
opts.settle_delay     // 50
opts.scroll           // "bottom"
opts.show             // "top"
opts.focus_scroll     // true
```

## Use Cases

This library is designed for:

- Building hypermedia-driven applications in MoonBit
- Creating htmx-like functionality for MoonBit web frameworks
- Parsing and validating hypermedia attribute specifications
- Type-safe representation of interactive web behaviors
- Server-side rendering with interactive element specifications

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

Apache-2.0

## Links

- Repository: https://github.com/f4ah6o/mhx_spec.mbt
- MoonBit: https://www.moonbitlang.com/
- Hypermedia Systems: https://hypermedia.systems/

## Keywords

hypermedia, hda, htmx, parser, web, interactive, moonbit
