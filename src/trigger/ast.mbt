///|
/// Abstract Syntax Tree for trigger definitions
/// Represents parsed mx-trigger attribute values

///|
/// A single trigger definition
/// e.g., "click" or "click[ctrlKey] delay:500ms from:body"
pub(all) struct TriggerDef {
  /// The event name (e.g., "click", "submit", "load", "revealed")
  event_name : String
  /// Modifiers that control trigger behavior
  modifiers : Array[Modifier]
} derive(Show, Eq)

///|
pub impl ToJson for TriggerDef with to_json(self) {
  { "event": self.event_name.to_json(), "modifiers": self.modifiers.to_json() }
}

///|
/// Create a simple trigger with just an event name
pub fn TriggerDef::simple(event_name : String) -> TriggerDef {
  { event_name, modifiers: [] }
}

///|
/// Create a trigger with modifiers
pub fn TriggerDef::new(
  event_name : String,
  modifiers : Array[Modifier],
) -> TriggerDef {
  { event_name, modifiers }
}

///|
/// Check if this trigger has the Once modifier
pub fn TriggerDef::is_once(self : TriggerDef) -> Bool {
  self.modifiers.iter().any(fn(m) { m is Once })
}

///|
/// Check if this trigger has the Changed modifier
pub fn TriggerDef::is_changed(self : TriggerDef) -> Bool {
  self.modifiers.iter().any(fn(m) { m is Changed })
}

///|
/// Get the delay modifier value, if present
pub fn TriggerDef::get_delay(self : TriggerDef) -> Int? {
  for m in self.modifiers {
    if m is Delay(ms) {
      return Some(ms)
    }
  }
  None
}

///|
/// Get the throttle modifier value, if present
pub fn TriggerDef::get_throttle(self : TriggerDef) -> Int? {
  for m in self.modifiers {
    if m is Throttle(ms) {
      return Some(ms)
    }
  }
  None
}

///|
/// Get the debounce modifier value, if present
pub fn TriggerDef::get_debounce(self : TriggerDef) -> Int? {
  for m in self.modifiers {
    if m is Debounce(ms) {
      return Some(ms)
    }
  }
  None
}

///|
/// Get the from selector, if present
pub fn TriggerDef::get_from(self : TriggerDef) -> Selector? {
  for m in self.modifiers {
    if m is From(sel) {
      return Some(sel)
    }
  }
  None
}

///|
/// Get the target selector, if present
pub fn TriggerDef::get_target(self : TriggerDef) -> Selector? {
  for m in self.modifiers {
    if m is Target(sel) {
      return Some(sel)
    }
  }
  None
}

///|
/// Get the filter expression, if present
pub fn TriggerDef::get_filter(self : TriggerDef) -> String? {
  for m in self.modifiers {
    if m is Filter(expr) {
      return Some(expr)
    }
  }
  None
}

///|
/// Check if consume (stopPropagation) is set
pub fn TriggerDef::should_consume(self : TriggerDef) -> Bool {
  self.modifiers.iter().any(fn(m) { m is Consume })
}

///|
/// Check if prevent (preventDefault) is set
pub fn TriggerDef::should_prevent(self : TriggerDef) -> Bool {
  self.modifiers.iter().any(fn(m) { m is Prevent })
}

///|
/// Get the queue mode, defaulting to Drop
pub fn TriggerDef::get_queue_mode(self : TriggerDef) -> QueueMode {
  for m in self.modifiers {
    if m is Queue(mode) {
      return mode
    }
  }
  QueueMode::Drop
}

///|
/// Render the trigger in canonical spec form for stable output.
pub fn TriggerDef::to_spec_string(self : TriggerDef) -> String {
  let filters : Array[String] = []
  let once_items : Array[String] = []
  let changed_items : Array[String] = []
  let consume_items : Array[String] = []
  let prevent_items : Array[String] = []
  let delay_items : Array[String] = []
  let throttle_items : Array[String] = []
  let debounce_items : Array[String] = []
  let from_items : Array[String] = []
  let target_items : Array[String] = []
  let queue_items : Array[String] = []
  for modifier in self.modifiers {
    match modifier {
      Filter(expr) => filters.push("[\{expr}]")
      Once => once_items.push(modifier.to_spec_string())
      Changed => changed_items.push(modifier.to_spec_string())
      Consume => consume_items.push(modifier.to_spec_string())
      Prevent => prevent_items.push(modifier.to_spec_string())
      Delay(_) => delay_items.push(modifier.to_spec_string())
      Throttle(_) => throttle_items.push(modifier.to_spec_string())
      Debounce(_) => debounce_items.push(modifier.to_spec_string())
      From(_) => from_items.push(modifier.to_spec_string())
      Target(_) => target_items.push(modifier.to_spec_string())
      Queue(_) => queue_items.push(modifier.to_spec_string())
    }
  }
  let ordered : Array[String] = []
  ordered.append(once_items)
  ordered.append(changed_items)
  ordered.append(consume_items)
  ordered.append(prevent_items)
  ordered.append(delay_items)
  ordered.append(throttle_items)
  ordered.append(debounce_items)
  ordered.append(from_items)
  ordered.append(target_items)
  ordered.append(queue_items)
  let mut result = self.event_name
  if !filters.is_empty() {
    result = result + filters.join("")
  }
  if ordered.is_empty() {
    result
  } else {
    result + " " + ordered.join(" ")
  }
}
