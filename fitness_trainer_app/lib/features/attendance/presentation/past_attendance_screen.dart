import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/widgets/attendance_calendar.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';

/// Attendance history + marking screen for a single client.
///
/// Marking a day consumes a session from the active plan (or a bonus session
/// when the plan has none left) and undo gives it back, so this screen is
/// also where the plan/session bookkeeping can be verified.
class PastAttendanceScreen extends ConsumerStatefulWidget {
  final int clientId;
  const PastAttendanceScreen({super.key, required this.clientId});

  @override
  ConsumerState<PastAttendanceScreen> createState() => _PastAttendanceScreenState();
}

class _PastAttendanceScreenState extends ConsumerState<PastAttendanceScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = Jalali.fromDateTime(DateTime.now());
    _year = now.year;
    _month = now.month;
  }

  void _shiftMonth(int delta) {
    setState(() {
      var month = _month + delta;
      var year = _year;
      if (month < 1) {
        month = 12;
        year -= 1;
      } else if (month > 12) {
        month = 1;
        year += 1;
      }
      _month = month;
      _year = year;
    });
  }

  /// Applies a status change for [date]; an empty status means "undo".
  Future<void> _apply(String date, String status) async {
    final notifier = ref.read(attendanceProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    if (status.isEmpty) {
      await notifier.undoAttendance(widget.clientId, date);
    } else {
      await notifier.markAttendance(widget.clientId, date, status);
    }
    if (!mounted) return;
    final label = status.isEmpty ? 'ثبت حذف شد' : status == 'present' ? 'حضور ثبت شد' : 'غیبت ثبت شد';
    messenger.showSnackBar(SnackBar(content: Text('$label · ${formatJalaliLong(date)}')));
  }

  @override
  Widget build(BuildContext context) {
    final attendanceMapAsync = ref.watch(clientAttendanceMapProvider(widget.clientId));
    final recordsAsync = ref.watch(clientAttendanceProvider(widget.clientId));
    final plansAsync = ref.watch(clientPlansProvider(widget.clientId));
    final clientsAsync = ref.watch(allClientsProvider);
    final busy = ref.watch(attendanceProvider).isLoading;

    ref.listen(attendanceProvider, (previous, next) {
      next.whenOrNull(error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $error')));
      });
    });

    final client = clientsAsync.value?.where((c) => c.id == widget.clientId).firstOrNull;
    final plans = plansAsync.value;
    final activePlan = plans?.where((p) => p.isActive).firstOrNull;
    final queuedCount = plans?.where((p) => p.isQueued).length ?? 0;
    final bonusSessions = client?.bonusSessions ?? 0;
    final attendanceMap = attendanceMapAsync.value ?? const <String, String>{};
    final records = recordsAsync.value ?? const <AttendanceRecord>[];

    final today = jalaliToday();

    return Scaffold(
      appBar: AppBar(
        title: Text(client?.name ?? 'حضور و غیاب'),
        bottom: busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SessionSummaryCard(
            activePlanRemaining: activePlan?.remaining,
            activePlanSessions: activePlan?.sessions,
            bonusSessions: bonusSessions,
            queuedCount: queuedCount,
            recordedDays: records.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: 'ثبت سریع امروز'),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _apply(today, 'present'),
                  icon: const Icon(Icons.check),
                  label: const Text('حاضر'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _apply(today, 'absent'),
                  icon: const Icon(Icons.close),
                  label: const Text('غایب'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: () => _apply(today, ''),
                icon: const Icon(Icons.undo),
                tooltip: 'لغو ثبت امروز',
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AttendanceCalendar(
            year: _year,
            month: _month,
            attendanceMap: attendanceMap,
            onDayChanged: _apply,
            onPreviousMonth: () => _shiftMonth(-1),
            onNextMonth: () => _shiftMonth(1),
            todayKey: jalaliToday(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: 'سوابق ثبت شده'),
          if (records.isEmpty)
            const AppEmptyState(
              icon: Icons.history,
              title: 'هنوز سابقه‌ای ثبت نشده',
              subtitle: 'روی روزهای تقویم بزنید تا وضعیت ثبت شود',
            )
          else
            ...records.map((record) {
              final isPresent = record.isPresent;
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  leading: Icon(
                    isPresent ? Icons.check_circle : Icons.cancel,
                    color: isPresent ? AppColors.present : AppColors.absent,
                  ),
                  title: Text(formatJalaliLong(record.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppPill(
                        label: isPresent ? 'حاضر' : 'غایب',
                        color: isPresent ? AppColors.successSoft : AppColors.errorSoft,
                      ),
                      IconButton(
                        onPressed: () => _apply(record.date, ''),
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'حذف و بازگشت جلسه',
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
/// Shows the plan/bonus session position so the effect of marking attendance
/// (and undoing it) is visible immediately.
class _SessionSummaryCard extends StatelessWidget {
  final int? activePlanRemaining;
  final int? activePlanSessions;
  final int bonusSessions;
  final int queuedCount;
  final int recordedDays;

  const _SessionSummaryCard({
    required this.activePlanRemaining,
    required this.activePlanSessions,
    required this.bonusSessions,
    required this.queuedCount,
    required this.recordedDays,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlan = activePlanRemaining != null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('وضعیت جلسات', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'جلسات باقی‌مانده برنامه فعال',
            value: hasPlan
                ? '${toPersian(activePlanRemaining!.toString())} از ${toPersian(activePlanSessions.toString())}'
                : 'برنامه فعالی نیست',
            color: hasPlan ? AppColors.success : AppColors.onSurfaceVar,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'جلسات اضافه (هدیه)',
            value: toPersian(bonusSessions.toString()),
            color: bonusSessions > 0 ? AppColors.warning : AppColors.onSurfaceVar,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'برنامه‌های در صف',
            value: toPersian(queuedCount.toString()),
            color: queuedCount > 0 ? AppColors.queued : AppColors.onSurfaceVar,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'روزهای ثبت شده',
            value: toPersian(recordedDays.toString()),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.labelLarge.copyWith(color: color)),
      ],
    );
  }
}

