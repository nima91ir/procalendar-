# DEVELOPMENT_HANDOFF — fitness_trainer_app (Pro Calendar / Pro Calender)

Persian (RTL) **personal-trainer CRM**: clients, plans (from templates),
attendance, accounting, Jalali calendar, JSON/CSV backup. Flutter app lives in
`fitness_trainer_app/`. This file tells the next session what exists and what's
next. It is the only long-form source of truth besides `AGENTS.md`.

**CURRENT HEAD (2026-09-26) — FULL-APP ۷ UX-LAW PROTOTYPE, no app code touched (design-only deliverable):**
- New standalone file: `fitness_trainer_app/build/mockups/redesign/ux-laws-all-pages.html`
  (~106 KB, 3 script blocks). This supersedes `ux-laws-lab.html`, which only covered the
  dashboard. Structure, Persian strings and paths were extracted from the real
  `routes.dart`, `main.dart` and `app_strings.dart` — **all 15 routes render**:
  `dashboard`, `clients`, `client-detail`, `client-add`, `client-edit`, `add-plan`,
  `attendance`, `templates`, `template-add`, `template-edit`, `tags`, `accounting`,
  `reports`, `settings`, `import`. Each tab keeps its own navigation stack, so
  «مشاهدهٔ پرونده» → «ویرایش» → back behaves like the real shell.
- Also implemented: 7 bottom sheets (`client`, `tx`, `tag`, `price`, `day`, `csv`, `end`)
  and 8 dialogs (`confirmPlan`, `replace`, `delPlan`, `delRec`, `delTx`, `delClient`,
  `delTag`, `delTpl`). All were clicked open and confirmed to render, with zero
  page errors.
- **The seven laws are individually toggleable and each one is measured from the rendered
  DOM** (`measure()` re-runs on every paint, paired with `ResizeObserver` +
  `document.fonts.ready`). Seven live metrics: Hick = action count, Fitts = smallest
  hit area, Miller = chunk count, von Restorff = distinct-element count, Jacob = nav-item
  count, Peak-End = closing affordance, Proximity = between-group gap. Verified deltas
  with all laws on: actions 43 → 19 on the clients list, smallest target 30 → 44px,
  chunks 0 → 3, group gap 12 → 36px. Turning each law off individually produced a
  measurable structural change on every page.
- **Four real bugs were found and fixed during validation** — all worth remembering:
  1. `const top = …` collided with the built-in `window.top` (non-configurable), which
     aborted the whole script block and cascaded into `$ is not defined`. Renamed to
     `topRoute`. **Check new top-level identifiers against the window's own globals.**
  2. A stray `}` inside a `.map(r => …)` template broke script 2 (`Unexpected token '}'`).
     `node --check` on each extracted `<script>` block finds these instantly; the browser
     only reports them as an opaque page error.
  3. **A `<button>` nested inside another `<button>`** on the add-plan page made the HTML
     parser auto-close the outer element, so the whole page fell apart and the bottom nav
     disappeared. The card is now a `<div>` wrapper with an inner row button. *Any* nested
     interactive element does this — check `screen.children` after rendering, not the source.
  4. `String(d).padStart(2,'۰')` produced `۰1` (Persian zero, Latin one). It must be
     `fa(String(d).padStart(2,'0'))`. A sweep for `/[0-9]/` in leaf text nodes now finds
     nothing on any of the 15 pages.
- Accessibility work: a `wireLabels()` pass after each render links every visible
  `<label>` to the control that follows it, so no input is left without an accessible
  name (search, backup textarea, all form fields). Every button has a name, no duplicate
  IDs, and the muted/chevron greys were darkened to clear WCAG AA on white — `--muted`
  `#6b786e` → `#5f6b5a`, chevrons `#8a9686` → `#67735f`. Contrast now passes AA on all
  15 pages (text sitting on a gradient is excluded — the checker cannot resolve those).
- Responsive: no horizontal overflow at 320/360/380/420/480/560/768/820/900/1024/1280/1600px;
  the law bar reflows 2 → 3 → 4 → 7 columns. Three layout bugs were found and fixed:
  `grid-template-columns:1fr` in the ≤820px query overflowed because a `1fr` track's
  automatic minimum is `auto` (now `minmax(0,1fr)`); the sticky offset was hardcoded
  `top:80px` while the topbar wraps to 120–170px on narrow viewports, sliding the phone
  and panels underneath it (now a `--topbar-h` custom property measured by a
  `ResizeObserver`); and `scroll-padding-top` was set on `html` by hand rather than
  derived from the real topbar height.
- **Navigation-stack bug worth remembering:** `goto` was calling `go()`, which *resets*
  the tab stack, so the appbar back button was dead code and «برگشت» never worked. It now
  pushes for same-tab navigation and switches tabs (resetting) for cross-tab links, so
  «قالب‌ها» → «ویرایش قالب» → back works and the back button appears only when there is
  somewhere to go.
- **Fidelity pass against the real running app (`http://localhost:10179/`, 2026-09-26).** The
  running app was driven in a browser and the semantics tree read, which caught six places the
  prototype had drifted from the real screens. All are now fixed:
  1. **Settings had an invented «اطلاعات مربی» section.** The real screen has exactly five:
     ظاهر برنامه / زبان / برچسب‌ها / پشتیبان‌گیری و خروجی / ابزار توسعه. Removed, and the
     Hick focal copy changed from «شش بخش» to «پنج بخش» to match.
  2. **Two Persian strings were truncated.** The real backup note ends «… هنگام ورود، داده‌ها
     ابتدا ادغام می‌شوند و در صورت نیاز می‌توانید همه را جایگزین کنید.» and the dev-tools note
     ends «… تا داشبورد، برنامه‌ها و مصرف جلسات بررسی شود.» Both restored verbatim.
  3. **The clients list row was wrong.** The real row is name + phone + `plan · X از Y · N روز
     باقی‌مانده` followed by four named actions: حضور و غیاب / گزینه‌های مشتری / متوقف
     (only when a plan is active) / افزودن برنامه. The prototype had حاضر/غایب buttons and a ⋮ —
     those belong to the **dashboard** row, which is a different component. Split into
     `clientRowPlain` (list) and `dashRowPlain` (dashboard).
  4. **Tag filters are multi-select checkboxes, not single-select chips.** Real: four
     `checkbox` chips (همه + tags) that union. Changed `S.tag` (single id) → `S.tags` (a Set);
     the filter matches clients holding *any* selected tag. The chips row was also missing from
     the **clients** screen (it was only on the dashboard) — added. Verified 8 → 3 (one tag)
     → 6 (two tags) → 8 (همه).
  5. **Client detail appbar was missing «حذف مشتری»** (real: برگشتن + name + ویرایش + حذف
     مشتری), and **«جلسه هدیه حذف شد» is `disabled` at zero bonus** in the real app.
  6. **Attendance is missing two real details**: the calendar legend (امروز / حاضر / غایب) and
     weekday names on the history groups — the real app shows «پنج‌شنبه ۱۴۰۵/۰۶/۰۳», not a raw
     date. Also the dashboard backup banner has a **«بعداً» dismiss** button, now present and
     wired to `S.bannerLater`. The reports chart also gained the real Jalali month labels.
- Re-validated after the fidelity pass: all 15 routes × both law modes = 30 combinations with
  zero console errors, 5 nav items, ≥44px minimum target with Fitts on, no Latin digits, no
  duplicate IDs, no unnamed buttons, no unlabeled inputs, no clipped scroll, and **WCAG AA
  contrast on every non-gradient text node**. A 20-step interaction smoke test (mark, undo,
  freeze, bonus, day sheet, plan confirm, banner dismiss, tag filter, back, reset) runs clean
  and `reset` restores the seed data.
- One contrast bug worth remembering: a `[style*="color:#78856f"]{color:#e8f0e2!important}`
  override added for the hero gradient also matched the same inline colour on a *light* card,
  dropping those captions to 1.17:1. Scope such overrides to the gradient's own container
  (`.hero …`) and keep a separate light-background rule.
