import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class ClientDetailScreen extends ConsumerWidget {
  final int clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(allClientsProvider);
    final plansAsync = ref.watch(clientPlansProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: clientsAsync.value != null
            ? Text(clientsAsync.value!.firstWhere((c) => c.id == clientId, orElse: () => clientsAsync.value!.first).name)
            : const Text('جزئیات مشتری'),
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (clients) {
          final client = clients.firstWhere((c) => c.id == clientId, orElse: () => clients.isNotEmpty ? clients.first : throw StateError('No client'));
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(client.name[0], style: AppTypography.displayLarge.copyWith(fontSize: 28)),
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
                                  Text('برنامه ${plan.id ?? 0}', style: AppTypography.headlineMedium),
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
                              Text('باقی‌مانده: $remaining/$sessions جلسه', style: AppTypography.bodySmall),
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
