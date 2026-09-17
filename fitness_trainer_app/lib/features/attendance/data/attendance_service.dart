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

  Future<AttendanceRecord?> markAttendance(int clientId, String date, String status) async {
    final existing = await repository.getAttendance(clientId, date);
    if (existing != null) {
      final updated = await repository.updateAttendance(AttendanceCompanion.insert(
        id: Value(existing.id!),
        clientId: existing.clientId,
        date: existing.date,
        status: status,
      ));
      return updated ? existing.copyWith(status: status) : null;
    }
    final id = await repository.insertAttendance(AttendanceCompanion.insert(
      clientId: clientId,
      date: date,
      status: status,
    ));
    return AttendanceRecord(id: id, clientId: clientId, date: date, status: status);
  }

  Future<void> deleteAttendance(int id) async => repository.deleteAttendance(id);

  Future<void> undoAttendance(int clientId, String date) async {
    final existing = await repository.getAttendance(clientId, date);
    if (existing != null) {
      await repository.deleteAttendance(existing.id!);
    }
  }
}
