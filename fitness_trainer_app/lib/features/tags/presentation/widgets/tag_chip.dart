import 'package:flutter/material.dart';
import 'package:fitness_trainer_app/features/tags/domain/tag.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const TagChip({
    super.key,
    required this.tag,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name),
      backgroundColor: Color(tag.color),
      labelStyle: const TextStyle(color: Colors.white),
      onDeleted: onRemove,
    );
  }
}
