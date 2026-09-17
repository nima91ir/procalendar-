# PRO CALENDAR — New Flutter Project Plan

## 1. Project Overview

Build a new Flutter personal trainer management app at `D:\work\ZAHRA\PRO CALENDER\fitness_trainer_app\`.

**Name**: PRO CALENDAR (Persian: تقویم حرفه‌ای)
**Type**: Personal trainer client management & scheduling app
**Target Platform**: Android (Myket), iOS
**Language**: Persian (Farsi) with RTL layout
**Architecture**: Feature-first modular, Riverpod, Drift

## 2. Core Features

### 2.1 Client Management
- Add/edit/delete clients
- Contact info, notes, tags
- Bonus sessions tracking
- Client profile with avatar

### 2.2 Plan Templates
- Create reusable programme templates (sessions + days)
- Edit/delete templates
- Usage tracking (how many clients use each template)

### 2.3 Client Plans
- Assign templates to clients
- Active, frozen, expired, queued plan statuses
- Queue management with auto-promotion
- Remaining sessions/days tracking
- Plan timeline visualization

### 2.4 Attendance Tracking
- Mark present/absent per day (Jalali calendar)
- Attendance history
- Past attendance calendar view
- Session consumption from active plan or bonus sessions

### 2.5 Dashboard
- Today's attendance overview
- Calendar with attendance dots
- Alert cards (expired, frozen, low sessions, queued)
- Bonus sessions banner
- Total clients count

### 2.6 Tags
- Create/edit/delete tags
- Assign tags to clients
- Usage count per tag
- Filter clients by tags

### 2.7 Settings
- Trainer name
- Dark/light theme toggle
- App preferences

## 3. Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **State Management** | Riverpod + flutter_riverpod | Already used in reference project; type-safe, testable, no BuildContext dependency |
| **Database** | Drift (SQLite) | Already used in reference project; type-safe queries, migrations, reactive streams |
| **Navigation** | go_router | Declarative routing, deep linking, better navigation control |
| **Models** | freezed + json_serializable | Immutable models, copyWith generation, JSON serialization |
| **UI Components** | Custom design system | Reusable, consistent, token-based |
| **Calendar** | shamsi_date | Jalali/Persian calendar conversion |
| **Fonts** | Vazir | Persian font, already integrated |
| **Linting** | flutter_lints | Code quality |
| **Testing** | flutter_test + mocktail | Unit and widget tests |

## 4. Project Structure

```
fitness_trainer_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── features/
│   │   ├── clients/
│   │   │   ├── data/
│   │   │   │   ├── clients_repository.dart
│   │   │   │   ├── clients_service.dart
│   │   │   │   └── clients_dao.dart
│   │   │   ├── domain/
│   │   │   │   └── client.dart
│   │   │   ├── presentation/
│   │   │   │   ├── clients_screen.dart
│   │   │   │   ├── client_detail_screen.dart
│   │   │   │   ├── add_edit_client_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── client_card.dart
│   │   │   │       └── client_avatar.dart
│   │   │   └── providers/
│   │   │       └── clients_providers.dart
│   │   │
│   │   ├── plans/
│   │   │   ├── data/
│   │   │   │   ├── plans_repository.dart
│   │   │   │   ├── plans_service.dart
│   │   │   │   └── plans_dao.dart
│   │   │   ├── domain/
│   │   │   │   └── client_plan.dart
│   │   │   ├── presentation/
│   │   │   │   ├── add_plan_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── active_plan_card.dart
│   │   │   │       └── queued_plan_card.dart
│   │   │   └── providers/
│   │   │       └── plans_providers.dart
│   │   │
│   │   ├── attendance/
│   │   │   ├── data/
│   │   │   │   ├── attendance_repository.dart
│   │   │   │   ├── attendance_service.dart
│   │   │   │   └── attendance_dao.dart
│   │   │   ├── domain/
│   │   │   │   └── attendance_record.dart
│   │   │   ├── presentation/
│   │   │   │   ├── past_attendance_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── attendance_calendar.dart
│   │   │   └── providers/
│   │   │       └── attendance_providers.dart
│   │   │
│   │   ├── templates/
│   │   │   ├── data/
│   │   │   │   ├── templates_repository.dart
│   │   │   │   ├── templates_service.dart
│   │   │   │   └── templates_dao.dart
│   │   │   ├── domain/
│   │   │   │   └── plan_template.dart
│   │   │   ├── presentation/
│   │   │   │   ├── templates_screen.dart
│   │   │   │   ├── add_edit_template_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── template_card.dart
│   │   │   └── providers/
│   │   │       └── templates_providers.dart
│   │   │
│   │   ├── tags/
│   │   │   ├── data/
│   │   │   │   ├── tags_repository.dart
│   │   │   │   ├── tags_service.dart
│   │   │   │   └── tags_dao.dart
│   │   │   ├── domain/
│   │   │   │   └── tag.dart
│   │   │   ├── presentation/
│   │   │   │   ├── tags_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── tag_chip.dart
│   │   │   └── providers/
│   │   │       └── tags_providers.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   │   └── dashboard_service.dart
│   │   │   ├── presentation/
│   │   │   │   ├── dashboard_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── stat_alert_card.dart
│   │   │   │       ├── bonus_banner.dart
│   │   │   │       └── jalali_calendar.dart
│   │   │   └── providers/
│   │   │       └── dashboard_providers.dart
│   │   │
│   │   └── settings/
│   │       ├── data/
│   │   │   ├── settings_repository.dart
│   │   │   └── settings_service.dart
│   │       ├── domain/
│   │       │   └── app_settings.dart
│   │       ├── presentation/
│   │       │   ├── settings_screen.dart
│   │       │   └── widgets/
│   │       │       └── settings_sheet.dart
│   │       └── providers/
│   │           └── settings_providers.dart
│   │
│   ├── core/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── database_module.dart
│   │   │   └── migrations/
│   │   │       ├── 1_initial_schema.dart
│   │   │       └── 2_add_fields.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_tokens.dart
│   │   │   ├── app_typography.dart
│   │   │   └── app_colors.dart
│   │   ├── utils/
│   │   │   ├── jalali_calendar.dart
│   │   │   ├── persian_numbers.dart
│   │   │   └── extensions/
│   │   │       ├── string_extensions.dart
│   │   │       └── date_extensions.dart
│   │   └── widgets/
│   │       ├── app_bottom_sheet.dart
│   │       ├── app_button.dart
│   │       ├── app_card.dart
│   │       ├── app_pill.dart
│   │       ├── app_empty_state.dart
│   │       ├── app_error_state.dart
│   │       ├── app_confirm_dialog.dart
│   │       ├── bottom_nav_bar.dart
│   │       ├── mini_tag.dart
│   │       └── settings_sheet.dart
│   │
│   └── routing/
│       ├── app_router.dart
│       └── routes.dart
│
├── test/
│   ├── unit/
│   │   ├── clients_service_test.dart
│   │   ├── plans_service_test.dart
│   │   ├── attendance_service_test.dart
│   │   ├── templates_service_test.dart
│   │   └── tags_service_test.dart
│   └── widget/
│       ├── clients_screen_test.dart
│       ├── dashboard_screen_test.dart
│       └── ...
│
├── pubspec.yaml
├── README.md
└── analysis_options.yaml
```

## 5. Database Schema (Drift)

```sql
-- Clients
CREATE TABLE clients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  contact TEXT,
  note TEXT NOT NULL DEFAULT '',
  bonus_sessions INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tags
CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  emoji TEXT NOT NULL DEFAULT '',
  color INTEGER NOT NULL DEFAULT 0xFF88A36B
);

-- Client-Tag relationship
CREATE TABLE client_tags (
  client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (client_id, tag_id)
);

-- Plan Templates
CREATE TABLE plan_templates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  sessions INTEGER NOT NULL,
  days INTEGER NOT NULL
);

-- Client Plans
CREATE TABLE client_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  template_id INTEGER NOT NULL REFERENCES plan_templates(id),
  start_date TEXT,
  sessions INTEGER NOT NULL,
  days INTEGER NOT NULL,
  remaining INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'active', -- active, frozen, expired, queued
  queue_order INTEGER,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Attendance Records
CREATE TABLE attendance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  date TEXT NOT NULL, -- Jalali date string 'YYYY/MM/DD'
  status TEXT NOT NULL, -- 'present' or 'absent'
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(client_id, date)
);

-- App Settings
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

## 6. State Management (Riverpod)

### 6.1 Provider Structure

```dart
// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden');
});

// Repository providers
final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  return ClientsRepository(ref.watch(databaseProvider));
});

// Service providers
final clientsServiceProvider = Provider<ClientsService>((ref) {
  return ClientsService(ref.watch(clientsRepositoryProvider));
});

// State providers
final clientsProvider = StateNotifierProvider<ClientsNotifier, List<Client>>((ref) {
  return ClientsNotifier(ref.watch(clientsServiceProvider));
});

// Async data providers
final allClientsProvider = FutureProvider<List<Client>>((ref) {
  return ref.watch(clientsServiceProvider).getAllClients();
});
```

