import 'package:fitness_trainer_app/core/database/app_database.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart' as domain;

class AttendanceRepository {
  final AppDatabase db;
  AttendanceRepository(this.db);

  Future<List<domain.AttendanceRecord>> getClientAttendance(int clientId) async {
    final rows = await db.getClientAttendance(clientId);
    return rows.map((r) => domain.AttendanceRecord(
      id: r.id,
      clientId: r.clientId,
      planId: r.planId,
      date: r.date,
      status: r.status,
      createdAt: r.createdAt,
    )).toList();
  }

  /// Every attendance record, unscoped.
  ///
  /// The dashboard uses this to work out each client's most recent visit, which
  /// is the only signal the data model offers about who is likely to train
  /// today — there is no schedule to consult.
  Future<List<domain.AttendanceRecord>> getAllAttendance() async {
    final rows = await db.getAllAttendance();
    return rows.map((r) => domain.AttendanceRecord(
      id: r.id,
      clientId: r.clientId,
      planId: r.planId,
      date: r.date,
      status: r.status,
      createdAt: r.createdAt,
    )).toList();
  }

  Future<domain.AttendanceRecord?> getAttendance(int clientId, String date) async {
    final row = await db.getAttendance(clientId, date);
    if (row == null) return null;
    return domain.AttendanceRecord(
      id: row.id,
      clientId: row.clientId,
      planId: row.planId,
      date: row.date,
      status: row.status,
      createdAt: row.createdAt,
    );
  }

  Future<List<domain.AttendanceRecord>> getPlanAttendance(int planId) async {
    final rows = await db.getPlanAttendance(planId);
    return rows.map((r) => domain.AttendanceRecord(
      id: r.id,
      clientId: r.clientId,
      planId: r.planId,
      date: r.date,
      status: r.status,
      createdAt: r.createdAt,
    )).toList();
  }

  Future<domain.AttendanceRecord?> getPlanAttendanceForDate(int planId, String date) async {
    final row = await db.getPlanAttendanceForDate(planId, date);
    if (row == null) return null;
    return domain.AttendanceRecord(
      id: row.id,
      clientId: row.clientId,
      planId: row.planId,
      date: row.date,
      status: row.status,
      createdAt: row.createdAt,
    );
  }

Future<int> insertAttendance(AttendanceCompanion insert) => db.insertAttendance(insert);
  Future<bool> updateAttendance(AttendanceCompanion insert) => db.updateAttendance(insert);
  Future<int> deleteAttendance(int id) => db.deleteAttendance(id);

  Future<int> addAttendance(AttendanceCompanion insert) => db.addAttendance(insert);

  Future<domain.AttendanceRecord?> getAttendanceById(int id) async {
    final row = await db.getAttendanceById(id);
    if (row == null) return null;
    return domain.AttendanceRecord(
      id: row.id,
      clientId: row.clientId,
      planId: row.planId,
      date: row.date,
      status: row.status,
      createdAt: row.createdAt,
    );
  }

  Stream<List<domain.AttendanceRecord>> watchClientAttendance(int clientId) {
    return db.watchClientAttendance(clientId).map((rows) => rows.map((r) => domain.AttendanceRecord(
      id: r.id,
      clientId: r.clientId,
      planId: r.planId,
      date: r.date,
      status: r.status,
      createdAt: r.createdAt,
    )).toList());
  }
}
