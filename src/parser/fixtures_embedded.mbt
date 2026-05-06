///|
/// Generated from fixtures/ by scripts/embed_fixtures.py. Do not edit manually.

///|
let fixture_fixtures_compat_htmx_mhx_extensions_focus_scroll_json : String =
  #|{
  #|  "kind": "swap",
  #|  "show": "{strategy: OuterHTML, swap_delay: 0, settle_delay: 20, scroll: \"\", show: \"\", focus_scroll: true}",
  #|  "canonical": "outerHTML focus-scroll:true",
  #|  "diagnostic_codes": []
  #|}
  #|

///|
let fixture_fixtures_compat_htmx_mhx_extensions_focus_scroll_txt : String =
  #|outerHTML focus-scroll:true
  #|

///|
let fixture_fixtures_compat_htmx_swap_compatible_outerhtml_json : String =
  #|{
  #|  "kind": "swap",
  #|  "show": "{strategy: OuterHTML, swap_delay: 200, settle_delay: 20, scroll: \"\", show: \"\", focus_scroll: false}",
  #|  "canonical": "outerHTML swap:200ms",
  #|  "diagnostic_codes": []
  #|}
  #|

///|
let fixture_fixtures_compat_htmx_swap_compatible_outerhtml_txt : String =
  #|outerHTML swap:200ms
  #|

///|
let fixture_fixtures_compat_htmx_sync_compatible_queue_last_json : String =
  #|{
  #|  "kind": "sync",
  #|  "show": "Queue(Last)",
  #|  "canonical": "queue:last",
  #|  "diagnostic_codes": []
  #|}
  #|

///|
let fixture_fixtures_compat_htmx_sync_compatible_queue_last_txt : String =
  #|queue:last
  #|

///|
let fixture_fixtures_compat_htmx_trigger_compatible_click_once_json : String =
  #|{
  #|  "kind": "trigger",
  #|  "show": "[{event_name: \"click\", modifiers: [Once]}]",
  #|  "canonical": "click once",
  #|  "diagnostic_codes": []
  #|}
  #|

///|
let fixture_fixtures_compat_htmx_trigger_compatible_click_once_txt : String =
  #|click once
  #|

///|
let fixture_fixtures_compat_htmx_unsupported_trigger_closest_empty_json : String =
  #|{
  #|  "kind": "trigger",
  #|  "show": null,
  #|  "canonical": null,
  #|  "diagnostic_codes": ["MHX_PARSE_INVALID_SELECTOR"]
  #|}
  #|

///|
let fixture_fixtures_compat_htmx_unsupported_trigger_closest_empty_txt : String =
  #|click from:closest
  #|

///|
let fixture_fixtures_swap_golden_outerhtml_delay_json : String =
  #|{
  #|  "kind": "swap",
  #|  "show": "{strategy: OuterHTML, swap_delay: 1500, settle_delay: 50, scroll: \"\", show: \"\", focus_scroll: false}",
  #|  "canonical": "outerHTML swap:1500ms settle:50ms",
  #|  "diagnostic_codes": []
  #|}
  #|

///|
let fixture_fixtures_swap_golden_unknown_strategy_json : String =
  #|{
  #|  "kind": "swap",
  #|  "show": null,
  #|  "canonical": null,
  #|  "diagnostic_codes": ["MHX_PARSE_UNKNOWN_SWAP_STRATEGY"]
  #|}
  #|

///|
let fixture_fixtures_swap_invalid_unknown_strategy_txt : String =
  #|bogus
  #|

///|
let fixture_fixtures_swap_valid_outerhtml_delay_txt : String =
  #|outerHTML swap:1.5s settle:50ms
  #|

///|
let fixture_fixtures_sync_golden_queue_last_json : String =
  #|{
  #|  "kind": "sync",
  #|  "show": "Queue(Last)",
  #|  "canonical": "queue:last",
  #|  "diagnostic_codes": []
  #|}
  #|

///|
let fixture_fixtures_sync_golden_unknown_strategy_json : String =
  #|{
  #|  "kind": "sync",
  #|  "show": null,
  #|  "canonical": null,
  #|  "diagnostic_codes": ["MHX_PARSE_UNKNOWN_SYNC_STRATEGY"]
  #|}
  #|

///|
let fixture_fixtures_sync_invalid_unknown_strategy_txt : String =
  #|bogus
  #|

///|
let fixture_fixtures_sync_valid_queue_last_txt : String =
  #|queue last
  #|

///|
let fixture_fixtures_trigger_golden_click_once_delay_json : String =
  #|{
  #|  "kind": "trigger",
  #|  "show": "[{event_name: \"click\", modifiers: [Delay(1000), Once]}]",
  #|  "canonical": "click once delay:1000ms",
  #|  "diagnostic_codes": []
  #|}
  #|

///|
let fixture_fixtures_trigger_golden_from_closest_empty_json : String =
  #|{
  #|  "kind": "trigger",
  #|  "show": null,
  #|  "canonical": null,
  #|  "diagnostic_codes": ["MHX_PARSE_INVALID_SELECTOR"]
  #|}
  #|

///|
let fixture_fixtures_trigger_golden_multi_trigger_json : String =
  #|{
  #|  "kind": "trigger",
  #|  "show": "[{event_name: \"click\", modifiers: []}, {event_name: \"keyup\", modifiers: [Delay(100)]}]",
  #|  "canonical": "click, keyup delay:100ms",
  #|  "diagnostic_codes": []
  #|}
  #|

