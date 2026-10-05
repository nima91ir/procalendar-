import 'package:drift/drift.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';
import 'package:fitness_trainer_app/features/attendance/data/attendance_repository.dart';
import 'package:fitness_trainer_app/core/database/app_database.dart';

class AttendanceService {
  final AttendanceRepository repository;
  final AppDatabase db;
  AttendanceService(this.repository, this.db);

  Future<List<AttendanceRecord>> getClientAttendance(int clientId) =>
      repository.getClientAttendance(clientId);
  Future<AttendanceRecord?> getAttendance(int clientId, String date) =>
      repository.getAttendance(clientId, date);
  Stream<List<AttendanceRecord>> watchClientAttendance(int clientId) =>
      repository.watchClientAttendance(clientId);

  Future<List<AttendanceRecord>> getPlanAttendance(int planId) =>
      repository.getPlanAttendance(planId);
  Future<AttendanceRecord?> getPlanAttendanceForDate(int planId, String date) =>
      repository.getPlanAttendanceForDate(planId, date);

  Future<AttendanceRecord?> getAttendanceById(int id) =>
      repository.getAttendanceById(id);

  /// Every attendance record, unscoped (see [AttendanceRepository.getAllAttendance]).
  Future<List<AttendanceRecord>> getAllAttendance() =>
      repository.getAllAttendance();

  /// The latest record for a client/day.
  Future<AttendanceRecord?> getLatestAttendance(int clientId, String date) =>
      repository.getAttendance(clientId, date);

  Future<int> deleteAttendanceById(int id) => repository.deleteAttendance(id);

  /// Always inserts a *new* record — a client may have several attendance
  /// records on the same day.
  ///
  /// [planId] records where the consumed session came from, which is what lets
  /// a later removal refund the right place: a plan id refunds that plan,
  /// `null` refunds a bonus session, and [kNoSessionConsumed] means nothing was
  /// consumed. This is the only insert on the attendance path — the callers that
  /// also consume or refund a session wrap it in a transaction.
  Future<int> addAttendance(
    int clientId,
    String date,
    String status, {
    int? planId,
  }) async {
    return repository.addAttendance(
      AttendanceCompanion.insert(
        clientId: clientId,
        planId: Value(planId),
        date: date,
        status: status,
      ),
    );
  }
}
