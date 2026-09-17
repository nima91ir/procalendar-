import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/widgets/bottom_nav_bar.dart';
import 'package:fitness_trainer_app/features/clients/presentation/clients_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/add_edit_client_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/client_detail_screen.dart';
import 'package:fitness_trainer_app/features/templates/presentation/templates_screen.dart';
import 'package:fitness_trainer_app/features/templates/presentation/add_edit_template_screen.dart';
import 'package:fitness_trainer_app/features/tags/presentation/tags_screen.dart';
import 'package:fitness_trainer_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:fitness_trainer_app/features/settings/presentation/settings_screen.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/features/plans/presentation/add_plan_screen.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/past_attendance_screen.dart';

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
                  const Icon(Icons.storage_rounded, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'راه‌اندازی بانک اطلاعاتی ناموفق بود',
                    style: AppTypography.headlineMedium.copyWith(color: AppColors.onSurface),
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
      // Now driven by the (persisted) choice in Settings instead of being
      // hardcoded to ThemeMode.system.
      themeMode: ref.watch(themeModeProvider),
      // Force the Persian locale so the whole app lays out RTL even on
      // English/other system locales (previously it rendered LTR).
      locale: const Locale('fa', 'IR'),
      initialRoute: '/dashboard',
      onGenerateRoute: AppRouter.onGenerateRoute,
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
    MaterialPageRoute<dynamic> page(Widget child, {required int tab}) => MaterialPageRoute(
      settings: settings,
      // Every screen lives inside the shell so the nav bar is always visible;
      // `tab` pins the highlight for that screen. Sub-screens keep their
      // section highlighted and never move the selection on their own.
      builder: (_) => MainShell(tabIndex: tab, child: child),
    );

    if (name == AppRoutes.dashboard || name == '/') return page(const DashboardScreen(), tab: 0);
    if (name == AppRoutes.clients) return page(const ClientsScreen(), tab: 1);
    if (name == AppRoutes.templates) return page(const TemplatesScreen(), tab: 2);
    if (name == AppRoutes.tags) return page(const TagsScreen(), tab: 3);
    if (name == AppRoutes.settings) return page(const SettingsScreen(), tab: 4);
    if (name == AppRoutes.addClient) return page(const AddEditClientScreen(), tab: 1);
    if (name == AppRoutes.addTemplate) return page(const AddEditTemplateScreen(), tab: 2);

    final clientDetailId = _idFrom(name, AppRoutes.clientDetail);
    if (clientDetailId != null) return page(ClientDetailScreen(clientId: clientDetailId), tab: 1);
    final editClientId = _idFrom(name, AppRoutes.editClient);
    if (editClientId != null) return page(AddEditClientScreen(clientId: editClientId), tab: 1);
    final editTemplateId = _idFrom(name, AppRoutes.editTemplate);
    if (editTemplateId != null) return page(AddEditTemplateScreen(templateId: editTemplateId), tab: 2);
    final attendanceClientId = _idFrom(name, AppRoutes.attendance);
    if (attendanceClientId != null) return page(PastAttendanceScreen(clientId: attendanceClientId), tab: 1);
    final addPlanClientId = _idFrom(name, AppRoutes.addPlan);
    if (addPlanClientId != null) return page(AddPlanScreen(clientId: addPlanClientId), tab: 1);
    return null;
  }
}

/// Wraps every screen with the persistent bottom navigation bar.
///
/// The bar is always visible (dashboard, tabs *and* sub-screens like client
/// detail or attendance). `tabIndex` is passed per route, so the highlight
/// reflects *which screen you are on* and does not change by itself — tapping
/// another section pushes that screen (back preserves where you were).
class MainShell extends StatelessWidget {
  final Widget child;

  /// Index of the nav item highlighted for the wrapped screen
  /// (0 dashboard, 1 clients, 2 templates, 3 tags, 4 settings).
  final int tabIndex;

  const MainShell({super.key, required this.child, required this.tabIndex});

  static const _routes = [
    AppRoutes.dashboard,
    AppRoutes.clients,
    AppRoutes.templates,
    AppRoutes.tags,
    AppRoutes.settings,
  ];

  void _onTap(BuildContext context, int index) {
    if (index == tabIndex) return;
    // Switching sections *replaces* the stack instead of stacking routes on
    // top of each other. dashboard -> plans -> clients never accumulates
    // history, so there is no step-by-step back to walk through and tab
    // roots never show a back arrow. Sub-screens (client detail, forms,
    // attendance) are still pushed normally, so back returns from them.
    Navigator.pushNamedAndRemoveUntil(context, _routes[index], (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: tabIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}

class AppRoutes {
  static const dashboard = '/dashboard';
  static const clients = '/clients';
  static const clientDetail = '/clients/detail';
  static const addClient = '/clients/add';
  static const editClient = '/clients/edit';
  static const templates = '/templates';
  static const addTemplate = '/templates/add';
  static const editTemplate = '/templates/edit';
  static const tags = '/tags';
  static const settings = '/settings';
  static const attendance = '/attendance';
  static const addPlan = '/add-plan';
}
