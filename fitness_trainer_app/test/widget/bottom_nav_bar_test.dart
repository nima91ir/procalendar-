import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('BottomNavBar renders all five items', (WidgetTester tester) async {
    int selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(
            selectedIndex: selectedIndex,
            onTap: (index) {
              selectedIndex = index;
            },
          ),
        ),
      ),
    );

    expect(find.text('داشبورد'), findsOneWidget);
    expect(find.text('مشتریان'), findsOneWidget);
    expect(find.text('برنامه‌ها'), findsOneWidget);
    expect(find.text('حسابداری'), findsOneWidget);
    expect(find.text('تنظیمات'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsNothing);

    await tester.tap(find.text('مشتریان'));
    expect(selectedIndex, 1);
  });
}
