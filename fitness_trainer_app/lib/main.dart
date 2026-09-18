import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/navigation/navigation_providers.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/core/widgets/bottom_nav_bar.dart';
import 'package:fitness_trainer_app/features/clients/presentation/clients_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/add_edit_client_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/client_detail_screen.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/templates/presentation/templates_screen.dart';
import 'package:fitness_trainer_app/features/templates/presentation/add_edit_template_screen.dart';
import 'package:fitness_trainer_app/features/tags/presentation/tags_screen.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/settings/presentation/settings_screen.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';
import 'package:fitness_trainer_app/features/plans/presentation/add_plan_screen.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/past_attendance_screen.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final db = await AppDatabase.create();
    runApp(ProviderScope(overrides: [
      databaseProvider.overrideWithValue(db),
    ], child: const ProCalendarApp()));
  } catch (error, stackTrace) {
    // Without this guard a database failure (corrupt file, unsupported
    // platform, missing sqlite3) produced a black screen with no UI.
    debugPrint('PRO CALENDAR: database initialisation failed -> $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(StartupErrorApp(message: error.toString()));
  }
}

/// Shown when the database cannot be opened, instead of a blank window.
class StartupErrorApp extends StatelessWidget {
  final String message;

  const StartupErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    return MaterialApp(
      title: 'تقویم حرفه‌ای',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storage_rounded, size: 64, color: t.error),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'راه‌اندازی بانک اطلاعاتی ناموفق بود',
                    style: AppTypography.headlineMedium.copyWith(color: t.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(message, style: AppTypography.bodySmall, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProCalendarApp extends ConsumerWidget {
  const ProCalendarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'تقویم حرفه‌ای',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      locale: Locale(ref.watch(languageProvider)),
      home: const MainShell(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
    );
  }
}

class AppRouter {
  /// Extracts the numeric id from a `prefix/<id>` route name, or null when the
  /// name is not that route.
  ///
  /// This replaces `name.startsWith(prefix)` + `int.parse(name.split('/').last)`,
  /// which crashed with `FormatException: Invalid radix-10 number` whenever the
  /// route had no id. Two real cases hit that:
  ///  * Flutter's deep-link handling asks for the *intermediate* route first
  ///    (`/clients/detail` before `/clients/detail/1`), so any browser URL /
  ///    restored route matching a detail path threw.
  ///  * Any `pushNamed` of a prefix without an id.
  static int? _idFrom(String? name, String prefix) {
    if (name == null || !name.startsWith('$prefix/')) return null;
    return int.tryParse(name.substring(prefix.length + 1));
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    MaterialPageRoute<dynamic> page(Widget child) => MaterialPageRoute(
      settings: settings,
      builder: (_) => child,
    );

    if (name == AppRoutes.addClient) return page(const AddEditClientScreen());
    if (name == AppRoutes.addTemplate) return page(const AddEditTemplateScreen());

    final clientDetailId = _idFrom(name, AppRoutes.clientDetail);
    if (clientDetailId != null) return page(ClientDetailScreen(clientId: clientDetailId));
    final editClientId = _idFrom(name, AppRoutes.editClient);
    if (editClientId != null) return page(AddEditClientScreen(clientId: editClientId));
    final editTemplateId = _idFrom(name, AppRoutes.editTemplate);
    if (editTemplateId != null) return page(AddEditTemplateScreen(templateId: editTemplateId));
    final attendanceClientId = _idFrom(name, AppRoutes.attendance);
    if (attendanceClientId != null) {
      final segments = (name ?? '').split('/');
      final planId = segments.length > 3 ? int.tryParse(segments[3]) : null;
      return page(PastAttendanceScreen(clientId: attendanceClientId, planId: planId));
    }
    final addPlanClientId = _idFrom(name, AppRoutes.addPlan);
    if (addPlanClientId != null) return page(AddPlanScreen(clientId: addPlanClientId));
    return null;
  }

  /// Instead of returning `null` (which throws "Could not find a generator for
  /// route" and blanks the app), unknown routes render a friendly page.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(),
        body: AppEmptyState(
          icon: Icons.explore_off_outlined,
          title: AppStrings.of(context).pageNotFound,
        ),
      ),
    );
  }
}

/// Wraps the five primary screens with a persistent bottom navigation bar.
///
/// Tab switching is handled by an `IndexedStack` so each tab's state is
/// preserved and there is no duplicate-route history.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _screens = [
    DashboardScreen(),
    ClientsScreen(),
    TemplatesScreen(),
    TagsScreen(),
    SettingsScreen(),
  ];

  void _invalidateTabProviders(int index) {
    switch (index) {
      case 0:
        ref.invalidate(totalClientsProvider);
        ref.invalidate(expiredPlansCountProvider);
        ref.invalidate(frozenPlansCountProvider);
        ref.invalidate(queuedPlansProvider);
        ref.invalidate(lowSessionPlansProvider);
        ref.invalidate(bonusSessionClientsProvider);
        ref.invalidate(todayAttendanceProvider);
        ref.invalidate(clientNamesProvider);
        break;
      case 1:
        ref.invalidate(allClientsProvider);
        ref.invalidate(clientsProvider);
        break;
      case 2:
        ref.invalidate(allTemplatesProvider);
        break;
      case 3:
        ref.invalidate(allTagsProvider);
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider);
    ref.listen<int>(tabIndexProvider, (previous, next) {
      if (previous != next) _invalidateTabProviders(next);
    });
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: currentIndex,
        onTap: (index) => ref.read(tabIndexProvider.notifier).select(index),
      ),
    );
  }
}

