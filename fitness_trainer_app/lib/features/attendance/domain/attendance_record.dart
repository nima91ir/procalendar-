class AttendanceRecord {
  final int? id;
  final int clientId;
  final int? planId;
  final String date;
  final String status;
  final String createdAt;

  const AttendanceRecord({
    this.id,
    required this.clientId,
    this.planId,
    required this.date,
    required this.status,
    this.createdAt = '',
  });

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';

  AttendanceRecord copyWith({
    int? id,
    int? clientId,
    int? planId,
    String? date,
    String? status,
    String? createdAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
