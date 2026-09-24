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
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/features/tags/domain/tag.dart' as domain;
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Set<int> _selectedTagIds = {};

  String _num(int? value, String languageCode) =>
      localizeNumber(value?.toString() ?? '—', languageCode);

  /// Applies a client-list quick filter and switches to the Clients tab.
  void _drillDown(ClientQuickFilter filter) {
    ref.read(clientQuickFilterProvider.notifier).set(filter);
    ref.read(tabIndexProvider.notifier).select(1);
  }

  Future<void> _mark(WidgetRef ref, BuildContext context, AppStrings s, String lang, int clientId, String status) async {
    final messenger = ScaffoldMessenger.of(context);
    final label = status == 'present' ? s.present : s.absent;
    try {
      await ref.read(attendanceProvider.notifier).addSession(clientId, jalaliToday(), status: status);
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.recordAdded(label, formatDateLong(jalaliToday(), lang)))));
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('${s.errorPrefix}$e')));
    }
  }

  Future<void> _undo(WidgetRef ref, BuildContext context, AppStrings s, String lang, int clientId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(attendanceProvider.notifier).removeLatestSession(clientId, jalaliToday());
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.recordRemoved(formatDateLong(jalaliToday(), lang)))));
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('${s.errorPrefix}$e')));
    }
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
    final todayAttendanceAsync = ref.watch(todayAttendanceProvider);
    final clientNamesAsync = ref.watch(clientNamesProvider);
    final allClientsAsync = ref.watch(allClientsProvider);
    final tagsAsync = ref.watch(allTagsProvider);
    final tagFilterAsync = ref.watch(clientTagFilterProvider);
    // A tag may be deleted while selected; drop stale ids so the filter never
    // silently empties the list.
    final validTagIds = (tagsAsync.value ?? const <domain.Tag>[]).map((t) => t.id).toSet();
    final selectedTags = _selectedTagIds.where(validTagIds.contains).toSet();

    final clientNames = clientNamesAsync.value ?? const <int, String>{};

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
            SectionHeader(
              title: s.todayAttendance,
              actionLabel: s.viewClients,
              onAction: () => ref.read(tabIndexProvider.notifier).select(1),
            ),
            const SizedBox(height: AppSpacing.xs),
            tagsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (tags) {
                if (tags.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tags.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          child: FilterChip(
                            label: Text(s.allLabel),
                            selected: _selectedTagIds.isEmpty,
                            onSelected: (_) => setState(_selectedTagIds.clear),
                            selectedColor: t.primaryLight,
                            checkmarkColor: t.onSurface,
                          ),
                        );
                      }
                      final tag = tags[index - 1];
                      final isSelected = selectedTags.contains(tag.id);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: FilterChip(
                          label: Text(tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name),
                          selected: isSelected,
                          onSelected: (_) => setState(() {
                            if (isSelected) {
                              _selectedTagIds.remove(tag.id);
                            } else {
                              _selectedTagIds.add(tag.id!);
                            }
                          }),
                          selectedColor: Color(tag.color),
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            allClientsAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => AppErrorState(message: '$error'),
              data: (clients) {
                if (clients.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.person_add_alt_1_outlined,
                    title: s.noClientsTitle,
                    subtitle: s.noClientsSubtitle,
                  );
                }
                final tagIdsByClient = tagFilterAsync.value ?? const <int, List<int>>{};
                // AND semantics: a client is shown only when it carries every
                // selected tag, so combining tags narrows the list.
                final visible = selectedTags.isEmpty
                    ? clients
                    : clients
                        .where((c) =>
                            selectedTags.every((id) => (tagIdsByClient[c.id] ?? const <int>[]).contains(id)))
                        .toList();
                if (visible.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: s.noClientsWithTag,
                  );
                }
                final statuses = todayAttendanceAsync.value ?? const <int, Map<String, int>>{};
                return Column(
                  children: [
                    for (final client in visible)
                      _TodayRow(
                        name: client.name,
                        counts: statuses[client.id],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '${AppRoutes.clientDetail}/${client.id}',
                        ),
                        onMarkPresent: () => _mark(ref, context, s, lang, client.id!, 'present'),
                        onMarkAbsent: () => _mark(ref, context, s, lang, client.id!, 'absent'),
                        onUndo: () => _undo(ref, context, s, lang, client.id!),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (lowSessionAsync.value != null && lowSessionAsync.value!.isNotEmpty) ...[
              SectionHeader(
                title: s.lowSessionPlans,
                actionLabel: s.viewClients,
                onAction: () => _drillDown(ClientQuickFilter.lowSession),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...lowSessionAsync.value!.map((p) {
                final clientId = p['clientId'] as int;
                final remaining = p['remaining'] as int;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '${AppRoutes.clientDetail}/$clientId',
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timelapse, color: t.warning, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          clientNames[clientId] ?? s.noClientsTitle,
                          style: AppTypography.bodyLarge,
                        ),
                      ),
                      _TonePill(
                        label: '${_num(remaining, lang)} ${s.sessionsLeft}',
                        bg: t.warningSoft,
                        fg: t.warning,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xxl),
            ],
            if (bonusAsync.value != null && bonusAsync.value!.isNotEmpty) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                onTap: () => _drillDown(ClientQuickFilter.bonus),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: t.warning),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        s.bonusClients(bonusAsync.value!.length),
                        style: AppTypography.bodyLarge,
                      ),
                    ),
                    Icon(Icons.chevron_left, color: t.onSurfaceVar, size: 20),
                  ],
                ),
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

/// One client, ready for today's attendance. The quick-mark buttons stay
/// available even after records exist (a client can be marked more than once
/// per day); once any records exist a per-status count pill plus undo appear
/// on the first line so the coach can review or roll back.
class _TodayRow extends StatelessWidget {
  final String name;
  final Map<String, int>? counts;
  final VoidCallback onTap;
  final VoidCallback onMarkPresent;
  final VoidCallback onMarkAbsent;
  final VoidCallback onUndo;

  const _TodayRow({
    required this.name,
    required this.counts,
    required this.onTap,
    required this.onMarkPresent,
    required this.onMarkAbsent,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final present = counts?['present'] ?? 0;
    final absent = counts?['absent'] ?? 0;
    final marked = present > 0 || absent > 0;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: t.primaryLight,
                child: Text(
                  name.isEmpty ? '؟' : name[0],
                  style: AppTypography.bodySmall.copyWith(color: t.onSurface),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (marked) ...[
                if (present > 0) ...[
                  _TonePill(
                    label: s.attendanceCount(s.present, present),
                    bg: t.successSoft,
                    fg: t.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                if (absent > 0) ...[
                  _TonePill(
                    label: s.attendanceCount(s.absent, absent),
                    bg: t.errorSoft,
                    fg: t.error,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                IconButton(
                  onPressed: onUndo,
                  tooltip: s.undoAttendance,
                  icon: Icon(Icons.undo, size: 20, color: t.onSurfaceVar),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _QuickButton(
                  label: s.registerPresent,
                  bg: t.successSoft,
                  fg: t.success,
                  onTap: onMarkPresent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickButton(
                  label: s.registerAbsent,
                  bg: t.errorSoft,
                  fg: t.error,
                  onTap: onMarkAbsent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _QuickButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _TonePill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _TonePill({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}