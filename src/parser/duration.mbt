///|
/// Shared duration parsing and formatting helpers used by spec parsers.

///|
fn is_ascii_letter(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
}

///|
fn pow10(n : Int) -> Int {
  let mut result = 1
  for _i = 0; _i < n; _i = _i + 1 {
    result = result * 10
  }
  result
}

///|
fn parse_digits(
  numeric : String,
  full_input : String,
  offset : Int,
) -> Int raise ParseError {
  if numeric.is_empty() {
    raise MalformedDuration(
      pos=Position::at(offset, full_input),
      value=full_input,
      reason="missing numeric component",
    )
  }
  let mut result = 0
  for i = 0; i < numeric.length(); i = i + 1 {
    match numeric.get_char(i) {
      Some(c) if c >= '0' && c <= '9' =>
        result = result * 10 + (c.to_int() - '0'.to_int())
      _ =>
        raise MalformedDuration(
          pos=Position::at(offset + i, full_input),
          value=full_input,
          reason="non-digit in numeric component",
        )
    }
  }
  result
}

///|
/// Parse a duration into milliseconds.
///
/// Accepted inputs:
/// - `100`
/// - `100ms`
/// - `1s`
/// - `1.5s`
pub fn parse_duration_ms(input : String) -> Int raise ParseError {
  let trimmed = input.trim().to_string()
  if trimmed.is_empty() {
    raise MalformedDuration(
      pos=Position::zero(),
      value=input,
      reason="empty value",
    )
  }
  if trimmed.has_prefix("-") {
    raise MalformedDuration(
      pos=Position::zero(),
      value=trimmed,
      reason="negative durations are not supported",
    )
  }
  let unit = if trimmed.has_suffix("ms") {
    "ms"
  } else if trimmed.has_suffix("s") {
    "s"
  } else {
    match trimmed.get_char(trimmed.length() - 1) {
      Some(c) if is_ascii_letter(c) =>
        raise MalformedDuration(
          pos=Position::at(trimmed.length() - 1, trimmed),
          value=trimmed,
          reason="unknown duration unit",
        )
      _ => ""
    }
  }
  let numeric = match unit {
    "ms" => trimmed[:trimmed.length() - 2].to_string()
    "s" => trimmed[:trimmed.length() - 1].to_string()
    _ => trimmed
  }
  if numeric.is_empty() {
    raise MalformedDuration(
      pos=Position::zero(),
      value=trimmed,
      reason="missing numeric component",
    )
  }
  match numeric.find(".") {
    Some(dot_index) => {
      if unit != "s" {
        raise MalformedDuration(
          pos=Position::at(dot_index, trimmed),
          value=trimmed,
          reason="fractional durations require the `s` unit",
        )
      }
      let whole_str = numeric[:dot_index].to_string()
      let frac_str = numeric[dot_index + 1:].to_string()
      if whole_str.is_empty() || frac_str.is_empty() {
        raise MalformedDuration(
          pos=Position::at(dot_index, trimmed),
          value=trimmed,
          reason="malformed decimal duration",
        )
      }
      let whole = parse_digits(whole_str, trimmed, 0)
      let fraction = parse_digits(frac_str, trimmed, dot_index + 1)
      whole * 1000 + fraction * 1000 / pow10(frac_str.length())
    }
    None => {
      let whole = parse_digits(numeric, trimmed, 0)
      match unit {
        "s" => whole * 1000
        _ => whole
      }
    }
  }
}

///|
pub fn format_duration_ms(ms : Int) -> String {
  "\{ms}ms"
}
