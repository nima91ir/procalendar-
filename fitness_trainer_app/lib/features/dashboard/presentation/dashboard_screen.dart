import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/features/backup/presentation/widgets/backup_reminder_banner.dart';
import 'package:fitness_trainer_app/core/navigation/navigation_providers.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/date_format.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _num(int? value, String languageCode) =>
      localizeNumber(value?.toString() ?? '—', languageCode);

  /// Switches to the Clients tab and guarantees it shows the client *list*.
  ///
  /// Each tab keeps its own navigation stack, so a client profile opened
  /// earlier in that tab would still be on top — the user would land back on
  /// that profile instead of on the list this action promises. The request
  /// makes `MainShell` clear the stack; a plain tab tap deliberately does not.
  void _openClientsList() {
    ref.read(tabIndexProvider.notifier).select(1);
    ref.read(tabRootRequestProvider.notifier).request();
  }

  /// Applies a client-list quick filter and switches to the Clients tab.
  void _drillDown(ClientQuickFilter filter) {
    ref.read(clientQuickFilterProvider.notifier).set(filter);
    _openClientsList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final lang = ref.watch(languageProvider);
    final formattedToday = formatDateLong(jalaliToday(), lang);
    final trainerName = ref.watch(trainerNameProvider).value;
    final totalAsync = ref.watch(totalClientsProvider);
    final expiredAsync = ref.watch(expiredPlansCountProvider);
    final frozenAsync = ref.watch(frozenPlansCountProvider);
    final queuedAsync = ref.watch(queuedPlansProvider);
    final lowSessionAsync = ref.watch(lowSessionPlansProvider);
    final bonusAsync = ref.watch(bonusSessionClientsProvider);

    // Distinct clients, not plans: this row opens a client list, so a plan count
    // could read 13 while the list showed 12.
    final lowSessionClientCount = {
      for (final plan in lowSessionAsync.value ?? const <Map<String, dynamic>>[])
        plan['clientId'] as int,
    }.length;

    return Scaffold(
      appBar: AppBar(title: Text(s.dashboardTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidateAppData(),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppHeroHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.waving_hand_outlined, size: 22),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          (trainerName != null && trainerName.isNotEmpty)
                              ? s.welcomeWith(trainerName)
                              : s.appTitle,
                          style: AppTypography.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(formattedToday, style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      _HeroStat(
                        icon: Icons.people_outline,
                        label: s.totalClients,
                        value: _num(totalAsync.value, lang),
                        onTap: () => _drillDown(ClientQuickFilter.all),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _HeroStat(
                        icon: Icons.event_busy,
                        label: s.expiredPlans,
                        value: _num(expiredAsync.value, lang),
                        onTap: () => _drillDown(ClientQuickFilter.expired),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _HeroStat(
                        icon: Icons.lock_outline,
                        label: s.frozenPlans,
                        value: _num(frozenAsync.value, lang),
                        onTap: () => _drillDown(ClientQuickFilter.frozen),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _HeroStat(
                        icon: Icons.schedule,
                        label: s.queuedPlans,
                        value: _num(queuedAsync.value, lang),
                        onTap: () => _drillDown(ClientQuickFilter.queued),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const BackupReminderBanner(),
            const SizedBox(height: AppSpacing.xxl),
            // These two are the same *kind* of thing — a count of clients worth
            // a look — so they are built the same way: a heading with an action,
            // then one summary row that opens that filtered list.
            //
            // Low-session used to render a card per plan. On a full book that
            // was a wall of rows on the landing screen (the same problem the
            // today-attendance list had), and it contradicted its own action:
            // the rows counted plans while "view clients" led to clients.
            if (lowSessionClientCount > 0) ...[
              SectionHeader(
                title: s.lowSessionPlans,
                actionLabel: s.viewClients,
                onAction: () => _drillDown(ClientQuickFilter.lowSession),
              ),
              const SizedBox(height: AppSpacing.xs),
              _DashboardSummaryRow(
                icon: Icons.timelapse,
                // Amber stays for the one that genuinely needs action.
                iconColor: t.warning,
                label: s.lowSessionClients(lowSessionClientCount),
                onTap: () => _drillDown(ClientQuickFilter.lowSession),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
            if (bonusAsync.value != null && bonusAsync.value!.isNotEmpty) ...[
              SectionHeader(
                title: s.bonusSessions,
                actionLabel: s.viewClients,
                onAction: () => _drillDown(ClientQuickFilter.bonus),
              ),
              const SizedBox(height: AppSpacing.xs),
              _DashboardSummaryRow(
                icon: Icons.card_giftcard,
                // Neutral, deliberately not a warning: holding gift sessions is
                // a fact, not a problem. It was painted amber before, which made
                // information read like an alert.
                iconColor: t.onSurfaceVar,
                label: s.bonusClients(bonusAsync.value!.length),
                onTap: () => _drillDown(ClientQuickFilter.bonus),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _HeroStat({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  label,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A dashboard section reduced to a single row: icon, count-and-label, chevron.
///
/// Both dashboard sections now use this, so they cannot drift apart again. One
/// was a list of plans and the other a single count, which gave no clue what a
/// tap would do — and the list version grew without bound as plans ran low.
class _DashboardSummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _DashboardSummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTypography.bodyLarge)),
          Icon(Icons.chevron_left, color: t.onSurfaceVar, size: 20),
        ],
      ),
    );
  }
}