import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/plan_dates.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
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

  /// Remaining days for a running plan; falls back to the plan's total
  /// duration when there is no start date to measure from (queued plans).
  String _planTimeLabel(AppStrings s, plandomain.ClientPlan plan) {
    final daysLeft = planRemainingDays(startDate: plan.startDate, days: plan.days);
    return daysLeft == null ? s.daysCount(plan.days) : s.remainingDays(daysLeft);
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
                      // 44x44 with `shrinkWrap`: the tap area *is* the visible
                      // box. `VisualDensity.compact` used to shrink the visuals
                      // to 36x32 while Material still claimed a padded ~40px hit
                      // area, so the two buttons' invisible areas overlapped and
                      // an imprecise tap landed on the neighbour.
                      IconButton(
                        tooltip: s.attendanceLabel,
                        icon: Icon(Icons.calendar_month_outlined, size: 22, color: t.onSurfaceVar),
                        onPressed: () => Navigator.pushNamed(context, '${AppRoutes.attendance}/$clientId'),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(44, 44),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      if (onShowActions != null) ...[
                        // A real gap, so the two hit areas abut rather than
                        // overlap.
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          tooltip: s.clientActionsTitle,
                          icon: Icon(Icons.more_vert, size: 22, color: t.onSurfaceVar),
                          onPressed: onShowActions,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
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
                          // Both trailing texts are Flexible with ellipsis.
                          // Only the template name could shrink before, so the
                          // fixed pair drove the row past its width and produced
                          // a striped overflow — longest in English, where these
                          // strings are wordier. Found while verifying the touch
                          // targets; it predates that change.
                          Flexible(
                            child: Text(
                              s.remainingDetail(plan.remaining, plan.sessions),
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              _planTimeLabel(s, plan),
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Freeze moved out of the pill onto its own labelled row.
                    //
                    // It used to be an icon buried among the pill's text: 20x20
                    // from `padding: EdgeInsets.zero` plus tight constraints,
                    // while still claiming a padded hit area that reached into
                    // the text beside it. An interactive control inside a label
                    // is exactly where mis-taps come from, so the pill is now
                    // information only.
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        // The theme sets a 44 minimum height; `shrinkWrap` stops
                        // Material padding an invisible tap target beyond it.
                        style: OutlinedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _toggleFreeze(ref, context, plan),
                        icon: Icon(
                          plan.isFrozen ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          size: 18,
                          color: plan.isFrozen ? t.warning : t.onSurfaceVar,
                        ),
                        label: Text(plan.isFrozen ? s.activate : s.freeze),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      // Same as the freeze row above, so the card's two actions
                      // stay the same height.
                      style: OutlinedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '${AppRoutes.addPlan}/$clientId'),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(s.addPlan),
                    ),
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