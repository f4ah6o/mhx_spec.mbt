///|
/// Element-level parsing helpers for mhx/hx-like attribute bundles.

///|
pub(all) struct MhxAttributes {
  trigger : Array[@trigger.TriggerDef]?
  swap : @swap.SwapOptions?
  sync : @sync.SyncStrategy?
  target : @trigger.Selector?
  get : String?
  post : String?
  put : String?
  patch : String?
  delete : String?
} derive(Show, Eq)

///|
pub fn MhxAttributes::empty() -> MhxAttributes {
  {
    trigger: None,
    swap: None,
    sync: None,
    target: None,
    get: None,
    post: None,
    put: None,
    patch: None,
    delete: None,
  }
}

///|
fn is_prefixed_mhx_attr(name : String) -> Bool {
  let lower = name.to_lower()
  lower.has_prefix("hx-") || lower.has_prefix("mx-") || lower.has_prefix("mhx-")
}

///|
fn normalize_attr_name(name : String) -> String {
  let lower = name.to_lower()
  if lower.has_prefix("mhx-") {
    lower[4:].to_string()
  } else if lower.has_prefix("hx-") || lower.has_prefix("mx-") {
    lower[3:].to_string()
  } else {
    lower
  }
}

///|
fn parse_selector_input(value : String) -> @trigger.Selector {
  let trimmed = value.trim().to_string()
  match trimmed {
    "this" => @trigger.Selector::This
    "body" => @trigger.Selector::Body
    "window" => @trigger.Selector::Window
    "document" => @trigger.Selector::Document
    _ =>
      if trimmed.has_prefix("closest ") {
        @trigger.Selector::Closest(trimmed[8:].to_string().trim().to_string())
      } else if trimmed == "closest" {
        @trigger.Selector::Closest("")
      } else if trimmed.has_prefix("find ") {
        @trigger.Selector::Find(trimmed[5:].to_string().trim().to_string())
      } else if trimmed == "find" {
        @trigger.Selector::Find("")
      } else if trimmed.has_prefix("next ") {
        @trigger.Selector::Next(trimmed[5:].to_string().trim().to_string())
      } else if trimmed == "next" {
        @trigger.Selector::Next("")
      } else if trimmed.has_prefix("previous ") {
        @trigger.Selector::Previous(trimmed[9:].to_string().trim().to_string())
      } else if trimmed == "previous" {
        @trigger.Selector::Previous("")
      } else {
        @trigger.Selector::Css(trimmed)
      }
  }
}

///|
fn unknown_attribute_diagnostic(name : String) -> Diagnostic {
  validation_diagnostic(
    "MHX_VALIDATE_UNKNOWN_ATTRIBUTE",
    "Unknown mhx attribute `\{name}`",
    name,
    Some("Use trigger, swap, sync, target, get, post, put, patch, or delete."),
    None,
  )
}

///|
pub fn parse_attributes(
  attrs : Map[String, String],
) -> Result[MhxAttributes, Array[Diagnostic]] {
  let mut parsed = MhxAttributes::empty()
  let diags : Array[Diagnostic] = []
  for raw_name, raw_value in attrs {
    let name = normalize_attr_name(raw_name)
    match name {
      "trigger" => {
        let result : Result[Array[@trigger.TriggerDef], ParseError] = try? parse_trigger(
          raw_value,
        )
        match result {
          Ok(triggers) => parsed = { ..parsed, trigger: Some(triggers) }
          Err(err) => diags.push(err.to_diagnostic(target=raw_name))
        }
      }
      "swap" => {
        let result : Result[@swap.SwapOptions, ParseError] = try? parse_swap(
          raw_value,
        )
        match result {
          Ok(options) => parsed = { ..parsed, swap: Some(options) }
          Err(err) => diags.push(err.to_diagnostic(target=raw_name))
        }
      }
      "sync" => {
        let result : Result[@sync.SyncStrategy, ParseError] = try? parse_sync(
          raw_value,
        )
        match result {
          Ok(strategy) => parsed = { ..parsed, sync: Some(strategy) }
          Err(err) => diags.push(err.to_diagnostic(target=raw_name))
        }
      }
      "target" =>
        parsed = { ..parsed, target: Some(parse_selector_input(raw_value)) }
      "get" => parsed = { ..parsed, get: Some(raw_value) }
      "post" => parsed = { ..parsed, post: Some(raw_value) }
      "put" => parsed = { ..parsed, put: Some(raw_value) }
      "patch" => parsed = { ..parsed, patch: Some(raw_value) }
      "delete" => parsed = { ..parsed, delete: Some(raw_value) }
      _ =>
        if is_prefixed_mhx_attr(raw_name) {
          diags.push(unknown_attribute_diagnostic(raw_name))
        }
    }
  }
  if diags.is_empty() {
    Ok(parsed)
  } else {
    Err(diags)
  }
}

///|
fn request_method_entries(attrs : MhxAttributes) -> Array[(String, String)] {
  let methods : Array[(String, String)] = []
  match attrs.get {
    Some(value) => methods.push(("get", value))
    None => ()
  }
  match attrs.post {
    Some(value) => methods.push(("post", value))
    None => ()
  }
  match attrs.put {
    Some(value) => methods.push(("put", value))
    None => ()
  }
  match attrs.patch {
    Some(value) => methods.push(("patch", value))
    None => ()
  }
  match attrs.delete {
    Some(value) => methods.push(("delete", value))
    None => ()
  }
  methods
}

///|
pub fn validate_attributes(attrs : MhxAttributes) -> Array[Diagnostic] {
  let diags : Array[Diagnostic] = []
  match attrs.trigger {
    Some(triggers) => {
      for trigger in triggers {
        diags.append(validate_trigger(trigger))
      }
      match attrs.sync {
        Some(@sync.SyncStrategy::Queue(_)) =>
          if triggers
            .iter()
            .any(fn(trigger) {
              trigger.get_queue_mode() != @trigger.QueueMode::Drop
            }) {
            diags.push(
              validation_diagnostic(
                "MHX_VALIDATE_TRIGGER_SYNC_CONFLICT",
                "Trigger queue modifiers overlap with sync queue strategy",
                "sync",
                Some("Prefer configuring queueing in one place."),
                None,
              ),
            )
          }
        _ => ()
      }
    }
    None => ()
  }
  match attrs.swap {
    Some(options) => diags.append(validate_swap(options))
    None => ()
  }
  match attrs.sync {
    Some(strategy) => diags.append(validate_sync(strategy))
    None => ()
  }
  match attrs.target {
    Some(selector) =>
      diags.append(
        validate_selector_with_target(
          selector,
          SelectorValidation::KnownExtendedSelector,
          "target",
        ),
      )
    None => ()
  }
  let methods = request_method_entries(attrs)
  if methods.length() > 1 {
    let method_names : Array[String] = []
    for request_attr in methods {
      match request_attr {
        (name, _value) => method_names.push(name)
      }
    }
    diags.push(
      validation_diagnostic(
        "MHX_VALIDATE_CONFLICTING_REQUEST_METHODS",
        "Element bundle contains multiple request method attributes",
        "attributes",
        Some("Keep only one of get/post/put/patch/delete."),
        Some(method_names.join(",")),
      ),
    )
  }
  for request_attr in methods {
    match request_attr {
      (name, value) =>
        if value.trim().is_empty() {
          diags.push(
            validation_diagnostic(
              "MHX_VALIDATE_EMPTY_REQUEST_URL",
              "Request URL must not be empty",
              name,
              Some("Provide a non-empty request URL."),
              None,
            ),
          )
        }
    }
  }
  diags
}
