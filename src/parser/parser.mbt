///|
/// Parser for mx-trigger attribute values
/// Converts DSL strings to typed TriggerDef structures

///|
/// Parse a complete trigger specification
/// e.g., "click", "click delay:500ms", "click, keyup"
pub fn parse_trigger(
  input : String,
) -> Array[@trigger.TriggerDef] raise ParseError {
  let scanner = Scanner::new(input)
  let triggers : Array[@trigger.TriggerDef] = []
  scanner.skip_whitespace()
  while !scanner.is_eof() {
    let trigger = parse_single_trigger(scanner)
    triggers.push(trigger)
    scanner.skip_whitespace()
    // Check for comma separator
    if scanner.try_consume(',') {
      scanner.skip_whitespace()
    }
  }
  triggers
}

///|
/// Parse a single trigger definition
fn parse_single_trigger(
  scanner : Scanner,
) -> @trigger.TriggerDef raise ParseError {
  // Parse event name
  let event_name = scanner.scan_identifier()
  if event_name.is_empty() {
    raise UnexpectedChar(
      pos=scanner.make_position(),
      expected="event name (identifier)",
    )
  }
  // Parse modifiers
  let modifiers = parse_modifiers(scanner)
  @trigger.TriggerDef::new(event_name, modifiers)
}

///|
/// Parse modifiers following an event name
fn parse_modifiers(
  scanner : Scanner,
) -> Array[@trigger.Modifier] raise ParseError {
  let modifiers : Array[@trigger.Modifier] = []
  while !scanner.is_eof() && !scanner.check(',') {
    scanner.skip_whitespace()
    if scanner.is_eof() || scanner.check(',') {
      break
    }
    // Filter condition: [expression]
    if scanner.check('[') {
      let expr = scanner.scan_bracketed()
      modifiers.push(@trigger.Modifier::Filter(expr))
      continue
    }
    // Named modifiers: name or name:value
    let name = scanner.scan_identifier()
    if name.is_empty() {
      break
    }
    let modifier = parse_modifier_by_name(scanner, name)
    modifiers.push(modifier)
  }
  modifiers
}

///|
/// Parse a modifier by its name
fn parse_modifier_by_name(
  scanner : Scanner,
  name : String,
) -> @trigger.Modifier raise ParseError {
  match name {
    "once" => @trigger.Modifier::Once
    "changed" => @trigger.Modifier::Changed
    "consume" => @trigger.Modifier::Consume
    "prevent" => @trigger.Modifier::Prevent
    "delay" => {
      scanner.skip_whitespace()
      scanner.expect(':')
      scanner.skip_whitespace()
      let ms = parse_time_value(scanner)
      @trigger.Modifier::Delay(ms)
    }
    "throttle" => {
      scanner.skip_whitespace()
      scanner.expect(':')
      scanner.skip_whitespace()
      let ms = parse_time_value(scanner)
      @trigger.Modifier::Throttle(ms)
    }
    "debounce" => {
      scanner.skip_whitespace()
      scanner.expect(':')
      scanner.skip_whitespace()
      let ms = parse_time_value(scanner)
      @trigger.Modifier::Debounce(ms)
    }
    "from" => {
      scanner.skip_whitespace()
      scanner.expect(':')
      scanner.skip_whitespace()
      let selector = parse_selector(scanner)
      @trigger.Modifier::From(selector)
    }
    "target" => {
      scanner.skip_whitespace()
      scanner.expect(':')
      scanner.skip_whitespace()
      let selector = parse_selector(scanner)
      @trigger.Modifier::Target(selector)
    }
    "queue" => {
      scanner.skip_whitespace()
      scanner.expect(':')
      scanner.skip_whitespace()
      let mode = parse_queue_mode(scanner)
      @trigger.Modifier::Queue(mode)
    }
    _ => raise InvalidModifier(pos=scanner.make_position(), name~)
  }
}

