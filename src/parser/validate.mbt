///|
/// Selector validation modes for tooling-oriented checks.

///|
pub(all) enum SelectorValidation {
  None
  NonEmpty
  KnownExtendedSelector
} derive(Show, Eq)

///|
pub fn SelectorValidation::default() -> SelectorValidation {
  SelectorValidation::None
}

///|
fn validation_diagnostic(
  code : String,
  message : String,
  target : String,
  hint : String?,
  context : String?,
) -> Diagnostic {
  Diagnostic::new(code, message, target, Position::zero(), hint, context)
}

///|
fn validate_selector_with_target(
  selector : @trigger.Selector,
  mode : SelectorValidation,
  target : String,
) -> Array[Diagnostic] {
  match mode {
    SelectorValidation::None => []
    SelectorValidation::NonEmpty =>
      match selector {
        @trigger.Selector::Css(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_EMPTY_SELECTOR",
              "Selector must not be empty",
              target,
              Some("Provide a CSS selector or supported keyword."),
              None,
            ),
          ]
        @trigger.Selector::Closest(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_EMPTY_SELECTOR",
              "Selector must not be empty",
              target,
              Some(
                "Provide a CSS selector after the extended selector keyword.",
              ),
              None,
            ),
          ]
        @trigger.Selector::Find(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_EMPTY_SELECTOR",
              "Selector must not be empty",
              target,
              Some(
                "Provide a CSS selector after the extended selector keyword.",
              ),
              None,
            ),
          ]
        @trigger.Selector::Next(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_EMPTY_SELECTOR",
              "Selector must not be empty",
              target,
              Some(
                "Provide a CSS selector after the extended selector keyword.",
              ),
              None,
            ),
          ]
        @trigger.Selector::Previous(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_EMPTY_SELECTOR",
              "Selector must not be empty",
              target,
              Some(
                "Provide a CSS selector after the extended selector keyword.",
              ),
              None,
            ),
          ]
        _ => []
      }
    SelectorValidation::KnownExtendedSelector =>
      match selector {
        @trigger.Selector::Closest(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_INVALID_SELECTOR",
              "Extended selector `closest` requires a trailing selector",
              target,
              Some("Use forms like `closest .item`."),
              Some("closest"),
            ),
          ]
        @trigger.Selector::Find(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_INVALID_SELECTOR",
              "Extended selector `find` requires a trailing selector",
              target,
              Some("Use forms like `find .item`."),
              Some("find"),
            ),
          ]
        @trigger.Selector::Next(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_INVALID_SELECTOR",
              "Extended selector `next` requires a trailing selector",
              target,
              Some("Use forms like `next .row`."),
              Some("next"),
            ),
          ]
        @trigger.Selector::Previous(value) if value.trim().is_empty() =>
          [
            validation_diagnostic(
              "MHX_PARSE_INVALID_SELECTOR",
              "Extended selector `previous` requires a trailing selector",
              target,
              Some("Use forms like `previous .row`."),
              Some("previous"),
            ),
          ]
        _ =>
          validate_selector_with_target(
            selector,
            SelectorValidation::NonEmpty,
            target,
          )
      }
  }
}

///|
pub fn validate_selector(
  selector : @trigger.Selector,
  mode : SelectorValidation,
) -> Array[Diagnostic] {
  validate_selector_with_target(selector, mode, "selector")
}

///|
fn duplicate_modifier_diagnostic(name : String) -> Diagnostic {
  validation_diagnostic(
    "MHX_VALIDATE_DUPLICATE_TRIGGER_MODIFIER",
    "Trigger repeats modifier `\{name}`",
    "trigger",
    Some("Keep only one modifier of each kind."),
    Some(name),
  )
}

///|
fn duplicate_if_needed(name : String, count : Int) -> Array[Diagnostic] {
  if count > 1 {
    [duplicate_modifier_diagnostic(name)]
  } else {
    []
  }
}

///|
pub fn validate_trigger(trigger : @trigger.TriggerDef) -> Array[Diagnostic] {
  let diags : Array[Diagnostic] = []
  let mut once_count = 0
  let mut changed_count = 0
  let mut consume_count = 0
  let mut prevent_count = 0
  let mut delay_count = 0
  let mut throttle_count = 0
  let mut debounce_count = 0
  let mut from_count = 0
  let mut target_count = 0
  let mut queue_count = 0
  let mut filter_count = 0
  for modifier in trigger.modifiers {
    match modifier {
      @trigger.Modifier::Once => once_count += 1
      @trigger.Modifier::Changed => changed_count += 1
      @trigger.Modifier::Consume => consume_count += 1
      @trigger.Modifier::Prevent => prevent_count += 1
      @trigger.Modifier::Delay(_) => delay_count += 1
      @trigger.Modifier::Throttle(_) => throttle_count += 1
      @trigger.Modifier::Debounce(_) => debounce_count += 1
      @trigger.Modifier::From(selector) => {
        from_count += 1
        diags.append(
          validate_selector_with_target(
            selector,
            SelectorValidation::KnownExtendedSelector,
            "trigger.from",
          ),
        )
      }
      @trigger.Modifier::Target(selector) => {
        target_count += 1
        diags.append(
          validate_selector_with_target(
            selector,
            SelectorValidation::KnownExtendedSelector,
            "trigger.target",
          ),
        )
      }
      @trigger.Modifier::Queue(_) => queue_count += 1
      @trigger.Modifier::Filter(_) => filter_count += 1
    }
  }
  diags.append(duplicate_if_needed("once", once_count))
  diags.append(duplicate_if_needed("changed", changed_count))
  diags.append(duplicate_if_needed("consume", consume_count))
  diags.append(duplicate_if_needed("prevent", prevent_count))
  diags.append(duplicate_if_needed("delay", delay_count))
  diags.append(duplicate_if_needed("throttle", throttle_count))
  diags.append(duplicate_if_needed("debounce", debounce_count))
  diags.append(duplicate_if_needed("from", from_count))
  diags.append(duplicate_if_needed("target", target_count))
  diags.append(duplicate_if_needed("queue", queue_count))
  diags.append(duplicate_if_needed("filter", filter_count))
  diags
}

///|
pub fn validate_swap(options : @swap.SwapOptions) -> Array[Diagnostic] {
  let diags : Array[Diagnostic] = []
  if options.strategy is @swap.Strategy::None_ &&
    (
      options.swap_delay != 0 ||
      options.settle_delay != 20 ||
      !options.scroll.is_empty() ||
      !options.show.is_empty() ||
      options.focus_scroll
    ) {
    diags.push(
      validation_diagnostic(
        "MHX_VALIDATE_SWAP_STRATEGY_CONFLICT",
        "`none` swap strategy cannot be combined with swap modifiers",
        "swap",
        Some("Remove swap, settle, scroll, show, or focus-scroll modifiers."),
        None,
      ),
    )
  }
  if options.strategy is @swap.Strategy::Delete &&
    (
      !options.scroll.is_empty() ||
      !options.show.is_empty() ||
      options.focus_scroll
    ) {
    diags.push(
      validation_diagnostic(
        "MHX_VALIDATE_DELETE_SWAP_CONFLICT",
        "`delete` swap strategy does not use scroll/show/focus-scroll modifiers",
        "swap",
        Some("Remove modifiers that only apply when content is retained."),
        None,
      ),
    )
  }
  diags
}

///|
pub fn validate_sync(_sync : @sync.SyncStrategy) -> Array[Diagnostic] {
  []
}
