# PRO CALENDER — Development Handoff

Handoff for continuing the "UI/UX refresh + new features + fa/en i18n" project.
Written at the end of the first working session (Phases 0–1 done). The next
engineer/AI can pick up at **Phase 2** below.

---

## 1. Environment facts (IMPORTANT)

- **Project root**: `D:\work\ZAHRA\PRO CALENDER`
- **App dir**: `D:\work\ZAHRA\PRO CALENDER\fitness_trainer_app`
- **Flutter is NOT on PATH.** It lives at `C:\flutter\bin\flutter.bat`.
  Every shell command must prefix:
  ```powershell
  $env:PATH = "C:\flutter\bin;$env:PATH"
  ```
- Flutter 3.47.2 stable / Dart 3.13.2 (verified 2026-08-26). This matters for
  API availability below.
- Git repo at project root, branch `master`. **Working tree was already dirty
  before this project started** (user had ~28 modified files + 4 untracked
  Python scripts). Do not `git clean`; only stage what you yourself changed.

### Commands
```powershell
# workdir: D:\work\ZAHRA\PRO CALENDER\fitness_trainer_app
$env:PATH = "C:\flutter\bin;$env:PATH"; flutter analyze
$env:PATH = "C:\flutter\bin;$env:PATH"; flutter test
$env:PATH = "C:\flutter\bin;$env:PATH"; flutter test test/widget/<file>_test.dart  # single file
```

---

## 2. What the app is

Persian (فارسی) RTL, offline-only personal-trainer CRM:
- Clients (name, contact, notes, tags, bonus sessions)
- Reusable plan templates (sessions + days)
- Per-client plans with statuses `active` / `frozen` / `expired` / `queued`;
  queued plans auto-promote; each attendance consumes 1 session (plan first,
  bonus sessions fallback)
- Attendance marked on a Jalali (Shamsi) calendar
- Dashboard (stats + alert cards + today's attendance), Settings (trainer
  name, theme, seed-demo data)

Stack: Flutter + **Riverpod 3** (code-gen `riverpod_generator`, NotifierProviders)
+ **Drift** (SQLite) + `shamsi_date` (Jalali) + `shared_preferences` +
`flutter_svg`. `flutter_localizations` is a dependency.

**Hard constraint (user-approved): NO new packages.** Everything below is done
with CustomPainter charts, hand-rolled CSV/JSON, and built-in widgets.

---

## 3. Approved plan (the contract)

| Phase | Scope | Status |
|---|---|---|
| 0 | Design foundation (colors, typography, card shadows, shared chart/ring/hero/empty-state widgets) | ✅ DONE |
| 1 | Localization: `AppStrings` fa/en, `languageProvider`, Settings toggle, locale-driven `MaterialApp`, Jalali(fa)/Gregorian(en) switching | ✅ DONE |
| 2 | Screen refresh + functional gaps (dashboard real "today attendance", clients cards/sort/undo, detail tabs, M3 nav + alert badge, soft-delete) | ⬅️ NEXT |
| 3 | Data layer schema v4 (`Payments`, `Measurements`, `Clients.isArchived`, migrations, services/providers) | ⏳ |
| 4 | Revenue tracking (plan price, payments, monthly income chart) | ⏳ |
| 5 | Measurements & progress (readings, trend chart, deltas) | ⏳ |
| 6 | Attendance statistics (per-client + global charts) | ⏳ |
| 7 | Reminders (in-app alerts, dashboard badge, thresholds in settings) | ⏳ |
| 8 | Backup & export (JSON backup/restore, CSV export) | ⏳ |
| 9 | Polish & verification (analyze clean, all tests green, new tests, dark-mode + RTL/LTR pass, web/Windows smoke) | ⏳ |

User decisions that shape everything:
- Language toggle lives in **Settings** (no first-launch prompt). Default `fa`.
- **Dates**: Jalali always shown as dates in fa; when UI language is `en`,
  the same stored Jalali key is rendered as its **Gregorian equivalent**.
- All new extra features are written bilingually from the start.
- Target: **Android + iOS** (iOS files must be reachable via Files app for
  backup — set `UIFileSharingEnabled` in Info.plist later in Phase 8).

---

## 4. Architecture map