///|
/// Parse a time value (number with optional ms/s suffix)
fn parse_time_value(scanner : Scanner) -> Int raise ParseError {
  let start = scanner.position()
  let token = scanner.scan_value_token()
  if token.is_empty() {
    raise MalformedDuration(
      pos=Position::at(start, scanner.input),
      value="",
      reason="missing numeric component",
    )
  }
  parse_duration_ms(token) catch {
    err => raise err.shift(start, scanner.input)
  }
}

///|
/// Parse a selector value
fn parse_selector(scanner : Scanner) -> @trigger.Selector {
  let value = scanner.scan_selector_value()
  match value {
    "this" => @trigger.Selector::This
    "body" => @trigger.Selector::Body
    "window" => @trigger.Selector::Window
    "document" => @trigger.Selector::Document
    "closest" => @trigger.Selector::Closest("")
    "find" => @trigger.Selector::Find("")
    "next" => @trigger.Selector::Next("")
    "previous" => @trigger.Selector::Previous("")
    _ =>
      if value.has_prefix("closest ") {
        let sel = value[8:].to_string().trim().to_string()
        @trigger.Selector::Closest(sel)
      } else if value.has_prefix("find ") {
        let sel = value[5:].to_string().trim().to_string()
        @trigger.Selector::Find(sel)
      } else if value.has_prefix("next ") {
        let sel = value[5:].to_string().trim().to_string()
        @trigger.Selector::Next(sel)
      } else if value.has_prefix("previous ") {
        let sel = value[9:].to_string().trim().to_string()
        @trigger.Selector::Previous(sel)
      } else {
        // Treat as CSS selector
        @trigger.Selector::Css(value)
      }
  }
}

///|
/// Parse queue mode
fn parse_queue_mode(scanner : Scanner) -> @trigger.QueueMode raise ParseError {
  let value = scanner.scan_identifier()
  match value {
    "drop" => @trigger.QueueMode::Drop
    "replace" => @trigger.QueueMode::Replace
    "first" => @trigger.QueueMode::QueueFirst
    "last" => @trigger.QueueMode::QueueLast
    "all" => @trigger.QueueMode::QueueAll
    _ =>
      raise InvalidModifier(pos=scanner.make_position(), name="queue:" + value)
  }
}

///|
fn parse_swap_strategy_strict(
  input : String,
  name : String,
  start : Int,
) -> @swap.Strategy raise ParseError {
  match name.to_lower() {
    "innerhtml" => @swap.Strategy::InnerHTML
    "outerhtml" => @swap.Strategy::OuterHTML
    "beforebegin" => @swap.Strategy::BeforeBegin
    "afterbegin" => @swap.Strategy::AfterBegin
    "beforeend" => @swap.Strategy::BeforeEnd
    "afterend" => @swap.Strategy::AfterEnd
    "delete" => @swap.Strategy::Delete
    "none" => @swap.Strategy::None_
    _ => raise UnknownSwapStrategy(pos=Position::at(start, input), value=name)
  }
}

///|
fn parse_bool_modifier_value(
  input : String,
  value : String,
  start : Int,
) -> Bool raise ParseError {
  match value.to_lower() {
    "true" => true
    "false" => false
    _ =>
      raise InvalidModifier(
        pos=Position::at(start, input),
        name="focus-scroll:" + value,
      )
  }
}

