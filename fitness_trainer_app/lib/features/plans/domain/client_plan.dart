class ClientPlan {
  final int? id;
  final int clientId;
  final int templateId;
  final String? startDate;
  final int sessions;
  final int days;
  final int price;
  final int sharePercent;
  final int remaining;
  final String status;
  final int? queueOrder;
  final String createdAt;

  const ClientPlan({
    this.id,
    required this.clientId,
    required this.templateId,
    this.startDate,
    required this.sessions,
    required this.days,
    this.price = 0,
    this.sharePercent = 0,
    required this.remaining,
    this.status = 'active',
    this.queueOrder,
    this.createdAt = '',
  });

  bool get isActive => status == 'active';
  bool get isFrozen => status == 'frozen';
  bool get isExpired => status == 'expired';
  bool get isQueued => status == 'queued';

  ClientPlan copyWith({
    int? id,
    int? clientId,
    int? templateId,
    String? startDate,
    int? sessions,
    int? days,
    int? price,
    int? sharePercent,
    int? remaining,
    String? status,
    int? queueOrder,
    String? createdAt,
  }) {
    return ClientPlan(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      templateId: templateId ?? this.templateId,
      startDate: startDate ?? this.startDate,
      sessions: sessions ?? this.sessions,
      days: days ?? this.days,
      price: price ?? this.price,
      sharePercent: sharePercent ?? this.sharePercent,
      remaining: remaining ?? this.remaining,
      status: status ?? this.status,
      queueOrder: queueOrder ?? this.queueOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
