import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/main.dart';

void main() {
  // StartupErrorApp builds its own MaterialApp and hardcodes Persian on
  // purpose: the chosen language lives in the database, and this screen only
  // appears when that database could not be used.
  testWidgets('storage failure says the data is safe and to relaunch', (
    tester,
  ) async {
    await tester.pumpWidget(const StartupErrorApp(storageUnavailable: true));

    expect(find.text(AppStrings.fa.storageUnavailableTitle), findsOneWidget);
    expect(find.text(AppStrings.fa.storageUnavailableMessage), findsOneWidget);
    // The generic wording would be wrong here: nothing "failed to set up", the
    // data is simply out of reach.
    expect(find.text(AppStrings.fa.databaseFailedTitle), findsNothing);
  });

  testWidgets('a generic failure is unchanged', (tester) async {
    await tester.pumpWidget(const StartupErrorApp(message: 'boom'));

    expect(find.text(AppStrings.fa.databaseFailedTitle), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);
    expect(find.text(AppStrings.fa.storageUnavailableTitle), findsNothing);
  });
}
