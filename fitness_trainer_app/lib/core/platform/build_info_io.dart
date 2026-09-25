/// Native builds are not served from a website, so there is no deployed build
/// to compare against. See `build_info.dart`.
Future<String?> fetchDeployedBuildId() async => null;

/// Native builds pick up an update by restarting the app, so there is nothing
/// to do here even if the banner were somehow shown.
void reloadApp() {}
