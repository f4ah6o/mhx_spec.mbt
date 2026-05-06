///|
/// Sync strategy spec for mx-sync

///|
/// Sync strategies for request coordination
pub(all) enum SyncStrategy {
  /// Drop new requests if one is already in flight
  Drop
  /// Cancel existing request and start new one
  Replace
  /// Queue requests to run sequentially
  Queue(QueueMode)
} derive(Show, Eq)

///|
/// Queue behavior options
pub(all) enum QueueMode {
  /// First in, first out
  First
  /// Last in, first out (drop intermediate)
  Last
  /// Allow all in order
  All
} derive(Show, Eq)

///|
/// Parse sync strategy from attribute value
pub fn parse_sync_strategy(value : String) -> SyncStrategy {
  let v = value.to_lower().trim().to_string()
  match v {
    "drop" => SyncStrategy::Drop
    "replace" => SyncStrategy::Replace
    "queue" | "queue first" | "queue:first" =>
      SyncStrategy::Queue(QueueMode::First)
    "queue last" | "queue:last" => SyncStrategy::Queue(QueueMode::Last)
    "queue all" | "queue:all" => SyncStrategy::Queue(QueueMode::All)
    _ => SyncStrategy::Drop // default
  }
}

///|
pub fn QueueMode::to_spec_string(self : QueueMode) -> String {
  match self {
    First => "first"
    Last => "last"
    All => "all"
  }
}

///|
/// Debug / human-readable representation.
/// Not guaranteed to be stable; prefer `to_spec_string` for canonical output.
pub fn SyncStrategy::to_string(self : SyncStrategy) -> String {
  match self {
    Drop => "drop"
    Replace => "replace"
    Queue(mode) =>
      match mode {
        QueueMode::First => "queue first"
        QueueMode::Last => "queue last"
        QueueMode::All => "queue all"
      }
  }
}

///|
/// Canonical spec output for formatters, golden tests, and stable diffs.
pub fn SyncStrategy::to_spec_string(self : SyncStrategy) -> String {
  match self {
    Drop => "drop"
    Replace => "replace"
    Queue(mode) => "queue:" + mode.to_spec_string()
  }
}
