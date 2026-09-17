import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';

/// Interactive Jalali month grid used to mark attendance.
///
/// [attendanceMap] is keyed by a Jalali `yyyy/MM/dd` string. Tapping a day
/// cycles the status `unmarked -> present -> absent -> unmarked` and reports
/// the *new* status through [onDayChanged]; an empty string means "unmarked",
/// i.e. the caller should delete the record.
class AttendanceCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, String> attendanceMap;
  final void Function(String date, String status) onDayChanged;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const AttendanceCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.attendanceMap,
    required this.onDayChanged,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  /// Jalali `yyyy/MM/dd` key used by the database and by [attendanceMap].
  static String dateKey(int year, int month, int day) =>
      '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';

  /// Next status in the tap cycle. Returns '' for "unmarked".
  static String nextStatus(String? current) {
    if (current == null || current.isEmpty) return 'present';
    if (current == 'present') return 'absent';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = Jalali(year, month, 1);
    final daysInMonth = firstOfMonth.monthLength;
    final firstDayWeekDay = firstOfMonth.weekDay % 7;
    final weeks = ((daysInMonth + firstDayWeekDay) / 7).ceil();

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
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'ماه قبل',
              ),
              Expanded(
                child: Text(
                  '${monthNames[month - 1]} ${toPersian(year.toString())}',
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'ماه بعد',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
                .map((d) => Expanded(child: Center(child: Text(d, style: AppTypography.labelMedium))))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ...List.generate(weeks, (week) {
            return Row(
              children: List.generate(7, (dayOfWeek) {
                final dayIndex = week * 7 + dayOfWeek - firstDayWeekDay + 1;
                if (dayIndex < 1 || dayIndex > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 48));
                }
                final key = AttendanceCalendar.dateKey(year, month, dayIndex);
                final status = attendanceMap[key];
                return Expanded(
                  child: _DayCell(
                    day: dayIndex,
                    status: status,
                    onTap: () => onDayChanged(key, AttendanceCalendar.nextStatus(status)),
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const _LegendDot(color: AppColors.present, label: 'حاضر'),
              const SizedBox(width: AppSpacing.md),
              const _LegendDot(color: AppColors.absent, label: 'غایب'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final String? status;
  final VoidCallback onTap;

  const _DayCell({required this.day, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPresent = status == 'present';
    final isAbsent = status == 'absent';
    final selected = isPresent || isAbsent;
    final color = isPresent
        ? AppColors.present
        : isAbsent
            ? AppColors.absent
            : AppColors.surfaceVariant;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: selected ? color : AppColors.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                toPersian(day.toString()),
                style: AppTypography.bodySmall.copyWith(
                  color: selected ? Colors.white : AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isPresent)
                const Icon(Icons.check, size: 12, color: Colors.white)
              else if (isAbsent)
                const Icon(Icons.close, size: 12, color: Colors.white)
              else
                const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}
