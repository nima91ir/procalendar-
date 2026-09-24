# AGENTS.md

Flutter app: `fitness_trainer_app/` (Persian/RTL personal-trainer CRM).
Long-form plan + per-file changelog lives in `../DEVELOPMENT_HANDOFF.md`
(relative to the app dir) — read it first; update it whenever a task completes.

## Commands (run inside `fitness_trainer_app/`)
- **flutter is NOT on PATH.** Prefix every command:
  `$env:PATH = "C:\flutter\bin;$env:PATH"; flutter ...`
- Analyze: `flutter analyze` — leave it at "No issues found!".
- Tests: `flutter test` — currently **199**, keep them all green.
- After editing Drift tables/providers in `app_database.dart` or any
  `*.g.dart`-backed file:
  `dart run build_runner build --delete-conflicting-outputs`
- Do NOT create new packages. Charts = `app_charts.dart`, CSV = hand-rolled.

## Ground truth (read this before trusting any document)

- **This app has live users.** All data lives in their browser storage; there is
  no server and no second copy. Treat every change as production-affecting.
- **`flutter analyze` + `flutter test` are the only authority** on the app's state.
  `../DEVELOPMENT_HANDOFF.md` is an append-only log and contains older snapshots
  that are stale or outright wrong. Check code, not prose.
- **`schemaVersion` is 7 and must not change.** Users' live databases are at v7, so
  a schema change makes Drift run a migration on their devices. **No schema
  changes in this app** — the successor app exists for that.
- Never touch `lib/core/database/app_database.dart`, `app_database.g.dart`, or the
  import/restore core in `backup_service.dart` without an explicit instruction.

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
- The root workspace used to contain throwaway scripts (`fix_*.py` etc.); they
  were reviewed and deleted (2026-09-20 cleanup). Only commit/stage when the
  user explicitly asks.
- **Publishing is now a MANUAL step.** `.github/workflows/deploy.yml` declares
  `on: workflow_dispatch` only, so a push to `main` does **not** publish — it runs
  `.github/workflows/ci.yml`, which does analyze+test on push/PR and never deploys.
  To publish: Actions → "Deploy Flutter Web to GitHub Pages" → Run workflow (main).
- `deploy.yml` runs analyze + test **before** the build, so a failing suite leaves
  the live site untouched; a failing build does not take the site down either
  (Pages keeps the previous artifact). The risk is a silently stale site.
- History: pushes to `main` used to auto-deploy with **no tests** — all 14 runs in
  the repo's history are `push` events, the last on `5cb7483`. Do not reintroduce
  `on: push` here. Rollback is operator-only and hits all users at once: re-run the
  previous successful run's jobs. That path is **unverified** — test it before you
  need it.
- **`.kilo/` duplicate worktrees**: `.kilo/` is gitignored (`.gitignore:2`) but has
  already come back after being deleted. When present it holds a full copy of the
  app and **breaks search**: an `includePattern` containing
  `fitness_trainer_app/lib/**` silently matches only the `.kilo` copy and misses
  the real `lib/`. Delete it if it reappears. When searching, scope with `lib/**`
  (relative to the app dir), never a path that contains `fitness_trainer_app/`.
- **Editing files**: apply **one** edit per file per tool call. Batching several
  edits to the same file in one block has repeatedly mis-applied them at the wrong
  offset (once splitting a Dart string literal so the whole library failed to
  compile). Start each `old_string` with a line that is unique in the file — a
  generic opener like `children: [` can match a different widget entirely — and
  read the region back afterwards. Markdown/docs are not caught by any tooling, so
  they *must* be read back.
- Commit-style prefixes from the repo history (`UI:`, `feat:`, `fix:`); ask
  before committing anyway.