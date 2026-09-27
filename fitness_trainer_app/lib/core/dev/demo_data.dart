import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/database/database_providers.dart';
import 'package:fitness_trainer_app/features/accounting/data/transactions_service.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';
import 'package:fitness_trainer_app/features/accounting/providers/transactions_providers.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_session_service.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/data/clients_service.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/settings/data/settings_service.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/features/tags/data/tags_service.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/templates/data/templates_service.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';

/// Development-only data seeder so the app can be exercised (attendance,
/// session consumption, queue promotion, dashboard alerts, accounting ledger)
/// without typing everything by hand.
///
/// Only wired into the UI behind `kDebugMode`, so it can never ship.
class DemoDataService {
  final ClientsService clientsService;
  final TagsService tagsService;
  final TemplatesService templatesService;
  final PlansService plansService;
  final AttendanceSessionService attendanceSessionService;
  final TransactionService transactionService;
  final SettingsService settingsService;

  /// Only [seedLarge] needs this — it batches its inserts instead of going
  /// through the per-record services (see that method for why).
  final AppDatabase db;

  DemoDataService({
    required this.clientsService,
    required this.tagsService,
    required this.templatesService,
    required this.plansService,
    required this.attendanceSessionService,
    required this.transactionService,
    required this.settingsService,
    required this.db,
  });