- **SIDE-BY-SIDE A/B (2026-09-26, user request).** The page now renders **two phones of the
  same route**: the right pane is «امروزیِ اپ» (all seven laws forced OFF) and the left pane is
  «با ۷ قانون» (whatever is toggled). Both panes share one dataset and one navigation stack,
  so a sheet, a mark, or a back press is visible in both at once. Making this work needed
  three structural changes:
  - `paneHTML(laws)` renders one phone under an arbitrary law set by swapping the module-level
    `LAW` object in and out around the (synchronous) template build, restoring it in a
    `finally`. All the `LAW.hick ? A : B` branches inside the screen renderers then produce
    the right variant for free — no per-screen duplication.
  - **The Fitts and Proximity CSS had to move from `html[data-…="on"] .phone …` to
    `.phone[data-…="on"] …`**, because a document-level attribute can only describe one state
    for both panes. `T()` also had to read `LAW.fitts` directly instead of the DOM attribute.
  - `wireLabels()`, `measure()` and the search-field focus restore all had to be re-pointed at
    both mounts (`#mountBefore` / `#mountAfter`); the search handler now captures which pane
    the user was typing in and restores focus there, otherwise typing jumps panes.
- **The live metrics panel now A/Bs the two visible panes directly** instead of comparing
  against a stored baseline: `measure('#mountBefore')` vs `measure('#mountAfter')`, with
  unchanged rows dimmed (`.metric.same`). With all laws on, every one of the 15 routes reports
  3–6 of 7 metrics differing; «حالت امروزیِ اپ» makes all 7 identical, which is the proof the
  comparison is real and not hardcoded.
- Verified: all 15 routes × both law modes × both panes = **60 combinations**, zero console
  errors, same appbar title in both panes, 5 nav items each, ≥44px targets on the laws pane,
  no Latin digits, no duplicate IDs, no unnamed buttons, no unlabeled inputs, no clipped
  scroll, and WCAG AA contrast on every non-gradient text node in **both** panes. Side by side
  from 1024px up, stacked below, no horizontal overflow 320→1920px.
- **Domain rules that must survive any future real implementation** (also in the page footer):
  **multi-attendance per day is legal** — the day sheet lists 2 records for `۱۴۰۵/۰۶/۰۳` for
  the same client and each is individually removable; it is never a single on/off toggle.
  And **expired plans stay listed as history** — only an explicit delete removes them.
- Verified after the work: `git status` over `lib/`, `pubspec.yaml`, `android/`, `ios/`,
  `test/`, `assets/` and `analysis_options.yaml` returns **0 changed files**. No Flutter
  analyze/test run was needed because no application code changed.
- Serve with `python -m http.server 8765 --directory …\build\mockups\redesign` and open
  `http://127.0.0.1:8765/ux-laws-all-pages.html`. `.vscode/tasks.json` wraps that as a "Serve
  mockups" task, but it is deliberately **not tracked**: it hard-codes this machine's absolute
  path and points into the gitignored `build/`, so it would be broken in a fresh clone. Use the
  plain command above.
  **Screenshots in this browser come out blank or at the wrong scale** — trust
  `getBoundingClientRect()` / `getComputedStyle()` assertions instead; that is how every number
  above was verified.

**PREVIOUS HEAD (2026-09-26) — ۷ UX-LAW PROTOTYPE, no app code touched (design-only deliverable):**
- New standalone file: `fitness_trainer_app/build/mockups/redesign/ux-laws-lab.html`. Separate from
  the theme lab and the logo lab; touches no Flutter, `lib/`, Android/iOS assets, Drift,
  `schemaVersion`, or settings.
- It runs **two live copies of the same dashboard data side by side**: «قبل» mirrors the current
  structure (4 hero stat tiles, backup banner, 8 tag chips, three small buttons per client row,
  two section headers) and «بعد» is the same app with the seven laws applied. Both are real,
  working screens — mark present/absent, undo from the snackbar, filter by tag, expand a group,
  open the row bottom sheet, and end the session, all in either pane.
- The seven laws are individually toggleable, so each one's effect is separable: Hick (one
  «قدم بعدی» decision, row = one target, fine choices move into the sheet), Fitts (real hit-area
  growth: 30px → 44px minimum via `.phone[data-fitts="on"]`, primary action in the thumb zone),
  Jacob (same 5-destination `NavigationBar`, same chips, same bottom sheet + snackbar pattern),
  Miller (list chunked into نیازمند اقدام / امروز ثبت شد / باقی مشتریان, capped at 3 with
  «نمایش بیشتر»), Peak-End (celebration on mark + a «پایان جلسه» summary sheet, undo always
  reachable), Proximity (label beside value, gap between groups 97px vs 0px within a group),
  von Restorff (exactly one high-contrast card per screen; the rest recede).
- **The metrics panel is measured, not asserted.** `measure()` reads the rendered DOM on every
  paint and reports choice count, smallest hit area, chunk count, distinct-element count, and
  the within-group vs between-group gaps. A `ResizeObserver` on both panes plus `document.fonts.ready`
  re-measure, so the numbers are never stale. Current all-laws delta: actions 36 → 16, min target
  30 → 44px, chunks 0 → 3, distinct elements 0 → 1, group gap 0 → 97px, total targets 44 → 24.
- **Two bugs found and fixed during validation** (worth remembering for future mockups): cards
  inside the flex-column `.scroll` were being compressed — fixed with `.scroll>*{flex:0 0 auto}`;
  and every law toggle was double-firing because both a per-button listener and the document-level
  delegation flipped `LAWS[id]`, cancelling itself out. Only the delegated handler should exist.
- Two measurement bugs were also corrected: the Restorff metric needed an `ideal1` comparator
  (1 distinct element is the goal, not "fewer"), and the proximity gaps must be measured between
  rendered row rectangles, not from `nextElementSibling` (which returned 0 for both).
- Validation: no console errors, no duplicate IDs, no unnamed buttons, no parser errors, no
  horizontal overflow at 360/480/768/1024/1280/1600px, and body-text contrast passes WCAG AA
  (muted 4.63:1, sage-dark 6.59:1, danger 5.87:1). No Flutter analyze/test run was needed because
  no application code changed.
- If any of this is later implemented for real, two app rules must survive it: **multi-attendance
  per day is legal** (so the row sheet must allow more than one record, not a single toggle), and
  **expired plans stay listed as history** (so the low-session section is not a cleanup task).

**CURRENT HEAD (2026-09-25) — UI THEME LAB, no app code touched (design-only deliverable):**
- The new standalone file is `fitness_trainer_app/build/mockups/redesign/ten-new-themes.html`.
  It is separate from the earlier `ten-new-concepts.html` and does not touch `lib/`, Flutter,
  Drift, `schemaVersion`, or app settings.
- It presents **10 light-first visual themes** over one canonical app scene: Soft Light, Compact
  Data, Kinetic Pop, Editorial Paper, Frosted Sky, Blueprint Grid, Soft Utility, Sport Duotone,
  Color Block, and Mono Utility. Theme differences include density, corners, surface depth,
  typography treatment, color-block hierarchy, and motion—not only palette swaps.
- Controls: screen (`dashboard`, `clients`, `attendance`, `finance`), density (`roomy`, `compact`),
  motion (`off`, `gentle`, `full`), replay, zoom, theme selection, favorites, and a two-theme
  compare tray. Attendance buttons show a local mockup toast; no persistence or data mutation.
- Motion honors `prefers-reduced-motion`; it is optional and never runs as the app's only feedback.
- Validation completed in Chrome via a local HTTP server: 10 themes, 4 screens, density and motion
  toggles, real-button attendance feedback, no duplicate IDs/parser errors, and no horizontal
  overflow at 375/768/1440px. Design references are embedded in the file: Material 3 Expressive,
  Navigation Bar, and Nielsen Norman mobile UX. No Flutter analyze/test run was needed because
  no application code changed.

**CURRENT HEAD (2026-09-25) — ۲۰ LOGO LAB, no app code touched (design-only deliverable):**
- New standalone editor: `fitness_trainer_app/build/mockups/redesign/twenty-logo-lab.html`.
  It is separate from the theme lab and does not touch Flutter, `lib/`, Android/iOS assets,
  Drift, `schemaVersion`, or settings.
- The editor contains **20 functional mark directions** tied to the app's real jobs: clients,
  plans, attendance, progress, accounting, and backup/continuity. Each direction is generated as
  editable inline SVG rather than as a screenshot, so the mark remains crisp at launcher sizes.
- Editable controls: six app-aligned palettes, custom background/primary/dark/accent colors,
  solid/gradient/duotone background, dots/grid/rays/orbit pattern, solid/outline/duotone treatment,
  mark scale, preview mask, monogram, lockup visibility, safe-zone and 10% grid overlays.
- Export actions: SVG, PNG 1024, iOS 1024 PNG, Android adaptive foreground/background/monochrome
  layers, complete kit, and a `flutter_launcher_icons` configuration snippet. Exports are local
  browser downloads only; no package or project file is changed automatically.
