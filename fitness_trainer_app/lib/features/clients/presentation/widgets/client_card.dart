import 'package:flutter/material.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/features/clients/domain/client.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ClientCard({
    super.key,
    required this.client,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(client.name[0], style: const TextStyle(color: AppColors.onSurface)),
        ),
        title: Text(client.name, style: AppTypography.bodyLarge),
        subtitle: Text('جلسات اضافه: ${client.bonusSessions}', style: AppTypography.bodySmall),
        trailing: onDelete != null
            ? IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: onDelete)
            : null,
        onTap: onTap,
      ),
    );
  }
}
