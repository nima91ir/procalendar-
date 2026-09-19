import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final templatesAsync = ref.watch(allTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.templatesTitle)),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (templates) {
          if (templates.isEmpty) {
            return AppEmptyState(icon: Icons.fitness_center, title: s.noTemplatesTitle, subtitle: s.noTemplatesSubtitle);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return FutureBuilder<int>(
                future: ref.read(templatesServiceProvider).countPlansUsingTemplate(template.id!),
                builder: (context, snapshot) {
                  final usageCount = snapshot.data ?? 0;
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(template.name, style: AppTypography.headlineMedium),
                            ),
                            if (usageCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: t.primaryLight,
                                  borderRadius: BorderRadius.circular(AppSpacing.xxl),
                                ),
                                child: Text(s.usedByCount(usageCount), style: AppTypography.labelMedium),
                              ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '${AppRoutes.editTemplate}/${template.id}');
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(s.deleteTemplateTitle),
                                    content: Text(s.deleteTemplateMessage(template.name)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.no)),
                                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.yes)),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(templatesServiceProvider).deleteTemplate(template.id!);
                                  ref.invalidate(allTemplatesProvider);
                                }
                              },
                              icon: Icon(Icons.delete_outline, color: t.error),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            AppPill(label: s.sessionsCount(template.sessions), color: t.primaryLight),
                            const SizedBox(width: AppSpacing.sm),
                            AppPill(label: s.daysCount(template.days), color: t.surfaceVariant),
                            const SizedBox(width: AppSpacing.sm),
                            AppPill(label: s.oneSessionPerDays(template.sessions > 0 ? template.days ~/ template.sessions : 0), color: t.warningSoft),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'templatesFab',
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addTemplate);
        },
        icon: const Icon(Icons.add),
        label: Text(s.addTemplate),
      ),
    );
  }
}
