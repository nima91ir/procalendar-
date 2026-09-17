class Tag {
  final int? id;
  final String name;
  final String emoji;
  final int color;

  const Tag({
    this.id,
    required this.name,
    this.emoji = '',
    this.color = 0xFF88A36B,
  });

  Tag copyWith({
    int? id,
    String? name,
    String? emoji,
    int? color,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
    );
  }
}