///|
pub fn parse_swap(input : String) -> @swap.SwapOptions raise ParseError {
  let scanner = Scanner::new(input)
  scanner.skip_whitespace()
  if scanner.is_eof() {
    raise UnexpectedEnd(pos=Position::zero(), expected="swap strategy")
  }
  let strategy_start = scanner.position()
  let strategy_name = scanner.scan_identifier()
  if strategy_name.is_empty() {
    raise UnexpectedChar(
      pos=Position::at(strategy_start, input),
      expected="swap strategy",
    )
  }
  let strategy = parse_swap_strategy_strict(
    input, strategy_name, strategy_start,
  )
  let mut options = @swap.SwapOptions::with_strategy(strategy)
  while true {
    scanner.skip_whitespace()
    if scanner.is_eof() {
      break
    }
    let modifier_start = scanner.position()
    let modifier_name = scanner.scan_identifier()
    if modifier_name.is_empty() {
      raise UnexpectedChar(
        pos=Position::at(modifier_start, input),
        expected="swap modifier",
      )
    }
    scanner.expect(':')
    let value_start = scanner.position()
    let value = scanner.scan_value_token().trim().to_string()
    if value.is_empty() {
      raise UnexpectedEnd(
        pos=Position::at(value_start, input),
        expected=modifier_name + " value",
      )
    }
    match modifier_name {
      "swap" => {
        let delay = parse_duration_ms(value) catch {
          err => raise err.shift(value_start, input)
        }
        options = { ..options, swap_delay: delay }
      }
      "settle" => {
        let delay = parse_duration_ms(value) catch {
          err => raise err.shift(value_start, input)
        }
        options = { ..options, settle_delay: delay }
      }
      "scroll" => options = { ..options, scroll: value }
      "show" => options = { ..options, show: value }
      "focus-scroll" =>
        options = {
          ..options,
          focus_scroll: parse_bool_modifier_value(input, value, value_start),
        }
      _ =>
        raise UnknownSwapModifier(
          pos=Position::at(modifier_start, input),
          name=modifier_name,
        )
    }
  }
  options
}

///|
pub fn parse_swap_or_default(input : String) -> @swap.SwapOptions {
  parse_swap(input) catch {
    _ => @swap.SwapOptions::parse(input)
  }
}

///|
fn parse_sync_queue_mode(
  input : String,
  value : String,
  start : Int,
) -> @sync.QueueMode raise ParseError {
  match value.to_lower() {
    "first" => @sync.QueueMode::First
    "last" => @sync.QueueMode::Last
    "all" => @sync.QueueMode::All
    _ =>
      raise UnknownSyncStrategy(
        pos=Position::at(start, input),
        value="queue:" + value,
      )
  }
}

///|
pub fn parse_sync(input : String) -> @sync.SyncStrategy raise ParseError {
  let scanner = Scanner::new(input)
  scanner.skip_whitespace()
  if scanner.is_eof() {
    raise UnexpectedEnd(pos=Position::zero(), expected="sync strategy")
  }
  let start = scanner.position()
  let strategy = scanner.scan_identifier().to_lower()
  if strategy.is_empty() {
    raise UnexpectedChar(
      pos=Position::at(start, input),
      expected="sync strategy",
    )
  }
  let parsed = match strategy {
    "drop" => @sync.SyncStrategy::Drop
    "replace" => @sync.SyncStrategy::Replace
    "queue" => {
      scanner.skip_whitespace()
      if scanner.try_consume(':') {
        scanner.skip_whitespace()
      }
      if scanner.is_eof() {
        @sync.SyncStrategy::Queue(@sync.QueueMode::First)
      } else {
        let queue_start = scanner.position()
        let mode = scanner.scan_identifier()
        if mode.is_empty() {
          raise UnexpectedEnd(
            pos=Position::at(queue_start, input),
            expected="queue mode",
          )
        }
        @sync.SyncStrategy::Queue(
          parse_sync_queue_mode(input, mode, queue_start),
        )
      }
    }
    _ =>
      raise UnknownSyncStrategy(
        pos=Position::at(start, input),
        value=input.trim().to_string(),
      )
  }
  scanner.skip_whitespace()
  if !scanner.is_eof() {
    raise UnknownSyncStrategy(
      pos=scanner.make_position(),
      value=input.trim().to_string(),
    )
  }
  parsed
}

///|
pub fn parse_sync_or_default(input : String) -> @sync.SyncStrategy {
  parse_sync(input) catch {
    _ => @sync.parse_sync_strategy(input)
  }
}
