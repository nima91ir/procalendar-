import 'package:flutter/material.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/features/templates/domain/plan_template.dart' as domain;

class TemplateCard extends StatelessWidget {
  final domain.PlanTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        title: Text(template.name, style: AppTypography.bodyLarge),
        subtitle: Text('${template.sessions} جلسه · ${template.days} روز'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: onDelete),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
