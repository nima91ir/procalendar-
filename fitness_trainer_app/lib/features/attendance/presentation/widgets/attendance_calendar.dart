import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';

/// Interactive Jalali month grid used to mark attendance.
///
/// [attendanceMap] maps a Jalali `yyyy/MM/dd` key to the list of recorded
/// statuses for that day — a client can have more than one record per day.
/// Tapping a day reports the `yyyy/MM/dd` key through [onDayTapped] so the
/// caller can open a day sheet (add/delete records) instead of cycling a
/// single status.
class AttendanceCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Map<String, List<String>> attendanceMap;
  final void Function(String date) onDayTapped;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final String? todayKey;

  /// When non-null, the calendar acts as a **date picker**: tapping a day
  /// reports the `yyyy/MM/dd` key through [onDaySelected] instead of opening
  /// the attendance sheet, and [selectionKey] is drawn as the picked day.
  final void Function(String dateKey)? onDaySelected;
  final String? selectionKey;

  const AttendanceCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.attendanceMap,
    required this.onDayTapped,
    this.onPreviousMonth,
    this.onNextMonth,
    this.todayKey,
    this.onDaySelected,
    this.selectionKey,
  });

  /// Jalali `yyyy/MM/dd` key used by the database and by [attendanceMap].
  static String dateKey(int year, int month, int day) =>
      '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';

  /// Month change for a horizontal swipe over the grid.
  ///
  /// The direction is mirrored for RTL so that swiping "forward" always
  /// advances the month, exactly like tapping the forward chevron: in LTR that
  /// is a left swipe, in RTL a right swipe. Short drags (below the velocity
  /// threshold) are ignored so a stray touch cannot jump a month.
  void _onSwipe(BuildContext context, DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 200) return;
    final forward = Directionality.of(context) == TextDirection.rtl ? velocity > 0 : velocity < 0;
    if (forward) {
      onNextMonth?.call();
    } else {
      onPreviousMonth?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final firstOfMonth = Jalali(year, month, 1);
    final daysInMonth = firstOfMonth.monthLength;
    final firstDayWeekDay = firstOfMonth.weekDay - 1;
    final weeks = ((daysInMonth + firstDayWeekDay) / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: t.outlineVariant),
      ),
      // A horizontal swipe over the grid changes the month, mirroring the
      // chevrons above it. Vertical drags are left to the surrounding scroll
      // view, so the calendar never fights a scrolling list.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (onPreviousMonth == null && onNextMonth == null)
            ? null
            : (details) => _onSwipe(context, details),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: s.prevMonth,
                ),
                Expanded(
                  child: Text(
                    '${s.monthShort(month)} ${s.isPersian ? toPersian(year.toString()) : year}',
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: s.nextMonth,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: List.generate(7, (i) => s.weekdayShort(i + 1).substring(0, 1))
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
                  final statuses = attendanceMap[key] ?? const <String>[];
                  return Expanded(
                    child: _DayCell(
                      day: dayIndex,
                      statuses: statuses,
                      isToday: key == todayKey,
                      isPicked: onDaySelected != null && key == selectionKey,
                      onTap: () {
                        final pick = onDaySelected;
                        if (pick != null) {
                          pick(key);
                        } else {
                          onDayTapped(key);
                        }
                      },
                    ),
                  );
                }),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            // Legend is attendance-specific; the picker mode shows its own
            // confirm controls below the grid.
            if (onDaySelected == null)
              Row(
                children: [
                  _LegendDot(color: t.today, label: s.todayLabel),
                  const SizedBox(width: AppSpacing.md),
                  _LegendDot(color: t.present, label: s.present),
                  const SizedBox(width: AppSpacing.md),
                  _LegendDot(color: t.absent, label: s.absent),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final List<String> statuses;
  final bool isToday;
  final bool isPicked;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.statuses,
    required this.isToday,
    required this.isPicked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final presentCount = statuses.where((s) => s == 'present').length;
    final absentCount = statuses.length - presentCount;
    // A day can hold several records. Letting "any present" paint the whole
    // cell green showed a day holding an absence *and* an attendance as fully
    // present — the exact case the multi-record model exists for. Mixed days
    // use the warning pair (contrast-safe in both themes) rather than a
    // status colour, so they can never be read as all-present or all-absent.
    final isMixed = presentCount > 0 && absentCount > 0;
    final isPresent = presentCount > 0 && absentCount == 0;
    final isAbsent = presentCount == 0 && absentCount > 0;
    final selected = isPresent || isAbsent || isMixed;
    final count = statuses.length;
    final color = isMixed
        ? t.warningSoft
        : isPresent
            ? t.present
            : isAbsent
                ? t.absent
                : isPicked
                    ? t.primaryLight
                    : t.surfaceVariant;
    // The status fills are saturated (white ink), the warning fill is pale
    // (warning ink), so the foreground cannot be a single constant.
    final fg = isMixed
        ? t.warning
        : selected
            ? Colors.white
            : isToday
                ? t.todayInk
                : t.onSurface;
    // Today always shows in orange: filled when unmarked, and an orange ring
    // around the present/absent colour when attendance is already recorded.
    final borderColor = isPicked
        ? t.primary
        : isToday
            ? t.today
            : isMixed
                ? t.warning
                : selected
                    ? color
                    : t.outlineVariant;
    final ringWidth = isToday || isPicked ? 2.0 : 1.0;

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
            border: Border.all(color: borderColor, width: ringWidth),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                toPersian(day.toString()),
                style: AppTypography.bodySmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (selected && count > 1)
                Text(
                  '×${toPersian(count.toString())}',
                  style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700),
                )
              else if (isPresent)
                Icon(Icons.check, size: 12, color: fg)
              else if (isAbsent)
                Icon(Icons.close, size: 12, color: fg)
              else if (isToday)
                Icon(Icons.circle, size: 6, color: t.today)
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