```
lib/
  main.dart                  # ProCalendarApp, AppRouter, MainShell (IndexedStack + BottomNavBar)
  core/
    database/app_database.dart        # Drift tables + queries (schemaVersion 3)
    database/migrations/              # EMPTY dir — migrations live inline in MigrationStrategy
    database/connection/{native,shared,unsupported,web}.dart
    database/database_providers.dart  # databaseProvider (+ _databaseFutureProvider)
    l10n/app_strings.dart             # NEW: AppStrings (fa/en) — see §6
    theme/app_{colors,tokens,typography,theme}.dart
    utils/{jalali_calendar,persian_numbers,date_format( NEW)}.dart
    dev/demo_data.dart                # DemoDataService.seed()
    widgets/{app_widgets,bottom_nav_bar,app_charts( NEW)}.dart
  features/
    attendance/{data,domain,presentation,providers}
    clients/{data,domain,presentation,providers}
    dashboard/{data,presentation,providers}
    plans/{data,domain,presentation,providers}
    settings/{data,domain,presentation,providers}
    tags/{data,domain,presentation,providers}
    templates/{data,domain,presentation,providers}
  routing/routes.dart                  # AppRoutes constants
```

### Provider inventory (all in `features/*/providers/*.dart`)
- **dashboard**: `totalClientsProvider`, `activePlansCountProvider`,
  `expiredPlansCountProvider`, `frozenPlansCountProvider`,
  `queuedPlansProvider(int)`, `lowSessionPlansProvider`,
  `bonusSessionClientsProvider`, `todayAttendanceProvider(Map<int,String> date→status)`,
  `clientNamesProvider`
- **clients**: `clientsServiceProvider`, `allClientsProvider`,
  `clientProvider(id)`, `clientsNotifier`
- **plans**: `plansServiceProvider`, `clientPlansProvider(id)`,
  `activePlanProvider(id)`, `plansNotifier`
- **attendance**: `attendanceProvider` (+`.notifier.addSession / markAttendance /
  undoAttendance`), `clientAttendanceProvider(id)`,
  `clientAttendanceMapProvider(id)`, `planAttendanceProvider(id)`,
  `planAttendanceMapProvider(id)`, `todayAttendanceCountProvider(id)`,
  `todayAttendanceStatusCountsProvider(id)`
- **sales/tags/templates**: `templatesServiceProvider`, `allTemplatesProvider`,
  `tagsServiceProvider`, `allTagsProvider`, `tagUsageCountProvider(id)`,
  `templateUsageCountProvider(id)`
- **settings**: `settingsServiceProvider`, `trainerNameProvider`,
  `themeModeProvider` (ThemeMode), `languageProvider` (String 'fa'/'en') — NEW

### DB tables (`app_database.dart`, schemaVersion 3)
`clients(id,name,contact,note,bonus_sessions,created_at)`,
`tags(id,name,emoji,color)`, `client_tags(clientId,tagId)`,
`plan_templates(id,name,sessions,days)`,
`client_plans(id,clientId,templateId,start_date,sessions,days,remaining,status,queue_order,created_at)`,
`attendance(id,clientId,planId?,date,status,created_at)`,
`app_settings(key,value)`.

Migration is inline:
```dart
onUpgrade: from<2 addColumn(queueOrder); from<3 addColumn(planId);
```

### Drift generated files
`app_database.g.dart` is generated. After editing tables run:
```powershell
$env:PATH = "C:\flutter\bin;$env:PATH"; dart run build_runner build --delete-conflicting-outputs
```

---

## 5. Done in this session — file-by-file

Session 2 additions:
- **Phase 2a (dashboard redesign)**: `dashboard_screen.dart` fully redone —
  `AppHeroHeader` with greeting + `formatDateLong` date + 4 translucent stat
  tiles (total/expired/frozen/queued), real "حضور امروز" list (one row per
  client with quick present/absent buttons, or status pill + undo), low-session
  cards with warning pill, tappable bonus banner. Localized; `RefreshIndicator`
  now calls `invalidateAppData()`.
- **Phase 2c (client detail)**: `client_detail_screen.dart` — gradient hero
  (avatar, name, contact, `_HeroChip` bonus + tag chips via new
  `clientTagsProvider`), localized contact section, plan cards with
  `AppProgressRing` (consumed ratio) + status `AppPill` + freeze/activate/delete.
- **AppStrings** grew to ~80 keys with `isPersian` flag; template methods now
  convert digits via `_digits()`. Notable new methods: `remainingDetail`,
  `deleteClientMessage`, `attendanceCount`, `recordAdded`, `recordRemoved`.
- `client_detail_screen` section title changed to `plansSection` («برنامهها»)
  to reflect that **finished/expired plans stay listed as history** (they are
  never auto-deleted; delete is explicit so a client can review how they used
  a plan). Update smoke-test assertion accordingly.
