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

### Parsing Triggers

```moonbit
// Simple event trigger
let triggers = @parser.parse_trigger("click")

// With modifiers
let triggers = @parser.parse_trigger("click once delay:500ms")

// With selectors
let triggers = @parser.parse_trigger("click from:body target:#result")

// With filters
let triggers = @parser.parse_trigger("keyup[ctrlKey]")

// Multiple events
let triggers = @parser.parse_trigger("click, keyup")

// Access parsed values
let trigger = triggers[0]
println(trigger.event_name)        // "click"
println(trigger.is_once())         // true
println(trigger.get_delay())       // Some(500)
```

### Parsing Swap Options

```moonbit
let opts = SwapOptions::parse("innerHTML swap:200ms settle:50ms scroll:top")

println(opts.strategy)       // InnerHTML
println(opts.swap_delay)     // 200
println(opts.settle_delay)   // 50
println(opts.scroll)         // "top"
```

### Parsing Sync Strategies

```moonbit
let sync = SyncStrategy::parse("replace")  // Replace
let sync = SyncStrategy::parse("drop")     // Drop
let sync = SyncStrategy::parse("queue:last") // Queue(QueueLast)
```

## Features

### Event Triggers

Parse event specifications with rich modifier support:

#### Basic Events
```moonbit
"click"           // Click event
"submit"          // Form submit
"keyup"           // Keyboard event
"change"          // Input change
```

#### Modifiers

**One-time Events**
```moonbit
"click once"      // Fire only once, then remove listener
```

**Change Detection**
```moonbit
"change changed"  // Fire only when value actually changes
```

**Timing Control**
```moonbit
"click delay:500ms"        // Wait 500ms before firing
"keyup throttle:1s"        // Fire at most once per second
"input debounce:300ms"     // Fire after 300ms of quiet period
```

**Selectors**
```moonbit
"click from:body"          // Listen from body element
"click target:#result"     // Target specific element
"click from:closest div"   // Listen from closest div
"click from:find .item"    // Listen from found element
```

**Event Control**
```moonbit
"click consume"            // Call stopPropagation()
"submit prevent"           // Call preventDefault()
```

**Request Queueing**
```moonbit
"click queue:drop"         // Drop new requests while one is pending
"click queue:replace"      // Replace pending request with new one
"click queue:first"        // Queue and process first
"click queue:last"         // Queue and process last
"click queue:all"          // Queue and process all
```

**Filters**
```moonbit
"keyup[ctrlKey]"                    // Only when Ctrl is pressed
"click[event.detail === 1]"         // Custom condition
```

### Swap Strategies

Control how content is replaced in the DOM:

```moonbit
"innerHTML"              // Replace inner content (default)
"outerHTML"              // Replace entire element
"beforeBegin"            // Insert before element
"afterBegin"             // Insert as first child
"beforeEnd"              // Insert as last child
"afterEnd"               // Insert after element
"delete"                 // Delete element
"none"                   // Don't swap content
```

#### Swap Modifiers

```moonbit
"innerHTML swap:200ms"           // Wait 200ms before swapping
"innerHTML settle:100ms"         // Wait 100ms after swap to settle
"innerHTML scroll:top"           // Scroll to top after swap
"innerHTML scroll:bottom"        // Scroll to bottom after swap
"innerHTML show:top"             // Show top of element
"innerHTML show:bottom"          // Show bottom of element
"innerHTML focus-scroll:false"   // Disable scroll on focus
```

### Sync Strategies

Control request synchronization:

- `drop` - Drop new requests while one is in flight
- `replace` - Cancel pending request and replace with new one
- `queue:first` - Queue requests and process first
- `queue:last` - Queue requests and process last
- `queue:all` - Queue and process all requests

## API Reference

### Parser Module (`@parser`)

#### `parse_trigger`
```moonbit
pub fn parse_trigger(input : String) -> Array[TriggerDef]!ParseError
```
Parse a trigger attribute value into an array of trigger definitions.

### Trigger Module (`@trigger`)

#### `TriggerDef`
```moonbit
pub struct TriggerDef {
  event_name : String
  modifiers : Array[Modifier]
}
```

**Methods:**
- `is_once() -> Bool` - Check if trigger fires only once
- `is_changed() -> Bool` - Check if trigger has changed modifier
- `is_consume() -> Bool` - Check if trigger consumes event
- `is_prevent() -> Bool` - Check if trigger prevents default
- `get_delay() -> Option[Int]` - Get delay in milliseconds
- `get_throttle() -> Option[Int]` - Get throttle interval
- `get_debounce() -> Option[Int]` - Get debounce interval
- `get_from() -> Option[Selector]` - Get source selector
- `get_target() -> Option[Selector]` - Get target selector
- `get_filter() -> Option[String]` - Get filter expression
- `get_queue() -> Option[QueueMode]` - Get queue mode

#### `Modifier`
```moonbit
pub enum Modifier {
  Once | Changed | Consume | Prevent
  | Delay(Int) | Throttle(Int) | Debounce(Int)
  | From(Selector) | Target(Selector)
  | Filter(String) | Queue(QueueMode)
}
```

#### `Selector`
```moonbit
pub enum Selector {
  This | Body | Window | Document
  | Closest(String) | Find(String)
  | Next(String) | Previous(String)
  | Css(String)
}
```

#### `QueueMode`
```moonbit
pub enum QueueMode {
  Drop | Replace | QueueFirst | QueueLast | QueueAll
}
```

### Swap Module (`@swap`)

#### `SwapOptions`
```moonbit
pub struct SwapOptions {
  pub strategy : Strategy
  pub swap_delay : Int
  pub settle_delay : Int
  pub scroll : String
  pub show : String
  pub focus_scroll : Bool
}
```

**Static Methods:**
- `parse(input : String) -> SwapOptions` - Parse swap options string

#### `Strategy`
```moonbit
pub enum Strategy {
  InnerHTML | OuterHTML | BeforeBegin | AfterBegin
  | BeforeEnd | AfterEnd | Delete | None_
}
```

### Sync Module (`@sync`)

#### `SyncStrategy`
```moonbit
pub enum SyncStrategy {
  Drop | Replace | Queue(QueueMode)
}
```

**Static Methods:**
- `parse(input : String) -> SyncStrategy` - Parse sync strategy string

### Error Handling

All parsing functions may raise `ParseError`:

```moonbit
pub suberror ParseError {
  UnexpectedChar(pos: Position, expected: String)
  | UnexpectedEnd(pos: Position, expected: String)
  | InvalidNumber(pos: Position, value: String)
  | InvalidModifier(pos: Position, name: String)
  | InvalidSelector(pos: Position, value: String)
}
```

Errors include position information for debugging:
```moonbit
pub struct Position {
  pub offset : Int
  pub line : Int
  pub column : Int
}
```

## Development

### Prerequisites

- MoonBit toolchain

### Building

```bash
# Format code
just fmt

# Type check
just check

# Run tests
just test

# Update test snapshots
just test-update
```

### Running Tests

The library includes comprehensive test coverage:

```bash
moon test
```

Test files:
- `src/parser/parser_test.mbt` - Parser tests (17 tests)
- `src/trigger/ast_test.mbt` - AST tests (6 tests)
- `src/swap/swap_test.mbt` - Swap strategy tests (13 tests)

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
