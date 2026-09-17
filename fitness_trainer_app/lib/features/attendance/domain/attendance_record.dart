class AttendanceRecord {
  final int? id;
  final int clientId;
  final String date;
  final String status;
  final String createdAt;

  const AttendanceRecord({
    this.id,
    required this.clientId,
    required this.date,
    required this.status,
    this.createdAt = '',
  });

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';

  AttendanceRecord copyWith({
    int? id,
    int? clientId,
    String? date,
    String? status,
    String? createdAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