- **Attendance multi-per-day rework (requested by user, IN PROGRESS)** — see
  §5a below.

### 5b. Clients screen refresh (Phase 2b/8b — DONE, analyze clean + 96 tests green)

Session 2b (this session):
- `app_strings.dart` **repaired** (see the ⚠️ note in §8) and extended:
  `clientDeletedTemplate` + `clientDeleted(name)`.
- `clients_screen.dart`: sort menu, tag chips kept, localized search +
  empty states, card tap → bottom sheet (view profile / attendance / quick
  present-absent today via `addSession` / edit / delete). `_SortMode`
  enum — newest sorts by `id` desc (`createdAt` is always `''`).
- `client_card.dart`: card is now tappable-only (chips + in-card delete
  removed); shows active plan + remaining + bonus + today-count pills.
- `app_widgets.dart`: `AppBottomSheet.show` Container→Material (ListTile ink fix).
- `clients_navigation_test.dart`: sheet-first navigation assertions.

### 5c. Client-card quick actions + dashboard tag filter (DONE, analyze clean + 99 tests green)

Session 2c (user-driven UX polish):
- **Client card** (`client_card.dart`): bonus sessions are now editable inline —
  a `− {n} جلسه اضافه +` stepper (`updateClientBonus` service + repo wrapper added),
  minus disabled at 0. Freeze/unfreeze is one tap too: the active-plan chip now
  shows active *or* frozen plans (warning tone + snowflake for frozen) with a
  pause/play toggle → `plansNotifier.freezePlan/unfreezePlan`. Card still shows
  remaining (`x از y`) + days + today-count pills; added `noActivePlanLabel`
  caption when no active/frozen plan exists.
- **AppStrings**: added `bonusSessionCountTemplate`, `bonusAdded`,
  `bonusRemoved`, `noClientsWithTag` (fa+en). Also **fixed pre-existing mojibake in
  the `en` block** (`Â«Â»`, `Ã—`, `Â·`, `ÙفØ§Ø±Ø³ÛŒ` → proper «» × · فارسی) — that
  corruption was baked in by an earlier repair, not the runtime.
- **Dashboard** (`dashboard_screen.dart` → now `ConsumerStatefulWidget`): the
  today-attendance section gained a horizontal **tag FilterChip row** («همه» +
  tags, same styling as the clients screen) filtering which clients appear;
  empty filter → `AppEmptyState(noClientsWithTag)`. Backing provider
  `clientTagFilterProvider` (clientId → tag ids) lives in `dashboard_providers.dart`.
- **`app_refresh.dart`**: registered `clientProvider` and `clientTagFilterProvider`
  in `_appDataProviders` so bonus/plan edits refresh card subtrees everywhere.
- New test `test/widget/client_card_quick_actions_test.dart` (3 cases): shows
  bonus + remaining; +/− persists bonus (db-checked); freeze toggle flips status
  (db-checked). **96 → 99 tests.**

### 5d. Systemic light/dark theme fix — `AppTones` (DONE, analyze clean + 99 tests green)

Root cause: every widget pulled colors straight from the light-only `AppColors`
palette, so dark mode showed dark-on-dark text (client cards, bottom sheet, etc.).

- New `lib/core/theme/app_tones.dart`: `@immutable AppTones` with
  `static const light` (== the old `AppColors` values) and `static const dark`
  palettes, `AppTones.of(context)` + `extension AppTonesContext on BuildContext
  { AppTones get tones }`. Semantic tokens: primary/primaryDark/primaryLight/
  onPrimary, success/successSoft, warning/warningSoft, error/errorSoft,
  surface/surfaceVariant/background, onSurface/onSurfaceVar, outline/
  outlineVariant, today/todaySoft/todayInk, present/absent/queued/frozen.
- `AppColors` is now **only** the brand palette (base hues + `gradient*`), and
  `app_theme.dart` still builds ThemeData from it — untouched.
- Migrated all widgets/screens from `AppColors.<token>` → `t.<token>` (with
  `final t = context.tones;` in build): `app_widgets.dart` (manual), plus
  `app_charts`, `styled_text_field`, `form_card_screen`, `bottom_nav_bar`,
  `main.dart`, `dashboard_screen`, `client_card`, `clients_screen`,
  `client_detail_screen`, `past_attendance_screen`, `attendance_calendar`,
  `add_plan_screen`, `templates_screen`, `template_card`, `tags_screen`.
  Non-build scopes resolved explicitly (`_statusColor(status, t)`,
  `_buildPlaceholder(context)`, `AppTones.of(context)` in dialog builders).
  Chart color params made nullable and resolved via `?? t.x`; the line-chart
  painter now takes a `highlightColor`.