### 6.2 Notifier Pattern

```dart
class ClientsNotifier extends StateNotifier<List<Client>> {
  final ClientsService _service;
  
  ClientsNotifier(this._service) : super([]) {
    loadClients();
  }
  
  Future<void> loadClients() async {
    state = await _service.getAllClients();
  }
  
  Future<void> addClient(Client client) async {
    final id = await _service.insertClient(client);
    state = [...state, client.copyWith(id: id)];
  }
  
  // ... other methods
}
```

## 7. UI/UX Design System

### 7.1 Color Tokens

```dart
class AppColors {
  // Primary
  static const primary = Color(0xFF88A36B);
  static const primaryDark = Color(0xFF6B8452);
  static const primaryLight = Color(0xFFB8C9A8);
  
  // Semantic
  static const success = Color(0xFF4A6B4E);
  static const successSoft = Color(0xFFE3F0E5);
  static const warning = Color(0xFF8B6F3E);
  static const warningSoft = Color(0xFFFFF3DE);
  static const error = Color(0xFF8B4A3E);
  static const errorSoft = Color(0xFFFCE5E0);
  
  // Surfaces
  static const surface = Color(0xFFFAFBF4);
  static const surfaceVariant = Color(0xFFF2F4EE);
  static const background = Color(0xFFEFF2EA);
  
  // Text
  static const onSurface = Color(0xFF1F2A1E);
  static const onSurfaceVar = Color(0xFF4A5A4A);
  
  // Borders
  static const outline = Color(0xFFC5D0C0);
  static const outlineVariant = Color(0xFFE0E6DD);
}
```

### 7.2 Typography Scale

```dart
class AppTypography {
  static const fontFamily = 'Vazir';
  
  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
  );
  
  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );
  
  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );
  
  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  
  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  
  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
```

### 7.3 Spacing Scale

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}
```

### 7.4 Component Library

| Component | Purpose |
|-----------|---------|
| `AppCard` | Standard card with optional header, footer, accent |
| `AppPill` | Reusable chip for tags, status badges |
| `AppEmptyState` | Consistent empty state with icon + title + subtitle |
| `AppErrorState` | Error state with retry button |
| `AppConfirmDialog` | Standard confirmation dialog |
| `SectionHeader` | Section title with optional action |
| `StatAlertCard` | Dashboard alert card with icon, value, label |
| `ClientCard` | Client list item with plan stats, attendance, tags |
| `ActivePlanCard` | Active plan display with remaining stats |
| `QueuedPlanCard` | Queued plan display with queue position |

## 8. Navigation (go_router)

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShell(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: 'clients',
            builder: (context, state) => const ClientsScreen(),
            routes: [
              GoRoute(
                path: 'detail/:clientId',
                builder: (context, state) {
                  final clientId = int.parse(state.pathParameters['clientId']!);
                  return ClientDetailScreen(clientId: clientId);
                },
              ),
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditClientScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'templates',
            builder: (context, state) => const TemplatesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditTemplateScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'tags',
            builder: (context, state) => const TagsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
```

