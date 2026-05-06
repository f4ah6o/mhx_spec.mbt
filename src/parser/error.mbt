///|
/// Parse error types with position information
/// Provides detailed error messages for debugging

///|
/// Position in the input string
pub(all) struct Position {
  offset : Int
  /// The character at this position (if available)
  char : Char
} derive(Show, Eq)

///|
pub impl ToJson for Position with to_json(self) {
  { "offset": self.offset.to_json(), "char": self.char.to_string().to_json() }
}

///|
pub fn Position::zero() -> Position {
  { offset: 0, char: '\u0000' }
}

///|
pub fn Position::shift(
  self : Position,
  offset : Int,
  input : String,
) -> Position {
  Position::at(self.offset + offset, input)
}

///|
pub struct Diagnostic {
  code : String
  message : String
  target : String
  position : Position
  hint : String?
  context : String?
} derive(Show, Eq)

///|
pub impl ToJson for Diagnostic with to_json(self) {
  {
    "code": self.code.to_json(),
    "message": self.message.to_json(),
    "target": self.target.to_json(),
    "position": self.position.to_json(),
    "hint": self.hint.to_json(),
    "context": self.context.to_json(),
  }
}

///|
pub fn Diagnostic::new(
  code : String,
  message : String,
  target : String,
  position : Position,
  hint : String?,
  context : String?,
) -> Diagnostic {
  { code, message, target, position, hint, context }
}

///|
/// Parse error with position and message
pub(all) suberror ParseError {
  UnexpectedChar(pos~ : Position, expected~ : String)
  UnexpectedEnd(pos~ : Position, expected~ : String)
  InvalidNumber(pos~ : Position, value~ : String)
  InvalidModifier(pos~ : Position, name~ : String)
  InvalidSelector(pos~ : Position, value~ : String)
  UnknownSwapModifier(pos~ : Position, name~ : String)
  UnknownSwapStrategy(pos~ : Position, value~ : String)
  UnknownSyncStrategy(pos~ : Position, value~ : String)
  MalformedDuration(pos~ : Position, value~ : String, reason~ : String)
} derive(Show, Eq)

///|
pub impl ToJson for ParseError with to_json(self) {
  match self {
    UnexpectedChar(pos~, expected~) =>
      {
        "type": "UnexpectedChar",
        "pos": pos.to_json(),
        "expected": expected.to_json(),
      }
    UnexpectedEnd(pos~, expected~) =>
      {
        "type": "UnexpectedEnd",
        "pos": pos.to_json(),
        "expected": expected.to_json(),
      }
    InvalidNumber(pos~, value~) =>
      {
        "type": "InvalidNumber",
        "pos": pos.to_json(),
        "value": value.to_json(),
      }
    InvalidModifier(pos~, name~) =>
      {
        "type": "InvalidModifier",
        "pos": pos.to_json(),
        "name": name.to_json(),
      }
    InvalidSelector(pos~, value~) =>
      {
        "type": "InvalidSelector",
        "pos": pos.to_json(),
        "value": value.to_json(),
      }
    UnknownSwapModifier(pos~, name~) =>
      {
        "type": "UnknownSwapModifier",
        "pos": pos.to_json(),
        "name": name.to_json(),
      }
    UnknownSwapStrategy(pos~, value~) =>
      {
        "type": "UnknownSwapStrategy",
        "pos": pos.to_json(),
        "value": value.to_json(),
      }
    UnknownSyncStrategy(pos~, value~) =>
      {
        "type": "UnknownSyncStrategy",
        "pos": pos.to_json(),
        "value": value.to_json(),
      }
    MalformedDuration(pos~, value~, reason~) =>
      {
        "type": "MalformedDuration",
        "pos": pos.to_json(),
        "value": value.to_json(),
        "reason": reason.to_json(),
      }
  }
}

///|
/// Create a position at the given offset
pub fn Position::at(offset : Int, input : String) -> Position {
  let char = if offset < input.length() {
    match input.get_char(offset) {
      Some(c) => c
      None => '\u0000'
    }
  } else {
    '\u0000'
  }
  { offset, char }
}

