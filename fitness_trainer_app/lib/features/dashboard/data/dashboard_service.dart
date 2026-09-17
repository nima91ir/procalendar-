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

  Future<Map<int, String>> getTodayAttendance() async {
    final date = jalaliToday();
    final rows = await (db.select(db.attendance)..where((a) => a.date.equals(date))).get();
    return {for (var r in rows) r.clientId: r.status};
  }
}
