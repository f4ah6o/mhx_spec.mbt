///|
fn fixture_content(path : String) -> String raise {
  match embedded_fixture(path) {
    Some(content) => content
    None => fail("missing embedded fixture: \{path}")
  }
}

///|
fn fixture_json(path : String) -> Json raise {
  @json.parse(fixture_content(path)) catch {
    _ => fail("invalid fixture json: \{path}")
  }
}

///|
fn json_object_field(json : Json, key : String) -> Json raise {
  match json {
    Object(map) =>
      match map.get(key) {
        Some(value) => value
        None => fail("missing json field: \{key}")
      }
    _ => fail("expected object json")
  }
}

///|
fn json_string_field(json : Json, key : String) -> String raise {
  match json_object_field(json, key) {
    String(value) => value
    _ => fail("expected string field: \{key}")
  }
}

///|
fn json_optional_string_field(json : Json, key : String) -> String? raise {
  match json_object_field(json, key) {
    Null => None
    String(value) => Some(value)
    _ => fail("expected nullable string field: \{key}")
  }
}

///|
fn json_string_array_field(json : Json, key : String) -> Array[String] raise {
  match json_object_field(json, key) {
    Array(values) => {
      let strings : Array[String] = []
      for value in values {
        match value {
          String(text) => strings.push(text)
          _ => fail("expected string array entry in field: \{key}")
        }
      }
      strings
    }
    _ => fail("expected array field: \{key}")
  }
}

///|
fn trigger_canonical(triggers : Array[@trigger.TriggerDef]) -> String {
  triggers.map(fn(trigger) { trigger.to_spec_string() }).join(", ")
}

///|
fn diagnostic_codes(diags : Array[Diagnostic]) -> Array[String] {
  let codes : Array[String] = []
  for diag in diags {
    codes.push(diag.code)
  }
  codes
}

///|
fn evaluate_fixture(
  kind : String,
  input : String,
) -> (String?, String?, Array[String]) raise {
  match kind {
    "trigger" => {
      let result : Result[Array[@trigger.TriggerDef], ParseError] = try? parse_trigger(
        input,
      )
      match result {
        Err(err) => (None, None, [err.to_diagnostic(target="trigger").code])
        Ok(triggers) => {
          let diags : Array[Diagnostic] = []
          for trigger in triggers {
            diags.append(validate_trigger(trigger))
          }
          let codes = diagnostic_codes(diags)
          if codes.is_empty() {
            (Some("\{triggers}"), Some(trigger_canonical(triggers)), codes)
          } else {
            (None, None, codes)
          }
        }
      }
    }
    "swap" => {
      let result : Result[@swap.SwapOptions, ParseError] = try? parse_swap(
        input,
      )
      match result {
        Err(err) => (None, None, [err.to_diagnostic(target="swap").code])
        Ok(options) => {
          let codes = diagnostic_codes(validate_swap(options))
          if codes.is_empty() {
            (Some("\{options}"), Some(options.to_spec_string()), codes)
          } else {
            (None, None, codes)
          }
        }
      }
    }
    "sync" => {
      let result : Result[@sync.SyncStrategy, ParseError] = try? parse_sync(
        input,
      )
      match result {
        Err(err) => (None, None, [err.to_diagnostic(target="sync").code])
        Ok(strategy) => {
          let codes = diagnostic_codes(validate_sync(strategy))
          if codes.is_empty() {
            (Some("\{strategy}"), Some(strategy.to_spec_string()), codes)
          } else {
            (None, None, codes)
          }
        }
      }
    }
    _ => fail("unsupported fixture kind: \{kind}")
  }
}

///|
fn assert_fixture(input_path : String, golden_path : String) -> Unit raise {
  let expected = fixture_json(golden_path)
  let kind = json_string_field(expected, "kind")
  let expected_show = json_optional_string_field(expected, "show")
  let expected_canonical = json_optional_string_field(expected, "canonical")
  let expected_codes = json_string_array_field(expected, "diagnostic_codes")
  let (actual_show, actual_canonical, actual_codes) = evaluate_fixture(
    kind,
    fixture_content(input_path),
  )
  assert_eq(actual_show, expected_show)
  assert_eq(actual_canonical, expected_canonical)
  assert_eq(actual_codes, expected_codes)
}

///|
test "golden fixtures cover trigger swap and sync contracts" {
  assert_fixture(
    "fixtures/trigger/valid/click-once-delay.txt", "fixtures/trigger/golden/click-once-delay.json",
  )
  assert_fixture(
    "fixtures/trigger/valid/multi-trigger.txt", "fixtures/trigger/golden/multi-trigger.json",
  )
  assert_fixture(
    "fixtures/trigger/invalid/from-closest-empty.txt", "fixtures/trigger/golden/from-closest-empty.json",
  )
  assert_fixture(
    "fixtures/swap/valid/outerhtml-delay.txt", "fixtures/swap/golden/outerhtml-delay.json",
  )
  assert_fixture(
    "fixtures/swap/invalid/unknown-strategy.txt", "fixtures/swap/golden/unknown-strategy.json",
  )
  assert_fixture(
    "fixtures/sync/valid/queue-last.txt", "fixtures/sync/golden/queue-last.json",
  )
  assert_fixture(
    "fixtures/sync/invalid/unknown-strategy.txt", "fixtures/sync/golden/unknown-strategy.json",
  )
}

///|
test "compat fixtures cover supported subset unsupported syntax and mhx extensions" {
  assert_fixture(
    "fixtures/compat/htmx/trigger-compatible/click-once.txt", "fixtures/compat/htmx/trigger-compatible/click-once.json",
  )
  assert_fixture(
    "fixtures/compat/htmx/swap-compatible/outerhtml.txt", "fixtures/compat/htmx/swap-compatible/outerhtml.json",
  )
  assert_fixture(
    "fixtures/compat/htmx/sync-compatible/queue-last.txt", "fixtures/compat/htmx/sync-compatible/queue-last.json",
  )
  assert_fixture(
    "fixtures/compat/htmx/unsupported/trigger-closest-empty.txt", "fixtures/compat/htmx/unsupported/trigger-closest-empty.json",
  )
  assert_fixture(
    "fixtures/compat/htmx/mhx-extensions/focus-scroll.txt", "fixtures/compat/htmx/mhx-extensions/focus-scroll.json",
  )
}
