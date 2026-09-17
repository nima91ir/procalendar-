import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class ClientDetailScreen extends ConsumerWidget {
  final int clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(allClientsProvider);
    final plansAsync = ref.watch(clientPlansProvider(clientId));
    final templatesAsync = ref.watch(allTemplatesProvider);

    // Was `firstWhere(..., orElse: () => clients.first)`, which silently
    // showed a *different* client when the id no longer existed.
    final client = clientsAsync.value?.where((c) => c.id == clientId).firstOrNull;
    final clientName = client?.name ?? 'مشتری';
    final templates = templatesAsync.value;

    String templateLabel(int templateId) =>
        templates?.where((t) => t.id == templateId).firstOrNull?.name ?? 'قالب #$templateId';

    Future<void> deleteClient() async {
      final confirmed = await AppConfirmDialog.show(
        context,
        title: 'حذف مشتری',
        message: 'آیا از حذف «$clientName» اطمینان دارید؟ برنامه‌ها و سوابق حضور هم حذف میشوند.',
        confirmLabel: 'حذف',
      );
      if (!confirmed) return;
      await ref.read(clientsServiceProvider).deleteClient(clientId);
      if (context.mounted) Navigator.pop(context, true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(client?.name ?? 'جزئیات مشتری'),
        actions: [
          IconButton(
            tooltip: 'ویرایش مشتری',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final changed = await Navigator.pushNamed(context, '${AppRoutes.editClient}/$clientId');
              if (changed == true) {
                ref.invalidate(allClientsProvider);
              }
            },
          ),
          IconButton(
            tooltip: 'حذف مشتری',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              if (client == null) return;
              deleteClient();
            },
          ),
        ],
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (clients) {
          if (client == null) {
            return const AppEmptyState(icon: Icons.person_off_outlined, title: 'مشتری یافت نشد');
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(client.name.isNotEmpty ? client.name[0] : '؟', style: AppTypography.displayLarge.copyWith(fontSize: 28)),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.name, style: AppTypography.headlineLarge),
                        if (client.contact != null && client.contact!.isNotEmpty)
                          Text(client.contact!, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              _CollapsibleSection(
                title: 'اطلاعات تماس',
                initiallyExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'شماره تماس', value: client.contact ?? 'ثبت نشده'),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(label: 'یادداشت', value: client.note.isNotEmpty ? client.note : 'ثبت نشده'),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(label: 'جلسات اضافه', value: client.bonusSessions.toString()),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader(title: 'برنامه‌های فعال', actionLabel: 'افزودن', onAction: () {
                    Navigator.pushNamed(context, '${AppRoutes.addPlan}/$clientId');
                  }),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '${AppRoutes.attendance}/$clientId');
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('حضور و غیاب'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              plansAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppErrorState(message: e.toString()),
                data: (plans) {
                  if (plans.isEmpty) return const AppEmptyState(icon: Icons.calendar_today, title: 'برنامه‌ای یافت نشد');
                  return Column(
                    children: plans.map((plan) {
                      final remaining = plan.remaining;
                      final sessions = plan.sessions;
                      final status = plan.status;
                      final progress = sessions > 0 ? (remaining / sessions) : 0.0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(templateLabel(plan.templateId), style: AppTypography.headlineMedium),
                                  AppPill(
                                    label: status == 'active' ? 'فعال' : status == 'frozen' ? 'قفل شده' : status == 'queued' ? 'در صف' : 'منقضی شده',
                                    color: status == 'active' ? AppColors.success : status == 'frozen' ? AppColors.frozen : status == 'queued' ? AppColors.queued : AppColors.error,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  status == 'active' ? AppColors.success : status == 'frozen' ? AppColors.frozen : status == 'queued' ? AppColors.queued : AppColors.error,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'باقی‌مانده: ${toPersian(remaining.toString())} از ${toPersian(sessions.toString())} جلسه',
                                style: AppTypography.bodySmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (status == 'active')
                                    TextButton.icon(
                                      onPressed: () async {
                                        await ref.read(plansServiceProvider).freezePlan(plan.id!);
                                        ref.invalidate(clientPlansProvider(clientId));
                                      },
                                      icon: const Icon(Icons.pause_circle_outline, size: 18),
                                      label: const Text('قفل'),
                                    ),
                                  if (status == 'frozen')
                                    TextButton.icon(
                                      onPressed: () async {
                                        await ref.read(plansServiceProvider).unfreezePlan(plan.id!);
                                        ref.invalidate(clientPlansProvider(clientId));
                                      },
                                      icon: const Icon(Icons.play_circle_outline, size: 18),
                                      label: const Text('فعال‌سازی'),
                                    ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final confirmed = await AppConfirmDialog.show(
                                        context,
                                        title: 'حذف برنامه',
                                        message: 'این برنامه حذف شود؟',
                                        confirmLabel: 'حذف',
                                      );
                                      if (!confirmed) return;
                                      await ref.read(plansServiceProvider).deletePlan(plan.id!);
                                      ref.invalidate(clientPlansProvider(clientId));
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                    label: const Text('حذف'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _CollapsibleSection({required this.title, required this.child, this.initiallyExpanded = false});

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, style: AppTypography.headlineMedium)),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: AppTypography.bodySmall)),
        Expanded(child: Text(value, style: AppTypography.bodyLarge)),
      ],
    );
  }
}