- Platform constraints are represented in the UI: iOS square/full-bleed preview, Android circle and
  adaptive previews, central safe zone, and monochrome layer. Apple HIG and Android adaptive icon
  guidance are embedded in the footer; Android uses a 108dp layer / 66dp safe-zone model.
- Validation completed in Chrome: all 20 cards select, all SVGs render, palette/background/pattern/
  treatment/scale/shape toggles update, export controls and config snippet are present, no parser
  errors, no unnamed buttons/duplicate IDs, and no horizontal overflow at 375/768/1440px.
- No Flutter analyze/test run was needed because no application code changed. The user must choose
  a mark before any real launcher asset is generated or installed.

**CURRENT HEAD (2026-09-24) — UI REDESIGN MOCKUPS, no app code touched (design-only deliverable):**
- **Nothing in `lib/` changed.** `git status` is clean; the deliverable is one file:
  `fitness_trainer_app/build/mockups/redesign/index.html` (gitignored because `build/` is, so it
  will not be committed — copy it out if it must survive a `flutter clean`).
- It is a **production-fidelity mockup** of 5 real screens (dashboard, clients, client profile,
  attendance, accounting) with the app's real strings, Jalali dates, Persian digits and the real
  sage palette / 6 accents from `app_accents.dart` + `app_tones.dart`. It renders the *same DOM*
  under 8 art directions by swapping CSS custom properties, which is how it would actually be
  built in Flutter (`AppTones.forAccent` + a direction token layer in `app_tokens.dart`).
- Directions (8, the user pruned the list — B/F/H were removed, so the letters are not
  contiguous): **A** Sage Refined · **C** Data Command · **D** Minimal Compact (replaced the
  rejected Neo-Brutal) · **E** Midnight Neon · **G** iOS Native · **I** Kinetic (motion) ·
  **J** Bento Grid · **K** Notion Style. Each has a note card explaining intent + its risk, and
  every direction works in light **and** dark plus all 6 brand accents.
- **J** reshapes only the dashboard into a 6-column widget grid (`[data-dir="j"] .body.dash` +
  `.tiles{display:contents}`), so the four metric cards become real bento tiles; **K** is the
  quiet "tool" look (hairlines, `#F1F1EF` tags, an emoji callout, checklist rows via
  `.trow:has(.kv)`). Both need the `dash`/`callout` marker classes that are now in the markup.
- Controls: pick a direction (5 phones), **گالری** (all side by side, zoomed), or **مقایسه همه**
  (every screen of every direction). Compare mode forces the root direction to `a` so no
  direction's rules leak into another block.
- Motion in **I** only: animated mesh background, staggered block entrance, self-drawing progress
  ring (`@property --v`), pulsing "today" cell, growing section underline, shimmer sweep on the
  primary button, shimmer skeleton. All of it is inside `@media (prefers-reduced-motion)`
  protection, so Windows "reduce motion" turns it off — the same rule the Flutter side must honour.
- **Not done on purpose:** templates/settings screens, empty/error/loading states beyond one
  skeleton, tablet/desktop layouts, and RTL-vs-LTR of the *review tool* itself (only the app
  surfaces are RTL). No direction has been chosen — do not start implementing one until the user
  picks, and keep `schemaVersion` 7 untouched whatever they pick.

**CURRENT HEAD (2026-09-24) — plan expiry, remaining days/sessions, card & profile UX, attendance-refund truth (implemented, 8 requested items):**

- **Plan expiry by elapsed days — a real bug, fixed.** `PlansService.consumeSession` was the
  *only* code that ever set `status = 'expired'`, and only when **sessions** hit 0. Nothing
  compared `startDate + days` with today (`getRemainingDays` computed the number for display
  only), so a plan whose duration ran out stayed `active` forever: it kept consuming sessions,
  kept showing as active on the card and profile, and blocked the client's queued plans.
  New `PlansService.expireElapsedPlans({int? clientId})` marks every `active` plan with
  `days > 0` and 0 days left as `expired`, then promotes the queued plan. Called on read from
  `getClientPlans`, `getAllPlans` and `getActivePlan` (so attendance can never consume a finished
  plan) and from the dashboard counters through the new `plansExpirySweepProvider`
  (added to `_appDataProviders`). **Frozen plans are skipped on purpose** — freezing stores no
  timestamp, so elapsed days cannot be measured for a paused plan. Window semantics: end =
  `startDate + days`, so a 30-day plan reports 30 days left on its first day and 0 from day 31.
  Date maths extracted to the pure `planRemainingDays` / `planDaysElapsed`
  (`lib/core/utils/plan_dates.dart`); `PlansService.getRemainingDays` delegates to it, so widgets
  use the same numbers without going through a service. No schema change.
