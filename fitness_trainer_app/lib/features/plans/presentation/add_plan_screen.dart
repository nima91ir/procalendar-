import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';

class AddPlanScreen extends ConsumerStatefulWidget {
  final int clientId;
  const AddPlanScreen({super.key, required this.clientId});

  @override
  ConsumerState<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends ConsumerState<AddPlanScreen> {
  int? _selectedTemplateId;

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(allTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('انتخاب قالب برنامه')),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (templates) {
          if (templates.isEmpty) {
            return const AppEmptyState(icon: Icons.fitness_center, title: 'قالبی تعریف نشده');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final isSelected = _selectedTemplateId == template.id;
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                onTap: () => setState(() => _selectedTemplateId = template.id),
                accentColor: isSelected ? AppColors.primary : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(template.name, style: AppTypography.headlineMedium),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        AppPill(label: '${template.sessions} جلسه', color: AppColors.primaryLight),
                        const SizedBox(width: AppSpacing.sm),
                        AppPill(label: '${template.days} روز', color: AppColors.surfaceVariant),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            await ref.read(plansServiceProvider).assignPlan(widget.clientId, template.id!, template.sessions, template.days);
                            if (mounted) {
                              navigator.pop();
                              messenger.showSnackBar(const SnackBar(content: Text('برنامه اضافه شد')));
                            }
                          },
                          child: const Text('انتخاب این قالب'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
