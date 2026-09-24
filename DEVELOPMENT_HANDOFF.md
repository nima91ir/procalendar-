# DEVELOPMENT_HANDOFF — fitness_trainer_app (Pro Calendar / Pro Calender)

Persian (RTL) **personal-trainer CRM**: clients, plans (from templates),
attendance, accounting, Jalali calendar, JSON/CSV backup. Flutter app lives in
`fitness_trainer_app/`. This file tells the next session what exists and what's
next. It is the only long-form source of truth besides `AGENTS.md`.

**CURRENT HEAD (2026-09-24) — backup wording: JSON is the backup, CSV is not (implemented):**
- **Why**: the card said "make a backup file **or** export CSV for Excel", which reads as two
  equivalent ways to back up. They are not equivalent. `exportJson` round-trips;
  `exportClientsCsv` / `exportPlansCsv` / `exportAttendanceCsv` / `exportTransactionsCsv` are
  four one-way, table-per-file, **unlinked** reports, and there is **no CSV import** —
  `importJson` validates an `"app": "procalendar"` header, so a CSV cannot be restored at all.
  Reconstructing plans/attendance/client links from four spreadsheets would be guesswork, so
  CSV is not a bug to fix: it is a report for Excel, not a lifeline.
- Copy changes (fa + en, no new keys except one): `backupDescription` now states backup = JSON
  and CSV cannot be restored; `exportCsv` became «خروجی برای اکسل (CSV)» / "Export for Excel
  (CSV)" so the button no longer reads as a backup peer of the JSON button;
  `backupSavedTemplate` gained "keep a copy somewhere else (email or cloud)" — a backup sitting
  on the same phone is not a backup.
- New key `csvNotBackupNote` (field + ctor param + fa + en), rendered as an amber
  `Icons.info_outline` line at the top of the CSV bottom sheet (`settings_screen.dart`,
  `_openCsvSheet`). Chosen because that is the decision point: the moment a user reaches for CSV
  is the moment they are most likely to mistake a spreadsheet for a backup. Deliberately
  advisory, not a blocker — all four CSV options still work.
- No behaviour change, no schema change, no new provider, no dependency. `flutter analyze` =
  No issues found!; `flutter test` = 199/199 (unchanged — copy + presentation only).
- Verified by running the app and reading the rendered accessibility tree, not just by reading
  code: the note appears above the four CSV choices and the relabelled button shows.
- Known gap, not fixed: CSV still needs four separate exports. Deferred — bundling them means
  four download prompts, and `saveTextFile` cannot detect a browser-blocked download.

**CURRENT HEAD (2026-09-24) — backup reminder banner + last-backup visibility (implemented):**
- **Why**: the app has no server; every record lives in the user's own browser storage and
  nothing in the product ever told the user to make a backup. Two known gaps were closed:
  *no backup reminder* and *no way to see whether the data had ever been backed up*.
- **`BackupReminder`** (`lib/features/backup/domain/backup_reminder.dart`, new): pure logic —
  `intervalDays = 14`, `snoozeDays = 2`, `isDue({lastBackup, snoozedUntil, today})`,
  `daysSince(...)`, `snoozeUntilFrom(now)`. The snooze comparison relies on zero-padded
  Jalali `yyyy/MM/dd` keys sorting lexicographically = chronologically. `today` is injected
  rather than read from the clock so the rules are unit-testable.
- **Persistence — no schema change**: `SettingsService` gained `getLastBackupDate` /
  `setLastBackupDate` / `getBackupSnoozeUntil` / `setBackupSnoozeUntil`, all riding the
  existing `app_settings` key/value table. `schemaVersion` stays **7**.
- **`BackupReminderBanner`** (`lib/features/backup/presentation/widgets/`, new) sits in the
  dashboard `ListView` above the attendance section. It returns `SizedBox.shrink()` when not
  due and carries its own bottom `margin`, so dashboard spacing is byte-identical while
  hidden. «پشتیبانگیری» jumps to the Settings tab (index 4); «بعداً» snoozes for 2 days. It
  reads `.value` from the provider, so a load/DB failure hides a reminder instead of breaking
  the dashboard.
- **`backupReminderProvider`** (`FutureProvider.autoDispose<BackupReminderState>`,
  `lib/features/backup/providers/backup_providers.dart`) reads the two dates and applies
  `BackupReminder`. Invalidated after a successful backup and after snoozing.