- **Remaining sessions + remaining days are now visible.** Client card pill: «X از Y» plus
  *remaining* days (it used to show the plan's **total** days). Profile plan card: activation date
  (`formatDateShort`), remaining sessions and remaining days as pills. Reuses existing `AppStrings`
  keys (`remainingDays`, `remainingSessions`, `startDateLabel`) — no new strings needed.
- **Bonus sessions moved off the client card** into the client profile (the «اطلاعات تماس»
  section, as a label + counter + −/+ buttons). The card's quick stepper is gone and
  `_BonusStepper` / `_adjustBonus` were deleted from `client_card.dart`; the card now carries an
  «افزودن برنامه» button pointing at `/clients/add-plan/:id`.
- **Add plan is a real button** in the profile (full-width `FilledButton`, next to the attendance
  button) instead of the `SectionHeader` text action.
- **Calendar swipe**: `AttendanceCalendar` wraps its grid in a `GestureDetector`
  (`onHorizontalDragEnd`, ~200 px/s threshold) and mirrors the direction for RTL — swiping right
  advances the month in the Persian app and left in English, matching the chevrons. Works in all
  three usages (attendance screen, plan start-date picker, transaction date picker). Day taps and
  vertical scrolling are unaffected (both covered by tests).
- **Price fields group thousands while typing** (`1,000,000`): new
  `ThousandsSeparatorInputFormatter` plus a shared `groupDigits`
  (`lib/core/utils/thousands_input_formatter.dart`; `AppStrings._grouped` now delegates to it so
  display and input can never disagree). Applied to the add-plan price field and the «ثبت قیمت»
  dialog, which now also **prefills** grouped. Those fields show Latin digits and pin the caret to
  the end.
- **Attendance removal no longer looks like it “mixes” bonus sessions.**
  1. *Real bug*: `addSession` stored `planId = null` both when it consumed a bonus **and** when it
     consumed **nothing** (no plan sessions left *and* 0 bonus sessions), while `_refund` read
     `null` as “bonus” — so deleting such a record **invented a bonus session**. New sentinel
     `kNoSessionConsumed = 0` (plan ids start at 1, and `attendance.planId` has no FK, so 0 is safe
     and survives export/import) records “consumed nothing”; `_refund` then refunds nothing.
     **Legacy rows cannot be distinguished** (they carry `null` for both cases) and keep the old
     refund-as-bonus behaviour — only new records are precise. Cosmetic side effect: the attendance
     **CSV export** prints `0` for those rows (left alone, `backup_service.dart` is protected).
  2. Removals now return `(clientId, SessionRefund)` and the snackbar says where the session went
     (plan / bonus / nothing) through `AppStrings.sessionRemovalMessage`, so a refund that lands in
     a bonus session is no longer silent.
  3. New refund rule (per the user's decision): when the record's plan is `expired` but still has
     **days left**, the session *and* the active slot go back to that plan (`reactivatePlan`), and
     an untouched successor returns to the queue (`requeuePlan`, start date cleared) — a client must
     never have two active plans. A successor that already consumed sessions keeps them, as before.
     If the recorded plan's days are over too, the refund still becomes a bonus session.
- Files touched: new `lib/core/utils/plan_dates.dart`, `lib/core/utils/thousands_input_formatter.dart`,
  `lib/features/attendance/domain/session_refund.dart`; modified `plans_service.dart`,
  `attendance_session_service.dart`, `attendance_providers.dart`, `plans_providers.dart`,
  `dashboard_providers.dart`, `app_refresh.dart`, `client_card.dart`, `client_detail_screen.dart`,
  `attendance_calendar.dart`, `past_attendance_screen.dart`, `dashboard_screen.dart`,
  `add_plan_screen.dart`, `app_strings.dart` (2 new keys: `sessionRefundedAsBonus`,
  `sessionNotConsumed` — fa + en + ctor param).
- Tests: +28 → `flutter analyze` = No issues found!; `flutter test` = **227/227**. New:
  `test/unit/plan_dates_test.dart` (4), `test/unit/thousands_input_formatter_test.dart` (7),
  `test/widget/attendance_calendar_swipe_test.dart` (6),
  `test/widget/client_detail_plans_test.dart` (3). Updated:
  `attendance_session_service_test.dart` (new return type, sentinel case, successor-requeue case),
  `plans_service_test.dart` (+5 sweep cases), `client_card_quick_actions_test.dart` (bonus stepper →
  add-plan button, remaining-days assertion), `plan_creation_refresh_test.dart` (the add-plan button
  now sits under the bottom nav bar on an 800x600 test window, so it needs `ensureVisible` first).
- Housekeeping: `.kilo/` (the duplicate worktree that silently breaks scoped searches) had
  reappeared and was deleted again. In this sandbox `Set-Location` into the workspace is denied even
  though the folder is readable — run commands as
  `cmd /c "cd /d D:\work\ZAHRA\PRO CALENDER\fitness_trainer_app && flutter ..."`.
- **Not done / open**: nothing *notifies* about an expiring plan (it expires silently on the next
  read); the dashboard's low-session list still counts sessions only; and a sweep only happens on
  the next read/invalidation, so an app left open across midnight keeps the old status until then.

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

- **CORRECTED 2026-09-24 for the tree at `6c2cd4c`: `main` does NOT auto-deploy any
  more.** `git show HEAD:.github/workflows/deploy.yml` declares `on: workflow_dispatch:`
  only — the `push` trigger is gone — and `.github/workflows/ci.yml`
  (`on: push: branches: [main]`, plus PRs and manual) runs `flutter analyze` +
  `flutter test` and **never publishes**. A push to `main` is verification-only, so
  pushing a green commit is safe. The bullet that used to sit here — claiming
  `on: push` was still live and the workflow edit uncommitted — was written before
  that change was committed and is wrong. Publishing remains: Actions → *Deploy
  Flutter Web to GitHub Pages* → Run workflow, and deploy still runs analyze + test
  before the build, so a red suite cannot replace the live site.
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

## 2026-09-25 — audit follow-up fixes (4 source files, 1 web file)
A full read-only audit was run first (UI/UX, performance, data layer, tests,
CI, repo hygiene). The findings below were fixed immediately because each was a
handful of lines and each stopped a user-visible bug; the larger items are
listed at the end as still open.

**Baseline re-verified after the changes: `flutter analyze` = "No issues
found!", `flutter test` = 227/227.** The "199" quoted in `AGENTS.md` and in the
Commands section above is stale — the real count is 227.

- `features/clients/presentation/add_edit_client_screen.dart` — the bonus
  sessions field now normalises through `toLatinDigits` before `int.tryParse`.
  It was the only numeric field in the app that did not, so typing Persian
  digits (`۵`) made `tryParse` return null and `?? 0` **silently saved 0**,
  wiping the existing bonus count.
- `features/attendance/presentation/past_attendance_screen.dart` — the delete
  button inside `_DayAttendanceSheet` now goes through `AppConfirmDialog.show`,
  matching the history list. It refunds a plan/bonus session and sat directly
  under the present/absent add buttons with no separator.
- `core/widgets/app_widgets.dart` (`AppBottomSheet.show`) — added
  `MediaQuery.viewInsetsOf(ctx).bottom` padding and `SafeArea(top: false)`.
  `isScrollControlled: true` only raises the height cap; it does not move the
  sheet, so the submit button of **every** sheet sat behind the keyboard.
- `features/backup/data/backup_service.dart` (`_validateHeader`) — `app` is now
  mandatory. It was `marker != null && marker != _appMarker`, so a payload with
  no `app` key passed and `{"schemaVersion":1}` was accepted as a valid
  replace-mode backup that wiped all eight tables and restored nothing. Also
  refuses a *newer* `format` (a missing one stays accepted so older exports
  remain restorable, and `schemaVersion` is a Drift number that cannot express
  a row-shape change — that is what `format` is for), and rejects a payload
  containing none of the eight known table keys.
- `features/attendance/presentation/widgets/attendance_calendar.dart`
  (`_DayCell`) — a day holding BOTH an absence and an attendance rendered as
  fully **green** (`isPresent = presentCount > 0`), and because the `×N` badge
  branch sat above the check/cross branches, the fill colour was the only
  remaining signal. Mixed days now use the `warningSoft` fill with `warning`
  ink and a `warning` border, and the foreground is computed once (`fg`)
  instead of being hardcoded to `Colors.white`. The legend still explains only
  today/present/absent, so a mixed-day legend entry still needs a new
  `AppStrings` key.
- `web/index.html` — added a CSS spinner + app title removed by the
  `flutter-first-frame` event. `main()` awaits `AppDatabase.create()` before
  `runApp` and `index.html` had no loader, so the entire boot (including the
  sqlite3 wasm + drift worker fetch) was a blank white page.

### Still open from the audit (each needs its own task)
- **Web safety copy is never verified.** `core/platform/file_transfer_web.dart`
  returns the file name unconditionally after `anchor.click()`, so the
  "safety copy failed -> abort the restore" guard in `import_backup_screen.dart`
  can never fire on the destructive path.
- **No test covers `onUpgrade` / `backfillMissingPlanIncome()`**, the only code
  that writes to live users' ledgers during a migration, and nothing asserts
  `schemaVersion == 7`.
- **Performance:** `clientTagFilterProvider` is a serial N+1; the dashboard does
  5 full scans of `clients` and 5 of `client_plans` and counts rows in Dart;
  ~43 providers are invalidated per attendance tap; `_invalidateTabProviders`
  in `main.dart` refetches data that cannot be stale.
- **Accessibility:** zero `Semantics`, `textScaler` or `PopScope` anywhere in
  `lib/`; the charts are pure `CustomPaint` with no labels.
- **CI:** `ci.yml` has no `flutter build web`, so web-only compile errors first
  surface at publish time (that already happened once, in `381c429`).

## 2026-09-25 (later) — in-app update notice
User decisions for this task: **no analytics** (the app promises users their data
never leaves the device — see `backupReminderNeverBody` — so a telemetry ping
would contradict that sentence); **yes** to an update notice; **tap** to reload
rather than auto-reload (an automatic reload would discard a half-filled form);
and **explicit permission to edit `deploy.yml`**.

`flutter analyze` = "No issues found!", `flutter test` = **236/236** (227 + 4
provider + 5 widget tests).

**How it works.** `deploy.yml` now compiles with
`--dart-define=BUILD_ID=${{ github.sha }}` and, *after* the build (because
`flutter build web` regenerates `build/web`), writes the same sha to
`build/web/build-id.json`. The running page fetches that file with a timestamp
cache-buster, compares it with the id it was compiled with, and offers a reload
when they differ. Comparing commit shas means **nothing has to be remembered per
release** — no `pubspec.yaml` version bump, unlike a `version.json` comparison
(that file has sat at `1.0.0+1` / `1` since launch). `schemaVersion` is untouched;
this needs no database change at all.

New files:
- `core/platform/build_info.dart` (+ `_io` / `_web`) — conditional import on
  `dart.library.html`, exactly the `file_transfer.dart` pattern, so native targets
  get a no-op and the check stays web-only.
- `core/providers/app_update.dart` — `kBuildId`, `currentBuildIdProvider`,
  `deployedBuildIdProvider`, `pendingUpdateProvider`. Current and deployed are
  separate providers purely so tests can override both, which is the only way to
  exercise the decision on the VM.
- `core/widgets/app_update_banner.dart` — renders nothing unless an update is
  pending, so it is invisible under `flutter run` (no injected id) and on native.

`main.dart` puts the banner in the same `bottomNavigationBar` slot as the nav bar
(inside a `Column`), so it is reachable from every tab rather than only the
dashboard, and collapses to nothing when hidden. It re-checks on
`AppLifecycleState.resumed`, **skipping that re-check while an update is already
on screen** — Flutter fires `resumed` on every visibility change on web, and
re-running a check we do not need would only rebuild the banner.

**Verified in a real browser, not just by unit tests.** Served a build compiled
with `BUILD_ID=aaa` at a mirrored `/procalendar-/` path while `build-id.json` read
`bbb`: the server log proved the fetch resolved to
`/procalendar-/build-id.json?t=...` (correct under the base href) and returned 200,
and the screenshot showed the banner above an otherwise unchanged nav bar. With
the file changed to `aaa` and the page reloaded, the banner correctly did *not*
appear. Both directions confirmed.

Accepted trade-off: `resumed` fires per visibility change on web, so the check
runs roughly once per tab focus switch (~20 bytes each). Deliberately not
debounced.

Test gap: the fetch in `build_info_web.dart` cannot run on the VM, so the widget
tests override `deployedBuildIdProvider` instead; the browser run above is what
covers the real fetch path.

## 2026-09-27 — client filters, dashboard consistency, selectable themes, touch targets

Commit `70e5d58` (60 files). The reasoning matters more than the diff:

**The client list became filterable.** `ClientQuickFilter` already existed with six
values and the filtering logic worked, but there was **no UI to choose one** — the
Clients page only *watched* the filter and offered a chip to clear it, and the only
way to set one was to tap a dashboard stat card. That is why filtering felt
"tags only". Added a filter bar with three presets (همهٔ مشتریان / امروز ثبت نشده /
نیاز به توجه) plus a sheet holding every filter, and six new time-based ones:
not-marked-today, away 14+ days, never attended, no active plan, expires within
7 days, needs-attention. `_idsForFilter(Ref, filter)` is the single implementation
shared by `quickFilterClientIdsProvider` and the new
`clientFilterCountsProvider`, so a chip's count can never disagree with the list it
produces. `needsAttention` deliberately **excludes** "has an expired plan" —
almost every long-standing client has one, so it would match nearly everybody.

**Tags left the page.** Two visually identical chip rows made two different things
read as one. Worse, with a long tag list a selected tag could scroll out of view,
leaving a short or empty list whose cause was invisible — which reads as "my
clients are gone". Tags now live in the filter sheet as *wrapped* chips (wrapping
means a selected tag cannot hide past the edge), and anything filtering the list
surfaces as a leading chip in the bar that names it.

**Two dashboard sections were inconsistent by accident.** «برنامه‌های رو به اتمام»
rendered one card per plan (twelve rows at 120 clients) and counted *plans* while
its own action opened *clients*; «جلسات هدیه» was a single row tinted amber, i.e.
information painted as a warning. Both are now one `_DashboardSummaryRow` under a
SectionHeader, counting distinct clients, with amber kept only for the real
warning. The today-attendance list was removed — it duplicated the Clients page and
built a row for every client.

**Themes replaced the accent picker.** `app_accents.dart` deleted,
`app_theme_spec.dart` added: `AppThemeSpec` + `AppThemePalette`, with
`AppThemes.all` as the single registry — adding a theme is one entry.
`AppTones.forTheme` supplies surfaces/ink/primary from the theme, while **status
colours stay on the shared base on purpose**: they carry meaning, not brand.

**Touch targets.** `client_card.dart` had `VisualDensity.compact` (twice) plus
`padding: EdgeInsets.zero` with 28px constraints on the freeze control. Rendered
sizes measured 20–36px while Material still claimed a padded ~40px tap area, so
neighbouring invisible targets overlapped and an imprecise tap hit the wrong one —
confirmed by aiming 8px above a button and activating its neighbour. The freeze
control also sat *inside* the plan pill among its text; it moved to its own
labelled row. `minimumSize: Size(0, 44)` now applies to the Elevated and Outlined
button themes; TextButton is deliberately excluded because it is used inline in
section headers where 44 would stretch dense rows. A zero-overflow sweep across
all five tabs was run after the change.

**Found while verifying:** a pre-existing `RenderFlex overflowed by 2.3 pixels` in
the plan pill. Its Row is `mainAxisSize: min` but only the template name was
`Flexible`, so the two fixed trailing texts overflowed — worst in English. Both are
now Flexible with ellipsis. Caught because the **console** was checked, not only
the screenshot.

**Two bugs I introduced and then fixed, both worth remembering:**
- The new providers were missing from `_appDataProviders` in `app_refresh.dart`,
  so their values went stale after a mutation — a chip advertised one number while
  the list showed another. The rule already exists; the lesson is that a *new*
  provider must be added to that list.
- `seedLarge` wrote plans + attendance + transactions in **one** transaction of
  ~11k rows and the result did not persist on web. Chunked to 10 clients per
  transaction. It is behind `kDebugMode` so it could never ship, but it cost real
  time and produced a false "data loss" scare.

## 2026-09-28 — accounting ledger first, with period reports

Commit `bfb7fd3`.

The accounting screen listed **every priced plan before the ledger**, so the only
interactive part of the screen sat behind one row per plan. Measured at 120
clients: **~38,400px, about 41 screens** of scrolling to reach the transactions.
The ledger moved directly under the summary; the per-plan share follows it, capped
at five with a «نمایش همه (N)» expander.

Kept rather than collapsed to a link, deliberately: I proposed replacing it with a
summary row linking to Reports, then checked — **Reports carries no per-plan
breakdown**, so that would have deleted information.

A period selector (today / this month / last month / last 6 months / this year /
all) drives the summary, the ledger *and* the per-plan share together. The share is
narrowed by `plan.startDate` so it stays in step with the income rows it derives
from — verified: last month reports 46,620,000 of 155,400,000, exactly 30%.

`accounting_period.dart` is pure Jalali date maths with 8 new tests covering the
cases that fail quietly: Farvardin rolling back into the previous year, six months
crossing a year boundary, and Esfand's 29-vs-30 day length.

Empty states now distinguish "nothing recorded yet" from "nothing in this window",
the second naming the period — a quiet month used to read as a broken screen.

Also: the Android back button now asks before closing the app (at the root of a tab
only; a pushed screen still pops). **This broke a test in a way worth knowing:** the
existing test's second `handlePopRoute()` awaited a dialog that was never answered,
so the suite *hung* rather than failing — and the stuck `flutter_tester` then held
`build/native_assets/windows/sqlite3.dll`, making every later run fail with a
misleading "Flutter failed to delete file". When a change makes a framework call
block on user input, watch for a suite that stops progressing, not for a red test.

## 2026-09-28 (later) — three more themes, colour names, motion, plan-history calendar

Commit `64dcc0a`.

**Themes now number eight**, adding نارنجی / یخی / زیتونی. یخی needed something the
system could not do: its identity is a background **gradient** with translucent
panels, so a flat colour would have been a pale imitation.
`AppThemePalette.backgroundGradient` is new; the theme's `scaffoldBackgroundColor`
goes transparent when it is set, and `MaterialApp` paints the gradient behind the
whole app, which is what lets translucent surfaces read as frosted panes.

**Theme names are now colour names** (سبز، شیری، آبی، سرمه‌ای، خاکستری، نارنجی،
یخی، زیتونی). The old ones came from design mockups that also define corner radii
this app does not implement, so «پرشتاب» promised motion and «کاغذی» promised paper
texture. **Ids are unchanged** — they are persisted in `app_settings`, and renaming
one would silently reset the theme for anyone already using it.

**Motion respects reduce-motion.** `AppMotion.of(context)` returns `Duration.zero`
when `MediaQuery.disableAnimations` is set, so the change is instant rather than
merely faster — verified by emulating `prefers-reduced-motion` in the browser. The
session figures on the attendance screen now ease in. Measured **701ms to update
with the animation against 622ms with reduced motion**, so the ~620ms database
round-trip is the cost and the motion is not. That figure is from a *debug web*
build and is not representative of release.

The default `AnimatedSwitcher` layout keeps the outgoing child, so during the
crossfade the accessibility tree held **both** values ("جلسات ثبت‌شده ۸۷ ۸۸") and a
screen reader would have read the number twice. Fixed with a `layoutBuilder` that
wraps `previousChildren` in `ExcludeSemantics`.

**Opening an expired plan now shows that plan's month.** `initState` seeded the
calendar from today unconditionally, so an expired plan's history opened on an
empty current month. Now **expired** jumps to its newest record's month, while
**active** and **queued** keep today — that is where marking happens. A
`_monthChosenByUser` flag stops a late-arriving load moving the month after the
user has already paged. All three states verified in the browser. Frozen plans were
left out: not named by the user, and a one-line change if wanted.

## Still open

- **Frozen plans** keep the current month rather than jumping to history.
- **Six inert accent strings** (`accentGreen`…`accentTeal`, `accentColorLabel`) and
  **`undoAttendance`** are now unused in `AppStrings`. Inert data, harmless, but
  `undoAttendance` was orphaned by removing the dashboard undo button.
- **English pluralisation** is fixed for two client-count strings only; most count
  templates still render "1 sessions left".
- **Per-theme corner radius** is not implemented. `AppThemeSpec.cardRadius` exists
  and returns `null`; the mockups define radii per theme (paper 2px, kinetic 23px),
  which is why those themes read as close-but-not-identical. About 45 call sites.
- **The attendance history builds every row eagerly** — 93 rows for one client,
  measured — inside `ListView(children: [...])` while other lists use
  `ListView.builder`. This is the one place worth fixing before animating it.
- **Accessibility**: tooltips now cover icon buttons and text scaling is clamped to
  0.8–1.3, but non-button content still has no explicit semantics.
- **Declined by the user** (do not re-propose unprompted): day-cell reaction
  animation, haptics on mark, undo on the mark message, and the direction-aware
  month sweep. On undo the user was right to decline it as a *fix* — the day sheet
  already removes a record with confirmation, so it is a 1-tap-vs-3-tap
  convenience. I had wrongly claimed "there is no way back" and corrected the
  proposal document at `build/mockups/redesign/marking-feedback-proposal.html`.
- **`DEVELOPMENT_HANDOFF.md` was not updated per-task** during the batches above;
  this entry is the catch-up, which is why it covers three commits.

## CURRENT STATE — verified 2026-09-28 (supersedes the 2026-09-24 block above)

Re-run immediately before writing these lines, so the numbers are measured rather
than remembered:

- `flutter analyze` → **No issues found!**
- `flutter test` → **244 passed**, 0 failed. The 2026-09-24 block above says 236 —
  that snapshot is stale; trust this one.
- `schemaVersion` is still **7**. No migration has been written and none is
  needed. It must not change: live users' databases are at v7.
- HEAD was `64dcc0a` with a clean tree, level with `origin/main`.
- Publishing is still **manual** (`deploy.yml` is `workflow_dispatch` only) — a
  push runs `ci.yml` and never deploys.

Changed since the 2026-09-24 snapshot: the client filter bar and filter sheet, the
theme system (8 themes, replacing accents), accounting periods, the motion
helpers, the back-button confirmation, and the plan-history calendar month. The
detail is in the three dated entries above.

---

## 2026-09-28 — a live user saw an EMPTY app; the web database could silently forget everything

**Reported:** a user opened the app, switched to another app before it finished
loading, and came back to a calendar with no data. Closing and reopening brought it
back — once. A later report said reopening did *not* bring it back.

**Root cause.** `main()` awaits `AppDatabase.create()` before `runApp`, and on web
that is:

```
WasmDatabase.open(...) -> result.resolvedExecutor      // only this was kept
```

`WasmDatabaseResult` also carries `chosenImplementation` and `missingFeatures`, and
drift uses those to report that it **fell back to a database that stores nothing**
when the browser probe cannot reach IndexedDB or the drift worker
(`availableImplementations` starts as `[inMemory]`; IndexedDB/OPFS are only added
after a successful worker probe, and both probes swallow their own errors).
Discarding those two fields meant the app returned a *perfectly healthy executor*
over an empty, memory-only database. drift's own documentation says to warn the
user in exactly this case.

Nothing was ever lost: the real database stayed in IndexedDB throughout. The app
merely looked normal with zero clients — and anything typed in that session existed
only in memory. Switching away during boot is a plausible trigger, because that is
the window in which the worker probe runs.

**A second detail that matters for support:** `main()` opens the database once per
page load, and `didChangeAppLifecycleState` only re-runs the build-id check.
"Closing" the app by switching away does **not** re-open the database, so it cannot
recover from this; only a real relaunch does.

**Fix** (no schema change; `app_database.dart`, its `.g.dart` and
`backup_service.dart` untouched):
- `lib/core/database/database_open_failure.dart` (new) — `PersistentStorageUnavailable`.
- `lib/core/database/connection/web.dart` — retry `open()` once (the failure is
  usually transient, so that case now recovers silently with no screen at all),
  then throw when `chosenImplementation == WasmStorageImplementation.inMemory`.
  Deliberately only `inMemory`: `unsafeIndexedDb` does persist and only races
  between tabs, so refusing it would break users whose browser legitimately picks it.
- `main.dart` — catches it and shows `StartupErrorApp(storageUnavailable: true)`,
  with new `storageUnavailableTitle` / `storageUnavailableMessage` in both
  languages, telling the user their data is safe and to relaunch fully — not to
  reinstall or clear browser data.
- `test/widget/startup_error_test.dart` (new, 2 tests).

**Verified:** `flutter analyze` → No issues found!; `flutter test` → **246 passed**
(244 + 2). The deployed web build was checked from a clean browser and is healthy —
build id `e3d91a1`, IndexedDB `fitness_trainer` created, served `drift_worker.js`
byte-identical to the repo's, `sqlite3.wasm` at the app root. This is not a bad deploy.

**Not verified:** the failure was never reproduced — no probe failure was forced — so
the trigger is inferred from the code rather than observed. The guard is web-only
code and cannot be unit-tested on the VM, which is why the test covers the screen
rather than the retry.

**Still open for the affected user:** they have no backup, are on Android with the
app installed, and the data did not return on relaunch. Decisive, tooling-free test:
add a test client, fully close the app (swipe it from recents), reopen. If the client
survives, the app's storage works but is empty (the original is gone); if it
vanishes, storage is non-persistent and the original data is still on the device.
Either way: do not clear site data and do not reinstall — an Android installed PWA
shares Chrome's origin storage, so clearing it destroys the only copy.

**RESOLVED 2026-09-28 — and the news is good.** The user did have a JSON export from
two days before, taken through the app's own backup flow, so the backup reminder did
its job. They restored and it worked, losing only ~2 days of input.

Verdict on the outage: the database was cleared or evicted by something *outside* the
app, and the app then recreated it empty — which is why a freshly created test client
survived a full close while the real data was gone. The app is exonerated by the code:
`connection/web.dart` has exactly one commit in the entire history, so the database
name and storage implementation have never changed; `pubspec.lock` is tracked, so
dependencies cannot drift between deploys; and the release build has no mass-delete
path (no dev-tools section in Settings, and `_wipe()` only runs on import-replace).
The decisive check was the dashboard's «تعداد مشتریان» card reading ۱ — that card
counts the whole database, so no filter can hide it.

**A restore trap worth knowing, because it is counter-intuitive:** for this case
`replace` («جایگزینی کامل») was the *safer* choice, not `merge` («ادغام با داده
موجود»). `_merge` inserts with `insertOrIgnore` and skips conflicting ids, and the
freshly recreated empty database already had the test client sitting at id 1 — so
merging would have silently dropped the backup's client id 1 while still inserting
that client's plans and attendance, welding them onto the test client. `replace` wipes
first, so nothing can collide. It also exports a safety copy of the current database
before wiping, and on web adds a confirmation that the download actually landed.

**Status:** the guard above is implemented, `flutter analyze` is clean and the suite is
246/246, but it is **uncommitted and undeployed** — nothing shipped from this
investigation. Prevention is the real fix and is a product decision rather than a bug
fix: storage loss inside a browser cannot be prevented by code, so the worst-case loss
equals the backup age. The levers are `BackupReminder.intervalDays` (currently 14, with
a 2-day snooze), a visible "last backup: N days ago" plus record counts in Settings, and
a one-tap export shortcut instead of Settings → scroll → button.

---

## 2026-09-28 — backup safety: permanent reminder, one-tap export, data counts, Contact us

All four prevention levers from the entry above, built in one pass. `flutter
analyze` → No issues found!; `flutter test` → **244 passed**.

- **`BackupReminder.intervalDays` 14 → 7.** `snoozeDays`, `snoozeUntilFrom` and
  `isDue` are gone, replaced by `isOverdue({lastBackup, today})`. A permanent
  reminder and a "later" button contradict each other, so the snooze went with it,
  along with `SettingsService.get/setBackupSnoozeUntil`. The existing
  `backup_snooze_until` row is left inert in live databases — `app_settings` is a
  key/value table, so there is nothing to migrate.
- **The dashboard reminder is now permanent.** `BackupReminderBanner` renders
  always instead of only when overdue, and freshness is expressed in colour (calm
  vs amber) so the warning colour keeps meaning something. New copy explains the
  thing nobody would guess: the records live in browser storage, the app has no
  control over it, and the browser or the phone can wipe it. While the provider is
  still loading the card renders without the last-backup line, so it never briefly
  claims "never backed up" to someone who has.
- **One tap to export, on the dashboard card.** It goes through
  `textFileSaverProvider` rather than calling `saveTextFile` directly — that
  indirection exists so a save is observable on the VM, and without it this new
  action could not be tested at all. The date is still recorded only when the saver
  reports a name.
- **Settings now shows what is actually stored** (`dataHealthProvider`: clients,
  plans and attendance counts, counted in SQL rather than by loading rows). This is
  the check that was missing during the incident — when the database was wiped the
  app still looked perfectly normal and nobody could tell whether the zeros were
  real. It is registered in `_appDataProviders`, which is the rule that came out of
  the earlier stale-chip-count bug.
- **Contact us → Telegram channel**, for bug reports and questions. Strings, a
  Settings row, and `core/platform/link_opener{,_io,_web}.dart` following the same
  conditional-export pattern as `file_transfer.dart` — no new package, and on native
  (where there is no URL launcher) the address is copied to the clipboard rather
  than leaving a button that does nothing. **`supportTelegramUrl` in
  `core/app_links.dart` is empty, so the row is hidden until the real channel handle
  is set.** Deliberately not guessed: a wrong handle would send users to a
  stranger's channel.

**A real bug was caught by the new test, not by review.** The card's two actions
were a `Row` and overflowed by 64px at 320 logical width; they are a `Wrap` now.
The 'fits a narrow phone without overflowing' test pins it, and is worth copying for
any dense row in this app — an overflow surfaces as an exception in a widget test.

**Two tests were silently lost mid-edit.** A later batch replacement clobbered the
tail of the banner test file, so it ended up green at 241 with two tests missing.
Only counting `testWidgets(` against the expected total caught it. The suite is at
244 now; count the tests, do not just look for green.

**Test bookkeeping:** the reminder unit test went from 13 tests to 9 (the nine
`isDue` + one `snoozeUntilFrom` cases became six `isOverdue` cases), and the banner
test from 5 to 7. `navigation_ux_test`'s "view clients" case needed
`tester.view.physicalSize = Size(1000, 2000)` because the new card pushes that action
under the bottom navigation bar, where the tap hit the nav bar and selected tab 4
instead of failing loudly. Assertions were not changed — this is the same pattern
`clients_tag_filter_test` already uses.

Inert strings left behind on purpose, as with `accentGreen..`: 
`backupReminderDueTitleTemplate`, `backupReminderNeverBody`, `backupReminderLater`.

**Nothing here is committed or deployed**, and the web build has not been exercised
in a browser this time — the layout is covered by widget tests instead, including
the narrow-width case.

---

## 2026-09-28 — the Clients filter bar was clipped on phones (real bug, user-reported)

**Reported:** "i'm on clients page and filters are not visible." Legitimate. I found
it by resizing the shared dev page to 360x780 — my own resize is what made it
visible — but it affects every real user, since they are all on phones.

**Cause.** The filter bar was a horizontal `ListView` inside
`SizedBox(height: 40, …)`, with the preset chips *and* the «فیلترها» ActionChip
inside the scroller. On a 360px-wide phone the three presets fill the row, so
«فیلترها» — the only route to the complete filter list, tags included — sat past the
left edge. Two and a half chips were visible, the third clipped mid-word.

Nothing threw: a horizontal `ListView` clips rather than overflowing, so there was no
exception and no failing test. The 2026-09-27 browser verification of this feature was
done at desktop width, which is exactly why it survived.

**Fix** (`clients_screen.dart` only): the ActionChip is now pinned **outside** the
scroller, as `Row([Expanded(ListView(presets…)), Padding(ActionChip)])`. The presets
may still scroll; the way through to every filter can never disappear.

**Verified by measuring, not by looking.** The rendered semantics rects at 360 wide:

| chip | left | right |
|---|---|---|
| «فیلترها» (pinned) | 16 | 109 |
| «نیاز به توجه · ۰» (in the scroller) | −57 | 59 |

The pinned chip is inside 0..360 and the scrolled one is clipped past the edge, so the
new assertion is genuinely sensitive rather than vacuously passing.

**New guard** — `clients_tag_filter_test.dart`, "the way into every filter stays on
screen on a phone": a 360x800 surface asserting the ActionChip's rect lies within
0..360. `findsOneWidget` on its own would **not** have caught this, because a
horizontal `ListView` builds children just past the viewport, so the off-screen chip
was in the tree and findable all along. Worth remembering for any horizontal scroller.

`flutter analyze` → No issues found!; `flutter test` → **245 passed**. Still
uncommitted and undeployed.

---

## 2026-09-28 — Clients list "jumps" while scrolling on a phone: swipe-to-delete removed

**Reported:** swiping up and down on the Clients page on a phone "jumps sometimes".
Confirmed by the user as: not a reload, and on the **installed app**, not in a browser.
The user then guessed it might be a touch-target problem — right in spirit.

**Cause.** Every client row was wrapped in `Dismissible(direction:
DismissDirection.endToStart)`, and a `Dismissible` installs a **horizontal** drag
recogniser. That recogniser competes in the gesture arena with the list's **vertical**
scroll. A thumb swipe that drifts sideways — which real thumbs do, and a mouse wheel
never does — lets the card capture the gesture, so the list stalls mid-scroll and then
jumps. That is exactly why every earlier browser verification missed it: those were all
driven with a wheel on a desktop.

**Fix.** The `Dismissible` is gone from the client list. Delete is unchanged in the
card's ⋮ menu (`_showClientActions` → «حذف مشتری», rendered in the error colour) and on
long-press, so no route to it was lost. Removing it also deleted a duplicated
destructive path and its `_dismissedIds` bookkeeping (the `unused_field` warning pointed
at the leftovers). Reverting is one small block if the swipe is wanted back — but note
the two cannot fully coexist, because the horizontal recogniser will always be able to
win a diagonal gesture.

**Not verified on a device.** The mechanism is inferred from the gesture setup, so this
is the best-supported explanation rather than a reproduced one. If the jump survives,
the next suspect is a layout shift rather than a gesture: `AppUpdateBanner` lives in
`Scaffold.bottomNavigationBar` inside a `Column`, and it only appears once the **async**
build-id fetch resolves — so the body's height changes under the list mid-scroll — and
`didChangeAppLifecycleState` re-runs that check on every foreground.

`flutter analyze` → No issues found!; `flutter test` → **245 passed**.

---

## 2026-09-28 — Display size (compact/zoom) control, and the two bugs it shipped with

**What it is.** A slider in Settings → Appearance («اندازهٔ نمایش»), 70–130%, live percentage
readout, and a «بازنشانی» reset. Stored in `app_settings` as `ui_scale` (no schema change) and
applied by `UiScale` in `MaterialApp.builder`. **Default is exactly 100%, and at that value
`UiScale` returns its child untouched** — so the default path is byte-for-byte what it was and
no existing user is affected unless they drag the slider.

It applies **on release**, not while dragging, and that is deliberate: the app resizing live
resizes the slider itself (measured: it grew 1.24× and moved 118px down the page), so the
control slid out from under the finger and could not be fine-tuned. The percentage readout is
the live feedback instead.

**Two real bugs, both found by the user, both now fixed:**

1. **The app shrank into a corner instead of reflowing.** `SizedBox` cannot exceed its parent's
   constraints, so the app laid out at the *physical* size and was then painted smaller. Fixed
   with `OverflowBox`, which hands it a genuinely larger canvas.
2. **The bottom `1 − scale` of every screen was dead, and the nav bar became unclickable.**
   Every render box rejects a position outside its own `size`. `RenderTransform` is the
   exception — it maps the position through the inverse transform and hit-tests the child with
   no size check of its own. So the constraint relaxation must go **above** the transform, with
   the logical-sized box as the transform's **direct child**:
   `ClipRect > OverflowBox > Transform.scale > SizedBox(logical) > MediaQuery > app`.
   With the `OverflowBox` below the transform its own box was only the physical size, so taps
   below that line were rejected before reaching the app. **Layout looked perfect — only hit
   testing broke.** This also explains the report that sub-screens were unusable: every pushed
   screen's action buttons sit along that dead band.

**My first test was worthless, and that is the lesson worth keeping.** It asserted the
`MediaQuery.size` that `UiScale` had just set itself — tautological, so it passed against the
broken build and let bug 2 reach the user. It now captures the child's **real constraints**
through a `LayoutBuilder`, plus a bottom-of-screen tap test. Assert what a widget *receives*,
never the value you just wrote.

**Measured, not assumed** (360×780 viewport): theme chips per row **5 at 100% → 6 at 82%**;
nav bar height **80 → 61 at 76%**; the nav bar spans the full width and stays clickable at 76%.

**Still open:** the user wants the nav bar to *not* scale (it currently shrinks with everything,
80 → 61). A `Transform` cannot easily exclude one child, so this needs either a counter-scale
around `BottomNavBar` (with the reserved height matched) or a different mechanism.

**If this needs to go further:** `Transform`-based zoom changes `MediaQuery.size` for the whole
app, so it also moves responsive breakpoints — that is why it was invasive. A density approach
(`VisualDensity` + text scaler + scaled shared tokens) would give "more rows fit" without
touching layout constraints or hit testing at all, and would leave the nav bar's frame alone.

**Also fixed here:** `_seedDemoData` refreshed a *hand-picked* provider list that predated
`dataHealthProvider`, so Settings reported "۰ مشتری" while four clients existed — the worst
possible signal from the line that exists to be trusted. It now uses `invalidateAppData()`,
matching `seedLarge`, so anything added to `app_refresh.dart` in future cannot slip through.

---

## 2026-09-28 (later) — planning only, plus the queue

Nothing below was built. This entry exists so the next session does not have to rediscover it.

**Booking + server.** Full plan lives in `BOOKING_AND_SERVER_PLAN.md` at the repo root, and is
**uncommitted**. Its §13 lists five open questions; the two that change the design most are
whether a bookable window is one session or is split into sub-slots, and whether confirming a
booking consumes a plan session. §0 records the user's product principle — *the trainer must never
leave the app* — which rules out the Calendly and Telegram short-cuts that were considered first.

**Queued ahead of any of that**, because it rewrites records that already exist in live databases:

1. **#1-C** — confirm before an attendance record that consumes nothing. The add path has no such
   check today (`past_attendance_screen._addRecord`, the day-sheet buttons, all plain `onPressed`).
2. **Expired-plan work** — backdated attendance inside an expired plan's range, plus retroactive
   attach of earlier attendance to a plan whose range covers it. `addSession` only consults
   `getActivePlan(clientId)`, so an expired plan is never credited. Every record's stored `planId`
   is the refund source of truth, so a retroactive move must move the refund target with it. Needs
   the assign → deduct → remove cycle proven, not assumed.

**Small deferred items, all discussed and none started:**

- Call `navigator.storage.persist()` on web. **Measured: `persisted()` returns false today**, so
  the database is evictable — this is the real defence against the incident that started the day.
- An **iOS install nudge**, with corrected copy: WebKit states installed home-screen web apps are
  **not** subject to the 7-day cap, only Safari browsing is. An earlier claim of mine to the
  contrary was wrong and must not be written into the UI.
- The **display-size slider cap**: above 100% the layout overflows (a real `RenderFlex` overflow
  was observed in `client_detail_screen.dart`). Either cap at 100%, or fix overflows case by case.
- Excluding the **nav bar** from the display-size scaling.
- A **Tavily MCP key** in `%APPDATA%\Code\User\mcp.json` is 23 characters and is rejected as
  invalid. Not blocking: the Apify web tools and `fetch_webpage` both work.
---

## 2026-10-05 — RTL money isolate; removed two dead attendance methods

Compared this app against the successor app (`D:\work\ZAHRA\business_manager`) and
implemented the two changes that need no schema change. Full comparison report:
session folder `plan.md`.

**Important context discovered:** `business_manager` is the successor app, built by
reading this one. Its `docs/DOMAIN_RULES.md` opens "Extracted from the legacy PRO
CALENDER app... the old app is frozen" and catalogues nine traps in *this* app's
code. That is why most of its ideas are deliberately not ours — they need schema
changes, and `schemaVersion` is frozen at 7.

### 1. `AppStrings.money()` now isolates the figure for bidi

`lib/core/l10n/app_strings.dart`. Money rendered as grouped Persian digits into an
RTL paragraph can come out visually reversed — `۲,۰۰۰,۰۰۰` renders as `۰,۰۰۰,۰۰۲`,
which reads as a different amount. `money()` now wraps its result in a
left-to-right isolate (U+2066 … U+2069).

Applied **inside** `money()`, not at call sites, so the accounting screen, plan
prices and the gym-share deduction are all covered by one change. `groupDigits`
and `ThousandsSeparatorInputFormatter` deliberately untouched: they feed an
editable `TextEditingController`, where a direction mark is visible garbage.
New `test/unit/app_strings_money_test.dart` (6 tests) pins this, including the
negative and English-digit cases.

### 2. Removed `AttendanceService.markAttendance` and `.undoAttendance`

`lib/features/attendance/data/attendance_service.dart`. Both had zero callers in
`lib/`. The successor documents the second as a trap: it deleted the latest record
for a client/day **without refunding**, so an undo would silently destroy a
paid-for session. All live paths already went through
`AttendanceSessionService.addSession` / `removeSessionById`, which are atomic
with their refund.

Two corrections to an earlier reading of this app, worth recording:

- **`addAttendance` was NOT dead.** `AttendanceSessionService.addSession` calls it
  (`attendance_session_service.dart:60`); it is the production insert and its
  `planId` parameter carries the session-source distinction. It stays.
- **Trap #1 (`planId: null` ambiguity) was already fixed here.**
  `kNoSessionConsumed = 0` (`attendance_session_service.dart:16`) already
  distinguishes plan id / bonus (`null`) / nothing consumed (`0`), and the refund
  path switches on it at `:115`. Do not "fix" this again.

Test fixtures that seeded rows via `markAttendance` now use
`addAttendance(..., planId: kNoSessionConsumed)`, so the fixture states its intent.

### Verification

- `flutter analyze` — No issues found!
- `flutter test` — **258 passing** (all green).
- No `build_runner` run needed: no Drift table, provider or `*.g.dart`-backed file
  changed. **No schema change; live user data is untouched.**
- `AGENTS.md` updated: test count corrected to 258 (it said 236, but the real
  pre-change baseline was 252 — the number was already stale), plus two new
  convention rules on money formatting and the single attendance write path.

### Still open, in priority order

1. **Backup file is plaintext JSON.** `exportJson()` writes every client's name,
   phone, plans and financials unencrypted. The successor uses AES-256-GCM with
   PBKDF2-HMAC-SHA256 (120k iterations) and a user passphrase. **Blocked**: the
   `cryptography` package is not in `pubspec.yaml` and `pub get` cannot reach
   pub.dev from this network. Do not half-implement — decide first whether the
   dependency resolves.
2. **Backup mapper hazard.** `exportJson()` maps every table field-by-field in
   Dart, so a newly added Drift column is silently omitted from every backup
   until someone remembers the mapper. Cheap fix is a warning comment; the real
   fix is `VACUUM INTO`, which needs checking on the web/wasm build.
3. **Frozen plans never expire by time.** `expireElapsedPlans` skips frozen plans
   because no freeze timestamp is stored. Real bug, needs a column — successor app.
4. **No debt/receivables concept.** Only `income`/`expense` exist; no per-client
   balance. Successor app.

---

## 2026-10-05 (later) — Fixed web attendance/data persistence loss

**Problem:** Users reported that attendance (and in fact any data entry) added in
one session disappeared after closing and reopening the app on a phone. Locally
reproduced: the web build was losing writes made inside Drift transactions.

**Root cause:** The resolved `drift` package was `2.35.0`, which contains a web
bug where writes made in transactions are not flushed to IndexedDB
(drift#3864). The fix shipped in `drift 2.35.1`: "Fix writes made in transactions
or through `RETURNING` statements not being persisted to IndexedDB".

**Changes:**
- `fitness_trainer_app/pubspec.yaml`: `drift: ^2.31.0` → `drift: ^2.35.1`.
- `fitness_trainer_app/pubspec.lock`: resolved `drift 2.35.1` (offline pub get,
  package already in local pub cache).
- `fitness_trainer_app/web/drift_worker.js` and `web/sqlite3.wasm`: replaced with
  the copies bundled with `drift 2.35.1` so the worker/wasm runtime matches the
  Dart package version. The old files matched `drift 2.35.0`.
- `fitness_trainer_app/lib/core/database/app_database.g.dart`: regenerated by
  `dart run build_runner build` for drift 2.35.1.

**No schema change.** `schemaVersion` remains 7 and live user databases are
untouched. The bug was purely in how Drift flushed transaction writes to browser
storage.

**Verification:**
- `flutter analyze` — No issues found!
- `flutter test` — **258 passing** (all green).
- `dart run build_runner build` completed with 260 outputs.