- `screens_smoke_test.dart` already renders every screen in both **light and
  dark**, so dark-mode regressions are covered. 99 tests stay green.

### 5e. Assign/remove tags on a client (DONE, analyze clean + 101 tests green)

The data layer already supported per-client tags (`client_tags` join table +
`assignTagToClient`/`removeTagFromClient`) but **no screen ever called them** —
tags were display/filter-only, so there was no way to add a tag to a client.

- New reusable picker `lib/features/tags/presentation/widgets/client_tag_picker.dart`:
  `showClientTagPicker(context, ref, selectedIds)` opens a bottom sheet listing
  every tag as a toggleable `FilterChip` and returns the new id set (or null).
  The caller persists — form keeps it local until save, detail writes instantly.
- **Add/Edit client form** (`add_edit_client_screen.dart`): new «برچسبها»
  section with removable `Chip`s + an «افزودن برچسب» `ActionChip` opening the
  picker. `_loadClient` seeds the current ids; `_save` diffs
  (`assign` added, `remove` dropped) and, for a brand-new client, assigns after
  `createClient` returns the new id. (Was also the only way to tag at creation.)
- **Client detail** (`client_detail_screen.dart`): hero tag chips are now tappable
  (`_HeroChip.onTap`), plus an «افزودن برچسب» chip; `editTags()` reads the current
  ids, opens the picker, applies the diff, then invalidates `clientTagsProvider`
  and `invalidateAppData()`.
- New `AppStrings`: `tagsSection`, `addTag`, `noTagsDefined` (fa+en).
- `app_refresh.dart`: registered `clientTagsProvider`, `allTagsProvider`,
  `tagUsageCountProvider` so assignments refresh the detail header, dashboard
  tag filter and tag usage counts.
- New test `test/widget/client_tags_test.dart` (2 cases, db-checked): edit form
  lists an assigned tag and adds a second; detail screen removes a tag.
  **99 → 101 tests.**

### 5a. Multi-attendance-per-day rework (DONE, analyze clean + 96 tests green)

The user requires: multiple attendance records allowed per **any** day (past or
today); quick add from client card; detailed calendar + records in the
attendance sub-page; finished-plan history kept.

Key facts learned:
- The `Attendance` table has **NO unique constraint on (clientId,date)** —
  multiple rows per day were already storable.
- Drift `getSingleOrNull` **throws when 2+ rows match** — everywhere that
  fetched one record per (client,date) needed a `..limit(1)`.

Changes made:
- `app_database.dart`: `getAttendance` and `getPlanAttendanceForDate` now
  order by `id DESC LIMIT 1` (latest record). `removeOneAttendance` also got
  `LIMIT 1` (it previously threw "Too many elements" on 2-record days).
- `attendance_service.dart`: `markAttendance` now **always inserts a new
  record** (no upsert of the existing row). `undoAttendance` deletes the
  latest record. `addAttendance`/`removeOneAttendance` retained (used by the
  session service).
- `attendance_session_service.dart`: removed `markAttendance`/`undoAttendance`;
   the UI layer now only uses `addSession` (insert + consume plan-then-bonus
   session) and `removeSession` (delete latest record + refund). Doc comment
   updated: **every add consumes, every removal refunds**.
- `attendance_providers.dart`: `clientAttendanceMapProvider` /
  `planAttendanceMapProvider` are now `Map<String, List<String>>` (date →
  list of statuses) for the calendar; `AttendanceNotifier` keeps only
  `addSession`/`removeSession`; `_invalidateFor` also invalidates
  `planAttendanceProvider`/`planAttendanceMapProvider` (whole families).
  `app_refresh.dart` lists both plan providers too.
- `attendance_calendar.dart`: `attendanceMap` is the list-map; cell shows the
  strongest status color (present wins) and a `×N` badge when a day has
  multiple records; attendance-mode tap now calls **`onDayTapped(dateKey)`**
  (no more status-cycling). Picker mode (`onDaySelected`/`selectionKey`)
  unchanged — `add_plan_screen.dart` updated to `const <String, List<String>>{}`
  + `onDayTapped: (_) {}`.
