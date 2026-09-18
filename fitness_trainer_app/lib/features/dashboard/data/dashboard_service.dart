import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';

class DashboardService {
  final AppDatabase db;
  DashboardService(this.db);

  Future<int> getTotalClients() async {
    final rows = await db.select(db.clients).get();
    return rows.length;
  }

  Future<int> getActivePlansCount() async {
    final rows = await (db.select(db.clientPlans)..where((p) => p.status.equals('active'))).get();
    return rows.length;
  }

  Future<int> getExpiredPlansCount() async {
    final rows = await (db.select(db.clientPlans)..where((p) => p.status.equals('expired'))).get();
    return rows.length;
  }

  Future<int> getFrozenPlansCount() async {
    final rows = await (db.select(db.clientPlans)..where((p) => p.status.equals('frozen'))).get();
    return rows.length;
  }

  Future<int> getQueuedPlansCount() async {
    final rows = await (db.select(db.clientPlans)..where((p) => p.status.equals('queued'))).get();
    return rows.length;
  }

  /// Distinct client ids that currently have at least one plan in [status].
  /// Used by the dashboard stat cards to drill into the client list.
  Future<List<int>> getClientIdsByPlanStatus(String status) async {
    final rows = await (db.select(db.clientPlans)..where((p) => p.status.equals(status))).get();
    return {for (final p in rows) p.clientId}.toList();
  }


  Future<List<Map<String, dynamic>>> getLowSessionPlans() async {
    final rows = await (db.select(db.clientPlans)..where((p) => p.status.equals('active'))).get();
    return rows.where((p) => p.remaining < 3).map((p) => {
      'planId': p.id,
      'clientId': p.clientId,
      'remaining': p.remaining,
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getBonusSessionClients() async {
    final rows = await db.select(db.clients).get();
    return rows.where((c) => c.bonusSessions > 0).map((c) => {
      'clientId': c.id,
      'clientName': c.name,
      'bonusSessions': c.bonusSessions,
    }).toList();
  }

/// Today's attendance counts per client and status — a client may have
  /// several records on the same day.
  Future<Map<int, Map<String, int>>> getTodayAttendance() async {
    final date = jalaliToday();
    final rows = await (db.select(db.attendance)..where((a) => a.date.equals(date))).get();
    final result = <int, Map<String, int>>{};
    for (final row in rows) {
      final counts = result.putIfAbsent(row.clientId, () => <String, int>{});
      counts[row.status] = (counts[row.status] ?? 0) + 1;
    }
    return result;
  }

  /// Client names keyed by id, for rendering attendance/plan lists with names
  /// instead of raw database ids.
  Future<Map<int, String>> getClientNames() async {
    final rows = await db.select(db.clients).get();
    return {for (final row in rows) row.id: row.name};
  }
}
