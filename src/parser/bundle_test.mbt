///|
test "selector validation detects empty and incomplete selectors" {
  json_inspect(
    validate_selector(@trigger.Selector::Css(""), SelectorValidation::NonEmpty),
    content=[
      {
        "code": "MHX_VALIDATE_EMPTY_SELECTOR",
        "message": "Selector must not be empty",
        "target": "selector",
        "position": { "offset": 0, "char": "\u0000" },
        "hint": ["Provide a CSS selector or supported keyword."],
        "context": null,
      },
    ],
  )
  json_inspect(
    validate_selector(
      @trigger.Selector::Closest(""),
      SelectorValidation::KnownExtendedSelector,
    ),
    content=[
      {
        "code": "MHX_VALIDATE_INVALID_SELECTOR",
        "message": "Extended selector `closest` requires a trailing selector",
        "target": "selector",
        "position": { "offset": 0, "char": "\u0000" },
        "hint": ["Use forms like `closest .item`."],
        "context": ["closest"],
      },
    ],
  )
}

///|
test "trigger validation detects duplicate modifiers" {
  let diags = validate_trigger(
    @trigger.TriggerDef::new("click", [
      @trigger.Modifier::Once,
      @trigger.Modifier::Once,
    ]),
  )
  json_inspect(diags, content=[
    {
      "code": "MHX_VALIDATE_DUPLICATE_TRIGGER_MODIFIER",
      "message": "Trigger repeats modifier `once`",
      "target": "trigger",
      "position": { "offset": 0, "char": "\u0000" },
      "hint": ["Keep only one modifier of each kind."],
      "context": ["once"],
    },
  ])
}

///|
test "bundle parser accepts normalized mhx attributes" {
  let attrs : Map[String, String] = {
    "hx-trigger": "click once delay:1s",
    "hx-swap": "outerHTML swap:1.5s",
    "hx-sync": "queue last",
    "hx-target": "closest .item",
    "hx-get": "/items",
  }
  let result = parse_attributes(attrs)
  match result {
    Err(diags) => fail("unexpected diagnostics: \{diags}")
    Ok(parsed) => {
      match parsed.trigger {
        Some(triggers) =>
          inspect(
            triggers[0].to_spec_string(),
            content="click once delay:1000ms",
          )
        None => fail("expected trigger")
      }
      match parsed.swap {
        Some(options) =>
          inspect(options.to_spec_string(), content="outerHTML swap:1500ms")
        None => fail("expected swap")
      }
      match parsed.sync {
        Some(strategy) =>
          inspect(strategy.to_spec_string(), content="queue:last")
        None => fail("expected sync")
      }
      inspect(parsed.target, content="Some(Closest(\".item\"))")
      inspect(parsed.get, content="Some(\"/items\")")
    }
  }
}

///|
test "bundle parser reports unknown mhx attributes with stable diagnostics" {
  let attrs : Map[String, String] = { "hx-unknown": "value" }
  let result = parse_attributes(attrs)
  match result {
    Ok(_) => fail("expected diagnostics")
    Err(diags) =>
      json_inspect(diags, content=[
        {
          "code": "MHX_VALIDATE_UNKNOWN_ATTRIBUTE",
          "message": "Unknown mhx attribute `hx-unknown`",
          "target": "hx-unknown",
          "position": { "offset": 0, "char": "\u0000" },
          "hint": [
            "Use trigger, swap, sync, target, get, post, put, patch, or delete.",
          ],
          "context": null,
        },
      ])
  }
}

///|
test "bundle validation detects request conflicts and selector issues" {
  let attrs = {
    ..MhxAttributes::default(),
    target: Some(@trigger.Selector::Closest("")),
    get: Some("/items"),
    post: Some(""),
  }
  json_inspect(validate_attributes(attrs), content=[
    {
      "code": "MHX_VALIDATE_INVALID_SELECTOR",
      "message": "Extended selector `closest` requires a trailing selector",
      "target": "target",
      "position": { "offset": 0, "char": "\u0000" },
      "hint": ["Use forms like `closest .item`."],
      "context": ["closest"],
    },
    {
      "code": "MHX_VALIDATE_CONFLICTING_REQUEST_METHODS",
      "message": "Element bundle contains multiple request method attributes",
      "target": "attributes",
      "position": { "offset": 0, "char": "\u0000" },
      "hint": ["Keep only one of get/post/put/patch/delete."],
      "context": ["get,post"],
    },
    {
      "code": "MHX_VALIDATE_EMPTY_REQUEST_URL",
      "message": "Request URL must not be empty",
      "target": "post",
      "position": { "offset": 0, "char": "\u0000" },
      "hint": ["Provide a non-empty request URL."],
      "context": null,
    },
  ])
}
