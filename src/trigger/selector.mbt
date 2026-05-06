///|
/// Selector types for targeting elements in trigger definitions
/// Used in modifiers like `from:`, `target:`, etc.

///|
/// Represents a CSS selector or special element reference
pub(all) enum Selector {
  /// The element itself (default)
  This
  /// document.body
  Body
  /// window object
  Window
  /// document object
  Document
  /// Find closest ancestor matching selector
  Closest(String)
  /// Find descendant matching selector
  Find(String)
  /// Find next sibling matching selector
  Next(String)
  /// Find previous sibling matching selector
  Previous(String)
  /// Arbitrary CSS selector
  Css(String)
} derive(Show, Eq)

///|
pub impl ToJson for Selector with to_json(self) {
  match self {
    This => "this".to_json()
    Body => "body".to_json()
    Window => "window".to_json()
    Document => "document".to_json()
    Closest(s) => { "closest": s.to_json() }
    Find(s) => { "find": s.to_json() }
    Next(s) => { "next": s.to_json() }
    Previous(s) => { "previous": s.to_json() }
    Css(s) => { "css": s.to_json() }
  }
}

///|
pub fn Selector::to_spec_string(self : Selector) -> String {
  match self {
    This => "this"
    Body => "body"
    Window => "window"
    Document => "document"
    Closest(s) =>
      if s.trim().is_empty() {
        "closest"
      } else {
        "closest " + s.trim().to_string()
      }
    Find(s) =>
      if s.trim().is_empty() {
        "find"
      } else {
        "find " + s.trim().to_string()
      }
    Next(s) =>
      if s.trim().is_empty() {
        "next"
      } else {
        "next " + s.trim().to_string()
      }
    Previous(s) =>
      if s.trim().is_empty() {
        "previous"
      } else {
        "previous " + s.trim().to_string()
      }
    Css(s) => s.trim().to_string()
  }
}