- `past_attendance_screen.dart` (rewritten, fully localized): session summary
  card (sessionStatusTitle/activePlanRemainingLabel/noActivePlanLabel/
  queuedPlansLabel/bonusSessions/recordedSessionsLabel), quick-add-today row
  (`s.quickAddToday`, «حاضر + / غایب +» → `addSession` with snackbars via
  `s.recordAdded`), calendar with day-tap → **`_DayAttendanceSheet`** bottom
  sheet (that day's records + per-record delete via `removeSession` +
  present/absent add buttons), history list grouped per day with per-record
  delete (`s.recordRemoved` snackbar, `s.deleteSession` tooltip). Empty states
  localized (`s.noHistoryYet`/`s.noHistorySubtitle`). Dates rendered with
  `formatDateLong(date, lang)`.
- `dashboard_screen.dart`: `_mark`/`_undo` now call notifier `addSession`/
  `removeSession` (incl. recordAdded/recordRemoved snackbars);
  `todayAttendanceProvider` is `Map<int, Map<String,int>>` (clientId →
  {status: count}) fed by `DashboardService.getTodayAttendance`; `_TodayRow`
  shows a count pill `s.attendanceCount('حاضر'|'غایب', n)` + undo when any
  records exist, else the quick-mark buttons. `dashboard_providers.dart` type
  updated.
- `client_detail_screen.dart`: plans section header now `s.plansSection`
  («برنامهها») to include finished/expired plans in history.
- `demo_data.dart`: switched to `addSession`.
- Tests: unit — replaced "updates existing record status" and "unique per
  client and date" with multi-record tests; added "getAttendance returns the
  latest" and "getTodayAttendance counts multiple records per client/status"
  (94 → **96 tests**). Widget — `attendance_marking_test.dart`:
  `PastAttendanceScreen` now needs the locale harness (bare MaterialApp fell
  back to English); buttons are «حاضر +» (was hardcoded «حضور +»); the undo
  tap targets the record-card `IconButton` after dismissing the snackbar and
  scrolling the lazy ListView (and asserts via DB, not off-screen text).
  `screens_smoke_test.dart` + `clients_navigation_test.dart` detail assertion
  is now «برنامهها» (was «برنامههای فعال»).

### Phase 0 — design foundation (DONE, analyze+94 tests green)

**`lib/core/theme/app_colors.dart`** — added gradient endpoint lists:
`gradientPrimary`, `gradientSuccess`, `gradientWarning`, `gradientError`,
`gradientFrozen`, `gradientDark`. Base palette untouched.

**`lib/core/theme/app_typography.dart`** — added `titleLarge` (16/w700) and
`caption` (11/w500).

**`lib/core/theme/app_theme.dart`** — both light & dark themes now define:
`navigationBarTheme` (Material 3 NavigationBar: elevation 0, indicator,
label font), `snackBarTheme` (floating + rounded), `progressIndicatorTheme`
(primary), `dialogTheme` (rounded), `dividerTheme`.
Note: `DialogThemeData` exists on Flutter 3.47 (do not downgrade to `DialogTheme`).

**`lib/core/widgets/app_widgets.dart`** —
- `AppCard`: now adds a soft box-shadow in light mode
  (`Color(0xFF1F2A1E).withValues(alpha:0.06)`, blur 14, offset (0,5)); in dark
  mode no shadow, uses theme surface + outline border.
- `AppEmptyState`: icon now sits in a 96px gradient circle (primaryLight→
  surfaceVariant), icon color `primaryDark`, size 44.
- NEW `AppHeroHeader`: gradient rounded header. `child`, optional `gradient`
  (default `AppColors.gradientPrimary`), optional `padding`. Foreground color is
  auto-derived from the last gradient color's luminance (white or `onSurface`)
  and merged into the child via `DefaultTextStyle`.

**`lib/core/widgets/app_charts.dart`** (NEW file, no external package):
- `AppProgressRing(value, size=88, strokeWidth=10, trackColor=surfaceVariant,
  progressColor=primary, child)` — CustomPainter arc with sweep shader + round
  cap. Clamp 0..1. The `.g.dart`-style const usage: `const AppProgressRing(...)`.
- `BarDatum(label, value, color?, highlighted?)`
- `AppMiniBarChart(data, height=120, maxValue?)` — vertical gradient bars,
  highlight draws a border.
- `ChartPoint(label, value, highlight=false)`
- `AppLineChart(points, height=140, lineColor=primary, fillColor?)` — grid,
  area fill, polyline, dots (highlight dots are bigger/onSurface).

### Phase 1 — localization (DONE)

