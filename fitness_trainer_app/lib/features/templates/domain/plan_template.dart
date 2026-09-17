class PlanTemplate {
  final int? id;
  final String name;
  final int sessions;
  final int days;

  const PlanTemplate({
    this.id,
    required this.name,
    required this.sessions,
    required this.days,
  });

  PlanTemplate copyWith({
    int? id,
    String? name,
    int? sessions,
    int? days,
  }) {
    return PlanTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      sessions: sessions ?? this.sessions,
      days: days ?? this.days,
    );
  }
}
