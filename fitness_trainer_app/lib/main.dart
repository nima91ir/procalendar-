import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/core/theme/app_theme.dart';
import 'package:fitness_trainer_app/core/widgets/bottom_nav_bar.dart';
import 'package:fitness_trainer_app/features/clients/presentation/clients_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/add_edit_client_screen.dart';
import 'package:fitness_trainer_app/features/clients/presentation/client_detail_screen.dart';
import 'package:fitness_trainer_app/features/templates/presentation/templates_screen.dart';
import 'package:fitness_trainer_app/features/templates/presentation/add_edit_template_screen.dart';
import 'package:fitness_trainer_app/features/tags/presentation/tags_screen.dart';
import 'package:fitness_trainer_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:fitness_trainer_app/features/settings/presentation/settings_screen.dart';
import 'package:fitness_trainer_app/features/plans/presentation/add_plan_screen.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/past_attendance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.create();
  runApp(ProviderScope(overrides: [
    databaseProvider.overrideWithValue(db),
  ], child: const ProCalendarApp()));
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
      themeMode: ThemeMode.system,
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
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final name = settings.name;

    if (name == AppRoutes.dashboard) {
      return MaterialPageRoute(builder: (_) => const MainShell(child: DashboardScreen()));
    }
    if (name == AppRoutes.clients) {
      return MaterialPageRoute(builder: (_) => const MainShell(child: ClientsScreen()));
    }
    if (name == AppRoutes.templates) {
      return MaterialPageRoute(builder: (_) => const MainShell(child: TemplatesScreen()));
    }
    if (name == AppRoutes.tags) {
      return MaterialPageRoute(builder: (_) => const MainShell(child: TagsScreen()));
    }
    if (name == AppRoutes.settings) {
      return MaterialPageRoute(builder: (_) => const MainShell(child: SettingsScreen()));
    }
    if (name != null && name.startsWith(AppRoutes.clientDetail)) {
      final clientId = int.parse(name.split('/').last);
      return MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: clientId));
    }
    if (name == AppRoutes.addClient) {
      return MaterialPageRoute(builder: (_) => const AddEditClientScreen());
    }
    if (name != null && name.startsWith(AppRoutes.editClient)) {
      final clientId = int.parse(name.split('/').last);
      return MaterialPageRoute(builder: (_) => AddEditClientScreen(clientId: clientId));
    }
    if (name == AppRoutes.addTemplate) {
      return MaterialPageRoute(builder: (_) => const AddEditTemplateScreen());
    }
    if (name != null && name.startsWith(AppRoutes.editTemplate)) {
      final templateId = int.parse(name.split('/').last);
      return MaterialPageRoute(builder: (_) => AddEditTemplateScreen(templateId: templateId));
    }
    if (name != null && name.startsWith(AppRoutes.attendance)) {
      final clientId = int.parse(name.split('/').last);
      return MaterialPageRoute(builder: (_) => PastAttendanceScreen(clientId: clientId));
    }
    if (name != null && name.startsWith(AppRoutes.addPlan)) {
      final clientId = int.parse(name.split('/').last);
      return MaterialPageRoute(builder: (_) => AddPlanScreen(clientId: clientId));
    }
    return null;
  }
}

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final name = ModalRoute.of(context)?.settings.name;
    if (name == null) return;
    if (name.startsWith('/clients')) {
      _selectedIndex = 1;
    } else if (name.startsWith('/templates')) {
      _selectedIndex = 2;
    } else if (name.startsWith('/tags')) {
      _selectedIndex = 3;
    } else if (name.startsWith('/settings')) {
      _selectedIndex = 4;
    } else {
      _selectedIndex = 0;
    }
  }

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.clients);
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.templates);
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.tags);
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
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
