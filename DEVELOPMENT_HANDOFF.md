# DEVELOPMENT_HANDOFF — fitness_trainer_app (Pro Calendar / Pro Calender)

Persian (RTL) **personal-trainer CRM**: clients, plans (from templates),
attendance, accounting, Jalali calendar, JSON/CSV backup. Flutter app lives in
`fitness_trainer_app/`. This file tells the next session what exists and what's
next. It is the only long-form source of truth besides `AGENTS.md`.

**CURRENT HEAD (2026-09-23) — cascade deletes (plan/client) + editable accounting ledger (implemented):**
- **Plan delete now removes its attendance history**: `PlansService.deletePlan` calls the new
  `db.deleteAttendanceForPlan(planId)` before deleting the row (it already removed the plan's
  income transaction). Attendance history survives only for plans that still exist (active /
  expired / frozen / queued). Tests: `plans_service_test.dart` +2 (delete removes plan history;
  deleting one plan keeps the others' attendance).
- **Client delete now cascades everything, on every platform**: new `AppDatabase.deleteClientCascade`
  runs one transaction deleting the client's ledger rows, attendance, plans and tag links, then the
  client. The web build never enables `PRAGMA foreign_keys`, so the old FK-cascade reliance silently
  left orphaned plans ("still in use by the deleted client"), attendance and accounting rows — now
  explicit. `ClientsRepository.deleteClient` routes through it. Tests: `clients_service_test.dart` +2
  (full cascade incl. transactions/tags; a web-like FK-off memory DB proves orphans are still removed);
  `transactions_service_test.dart` updated to assert client delete removes its ledger rows.
- **Accounting ledger is now editable + deletable**: rows already had delete; an edit IconButton on
  each row opens `AddTransactionSheet(initial: tx)` (prefilled type/category/date/client/amount/note,
  title «ویرایش تراکنش», save button flips to «ذخیره»), pops with id/createdAt preserved, then
  `TransactionService.updateTransaction`. `TransactionRepository.update` now preserves `planId` +
  `createdAt` (previously `update().replace()` fell back to defaults and would silently wipe a plan's
  income link when edited). Orphaned-client rows edit safely (dropdown falls back to «بدون مشتری» when
  the linked client is gone). New AppStrings: `editTransaction`, `transactionUpdated`.
- Verdict: `flutter analyze` = No issues found!; `flutter test` = 177/177 green.

**CURRENT HEAD (2026-09-20, after Option A) — legacy/expired plans can now be priced into accounting (implemented):**
- **«ثبت قیمت» button on every plan card** in `/clients/detail/:id` (status-
  agnostic: active / frozen / queued / expired). Opens a price + gym-share dialog
  (Persian digits supported, price/share clamped). Saving calls
  `PlansService.setPlanPrice(planId, price, sharePercent)`, which patches the
  plan and keeps the ledger in sync: inserts an `income/plan` transaction dated
  at the plan's `startDate` (today for queued plans without one) when missing,
  updates that row when the price changes, and removes it when price is set to 0.
  This is how pre-pricing-history plans (the bulk of old-user data) get their
  revenue onto the accounting page — no migration can invent prices, so the
  trainer enters them per plan.
- **One-time v7 data migration** (`app_database.dart` `onUpgrade`, `from < 7`):
  `backfillMissingPlanIncome()` inserts the missing income row for every plan
  with `price > 0` that lacks one (idempotent — rerun never duplicates rows; no
  schema change, no `.g.dart` regen). `schemaVersion` 6 → 7; fresh installs
  create at v7.
- New DAO: `getTransactionsForPlan(planId)`. New AppStrings keys (fa+en +
  ctor): `planPriceDialogTitle`, `planPriceSaved`, `setPlanPrice`.
- Tests: +5 in `plans_service_test.dart` (legacy set-price income, price-change
  updates the row, price-0 removes it, clamp behavior, backfill idempotency);
  `backup_service_test.dart` now asserts `schemaVersion` 7. `flutter analyze` =
  No issues found!; `flutter test` = 173/173 green.

**CURRENT HEAD (2026-09-20, after audit) — audit fixes APPLIED (H1, H2, M1, M2, M3):**
- **BUGFIX (same head):** clicking a plan card in `/clients/detail/:id` pushed
  `/attendance/:id/:planId`, which fell into the "page not found" route — the
  router's `_idFrom` tried to parse the whole tail (`3/7`) as one int. The
  attendance route in `AppRouter.onGenerateRoute` now splits the tail itself
  (`clientId` from `parts[0]`, optional `planId` from `parts[1]`).
  `screens_smoke_test.dart` gained `/attendance/:id/:planId` coverage (both
  themes). `flutter test` = 168/168.
- Full audit delivered, then all agreed fixes applied in one pass:
  `flutter analyze` = No issues found!; `flutter test` = 166/166 green.
- **H1 (double-`active` crash):** `plans_service.unfreezePlan` now reads
  `getActivePlan(clientId)` first; if a *different* plan is already active, the
  unfrozen plan is queued (`queueOrder = countQueuedPlans + 1`) instead of being
  set `active`. `app_database.getActivePlan` is now defensive (`firstOrNull`,
  tolerates a legacy duplicate-active state) instead of `getSingleOrNull`.
- **H2 (Jalali day-diff drift):** `getRemainingDays` uses
  `end.distanceFrom(today)` (exact Julian-day diff). The old code rebuilt a
  `DateTime` from Jalali components (treated as Gregorian) and drifted across
  month boundaries.
- **M1 (hardcoded Persian → AppStrings):** +30 catalog keys (fa+en + ctor params
  + `approximateEnd(date)` / `planAddedWithStart(date)`). Localized: add-plan
  flow (app bar, pills, start-date sheet, confirm dialog + actions, queued
  warning, success snackbar), attendance calendar (month header, weekday glyphs
  via `weekdayShort`, nav tooltips, legend), add-edit client/template forms +
  validation snackbars, `AppConfirmDialog.show` defaults → `s.confirm`/`s.cancel`,
  `form_card_screen` save default → `s.save`, `AppErrorState` retry → `s.retryLabel`,
  client/template cards, past-attendance session summary, `main.dart` titles.
  - NOTE: `ProCalendarApp`'s title comes from `languageProvider`
    (`lang == 'fa' ? AppStrings.fa.appTitle : AppStrings.en.appTitle`) — the
    context is ABOVE `MaterialApp`, so `AppStrings.of(context)` throws there.
- **M2 (Dismissible crash):** clients list tracks `_dismissedIds`; `onDismissed`
  removes the row synchronously (`setState`) then deletes; on failure the row
  returns with an error snackbar.
- **M3 (destructive delete):** past-attendance `_deleteRecord` confirms via
  `AppConfirmDialog` (`s.deleteSession` / `s.deleteSessionMessage`) first.
- Tests: +2 unit tests (`plans_service_test.dart`: unfreeze-queues-while-active;
  `getRemainingDays` = exactly 20). Widget tests updated: calendar-weekday test
  now wires the `fa` locale; attendance-marking test dismisses the new delete
  dialog. Smoke test untouched (title resolved via provider).

**LAST SESSION (2026-09-20) — web build fixed; package migration REVERTED:**
- An uncommitted, half-finished attempt to extract the Drift DB into a new
  `packages/fitness_database` package was found in the working tree (broken:
  277 analyze errors; package missing all DAO methods + `forTesting`). It is
  **reverted** — do NOT recreate a database package; ARCHITECTURE STANDS:
  `lib/core/database/app_database.dart` + `.g.dart`.
- **Root cause of `flutter run -d chrome` failing was in HEAD itself**: commit
  `7fe11b5` added `import 'package:sqlite3/sqlite3.dart';` to `app_database.dart`
  (to catch `SqliteException` in migrations), which pulls `dart:ffi` into the
  web build → dart2js: "Dart library 'dart:ffi' is not available on this
  platform". Fixed by dropping that import and using `on Exception` +
  `e.toString().contains(...)` (same duplicate-column/already-exists safety).
- Verdict: `flutter analyze` = No issues found!; `flutter test` = 164/164;
  `flutter build web` = builds (even wasm dry-run passes).
- **Workspace cleanup (same session)**: deleted root `sdk-archives.csv`, the two
  `1789550528600-*.md` plan docs, `.kilo/` state, `test_out.txt`, throwaway
  `fix_*.py`/`update_*.py` scripts, and regenerable caches
  (`.dart_tool`, `build/`, `.widget_preview/`, `.idea`, `.gradle`,
  `local.properties`, `.iml`). Removed unused deps from `pubspec.yaml`:
  `cupertino_icons`, `flutter_svg`, `shared_preferences` (zero imports).
- **Mojibake fix (same session)**: `lib/main.dart` contained literally
  double-encoded Persian (cp437 mojibake) in the app title + startup-error
  message; repaired to proper UTF-8 and replaced the string with the
  canonical `AppStrings.appTitle` value. Also set platform display names:
  Android label + iOS `CFBundleDisplayName` → `تقویم حرفه‌ای`; Windows/Linux
  runner window titles → `PRO CALENDAR`.
- **App icons regenerated (same session)**: programmatic (Pillow) icon set on
  the real brand palette (dark-green `#161D15`/`#1F2A1E`, sage `#9DBE7E`,
  pale `#E3F0E5`, amber "today" `#FFB74D`): 5 Android mipmaps, the 15-file iOS
  AppIcon set (opaque), web `favicon.png` (32), `apple-touch-icon.png` (180),
  `icons/Icon-{192,512}` + maskable variants. Sync: theme colors in
  `web/index.html` + `web/manifest.json` were navy `#1A1A2E` → now the green
  palette; deleted stale `web/icons/favicon.png` + `web/icons/apple-touch-icon.png`.
  NOTE: a future `flutter build web` may regenerate `web/favicon.png` — re-copy
  the design if it reverts.

Relative paths below are from the root `D:\work\ZAHRA\PRO CALENDER\fitness_trainer_app`.

**PATH & TOOLING GOTCHAS (READ FIRST — this burned a whole session):**
- These bind to ONE canonical tree only: `D:\work\ZAHRA\PRO CALENDER\fitness_trainer_app`
  (paths contain a REAL SPACE, "PRO CALENDER"). If your reads return content that
  doesn't match that path / looks like a spell-alike, IGNORE the spell-alike and
  fall back to `flutter analyze` + `flutter test` as the only ground truth.
- `flutter` is NOT on PATH. Prefix every command:
  `$env:PATH = "C:\flutter\bin;$env:PATH"; flutter ...  `  — run inside
  `fitness_trainer_app/`. Flutter lives at `C:\flutter`.
- After editing Drift tables/providers, regenerate the generated file:
  `dart run build_runner build --delete-conflicting-outputs` — STALE `.g.dart`
  is the #1 cause of "I edited it but nothing changed" confusion here.
- `dart run build_runner build` needs `dart` on PATH too (same prefix).

**ACTIVE WORK — Per-Plan Pricing + Auto-Income (Task 2 of the handoff plan): COMPLETED**
Goal: each plan gets its own `price` and gym `sharePercent`; assigning/purchasing a
plan auto-creates an **income** transaction; accounting shows per-plan share, and
reports (Jalali charts) show the split with a monthly Jalali chart.

STATUS: **All slices DONE — green.**
- `ClientPlans` table has `price` (default 0) and `sharePercent` (default 0);
  schemaVersion 6 (v5 added price/share, v6 added `Transactions.planId`). `.g.dart`
  regenerated. Auto-income rows link to their plan via `Transactions.planId` (FK
  setNull), and `deletePlan` deletes that plan's transactions first so the ledger
  and per-plan share stay in sync.
- **Inline create everywhere**: a shared `TagEditorDialog` (`lib/features/tags/presentation/widgets/tag_editor_dialog.dart`) provides one consistent create/edit tag UI (name + emoji + 8 colors) used by both the Tags screen and the client tag picker. The client tag picker (`client_tag_picker.dart`) now watches tags live and shows an "افزودن تگ جدید" affordance; newly created tags appear instantly and are auto-selected.
- **Add-plan empty-state create**: when no templates exist, the add-plan screen shows a "ساخت قالب جدید" button that pushes the existing `AddEditTemplateScreen`; on return it invalidates templates and auto-selects the newly created template.
- Review round: transaction rows delete via a trailing delete button (no whole-
  card tap), money/price/share/session inputs accept Persian digits
  (`toLatinDigits` in `core/utils/persian_numbers.dart`), dead code removed.
- Domain `ClientPlan` model, repository mappings, and `PlansService.assignPlan`
  all thread `price` + `sharePercent` (optional named params, default 0).
- **Bug fixed**: `PlansRepository.getActivePlan`, `getFrozenPlan`, `getPlan` now
  correctly map `price` + `sharePercent` (were missing before).
- **Auto-income wired**: `assignPlan(price > 0)` inserts `income/plan` transaction
  (active or queued). Provider + add-plan UI pass price/share; demo data seeds priced plans.
- **Per-plan share on accounting screen**: summary shows income, expense, gym share
  (Σ price×share%), net balance. New "سهم برنامه‌ها" section lists each priced plan
  with template name, client, price, share%, deduction, remaining days.
- **Reports feature** (`lib/features/reports/`): period selector (weekly/monthly/yearly),
  Jalali monthly income bar chart (last 12 months, current highlighted), 7-day trend
  line chart. Route `/reports` accessible from accounting app bar.
- **Accounting summary uses per-plan share**: `gymShare` = sum of per-plan deductions,
  `net` = income − gymShare − expense.
- **Onboarding (new)**: first-launch carousel (4 slides) covering Clients, Plans, Attendance, Reports. Shown once via `shared_preferences` flag `onboarding_completed`. Slide text fully localized in `AppStrings` (`onboardingTitle1..4`, `onboardingBody1..4`, `onboardingSkip/Next/GetStarted`). Implemented in `lib/features/onboarding/presentation/onboarding_screen.dart` and gated in `main.dart` via `OnboardingGate`.
- Verdict: `flutter analyze` clean; `flutter test` **129/129 pass** (onboarding included; core suite still 164/164).

## Architecture / how the app is planned
- **Data**: Drift (`lib/core/database/app_database.dart` + `.g.dart`). Tables:
  Clients, ClientTags, Tags, PlanTemplates, ClientPlans (price + sharePercent),
  Attendance, AppSettings, Transactions.
- **Plans feature** `lib/features/plans/`: service → repository → drift DAO.
  `assignPlan(clientId, templateId, sessions, days, price, sharePercent, startDate)`
  is the single plan-assignment entry point; queues when active exists; auto-income
  when `price > 0`. Freeze/promote/queue-promote in `plans_service.dart` /
  `plans_repository.dart`. `getAllPlans()`, `planShareDeduction(plan)` added.
- **Accounting feature** `lib/features/accounting/`: transactions service +
  repository; screen shows income/expense/gym-share/net + per-plan share section.
- **Reports feature** `lib/features/reports/`: pure `ReportsService` computes
  `totalsBetween`, `monthlyBuckets`, `dailyBuckets`; `ReportsScreen` renders charts
  using `AppMiniBarChart` + `AppLineChart`.
- **Providers**: Riverpod (`.autoDispose` reads), services kept alive. Providers in
  `lib/features/plans/providers/`, `lib/features/accounting/providers/`,
  `lib/features/reports/providers/`. `allPlansProvider` added + invalidated on mutations.
- **Localization**: `AppStrings` (Persian + English, `lib/core/l10n/`); new keys
  for price, share, per-plan share, reports, month/day labels. Jalali utils in
  `lib/core/utils/jalali_calendar.dart` + `shamsi_date`.
- **Backup**: `BackupService` JSON/CSV export/import; schema version exported in
  JSON marker (test asserts `schemaVersion == 6`).
- **Demo data**: seeds 4 clients, 3 templates, 3 tags, 31 attendance records;
  4 plans with price/sharePercent (auto-income recorded); 2 expense transactions.
- **Onboarding**: `lib/features/onboarding/presentation/onboarding_screen.dart` — 4-slide
  carousel (Clients, Plans, Attendance, Reports) with page indicators, Skip/Next/Get Started.
  Persists `onboarding_completed` in `shared_preferences`. Gated by `OnboardingGate` in `main.dart`.

## Commands
- Run: `$env:PATH = "C:\flutter\bin;$env:PATH"; flutter run`
- Analyze: `flutter analyze` (keep at "No issues found!")
- Tests: `flutter test` (keep at 160/160; add tests for new behavior)
- Drift codegen: `dart run build_runner build --delete-conflicting-outputs`
- Regenerate DB for a scratch run, etc. — careful with paths.

## Git / housekeeping
- Do not commit unless asked. Working-tree scratch scripts (`fix_*.py`, DB
  dumps, etc.) are throwaway — never delete or commit them.
- After each completed task, update this file's status lines so the next
  session knows exactly what's done.