///|
pub fn ParseError::shift(
  self : ParseError,
  offset : Int,
  input : String,
) -> ParseError {
  match self {
    UnexpectedChar(pos~, expected~) =>
      UnexpectedChar(pos=pos.shift(offset, input), expected~)
    UnexpectedEnd(pos~, expected~) =>
      UnexpectedEnd(pos=pos.shift(offset, input), expected~)
    InvalidNumber(pos~, value~) =>
      InvalidNumber(pos=pos.shift(offset, input), value~)
    InvalidModifier(pos~, name~) =>
      InvalidModifier(pos=pos.shift(offset, input), name~)
    InvalidSelector(pos~, value~) =>
      InvalidSelector(pos=pos.shift(offset, input), value~)
    UnknownSwapModifier(pos~, name~) =>
      UnknownSwapModifier(pos=pos.shift(offset, input), name~)
    UnknownSwapStrategy(pos~, value~) =>
      UnknownSwapStrategy(pos=pos.shift(offset, input), value~)
    UnknownSyncStrategy(pos~, value~) =>
      UnknownSyncStrategy(pos=pos.shift(offset, input), value~)
    MalformedDuration(pos~, value~, reason~) =>
      MalformedDuration(pos=pos.shift(offset, input), value~, reason~)
  }
}

///|
pub fn ParseError::to_diagnostic(
  self : ParseError,
  target? : String = "input",
) -> Diagnostic {
  match self {
    UnexpectedChar(pos~, expected~) =>
      Diagnostic::new(
        "MHX_PARSE_UNEXPECTED_CHAR",
        "Unexpected character while parsing \{expected}",
        target,
        pos,
        Some("Check the current token and expected syntax."),
        Some(expected),
      )
    UnexpectedEnd(pos~, expected~) =>
      Diagnostic::new(
        "MHX_PARSE_UNEXPECTED_END",
        "Unexpected end of input while parsing \{expected}",
        target,
        pos,
        Some("Provide the missing value or delimiter."),
        Some(expected),
      )
    InvalidNumber(pos~, value~) =>
      Diagnostic::new(
        "MHX_PARSE_INVALID_NUMBER",
        "Invalid number value `\{value}`",
        target,
        pos,
        Some("Use digits only."),
        Some(value),
      )
    InvalidModifier(pos~, name~) =>
      Diagnostic::new(
        "MHX_PARSE_INVALID_MODIFIER",
        "Invalid modifier `\{name}`",
        target,
        pos,
        Some("Use a supported modifier name and syntax."),
        Some(name),
      )
    InvalidSelector(pos~, value~) =>
      Diagnostic::new(
        "MHX_PARSE_INVALID_SELECTOR",
        "Invalid selector `\{value}`",
        target,
        pos,
        Some("Use a non-empty CSS selector or supported extended selector."),
        Some(value),
      )
    UnknownSwapModifier(pos~, name~) =>
      Diagnostic::new(
        "MHX_PARSE_UNKNOWN_SWAP_MODIFIER",
        "Unknown swap modifier `\{name}`",
        target,
        pos,
        Some("Use swap, settle, scroll, show, or focus-scroll."),
        Some(name),
      )
    UnknownSwapStrategy(pos~, value~) =>
      Diagnostic::new(
        "MHX_PARSE_UNKNOWN_SWAP_STRATEGY",
        "Unknown swap strategy `\{value}`",
        target,
        pos,
        Some(
          "Use innerHTML, outerHTML, beforebegin, afterbegin, beforeend, afterend, delete, or none.",
        ),
        Some(value),
      )
    UnknownSyncStrategy(pos~, value~) =>
      Diagnostic::new(
        "MHX_PARSE_UNKNOWN_SYNC_STRATEGY",
        "Unknown sync strategy `\{value}`",
        target,
        pos,
        Some("Use drop, replace, queue:first, queue:last, or queue:all."),
        Some(value),
      )
    MalformedDuration(pos~, value~, reason~) =>
      Diagnostic::new(
        "MHX_PARSE_MALFORMED_DURATION",
        "Malformed duration `\{value}`",
        target,
        pos,
        Some("Use `100`, `100ms`, `1s`, or `1.5s`."),
        Some(reason),
      )
  }
}
