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
import 'package:fitness_trainer_app/features/accounting/providers/transactions_providers.dart';
import 'package:fitness_trainer_app/features/backup/presentation/import_backup_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/clients_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/add_edit_client_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/client_detail_screen.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/templates/presentation/templates_screen.dart';
import 'package:fitness_trainer_app/features/templates/presentation/add_edit_template_screen.dart';
import 'package:fitness_trainer_app/features/tags/presentation/tags_screen.dart';
import 'package:fitness_trainer_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/settings/presentation/settings_screen.dart';
import 'package:fitness_trainer_app/features/accounting/presentation/accounting_screen.dart';
import 'package:fitness_trainer_app/features/reports/presentation/reports_screen.dart';
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
    final accent = ref.watch(accentProvider);
    return MaterialApp(
      title: 'تقویم حرفه‌ای',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightForAccent(accent),
      darkTheme: AppTheme.darkForAccent(accent),
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
    MaterialPageRoute<dynamic> page(Widget child) =>
        MaterialPageRoute(
          settings: settings,
          builder: (_) => child,
        );

    // Tab roots. `MainShell` gives each tab its own nested `Navigator`, so the
    // router is also the generator for the four primary screens.
    if (name == AppRoutes.dashboard) return page(const DashboardScreen());
    if (name == AppRoutes.clients) return page(const ClientsScreen());
    if (name == AppRoutes.templates) return page(const TemplatesScreen());
    if (name == AppRoutes.settings) return page(const SettingsScreen());
    if (name == AppRoutes.accounting) return page(const AccountingScreen());
    if (name == AppRoutes.reports) return page(const ReportsScreen());

    if (name == AppRoutes.addClient) return page(const AddEditClientScreen());
    if (name == AppRoutes.addTemplate) return page(const AddEditTemplateScreen());
    if (name == AppRoutes.tags) return page(const TagsScreen());
    if (name == AppRoutes.importBackup) return page(const ImportBackupScreen());

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

/// Wraps the four primary screens with a persistent bottom navigation bar.
///
/// Each tab has its own nested [Navigator], so every tab keeps its own back
/// stack (a detail screen opened in one tab stays when you switch away and
/// back). The `IndexedStack` preserves each tab's state. A nested navigator
/// does not receive platform back events itself — the root navigator's first
/// route just bubbles them (which would exit the app) — so this widget
/// registers a [WidgetsBindingObserver] and forwards back presses to the
/// active tab's navigator, falling back to app exit when it has nothing left
/// to pop.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  static const _tabRoutes = [
    AppRoutes.dashboard,
    AppRoutes.clients,
    AppRoutes.templates,
    AppRoutes.accounting,
    AppRoutes.settings,
  ];

  final _tabNavigators =
      List.generate(_tabRoutes.length, (_) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Platform back button. [WidgetsApp.didPopRoute] runs first and pops the
  /// root navigator; its first route (this shell) bubbles, so it returns
  /// false and we get the event. Pop the active tab's stack instead, and only
  /// return false (letting the system close the app) when it is empty.
  @override
  Future<bool> didPopRoute() async {
    final index = ref.read(tabIndexProvider);
    final navigator = _tabNavigators[index].currentState;
    if (navigator == null || !navigator.canPop()) return false;
    return navigator.maybePop();
  }

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
        ref.invalidate(transactionsProvider);
        ref.invalidate(clientTransactionsProvider);
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
        children: [
          for (var i = 0; i < _tabRoutes.length; i++)
            Navigator(
              key: _tabNavigators[i],
              initialRoute: _tabRoutes[i],
              onGenerateRoute: AppRouter.onGenerateRoute,
              onUnknownRoute: AppRouter.onUnknownRoute,
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: currentIndex,
        onTap: (index) => ref.read(tabIndexProvider.notifier).select(index),
      ),
    );
  }
}