**`lib/core/l10n/app_strings.dart`** (NEW) — pattern:
```dart
final s = AppStrings.of(context);   // resolves from Localizations.localeOf
```
- Const instances `AppStrings.fa` / `AppStrings.en` with ~45 fields each.
- Template strings use `{token}` placeholders resolved by methods:
  `welcomeWith(name)`, `bonusClients(count)`, `remainingSessions(count)`,
  `clientsWithBonus(count)`.
- Keys currently defined: common actions (ok/yes/no/cancel/confirm/delete/
  edit/save/saved/errorPrefix/loading), nav labels, settings labels
  (trainer/appearance/theme system/light/dark/language fa/en/dev tools),
  dashboard (totalClients/expired/frozen/queued/todayAttendance/present/absent/
  lowSessionPlans/viewClients/sessionsLeft/noAttendanceYet/...), databaseFailedTitle.
- **To add new strings**: add a `final String x;` + constructor param + both
  `fa` and `en` values. Ideally also add a wire test.

**`lib/core/utils/date_format.dart`** (NEW) —
- `formatDateLong(jalaliKey, languageCode)` — fa: «شنبه ۲۵ اسفند ۱۴۰۴»;
  en: «Saturday, 15 March 2026» (Gregorian of the same Jalali day).
- `formatDateShort(...)` — fa: «۱۴۰۴/۱۲/۲۵»; en: «2026/03/15».
- `localizeNumber(value, languageCode)` — Persian digits only when 'fa'.
- GOTCHA already fixed: `Jalali.toGregorian()` returns a **`Gregorian`**, not a
  `DateTime`; build a `DateTime(g.year, g.month, g.day)` for `.weekday`.

**`lib/core/utils/jalali_calendar.dart`** — bugfix: `formatJalaliLong` had a
literal `?` in the output (`'$dayName? ${...}'`) → removed. Result now clean:
«شنبه ۲۵ اسفند ۱۴۰۴».

**`lib/features/settings/data/settings_service.dart`** — added
`getLanguagePreference()` / `setLanguagePreference(code)` (key `'language'`).

**`lib/features/settings/providers/settings_providers.dart`** — added
`languageProvider` (NotifierProvider<String>), default `'fa'`, loads persisted
value, `setLanguage(code)` persists. NOTE: null-promotion gotcha — assignment
after an OR-check needs `stored!`.

**`lib/features/settings/presentation/settings_screen.dart`** — fully localized;
new **Language** section with `SegmentedButton<String>` (فارسی / English) wired
to `languageProvider`. Theme section unchanged but localized. Dev-tools seed
section still `kDebugMode`-only. Invalidates the same providers after seeding.

**`lib/main.dart`** —
- `ProCalendarApp`: `locale` is now `Locale(ref.watch(languageProvider))`
  (was hardcoded `Locale('fa','IR')`). Supported locales already
  `fa_IR` / `en_US`.
- `StartupErrorApp` stays hardcoded-Persian (fallback UI without providers).
- `MainShell` unchanged (IndexedStack + BottomNavBar).

**`lib/core/widgets/bottom_nav_bar.dart`** — replaced `BottomNavigationBar`
with Material 3 **`NavigationBar`** + `NavigationDestination`s; labels localized.
Added optional `badgeCount` param → shows a `Badge` on the **Dashboard**
destination and `Badge` with a bounce on Dashboard (Phase 7 will count
reminders and pass it from MainShell).

**`lib/features/templates/presentation/templates_screen.dart`** — fixed a
**pre-existing broken line** in the dirty tree: `usageCountAsync.value` was
undefined; changed to `snapshot.data ?? 0`.

### Test updates (in `test/widget/`)

Because nav is now M3 `NavigationBar` and labels are locale-driven:
- `bottom_nav_bar_test.dart`: MaterialApp now passes `locale: Locale('fa')`,
  `supportedLocales: [fa, en]`, and the three `Global*Localizations.delegate`s
  — otherwise locale resolves to `en` and Arabic-free labels are English.
- `screens_smoke_test.dart`: added `buildHarness(db, {theme, home, initialRoute})`
  that mirrors the app's locale wiring; all 7 route blocks use it;
  `find.byType(NavigationBar)` replaces `BottomNavigationBar`.
- `clients_navigation_test.dart`: same locale wiring + NavigationBar type.

**Rule for any future widget test that renders localized UI**: reuse the
`buildHarness` pattern (delegates + supportedLocales) or the locale falls back
to English.

---

## 6. Conventions (must follow)

1. **New UI strings go through `AppStrings`**, both `fa` and `en`. Do not
   hardcode new Persian strings in screens that are already localized.
   Screens not yet localized (templates, tags, add/edit forms, attendance)
   may keep Persian for now — they get converted as they are refreshed.
