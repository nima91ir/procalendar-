# AGENTS.md

Flutter app: `fitness_trainer_app/` (Persian/RTL personal-trainer CRM).
Long-form plan + per-file changelog lives in `../DEVELOPMENT_HANDOFF.md`
(relative to the app dir) — read it first; update it whenever a task completes.

## Commands (run inside `fitness_trainer_app/`)
- **flutter is NOT on PATH.** Prefix every command:
  `$env:PATH = "C:\flutter\bin;$env:PATH"; flutter ...`
- Analyze: `flutter analyze` — leave it at "No issues found!".
- Tests: `flutter test` — currently 96, keep them all green.
- After editing Drift tables/providers in `app_database.dart` or any
  `*.g.dart`-backed file:
  `dart run build_runner build --delete-conflicting-outputs`
- Do NOT create new packages. Charts = `app_charts.dart`, CSV = hand-rolled.

## Conventions
- **Localization**: every user-facing string goes through `AppStrings`
  (`lib/core/l10n/app_strings.dart`) with BOTH `fa` and `en` values + a
  constructor param. New template methods must render Persian digits via
  `_digits()`. Never hardcode new Persian strings in localized screens.
- **Dates**: store Jalali `yyyy/MM/dd` strings; display via `formatDateLong`
  / `formatDateShort` (`core/utils/date_format.dart`) with the app language.
- **State**: Riverpod 3 — `FutureProvider.autoDispose` for reads,
  `NotifierProvider` for mutable state, plain `Provider` for services, `.family`
  keyed by id. After any mutation, invalidate the affected providers AND call
  `ref.invalidateAppData()` (`core/providers/app_refresh.dart`).
- **Do not break the multi-attendance rule**: a client may have several
  attendance records per day (no unique constraint on `attendance(clientId,date)`).
  Single-record lookups must be `..orderBy(id desc)..limit(1)`. Use
  `addSession`/`removeSession` on the attendance notifier (each add consumes a
  plan/bonus session, each removal refunds one).
- **Plans stay as history**: expired ("برنامهها"/`plansSection`) plans remain
  listed — only explicit delete removes them.
- **Shared widgets**: cards/empty states/hero → `app_widgets.dart`; charts →
  `app_charts.dart`. M3 `NavigationBar` already in use.
- Keep `DEVELOPMENT_HANDOFF.md` updated after completing tasks (it drives the
  next session/agent).

## Tests
- Widget tests that render localized UI MUST pass locale wiring (delegate +
  supportedLocales) or use the existing `buildHarness(...)` pattern — otherwise
  strings resolve to English and finders fail.
- Don't assert on text that sits below the fold inside lazy `ListView`s —
  scroll first (`scrollUntilVisible`).

## Git
- The user's working tree contains throwaway scripts (`fix_*.py` etc.) — do
  not delete or commit them. Only commit/stage when the user explicitly asks.
- Commit-style prefixes from the repo history (`UI:`, `feat:`, `fix:`); ask
  before committing anyway.