// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Opens [url] in a new browser tab.
///
/// The bool reports whether this platform can open links **at all**, not whether
/// a tab appeared: `window.open` cannot say that, and neither can any other
/// browser API — the same limitation `kFileSaveIsVerifiable` documents for file
/// downloads. Callers must treat `true` as "asked", never as proof.
///
/// False is reserved for native, where there is no launcher and the caller
/// offers the address instead.
Future<bool> openExternalLink(String url) async {
  html.window.open(url, '_blank');
  return true;
}