## 9. Implementation Phases

### Phase 1: Foundation (Week 1)
1. Initialize Flutter project with dependencies
2. Set up folder structure
3. Configure Drift database with schema
4. Create core theme, tokens, typography
5. Build shared widget library
6. Set up Riverpod providers
7. Implement routing with go_router

### Phase 2: Core Features (Week 2-3)
1. Implement Clients feature (data, domain, presentation, providers)
2. Implement Tags feature
3. Implement Templates feature
4. Implement Plans feature
5. Implement Attendance feature

### Phase 3: Dashboard & Polish (Week 4)
1. Implement Dashboard feature
2. Implement Settings feature
3. Add animations and transitions
4. Polish UI/UX details

### Phase 4: Testing (Week 5)
1. Write unit tests for all services
2. Write widget tests for key screens
3. Integration tests for critical flows
4. Performance profiling

### Phase 5: Deployment Prep (Week 6)
1. Add app icons and splash screen
2. Configure build flavors (dev/prod)
3. Add analytics (optional)
4. Prepare for Myket submission

## 10. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.2
  
  # Database
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.2
  path: ^1.9.0
  
  # Navigation
  go_router: ^13.0.0
  
  # Models
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # Utils
  shamsi_date: ^1.1.1
  shared_preferences: ^2.2.2
  
  # UI
  flutter_svg: ^2.0.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  drift_dev: ^2.14.1
  riverpod_generator: ^2.3.9
  riverpod_lint: ^2.3.7
  
  # Testing
  mocktail: ^1.0.1
```

## 11. Business Rules (Preserved from Current App)

1. **Plan Creation**: If client has active/frozen plan, new plan is queued
2. **Attendance**: Both present/absent consume a session from active plan
3. **Bonus Sessions**: Used when no active plan or remaining=0
4. **Plan Progression**: When remaining=0, plan expires and queued plan promotes
5. **Template Propagation**: Editing active/frozen template updates those plans
6. **Cascade Delete**: Deleting client deletes all plans and attendance
7. **Tag Cleanup**: Deleting tag removes it from all clients

## 12. UI/UX Improvements

### 12.1 Dashboard
- Bento grid layout for stats
- Quick actions FAB
- Calendar with attendance dots
- Pull-to-refresh
- Navigation badges

### 12.2 Clients List
- Sticky search and filters
- Swipe actions (delete, mark attendance)
- Section headers by tag/status
- Bulk actions

### 12.3 Client Detail
- Collapsible sections
- Inline editing
- Plan timeline visualization
- Attendance history with calendar

### 12.4 Templates
- Visual cards with gradient accents
- Usage preview on cards

### 12.5 Animations
- Page route transitions
- Hero animations for client cards
- Animated tab switches
- Micro-interactions on buttons

## 13. Testing Strategy

### 13.1 Unit Tests
- All service classes (clients, plans, attendance, templates, tags)
- Business logic isolated from UI
- Mock database dependencies

### 13.2 Widget Tests
- Key screens: Dashboard, Clients, ClientDetail, Templates
- Component tests: ClientCard, ActivePlanCard, Calendar
- Provider integration tests

### 13.3 Integration Tests
- Critical flows: add client → add plan → mark attendance
- Navigation flows
- Database operations

## 14. Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| **Feature creep** | Stick to defined phases, defer nice-to-haves |
| **Database migration issues** | Use Drift's migration system, test thoroughly |
| **Riverpod learning curve** | Follow established patterns, reference existing project |
| **RTL bugs** | Test all screens in RTL mode, use Directionality widgets |
| **Performance** | Use ListView.builder, pagination, database indexes |

## 15. Success Criteria

- [ ] All features from current app are implemented
- [ ] App compiles without errors/warnings
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] RTL layout verified on all screens
- [ ] Performance is smooth (60fps)
- [ ] Code coverage > 80%
- [ ] App ready for Myket submission

## 16. Out of Scope (Phase 1)

- Backend sync / cloud backup
- Push notifications
- Analytics
- Payment integration
- Multi-language support
- Web platform