2. **Numbers**: use the `toPersian()` util (via `localizeNumber`) for Persian
   UI; keep Western digits in en mode and in stored data.
3. **Providers**: Riverpod 3 — `FutureProvider.autoDispose`/family for reads,
   `NotifierProvider` for mutable state, plain `Provider` for services.
   Invalidate tab providers in `MainShell._invalidateTabProviders` after
   mutations (it's the pattern that keeps stale data away).
4. **DB**: add columns/tables + bump `schemaVersion` + extend `onUpgrade`.
   Regenerate `.g.dart` with build_runner.
5. **No new packages.** Charts → `app_charts.dart`. CSV → hand-rolled.
   Anything needing ffi/plugins (notifications, share) is out of scope or
   replaced with in-app equivalents.
6. **RTL**: default direction comes from Material localizations; don't force
   `Directionality` in screens. Test in both themes (smoke test covers light+dark).
7. Cards/empty states/hero → shared widgets in `app_widgets.dart`; charts →
   `app_charts.dart`.

---

## 7. Gotchas / traps (learned the hard way)

- `flutter` not on PATH → prefix `$env:PATH = "C:\flutter\bin;$env:PATH"`.
- `Jalali.toGregorian()` returns `Gregorian` (no `.weekday`).
- Bare `MaterialApp` in tests resolves locale→`en` without delegates:
  localized widget tests need the delegates/supportedLocales harness.
- `AppCard` builds a Container inside InkWell; the shadow is added on the
  Container's BoxDecoration (uses `withValues`, which is the non-deprecated
  `withOpacity` replacement on modern Flutter — do NOT switch back to
  `withOpacity`).
- Riverpod 3 + code-gen: regenerate after touching `@riverpod` annotations;
  `ClientPlans` patch updates use `patchPlan` (a full `replace` wipes
  `Value.absent()` columns — documented in code).
- `SectionHeader` must never be placed inside a `Row` (unbounded-width
  `Expanded` crash — commented in `client_detail_screen.dart`).
- grep/ripgrep tool fails on paths containing spaces — use PowerShell
  `Select-String` in this workspace.
- The user's uncommitted working tree contains throwaway Python scripts
  (`fix_*.py`, `update_*.py`) — do not delete them.

---

## 8. Where to pick up — Phase 2 (screen refresh + gaps)

Status: **8a ✅ done** (dashboard), **8c ✅ done** (client detail + `clientTagsProvider`),
**5a ✅ done** (multi-per-day attendance rework — see §5a), **8b ✅ done**
(clients screen sort + bottom sheet — see below), **8d/8e pending**.