- **Settings screen**: `_exportJson` records the backup date **only when `saveTextFile`
  returns non-null** — the IO implementation returns null when the save is cancelled, and
  recording that would silence the nudge without a backup file actually existing. The backup
  card now shows «آخرین پشتیبانگیری» plus the date and «N روز پیش», switched to
  `tones.warning` once overdue.
- New AppStrings keys (fa + en + ctor param + both maps): `lastBackupLabel`,
  `lastBackupNever`, `lastBackupOnTemplate`, `daysAgoTemplate`, `backupReminderNeverBody`,
  `backupReminderDueTitleTemplate`, `backupReminderGo`, `backupReminderLater`; helper methods
  `lastBackupOn(date)`, `daysAgo(days)`, `backupReminderDueTitle(days)` (Persian digits via
  `_digits`). `jalali_calendar.dart` gained `jalaliToDateTime` / `jalaliFromDateTime` for date
  **arithmetic** only — display still uses the Jalali key via `formatDateShort`.
- Tests: `test/unit/backup_reminder_test.dart` (never backed up / 13 / 14 / 40 days,
  unreadable + out-of-range keys, snooze in the future / today / past, `snoozeUntilFrom`) and
  `test/widget/backup_reminder_banner_test.dart` (hidden when fresh, hidden exactly at the
  boundary, shown when never, Persian-digit overdue title, «بعداً» hides it and persists
  today+2). Verdict: `flutter analyze` = No issues found!; `flutter test` = **199/199** green
  (was 181).
- **Still open / explicitly deferred**: there is still no way for a user to tell *which
  version* they are running — no build stamp, no version picker, no user-facing rollback.
  Rollback remains operator-only and all-users-at-once. Deferred pending a decision.

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
- **FAB compaction (UI)**: the 4 `FloatingActionButton.extended` pills (clients/templates/tags/
  accounting) became compact circular icon FABs (label moved to tooltip), and every list got 88px of
  bottom padding so the last card/row's actions are never hidden behind the FAB.
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
  schemaVersion 6 when this entry was written. **The current `schemaVersion` is 7.**
  `.g.dart`
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
- ~~**Onboarding (new)**: first-launch carousel (4 slides)~~ **CORRECTED 2026-09-24:
  this was never implemented.** The bullet below used to claim a first-launch
  onboarding carousel persisted via `shared_preferences`, with keys
  `onboardingTitle1..4` in `AppStrings` and a file at
  `lib/features/onboarding/presentation/onboarding_screen.dart`. None of that exists
  in this repository: there is no `lib/features/onboarding/`, the string
  `onboarding` appears nowhere under `lib/`, `shared_preferences` is not a
  dependency and is not referenced anywhere, and
  `git log --all -- '*onboarding*'` returns no commit that ever added such a file.
  The claim was probably written from the abandoned `.kilo` worktree. If onboarding
  is wanted, it is **new work** — do not go hunting for missing files.
- Verdict at the time: `flutter analyze` clean; `flutter test` 129/129 (core suite
  164/164 earlier). **Current count is 177/177.** The "onboarding included" note was
  wrong — see the correction above.

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
- **Backup**: `BackupService` JSON/CSV export/import; schema version exported in the
  JSON marker. The exporter writes the live `db.schemaVersion`, and the test now
  asserts **7**, so it tracks the schema automatically (this line used to say 6).
- **Demo data**: seeds 4 clients, 3 templates, 3 tags, 31 attendance records;
  4 plans with price/sharePercent (auto-income recorded); 2 expense transactions.
- **Onboarding**: **does not exist** — see the correction above. There is no
  `OnboardingGate` in `main.dart`.

---

## ⚠️ CURRENT STATE — authoritative, verified 2026-09-24

This log is append-only and contains stale snapshots. When it disagrees with the
code, **the code wins**: `flutter analyze` + `flutter test` are the only authority.
Verified against `HEAD = 5cb7483`:

- `schemaVersion` = **7** (`lib/core/database/app_database.dart:101`).
- `flutter analyze` → No issues found!; `flutter test` → **181/181 pass**
  (was 177; the pre-restore safety net added 4).
- `lib/features/` contains exactly: accounting, attendance, backup, clients,
  dashboard, plans, reports, settings, tags, templates. **No onboarding.**
