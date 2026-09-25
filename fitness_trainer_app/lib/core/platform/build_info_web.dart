// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

/// Reads the build id stamped next to the deployed app.
///
/// Returns null on any failure — offline, a 404 before the first stamped
/// deploy, or a malformed file. A version check that cannot run must stay
/// invisible rather than surface an error the user can do nothing about.
Future<String?> fetchDeployedBuildId() async {
  try {
    // `Uri.base` is the page URL, so this resolves under the app's base href
    // (`/procalendar-/`) without hardcoding it.
    final uri = Uri.base.resolve('build-id.json');
    // The cache-buster is the whole point: the service worker and the browser
    // both cache aggressively, and a cached copy would report the running
    // build and never detect the update.
    final busted = uri.replace(
      queryParameters: {'t': '${DateTime.now().millisecondsSinceEpoch}'},
    );
    final raw = await html.HttpRequest.getString('$busted');
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final id = decoded['buildId'];
    return id is String ? id : null;
  } catch (_) {
    return null;
  }
}

/// Reloads the page, which fetches the newly deployed build.
void reloadApp() => html.window.location.reload();
