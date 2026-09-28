/// Native builds have no way to launch a URL: that needs a package, and this
/// project does not add them. Callers fall back to copying the address so the
/// user can paste it into a browser.
Future<bool> openExternalLink(String url) async => false;