> ⚠️ 2026-09 **l10n near-miss**: a parallel agent (Cline) left `app_strings.dart`
> half-wired — duplicate `en` block, constructor missing 17 required params, and
> a **mojibake fa block** (~3000 corrupted chars incl. literal `U+0081`/`U+00AD`).
> Repaired: rebuilt the whole `fa` block with correct Persian (Write-tool roundtrip
> verified; file re-saved UTF-8 **without** BOM — Read/Edit tools mis-decode a
> BOM'd file that was double-encoded), removed duplicate `en`, wired the 17
> constructor params, renamed the bogus `remainingDetail:` values. `app_strings.dart`
> is still **untracked** (part of the uncommitted 5a/2b work) — if it ever needs a
> clean source, tests + `postgres`… currently the tests ARE the oracle
> (`flutter test` = 96 green).

### 8b. Clients screen — DONE

Implemented (analyze clean + 96 tests green):
- `clients_screen.dart`: AppBar sort `PopupMenuButton` (`_SortMode.name/newest/bonus`,
  newest = `id` desc because `createdAt` defaults to `''` in the DB), tag chips,
  localized search/empty states (`s.emptyClientsTitle`, `s.noResults…`); card tap
  → `AppBottomSheet.show` with viewProfile → detail, «مشاهده حضور و غیاب» →
  `/attendance/:id`, quick-add present/absent today (`attendanceProvider.addSession`
  with `jalaliToday()` + active `planId`), edit, delete (localized
  `s.deleteClientMessage` + `s.clientDeleted` snackbar). Dismissible retained.
- `client_card.dart`: removed the `حضور+ / غیبت+` FilterChip row and `onDelete`
  icon — card is tappable-only, keeps active-plan chip + remaining (`s.remainingDetail`)
  + bonus + today-count pills.
- `AppBottomSheet.show` (`app_widgets.dart`): `Container(decoration…)` → `Material`
  (ListTiles asserted "ink may be invisible" on the decorated Container).
- `clients_navigation_test.dart`: tap «سارا محمدی» → sheet asserts
  «مشاهده پروفایل / ثبت سریع امروز / حاضر / غایب / ویرایش مشتری / حذف مشتری» → tap
  viewProfile → detail markers. (Sheet labels use status words «حاضر/غایب», not
  «حضور/غیبت» — the test matches the AppStrings values.)
- Added l10n: `clientDeletedTemplate` + `clientDeleted(name)` method (fa/en).

Remaining 8b idea (deferred to Phase 3 soft-delete): search matching note text.

### 8d. MainShell badge
- `MainShell._invalidateTabProviders` add new providers as they appear;
  pass a reminder/alarm count into `BottomNavBar(badgeCount: ...)`.

### 8e. Templates / Tags screens (light polish)
- Restyle cards to new tokens; localize strings; keep behavior.

---

## 9. Phase 3 — data layer detail (schema v4)

Attendance notes carried over into v4: do **not** add a unique index on
`attendance(clientId,date)` — multi-record days are intentional. `getAttendance`
returns the latest row for a day (`id` desc, limit 1); per-record ops use
`removeOneAttendance` (latest first). One record consumed = one session
(plan, then bonus); `removeSession` refunds.

In `app_database.dart`:
- `Clients`: add `BoolColumn get isArchived => boolean().withDefault(const Constant(false))();`
- New tables (mirror existing style):
  - `Payments`: `id` autoPK, `clientId` ref Clients #id cascade,
    `planId` int nullable, `amount` real, `date` text, `note` text default '',
    `createdAt` text default ''.
  - `Measurements`: `id` autoPK, `clientId` ref cascade, `date` text,
    `weight`/`bodyFat`/`chest`/`waist`/`hips`/`arm`/`thigh` real nullable,
    `note` text default '', `createdAt` text default ''.
- Bump `schemaVersion` → 4; in `onUpgrade`: `if (from < 4) { addColumn(isArchived); createTable(payments); createTable(measurements); }`
- Regenerate with build_runner.
- New feature dirs `lib/features/revenue/`, `lib/features/measurements/` with
  `data/repository`, `data/service`, `providers/*.dart` following the
  clients/plans pattern exactly (Repository wraps `db`, Service holds business
  logic, providers wire them).
- Archive-aware queries: list clients filters `isArchived == false`; Settings
  gets an "archive" section to restore/reactivate.

## 10. Phases 4–8 briefing

- **Revenue (4)**: add `price` IntColumn to `ClientPlans` (Phase 5 of migration
  — bump again) + AddPlan field; Payments screen under client detail; monthly
  income with `AppMiniBarChart`; "expected vs collected".
- **Measurements (5)**: readings form (weight/bodyFat/chest/waist/arm/thigh),
  `AppLineChart` trend, delta chip (▲/▼ vs previous), no photos (image_picker
  out).
- **Attendance stats (6)**: per-client % , streaks, weekday frequency;
  global monthly bar chart; entry from dashboard + attendance screen.
- **Reminders (7)**: computed list (expired/frozen>N/queued/≤2 sessions/
  inactive ≥ threshold/unpaid), Settings thresholds (`AppSettings` keys), a
  "یادآوریها" screen, badge on Nav `badgeCount`. No push notifications.
- **Backup/export (8)**: JSON of all tables (schemaVersion + exportedAt) to
  app documents dir (`path_provider` present), restore from in-app list (keep
  last N), CSV export (clients/attendance/payments) — hand-rolled, no `csv`
  package; Settings section "پشتیبانگیری". iOS: set
  `UIFileSharingEnabled` + `ITSAppUsesNonExemptEncryption` in
  `ios/Runner/Info.plist`.

## 11. Phase 9 — verification checklist
- `flutter analyze` → No issues found.
- `flutter test` → all green (101 today; will grow with new tests —
  add service unit tests for revenue/measurements/backup + a widget test that
  switches language in Settings and asserts an English label appears).
- Smoke builds (as past commits did): `flutter build web --release` and
  `flutter build windows --release` (or at least `flutter build web`).
- Dark-mode visual pass; RTL fa ↔ LTR en pass.
  (`screens_smoke_test.dart` already asserts every screen renders in light **and**
  dark, via `AppTones`.)

## 12. Git hygiene reminder
- Commit only when told; follow repo's commit-message style (prefix tags like
  `UI:`, `feat:`, `fix:`). The user's dirty tree is theirs — don't stage it.