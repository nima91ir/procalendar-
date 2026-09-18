import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_repository.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';

class AttendanceService {
  final AttendanceRepository repository;
  final AppDatabase db;
  AttendanceService(this.repository, this.db);

  Future<List<AttendanceRecord>> getClientAttendance(int clientId) => repository.getClientAttendance(clientId);
  Future<AttendanceRecord?> getAttendance(int clientId, String date) => repository.getAttendance(clientId, date);
  Stream<List<AttendanceRecord>> watchClientAttendance(int clientId) => repository.watchClientAttendance(clientId);

  Future<List<AttendanceRecord>> getPlanAttendance(int planId) => repository.getPlanAttendance(planId);
  Future<AttendanceRecord?> getPlanAttendanceForDate(int planId, String date) => repository.getPlanAttendanceForDate(planId, date);

/// Always inserts a *new* record — a client may have several attendance
  /// records on the same day.
  Future<AttendanceRecord?> markAttendance(int clientId, String date, String status) async {
    final id = await repository.addAttendance(AttendanceCompanion.insert(
      clientId: clientId,
      planId: const Value(null),
      date: date,
      status: status,
    ));
    return AttendanceRecord(id: id, clientId: clientId, planId: null, date: date, status: status);
  }

/// Deletes the *latest* attendance record for the given client/day.
  Future<void> undoAttendance(int clientId, String date) async {
    await repository.removeOneAttendance(clientId, date);
  }

  Future<int> addAttendance(int clientId, String date, String status, {int? planId}) async {
    return repository.addAttendance(AttendanceCompanion.insert(
      clientId: clientId,
      planId: Value(planId),
      date: date,
      status: status,
    ));
  }

  Future<int> removeOneAttendance(int clientId, String date) async {
    return repository.removeOneAttendance(clientId, date);
  }
}