  /// Jalali `yyyy/MM/dd` for [days] ago, using the same format as
  /// `jalaliToday()`.
  static String _daysAgo(int days) {
    final date = DateTime.now().subtract(Duration(days: days));
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  Future<String> seed() async {
    // Templates
    final basicId = await templatesService.createTemplate(
      'برنامه مبتدی',
      8,
      30,
    );
    final proId = await templatesService.createTemplate(
      'برنامه حرفه‌ای',
      12,
      45,
    );
    final intensiveId = await templatesService.createTemplate(
      'برنامه فشرده',
      24,
      90,
    );

    // Tags
    final beginnerTag = await tagsService.createTag(
      'مبتدی',
      emoji: '🌱',
      color: 0xFF88A36B,
    );
    final weightLossTag = await tagsService.createTag(
      'کاهش وزن',
      emoji: '🔥',
      color: 0xFF8B4A3E,
    );
    final vipTag = await tagsService.createTag(
      'ویژه',
      emoji: '⭐',
      color: 0xFFFFB74D,
    );

    // Clients
    final saraId = await clientsService.createClient(
      'سارا محمدی',
      contact: '09120000001',
      note: 'سه روز در هفته',
    );
    final aliId = await clientsService.createClient(
      'علی رضایی',
      contact: '09120000002',
      bonusSessions: 3,
    );
    final minaId = await clientsService.createClient(
      'مینا کریمی',
      contact: '09120000003',
    );
    final rezaId = await clientsService.createClient(
      'رضا احمدی',
      contact: '09120000004',
      note: 'برنامه فشرده',
    );

    await tagsService.assignTagToClient(saraId, weightLossTag);
    await tagsService.assignTagToClient(saraId, beginnerTag);
    await tagsService.assignTagToClient(aliId, vipTag);
    await tagsService.assignTagToClient(rezaId, vipTag);

    // Plans: Sara gets an active plan plus a queued one (so queue promotion
    // stays observable), Reza a long plan that is nearly finished (low-session
    // alert), Mina a normal plan, and Ali deliberately has no plan so his
    // bonus sessions get consumed instead.
    await plansService.assignPlan(
      saraId,
      basicId,
      8,
      30,
      price: 900000,
      sharePercent: 30,
    );
    await plansService.assignPlan(
      saraId,
      proId,
      12,
      45,
      price: 1500000,
      sharePercent: 30,
    );
    await plansService.assignPlan(
      rezaId,
      intensiveId,
      24,
      90,
      price: 2800000,
      sharePercent: 30,
    );
    await plansService.assignPlan(
      minaId,
      proId,
      12,
      45,
      price: 1200000,
      sharePercent: 30,
    );

    // Attendance (this consumes plan sessions / bonus sessions).
    // Sara: 7 records of 8 -> 1 session left (low-session alert).
    for (final day in [1, 3, 5, 8, 10, 12]) {
      await attendanceSessionService.addSession(
        saraId,
        _daysAgo(day),
        status: 'present',
      );
    }
    await attendanceSessionService.addSession(
      saraId,
      _daysAgo(2),
      status: 'absent',
    );
    // Reza: 22 of 24 -> 2 sessions left (low-session alert).
    for (var day = 1; day <= 22; day++) {
      await attendanceSessionService.addSession(
        rezaId,
        _daysAgo(day),
        status: 'present',
      );
    }
    // Mina: one session.
    await attendanceSessionService.addSession(
      minaId,
      _daysAgo(4),
      status: 'present',
    );
    // Ali: no plan, so one bonus session is consumed (2 left).
    await attendanceSessionService.addSession(
      aliId,
      _daysAgo(1),
      status: 'present',
    );

    // Accounting ledger: assigning the plans above already recorded an
    // automatic income/plan transaction for each priced plan, so no manual
    // plan-payment rows are needed here — only the gym's running costs. Gym
    // share now lives on the individual plans, not as a global workbook
    // setting.
    await transactionService.addTransaction(
      TransactionEntry(
        type: TransactionTypes.expense,
        category: TransactionCategories.rent,
        amount: 1200000,
        date: _daysAgo(30),
        note: 'اجاره سالن',
      ),
    );
    await transactionService.addTransaction(
      TransactionEntry(
        type: TransactionTypes.expense,
        category: TransactionCategories.equipment,
        amount: 450000,
        date: _daysAgo(18),
        note: 'مقاومت و تی آر‌ایکس',
      ),
    );

    return 'داده نمونه اضافه شد: ۴ مشتری، ۳ قالب، ۳ برچسب، ۳۱ رکورد حضور؛ ۴ برنامه با درآمد خودکار و ۲ تراکنش هزینه';
  }

  // ------------------------------------------------------------- large seed

  static const _firstNames = [
    'سارا',
    'علی',
    'مینا',
    'رضا',
    'نگار',
    'حسین',
    'مریم',
    'امیر',
    'زهرا',
    'محمد',
    'فاطمه',
    'حسن',
    'الهام',
    'بهرام',
    'شیما',
    'کاوه',
    'لیلا',
    'نوید',
    'پریسا',
    'سعید',
  ];

  static const _lastNames = [
    'محمدی',
    'رضایی',
    'کریمی',
    'احمدی',
    'رستمی',
    'کاظمی',
    'تهرانی',
    'نیکو',
    'شریفی',
    'موسوی',
    'حسینی',
    'صادقی',
    'جعفری',
    'قاسمی',
    'یوسفی',
    'مرادی',
    'سلطانی',
    'بهرامی',
    'فرهادی',
    'زمانی',
  ];

  /// Deletes every data table but deliberately leaves `app_settings` alone, so
  /// the chosen language, theme and trainer name survive a rebuild.
  Future<void> _clearAll() async {
    await db.transaction(() async {
      await db.delete(db.transactions).go();
      await db.delete(db.attendance).go();
      await db.delete(db.clientTags).go();
      await db.delete(db.clientPlans).go();
      await db.delete(db.clients).go();
      await db.delete(db.planTemplates).go();
      await db.delete(db.tags).go();
    });
  }

  /// Rebuilds the database as roughly a year of real use: [clientCount] clients,
  /// each with several finished plans, their attendance history, a queued plan
  /// behind the running one, and a year of ledger rows.
  ///
  /// **Replaces everything** (the caller confirms first), so repeated runs stay
  /// a known quantity instead of stacking duplicates.
  ///
  /// Attendance is written with batched inserts rather than through
  /// [AttendanceSessionService.addSession]. That path is the right one for a
  /// real tap, but it runs a plan scan plus two transactions per record — fine
  /// once, minutes for ~10k rows. Here each plan's `remaining` is derived from
  /// the records as they are generated, so the same invariants hold (sessions
  /// consumed, old plans expired, newest one active with sessions left) without
  /// the per-record cost.
  Future<String> seedLarge({
    int clientCount = 120,
    int planCycles = 4,
    int sessionsPerPlan = 24,
    int planDays = 90,
  }) async {
    await _clearAll();

    const templateSpecs = [
      ('برنامه مبتدی', 24, 90),
      ('برنامه حرفه‌ای', 36, 120),
      ('برنامه فشرده', 48, 90),
      ('برنامه هوازی', 20, 60),
      ('برنامه قدرتی', 30, 90),
      ('برنامه اصلاحی', 16, 60),
    ];
    final templateIds = <int>[];
    for (final (name, sessions, days) in templateSpecs) {
      templateIds.add(
        await templatesService.createTemplate(name, sessions, days),
      );
    }

    const tagSpecs = [
      ('مبتدی', '🌱', 0xFF88A36B),
      ('کاهش وزن', '🔥', 0xFF8B4A3E),
      ('ویژه', '⭐', 0xFFFFB74D),
      ('بانوان', '👩', 0xFFC26B7C),
      ('آقایان', '👨', 0xFF5B8DB8),
      ('آنلاین', '💻', 0xFF8E7BB8),
      ('خصوصی', '🔒', 0xFFC98A3C),
      ('قدرتی', '💪', 0xFF4A6B4E),
    ];
    final tagIds = <int>[];
    for (final (name, emoji, color) in tagSpecs) {
      tagIds.add(await tagsService.createTag(name, emoji: emoji, color: color));
    }

    final clientIds = <int>[];
    for (var i = 0; i < clientCount; i++) {
      final first = _firstNames[i % _firstNames.length];
      final last = _lastNames[(i ~/ _firstNames.length) % _lastNames.length];
      final id = await clientsService.createClient(
        '$first $last',
        contact: '0912${1000000 + i}',
        note: i % 7 == 0 ? 'جلسه صبح' : '',
        bonusSessions: i % 5 == 0 ? 2 : 0,
      );
      clientIds.add(id);
      await tagsService.assignTagToClient(id, tagIds[i % tagIds.length]);
      await tagsService.assignTagToClient(
        id,
        tagIds[(i * 3 + 1) % tagIds.length],
      );
    }

    var attendanceCount = 0;
    // Written in chunks, one transaction each.
    //
    // This was a single transaction covering ~11k rows, and on the web backend
    // the result did not survive a page reload: the client rows (each their own
    // small transaction) persisted, while the plans and attendance — the bulk of
    // it — silently did not. Small committed chunks are both safer and closer to
    // how the app actually writes.
    const clientsPerChunk = 10;
    for (
      var chunkStart = 0;
      chunkStart < clientIds.length;
      chunkStart += clientsPerChunk
    ) {
      final chunkEnd = (chunkStart + clientsPerChunk) > clientIds.length
          ? clientIds.length
          : chunkStart + clientsPerChunk;
      await db.transaction(() async {
        final attendanceRows = <AttendanceCompanion>[];
        final txRows = <TransactionsCompanion>[];

        for (var i = chunkStart; i < chunkEnd; i++) {
          final clientId = clientIds[i];
          final tIdx = i % templateIds.length;
          final (_, _, templateDays) = templateSpecs[tIdx];
          final price = 800000 + tIdx * 250000;

          // Client archetypes.
          //
          // A book of uniformly healthy regulars is not what a working trainer
          // has, and it made every time-based client filter read zero — which
          // meant none of them could be judged. Roughly: 40% regulars, then a
          // slice each of nearly-out, no-plan, expiring, drifting-away and
          // never-came.
          final kind = i % 10;
          final keepsActivePlan = kind != 5;
          final neverAttended = kind == 9;
          final driftedAway = kind == 7 || kind == 8;
          final nearlyOut = kind == 4;
          final expiringSoon = kind == 6;

          for (var c = 0; c < planCycles; c++) {
            final isNewest = c == planCycles - 1;
            // Older plans sit further back; the newest is usually still running.
            // "Expiring soon" starts its last plan near its own day limit, so it
            // has days left to lose but not many. Uses the template's duration,
            // not the nominal plan length, or a 60-day template would already
            // have elapsed.
            final startDaysAgo = isNewest
                ? (expiringSoon ? templateDays - 5 : 30)
                : 30 + planDays * (planCycles - 1 - c);
            // Only the elapsed part of the window can hold attendance, so a
            // running plan never gets records from the future.
            final windowDays = startDaysAgo < planDays
                ? startDaysAgo
                : planDays;

            var consumed = (windowDays ~/ 2).clamp(0, sessionsPerPlan);
            if (neverAttended) {
              consumed = 0;
            }
            // Drifting away: the running plan has had no visits, so the last one
            // is weeks back.
            if (driftedAway && isNewest) {
              consumed = 0;
            }
            if (nearlyOut && isNewest) {
              consumed = sessionsPerPlan - 1;
            }
            if (expiringSoon && isNewest) {
              consumed = (sessionsPerPlan * 0.4).round();
            }

            final planId = await db.insertPlan(
              ClientPlansCompanion.insert(
                clientId: clientId,
                templateId: templateIds[tIdx],
                startDate: Value(_daysAgo(startDaysAgo)),
                sessions: sessionsPerPlan,
                days: templateDays,
                price: Value(price),
                sharePercent: const Value(30),
                remaining: sessionsPerPlan - consumed,
                // Older plans are finished; the newest runs unless this client is
                // one of the "needs a plan" ones.
                status: Value(
                  isNewest && keepsActivePlan ? 'active' : 'expired',
                ),
              ),
            );

            // The plan's own income row, so the ledger and the per-plan share
            // section have a year of history to summarise.
            txRows.add(
              TransactionsCompanion.insert(
                clientId: Value(clientId),
                planId: Value(planId),
                type: 'income',
                category: 'plan',
                amount: price,
                date: _daysAgo(startDaysAgo),
              ),
            );

            for (var s = 0; s < consumed; s++) {
              final dayAgo = startDaysAgo - s * 2;
              if (dayAgo < 0) break;
              attendanceRows.add(
                AttendanceCompanion.insert(
                  clientId: clientId,
                  planId: Value(planId),
                  date: _daysAgo(dayAgo),
                  status: s % 9 == 0 ? 'absent' : 'present',
                ),
              );
              attendanceCount++;
            }

            if (isNewest && keepsActivePlan) {
              // A queued plan waiting behind the running one, so the queue and
              // "plans left in line" paths have something real to show. Clients
              // deliberately left without a plan get none: their state is "needs
              // a plan", and nothing would ever promote it anyway.
              await db.insertPlan(
                ClientPlansCompanion.insert(
                  clientId: clientId,
                  templateId: templateIds[(tIdx + 1) % templateIds.length],
                  sessions: sessionsPerPlan,
                  days: templateDays,
                  remaining: sessionsPerPlan,
                  status: const Value('queued'),
                  queueOrder: const Value(1),
                ),
              );
            }
          }
        }

        // Chunked too, so no single statement carries the whole set.
        for (var start = 0; start < attendanceRows.length; start += 500) {
          final end = (start + 500) > attendanceRows.length
              ? attendanceRows.length
              : start + 500;
          await db.batch(
            (b) =>
                b.insertAll(db.attendance, attendanceRows.sublist(start, end)),
          );
        }
        await db.batch((b) => b.insertAll(db.transactions, txRows));
      });
    }

    // A year of running costs, once.
    await db.transaction(() async {
      final txRows = <TransactionsCompanion>[];
      for (var m = 0; m < 12; m++) {
        txRows.add(
          TransactionsCompanion.insert(
            type: 'expense',
            category: 'rent',
            amount: 1200000,
            date: _daysAgo(m * 30 + 3),
          ),
        );
        txRows.add(
          TransactionsCompanion.insert(
            type: 'expense',
            category: 'salary',
            amount: 800000,
            date: _daysAgo(m * 30 + 5),
          ),
        );
      }
      await db.batch((b) => b.insertAll(db.transactions, txRows));
    });

    final planCount = clientCount * (planCycles + 1);
    return 'داده پرحجم ساخته شد: $clientCount مشتری، $planCount برنامه، $attendanceCount رکورد حضور';
  }
}

final demoDataServiceProvider = Provider<DemoDataService>((ref) {
  return DemoDataService(
    clientsService: ref.watch(clientsServiceProvider),
    tagsService: ref.watch(tagsServiceProvider),
    templatesService: ref.watch(templatesServiceProvider),
    plansService: ref.watch(plansServiceProvider),
    attendanceSessionService: ref.watch(attendanceSessionServiceProvider),
    transactionService: ref.watch(transactionServiceProvider),
    settingsService: ref.watch(settingsServiceProvider),
    db: ref.watch(databaseProvider),
  );
});