///|
let fixture_fixtures_trigger_invalid_from_closest_empty_txt : String =
  #|click from:closest
  #|

///|
let fixture_fixtures_trigger_valid_click_once_delay_txt : String =
  #|click delay:1s once
  #|

///|
let fixture_fixtures_trigger_valid_multi_trigger_txt : String =
  #|click, keyup delay:100ms
  #|

///|
let embedded_fixture_map : Map[String, String] = {
  "fixtures/compat/htmx/mhx-extensions/focus-scroll.json": fixture_fixtures_compat_htmx_mhx_extensions_focus_scroll_json,
  "fixtures/compat/htmx/mhx-extensions/focus-scroll.txt": fixture_fixtures_compat_htmx_mhx_extensions_focus_scroll_txt,
  "fixtures/compat/htmx/swap-compatible/outerhtml.json": fixture_fixtures_compat_htmx_swap_compatible_outerhtml_json,
  "fixtures/compat/htmx/swap-compatible/outerhtml.txt": fixture_fixtures_compat_htmx_swap_compatible_outerhtml_txt,
  "fixtures/compat/htmx/sync-compatible/queue-last.json": fixture_fixtures_compat_htmx_sync_compatible_queue_last_json,
  "fixtures/compat/htmx/sync-compatible/queue-last.txt": fixture_fixtures_compat_htmx_sync_compatible_queue_last_txt,
  "fixtures/compat/htmx/trigger-compatible/click-once.json": fixture_fixtures_compat_htmx_trigger_compatible_click_once_json,
  "fixtures/compat/htmx/trigger-compatible/click-once.txt": fixture_fixtures_compat_htmx_trigger_compatible_click_once_txt,
  "fixtures/compat/htmx/unsupported/trigger-closest-empty.json": fixture_fixtures_compat_htmx_unsupported_trigger_closest_empty_json,
  "fixtures/compat/htmx/unsupported/trigger-closest-empty.txt": fixture_fixtures_compat_htmx_unsupported_trigger_closest_empty_txt,
  "fixtures/swap/golden/outerhtml-delay.json": fixture_fixtures_swap_golden_outerhtml_delay_json,
  "fixtures/swap/golden/unknown-strategy.json": fixture_fixtures_swap_golden_unknown_strategy_json,
  "fixtures/swap/invalid/unknown-strategy.txt": fixture_fixtures_swap_invalid_unknown_strategy_txt,
  "fixtures/swap/valid/outerhtml-delay.txt": fixture_fixtures_swap_valid_outerhtml_delay_txt,
  "fixtures/sync/golden/queue-last.json": fixture_fixtures_sync_golden_queue_last_json,
  "fixtures/sync/golden/unknown-strategy.json": fixture_fixtures_sync_golden_unknown_strategy_json,
  "fixtures/sync/invalid/unknown-strategy.txt": fixture_fixtures_sync_invalid_unknown_strategy_txt,
  "fixtures/sync/valid/queue-last.txt": fixture_fixtures_sync_valid_queue_last_txt,
  "fixtures/trigger/golden/click-once-delay.json": fixture_fixtures_trigger_golden_click_once_delay_json,
  "fixtures/trigger/golden/from-closest-empty.json": fixture_fixtures_trigger_golden_from_closest_empty_json,
  "fixtures/trigger/golden/multi-trigger.json": fixture_fixtures_trigger_golden_multi_trigger_json,
  "fixtures/trigger/invalid/from-closest-empty.txt": fixture_fixtures_trigger_invalid_from_closest_empty_txt,
  "fixtures/trigger/valid/click-once-delay.txt": fixture_fixtures_trigger_valid_click_once_delay_txt,
  "fixtures/trigger/valid/multi-trigger.txt": fixture_fixtures_trigger_valid_multi_trigger_txt,
}

///|
pub fn embedded_fixture(path : String) -> String? {
  embedded_fixture_map.get(path)
}

///|
pub fn embedded_fixture_paths() -> Array[String] {
  [
    "fixtures/compat/htmx/mhx-extensions/focus-scroll.json", "fixtures/compat/htmx/mhx-extensions/focus-scroll.txt",
    "fixtures/compat/htmx/swap-compatible/outerhtml.json", "fixtures/compat/htmx/swap-compatible/outerhtml.txt",
    "fixtures/compat/htmx/sync-compatible/queue-last.json", "fixtures/compat/htmx/sync-compatible/queue-last.txt",
    "fixtures/compat/htmx/trigger-compatible/click-once.json", "fixtures/compat/htmx/trigger-compatible/click-once.txt",
    "fixtures/compat/htmx/unsupported/trigger-closest-empty.json", "fixtures/compat/htmx/unsupported/trigger-closest-empty.txt",
    "fixtures/swap/golden/outerhtml-delay.json", "fixtures/swap/golden/unknown-strategy.json",
    "fixtures/swap/invalid/unknown-strategy.txt", "fixtures/swap/valid/outerhtml-delay.txt",
    "fixtures/sync/golden/queue-last.json", "fixtures/sync/golden/unknown-strategy.json",
    "fixtures/sync/invalid/unknown-strategy.txt", "fixtures/sync/valid/queue-last.txt",
    "fixtures/trigger/golden/click-once-delay.json", "fixtures/trigger/golden/from-closest-empty.json",
    "fixtures/trigger/golden/multi-trigger.json", "fixtures/trigger/invalid/from-closest-empty.txt",
    "fixtures/trigger/valid/click-once-delay.txt", "fixtures/trigger/valid/multi-trigger.txt",
  ]
}
