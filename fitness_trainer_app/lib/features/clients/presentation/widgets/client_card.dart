import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/clients/domain/client.dart' as domain;
import 'package:fitness_trainer_app/features/plans/domain/client_plan.dart' as plandomain;
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class ClientCard extends ConsumerWidget {
  final int clientId;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onShowActions;

  const ClientCard({
    super.key,
    required this.clientId,
    this.onTap,
    this.onLongPress,
    this.onShowActions,
  });

  Widget _buildPlaceholder(BuildContext context) {
    final t = context.tones;
    return Row(
      children: [
        CircleAvatar(radius: 24, backgroundColor: t.surfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 120, color: t.surfaceVariant),
              const SizedBox(height: 8),
              Container(height: 12, width: 80, color: t.surfaceVariant),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _adjustBonus(WidgetRef ref, BuildContext context, domain.Client client, int delta) async {
    final messenger = ScaffoldMessenger.of(context);
    final next = (client.bonusSessions + delta).clamp(0, 9999);
    if (next == client.bonusSessions) return;
    await ref.read(clientsServiceProvider).updateClientBonus(client.id!, next);
    ref.invalidateAppData();
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(delta > 0 ? AppStrings.of(context).bonusAdded : AppStrings.of(context).bonusRemoved)));
  }

  Future<void> _toggleFreeze(WidgetRef ref, BuildContext context, plandomain.ClientPlan plan) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(plansProvider.notifier);
    if (plan.isFrozen) {
      await notifier.unfreezePlan(plan.id!);
    } else {
      await notifier.freezePlan(plan.id!);
    }
    ref.invalidateAppData();
    if (!context.mounted) return;
    final s = AppStrings.of(context);
    messenger.showSnackBar(SnackBar(content: Text(plan.isFrozen ? s.activate : s.freeze)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final clientAsync = ref.watch(clientProvider(clientId));
    final plansAsync = ref.watch(clientPlansProvider(clientId));
    final templatesAsync = ref.watch(allTemplatesProvider);
    final todayCountAsync = ref.watch(todayAttendanceCountProvider(clientId));
    final todayStatusAsync = ref.watch(todayAttendanceStatusCountsProvider(clientId));

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: clientAsync.when(
              loading: () => _buildPlaceholder(context),
              error: (e, _) => _buildPlaceholder(context),
            data: (client) {
              final plans = plansAsync.value ?? const [];
              final plan = plans.where((p) => p.isActive || p.isFrozen).firstOrNull;
              final templates = templatesAsync.value;
              final templateName = plan != null
                  ? (templates?.where((t) => t.id == plan.templateId).firstOrNull?.name ?? s.activePlanFallback)
                  : null;
              final todayCount = todayCountAsync.value ?? 0;
              final todayStatus = todayStatusAsync.value ?? const <String, int>{};
              final presentCount = todayStatus['present'] ?? 0;
              final absentCount = todayStatus['absent'] ?? 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: t.primaryLight,
                        child: Text(client.name[0], style: TextStyle(color: t.onSurface, fontSize: 18)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(client.name, style: AppTypography.bodyLarge),
                            if (client.contact != null && client.contact!.isNotEmpty)
                              Text(client.contact!, style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: s.attendanceLabel,
                        icon: Icon(Icons.calendar_month_outlined, size: 20, color: t.onSurfaceVar),
                        onPressed: () => Navigator.pushNamed(context, '${AppRoutes.attendance}/$clientId'),
                      ),
                      if (onShowActions != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: s.clientActionsTitle,
                          icon: Icon(Icons.more_vert, size: 20, color: t.onSurfaceVar),
                          onPressed: onShowActions,
                        ),
                    ],
                  ),
                  if (plan != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: plan.isFrozen ? t.warningSoft : t.successSoft,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            plan.isFrozen ? Icons.ac_unit : Icons.check_circle_outline,
                            size: 16,
                            color: plan.isFrozen ? t.warning : t.success,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              templateName ?? s.activePlanFallback,
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(s.remainingDetail(plan.remaining, plan.sessions), style: AppTypography.bodySmall),
                          const SizedBox(width: AppSpacing.sm),
                          Text(s.daysCount(plan.days), style: AppTypography.bodySmall),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            tooltip: plan.isFrozen ? s.activate : s.freeze,
                            onPressed: () => _toggleFreeze(ref, context, plan),
                            icon: Icon(
                              plan.isFrozen ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              size: 20,
                              color: plan.isFrozen ? t.warning : t.onSurfaceVar,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.card_giftcard, size: 14, color: t.warning),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(s.bonusSessionsCount(client.bonusSessions), style: AppTypography.bodySmall),
                      ),
                      _BonusStepper(
                        tooltip: s.bonusRemoved,
                        icon: Icons.remove_circle_outline,
                        color: client.bonusSessions > 0 ? t.onSurfaceVar : t.surfaceVariant,
                        onTap: client.bonusSessions > 0 ? () => _adjustBonus(ref, context, client, -1) : null,
                      ),
                      const SizedBox(width: 4),
                      _BonusStepper(
                        tooltip: s.bonusAdded,
                        icon: Icons.add_circle_outline,
                        color: t.success,
                        onTap: () => _adjustBonus(ref, context, client, 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (plan == null) ...[
                    Text(s.noActivePlanLabel, style: AppTypography.caption),
                  ],
                  if (todayCount > 0) ...[
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        if (presentCount > 0)
                          AppPill(label: '${s.present}: $presentCount', color: t.successSoft),
                        if (absentCount > 0)
                          AppPill(label: '${s.absent}: $absentCount', color: t.errorSoft),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Compact circular icon button used for quick bonus session +/−.
class _BonusStepper extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _BonusStepper({required this.tooltip, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
    );
  }
}