///|
test "parse_sync_strategy keeps permissive defaults" {
  assert_eq(parse_sync_strategy("queue:first"), Queue(First))
  assert_eq(parse_sync_strategy("queue last"), Queue(Last))
  assert_eq(parse_sync_strategy("unknown"), Drop)
}

///|
test "SyncStrategy canonical serialization is stable" {
  inspect(SyncStrategy::Drop.to_spec_string(), content="drop")
  inspect(SyncStrategy::Replace.to_spec_string(), content="replace")
  inspect(
    SyncStrategy::Queue(QueueMode::Last).to_spec_string(),
    content="queue:last",
  )
}
