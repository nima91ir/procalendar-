import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/providers/app_update.dart';

/// The update banner is the only thing that tells a user their long-open tab is
/// running stale code, so the decision behind it is worth pinning down: a
/// genuine mismatch means update, and anything *unknown* must stay silent.
void main() {
  Future<bool> pending({
    required String current,
    required String? deployed,
  }) async {
    final container = ProviderContainer(
      overrides: [
        currentBuildIdProvider.overrideWithValue(current),
        deployedBuildIdProvider.overrideWith((ref) async => deployed),
      ],
    );
    addTearDown(container.dispose);
    // Keep the autoDispose providers alive while the future resolves.
    final sub = container.listen(pendingUpdateProvider, (_, _) {});
    addTearDown(sub.close);
    return container.read(pendingUpdateProvider.future);
  }

  group('pendingUpdateProvider', () {
    test('is true when the site is serving a different build', () async {
      expect(await pending(current: 'aaa', deployed: 'bbb'), isTrue);
    });

    test('is false when the site is serving the same build', () async {
      expect(await pending(current: 'aaa', deployed: 'aaa'), isFalse);
    });

    test('is false when the deployed id is unknown', () async {
      // Offline, a 404 before the first stamped deploy, or a malformed file all
      // mean "cannot tell" — which must never show the banner.
      expect(await pending(current: 'aaa', deployed: null), isFalse);
      expect(await pending(current: 'aaa', deployed: ''), isFalse);
    });

    test('is false for a local build with no injected id', () async {
      // `flutter run` and this suite have no BUILD_ID, so the check stays off
      // entirely and the banner can never appear in development.
      expect(await pending(current: '', deployed: 'bbb'), isFalse);
    });
  });
}
