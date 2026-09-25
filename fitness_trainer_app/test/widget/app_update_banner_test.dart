import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/providers/app_update.dart';
import 'package:fitness_trainer_app/core/widgets/app_update_banner.dart';

/// Localized UI needs the locale wiring or `AppStrings.of` resolves to English
/// and the Persian finders below would never match.
Widget buildHarness({required String current, required String? deployed}) {
  final container = ProviderContainer(
    overrides: [
      currentBuildIdProvider.overrideWithValue(current),
      deployedBuildIdProvider.overrideWith((ref) async => deployed),
    ],
  );
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(body: Center(child: AppUpdateBanner())),
    ),
  );
}

void main() {
  group('AppUpdateBanner', () {
    testWidgets('offers a reload when the site serves a different build',
        (tester) async {
      await tester.pumpWidget(buildHarness(current: 'aaa', deployed: 'bbb'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.fa.updateAvailable), findsOneWidget);
      expect(find.text(AppStrings.fa.updateReload), findsOneWidget);

      // On the VM `reloadApp()` is a no-op, so tapping must simply not throw.
      await tester.tap(find.text(AppStrings.fa.updateReload));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders nothing when the build is current', (tester) async {
      await tester.pumpWidget(buildHarness(current: 'aaa', deployed: 'aaa'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.fa.updateAvailable), findsNothing);
    });

    testWidgets('renders nothing when the deployed id is unknown',
        (tester) async {
      await tester.pumpWidget(buildHarness(current: 'aaa', deployed: null));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.fa.updateAvailable), findsNothing);
    });

    testWidgets('renders nothing for a local build with no injected id',
        (tester) async {
      await tester.pumpWidget(buildHarness(current: '', deployed: 'bbb'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.fa.updateAvailable), findsNothing);
    });

    testWidgets('dismissing hides it for the session', (tester) async {
      await tester.pumpWidget(buildHarness(current: 'aaa', deployed: 'bbb'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.fa.updateAvailable), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.fa.updateAvailable), findsNothing);
    });
  });
}