- `shared_preferences` is not a dependency and is not referenced anywhere.
- Backup/restore is in **better** shape than this log implies:
  - `BackupService.previewCounts()` validates a file and returns row counts
    **without writing**, and `import_backup_screen.dart` already calls it — a
    dry-run preview already exists.
  - `importJson` runs `_wipe()` + insert inside a single `db.transaction`, so a
    `replace` restore is atomic.
  - `_merge` inserts only missing ids, so restore-by-merge never overwrites
    existing data.
  - **Pre-restore safety net (added 2026-09-24):** a `replace` restore now saves
    `procalendar-safety-<timestamp>.json` first and **aborts the restore if that
    save fails**, so a wrong-file restore can no longer destroy the only copy. An
    empty database skips the file (nothing is at risk); `merge` is untouched
    because it never deletes anything.
  - **Remaining gap:** no "last backup" tracking or reminder anywhere in the app.
- The safety net is testable because the save goes through
  `textFileSaverProvider` (`lib/core/platform/file_saver_provider.dart`). That
  indirection is not decoration: a widget test runs on the VM, where
  `file_transfer.dart` resolves to the **native** implementation and
  `getApplicationDocumentsDirectory()` has no platform channel, so an
  un-injectable save can never be covered by a test. Covered by
  `test/widget/import_backup_safety_test.dart` (4 cases: copy saved before wiping,
  empty-DB skip, failed save aborts and keeps the data, merge untouched).
- **Known limitation:** on the web `saveTextFile` cannot confirm that the browser
  actually delivered the file, so a *blocked* download is not detected. The net
  catches failures, not a silently blocked download.
- False/outdated claims corrected in place above: the onboarding feature (×2),
  `schemaVersion 6`, and stale test counts.

### Deploy safety (also 2026-09-24)

- **`main` STILL AUTO-DEPLOYS.** Verified 2026-09-24 against `origin`: its
  `deploy.yml` declares `on: push: branches: [main]` as well as `workflow_dispatch`,
  and the newest successful run was a `push` on `5cb7483`. The working-copy edit
  removes the push trigger **and** adds `flutter analyze` + `flutter test` before
  the build, but it is uncommitted — so as of now a push to `main` still publishes
  *without* tests. Once committed, publishing becomes: Actions → *Deploy Flutter
  Web to GitHub Pages* → Run workflow.
- Rollback target: tag **`live-2026-09-24`** = `5cb7483`, which the API confirms is
  the **currently deployed** commit, so the tag is correct. Pushed to `origin` on
  2026-09-24 (it was local-only before that — one deleted folder away from being
  lost entirely).
- **Rollback is operator-only and all-users-at-once.** There is no per-user version
  choice and no update prompt anywhere in `lib/`. The deployed bundle carries no
  commit stamp (`version.json` is only `1.0.0`/`1`), so you cannot tell from the
  live site which commit is serving. Users with a cached tab keep the old build
  until the service worker refreshes.
- **Rolling back code does NOT roll back data.** Every user's data sits in their own
  browser storage, so redeploying `5cb7483` just reads whatever state the bad
  release left behind. The only real data rollback is restoring a backup JSON.
- A failing build does not take the site down: when the `build` job fails the
  `deploy` job never runs, so Pages keeps the previous artifact (the 2026-09-19
  failure was followed by a success with no outage). The risk is a silently stale
  site, not a broken one.
- `.github/workflows/ci.yml` runs analyze + test on push/PR and **never deploys**.
- The `.kilo/` duplicate worktree was deleted again. It is gitignored, so this
  change is local-only. **Deleting it matters:** while present it shadows the real
  files in searches (an `includePattern` of `fitness_trainer_app/lib/**` matches
  only the `.kilo` copy).

## Commands
- Run: `$env:PATH = "C:\flutter\bin;$env:PATH"; flutter run`
- Analyze: `flutter analyze` (keep at "No issues found!")
- Tests: `flutter test` (keep at 199/199; add tests for new behavior)
- Drift codegen: `dart run build_runner build --delete-conflicting-outputs`
- Regenerate DB for a scratch run, etc. — careful with paths.

## Git / housekeeping
- Do not commit unless asked. Working-tree scratch scripts (`fix_*.py`, DB
  dumps, etc.) are throwaway — never delete or commit them.
- After each completed task, update this file's status lines so the next
  session knows exactly what's done.