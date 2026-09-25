// Tells the running app whether the deployed site is newer than the build it
// was compiled from.
//
// `deploy.yml` compiles with `--dart-define=BUILD_ID=<commit sha>` and writes
// the same sha into `build-id.json`, deployed next to the app. Comparing the two
// is how a tab that has been open for a long time finds out that a new version
// was published — the service worker only swaps the app in when the page is
// loaded again, so an open tab keeps running old code indefinitely.
//
// `dart.library.html` is true on Web and false on native (the same gate
// `file_transfer.dart` uses), so native builds get the no-op implementation.
export 'build_info_io.dart' if (dart.library.html) 'build_info_web.dart';
