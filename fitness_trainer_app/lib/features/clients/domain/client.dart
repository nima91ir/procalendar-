class Client {
  final int? id;
  final String name;
  final String? contact;
  final String note;
  final int bonusSessions;
  final String createdAt;

  const Client({
    this.id,
    required this.name,
    this.contact,
    this.note = '',
    this.bonusSessions = 0,
    this.createdAt = '',
  });

  Client copyWith({
    int? id,
    String? name,
    String? contact,
    String? note,
    int? bonusSessions,
    String? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      note: note ?? this.note,
      bonusSessions: bonusSessions ?? this.bonusSessions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
