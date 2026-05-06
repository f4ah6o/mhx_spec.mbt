///|
/// Canonical duration formatting — single source of truth for spec output.

///|
/// Format milliseconds to canonical string.
///
/// Always renders as `{ms}ms`. Caller must ensure `ms >= 0`;
/// callers that construct durations from typed spec values are expected
/// to guarantee non-negative input. If a caller path might supply a
/// negative value it must guard before calling this function.
pub fn format_duration_ms(ms : Int) -> String {
  "\{ms}ms"
}
