///|
test "shared duration parser accepts supported formats" {
  assert_eq(parse_duration_ms("100"), 100)
  assert_eq(parse_duration_ms("100ms"), 100)
  assert_eq(parse_duration_ms("1s"), 1000)
  assert_eq(parse_duration_ms("1.5s"), 1500)
  inspect(format_duration_ms(1500), content="1500ms")
}

///|
test "diagnostic v1 reports stable code and position for malformed duration" {
  let result : Result[Int, ParseError] = try? parse_duration_ms("1mss")
  match result {
    Ok(_) => fail("expected malformed duration error")
    Err(err) =>
      json_inspect(err.to_diagnostic(target="duration"), content={
        "code": "MHX_PARSE_MALFORMED_DURATION",
        "message": "Malformed duration `1mss`",
        "target": "duration",
        "position": { "offset": 1, "char": "m" },
        "hint": ["Use `100`, `100ms`, `1s`, or `1.5s`."],
        "context": ["non-digit in numeric component"],
      })
  }
}

///|
test "strict swap parser preserves canonical form and round-trips" {
  let options = parse_swap("outerHTML swap:1.5s settle:100ms scroll:top")
  inspect(
    options.to_spec_string(),
    content="outerHTML swap:1500ms settle:100ms scroll:top",
  )
  let round_tripped = parse_swap(options.to_spec_string())
  assert_eq(round_tripped, options)
}

///|
test "permissive swap parser remains available" {
  let strict_result : Result[@swap.SwapOptions, ParseError] = try? parse_swap(
    "bogus",
  )
  match strict_result {
    Err(msg) =>
      assert_eq(
        msg,
        UnknownSwapStrategy(pos=Position::at(0, "bogus"), value="bogus"),
      )
    Ok(_) => fail("expected error")
  }
  let permissive = parse_swap_or_default("bogus unknown:value")
  assert_eq(permissive.strategy, @swap.Strategy::InnerHTML)
}

///|
test "strict sync parser preserves canonical form and round-trips" {
  let sync = parse_sync("queue last")
  inspect(sync.to_spec_string(), content="queue:last")
  let round_tripped = parse_sync(sync.to_spec_string())
  assert_eq(round_tripped, sync)
}

///|
test "permissive sync parser remains available" {
  let strict_result : Result[@sync.SyncStrategy, ParseError] = try? parse_sync(
    "bogus",
  )
  match strict_result {
    Err(msg) =>
      assert_eq(
        msg,
        UnknownSyncStrategy(pos=Position::at(0, "bogus"), value="bogus"),
      )
    Ok(_) => fail("expected error")
  }
  assert_eq(parse_sync_or_default("bogus"), @sync.SyncStrategy::Drop)
}
