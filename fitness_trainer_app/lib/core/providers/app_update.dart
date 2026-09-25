import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/platform/build_info.dart';

/// The id this build was compiled with, injected by `deploy.yml` as
/// `--dart-define=BUILD_ID=<commit sha>`.
///
/// Empty for a local `flutter run` and for any build that did not pass the
/// define, which is what keeps the update check off entirely in development.
const String kBuildId = String.fromEnvironment('BUILD_ID');

/// Overridable so a test can pretend a specific build is running.
final currentBuildIdProvider = Provider<String>((ref) => kBuildId);

/// The id the deployed site is currently serving, or null when the check
/// cannot run (see `build_info.dart`).
final deployedBuildIdProvider = FutureProvider.autoDispose<String?>(
  (ref) => fetchDeployedBuildId(),
);

/// True when the site is serving a build other than the one running.
///
/// A null or empty deployed id means "could not tell", which is not an update
/// — the banner must never appear just because the network was down.
final pendingUpdateProvider = FutureProvider.autoDispose<bool>((ref) async {
  final current = ref.watch(currentBuildIdProvider);
  if (current.isEmpty) return false;
  final deployed = await ref.watch(deployedBuildIdProvider.future);
  return deployed != null && deployed.isNotEmpty && deployed != current;
});
