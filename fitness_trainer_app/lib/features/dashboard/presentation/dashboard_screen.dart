import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = jalaliToday();
    final formattedToday = formatJalaliLong(today);
    final trainerNameAsync = ref.watch(trainerNameProvider);
    final totalClientsAsync = ref.watch(totalClientsProvider);
    final expiredAsync = ref.watch(expiredPlansCountProvider);
    final frozenAsync = ref.watch(frozenPlansCountProvider);
    final queuedAsync = ref.watch(queuedPlansProvider);
    final lowSessionAsync = ref.watch(lowSessionPlansProvider);
    final bonusAsync = ref.watch(bonusSessionClientsProvider);
    final todayAttendanceAsync = ref.watch(todayAttendanceProvider);
    final attendanceByDateAsync = ref.watch(attendanceByDateProvider);
    final clientNamesAsync = ref.watch(clientNamesProvider);
    final clientNames = clientNamesAsync.value ?? const <int, String>{};

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('تقویم حرفه‌ای', style: AppTypography.headlineLarge),
            Text(formattedToday, style: AppTypography.bodySmall),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(totalClientsProvider);
          ref.invalidate(expiredPlansCountProvider);
          ref.invalidate(frozenPlansCountProvider);
          ref.invalidate(queuedPlansProvider);
          ref.invalidate(lowSessionPlansProvider);
          ref.invalidate(bonusSessionClientsProvider);
          ref.invalidate(todayAttendanceProvider);
          ref.invalidate(attendanceByDateProvider);
          ref.invalidate(clientNamesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (trainerNameAsync.value != null && trainerNameAsync.value!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Text('خوش آمدید، ${trainerNameAsync.value}', style: AppTypography.headlineMedium),
              ),
            _buildStatsRow(context, totalClientsAsync, expiredAsync, frozenAsync, queuedAsync),
            const SizedBox(height: AppSpacing.xxl),
            if (lowSessionAsync.value != null && lowSessionAsync.value!.isNotEmpty) ...[
              SectionHeader(
                title: 'برنامه‌های با جلسات کم',
                actionLabel: 'مشاهده مشتریان',
                onAction: () => Navigator.pushNamed(context, AppRoutes.clients),
              ),
              ...lowSessionAsync.value!.map((p) {
                final clientId = p['clientId'] as int;
                return ListTile(
                  leading: const Icon(Icons.timelapse, color: AppColors.warning),
                  title: Text(clientNames[clientId] ?? 'مشتری #$clientId'),
                  trailing: Text('${p['remaining']} جلسه باقی', style: const TextStyle(color: AppColors.warning)),
                  onTap: () => Navigator.pushNamed(context, '${AppRoutes.clientDetail}/$clientId'),
                );
              }),
              const SizedBox(height: AppSpacing.xxl),
            ],
            if (bonusAsync.value != null && bonusAsync.value!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text('${bonusAsync.value!.length} مشتری دارای جلسات اضافه', style: AppTypography.bodyLarge),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
            SectionHeader(title: 'تقویم حضور و غیاب'),
            const SizedBox(height: AppSpacing.md),
            _buildMiniCalendar(context, attendanceByDateAsync.value ?? const <String, String>{}),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(title: 'حضور امروز'),
            const SizedBox(height: AppSpacing.md),
            todayAttendanceAsync.value != null && todayAttendanceAsync.value!.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayAttendanceAsync.value!.length,
                    itemBuilder: (context, index) {
                      final entry = todayAttendanceAsync.value!.entries.elementAt(index);
                      final clientId = entry.key;
                      return ListTile(
                        leading: Icon(
                          entry.value == 'present' ? Icons.check_circle : Icons.cancel,
                          color: entry.value == 'present' ? AppColors.present : AppColors.absent,
                        ),
                        title: Text(clientNames[clientId] ?? 'مشتری #$clientId'),
                        trailing: AppPill(
                          label: entry.value == 'present' ? 'حاضر' : 'غایب',
                          color: entry.value == 'present' ? AppColors.successSoft : AppColors.errorSoft,
                        ),
                        onTap: () => Navigator.pushNamed(context, '${AppRoutes.clientDetail}/$clientId'),
                      );
                    },
                  )
                : const AppEmptyState(icon: Icons.event_busy, title: 'هنوز ثبت نشده', subtitle: 'برای مشتریان مورد نظر حضور را ثبت کنید'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AsyncValue<int> total, AsyncValue<int> expired, AsyncValue<int> frozen, AsyncValue<int> queued) {
    return Row(
      children: [
        Expanded(child: _StatCard(title: 'کل مشتریان', value: total.value?.toString() ?? '—', color: AppColors.primary, icon: Icons.people)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _StatCard(title: 'منقضی شده', value: expired.value?.toString() ?? '—', color: AppColors.error, icon: Icons.event_busy)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _StatCard(title: 'قفل شده', value: frozen.value?.toString() ?? '—', color: AppColors.frozen, icon: Icons.lock)),
      ],
    );
  }

  Widget _buildMiniCalendar(BuildContext context, Map<String, String> attendanceMap) {
    final now = DateTime.now();
    final j = Jalali.fromDateTime(now);
    final daysInMonth = j.monthLength;
    final firstDayWeekDay = j.weekDay % 7;
    const monthNames = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${monthNames[j.month - 1]} ${j.year}', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
                .map((d) => Expanded(child: Center(child: Text(d, style: AppTypography.labelMedium))))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate((daysInMonth + firstDayWeekDay) ~/ 7 + 1, (week) {
            return Row(
              children: List.generate(7, (dayOfWeek) {
                final dayIndex = week * 7 + dayOfWeek - firstDayWeekDay + 1;
                if (dayIndex < 1 || dayIndex > daysInMonth) return const Expanded(child: SizedBox());
                // Dots must be per-day: previously this checked whether *any*
                // status existed in a client-id keyed map, so every day in the
                // month got a dot as soon as one client was marked today.
                final dateKey = '${j.year}/${j.month.toString().padLeft(2, '0')}/${dayIndex.toString().padLeft(2, '0')}';
                final status = attendanceMap[dateKey];
                final isToday = dayIndex == j.day;
                return Expanded(
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primaryLight : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: isToday ? Border.all(color: AppColors.primary) : null,
                      ),
                      child: Stack(
                        children: [
                          Center(child: Text('$dayIndex', style: AppTypography.bodySmall.copyWith(color: isToday ? AppColors.onSurface : AppColors.onSurfaceVar))),
                          if (status != null)
                            Positioned(
                              bottom: 3,
                              left: 0,
                              right: 0,
                              // `Center` is required: with left+right set the
                              // 6px container was being stretched into a bar
                              // across the whole cell.
                              child: Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: status == 'present' ? AppColors.present : AppColors.absent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.displayLarge.copyWith(color: color, fontSize: 20)),
          const SizedBox(height: AppSpacing.xs),
          Text(title, style: AppTypography.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
