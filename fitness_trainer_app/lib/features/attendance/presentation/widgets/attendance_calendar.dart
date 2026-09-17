import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';

class AttendanceCalendar extends StatelessWidget {
  final Map<String, String> attendanceMap;
  final void Function(String date, String status) onDayTap;

  const AttendanceCalendar({
    super.key,
    required this.attendanceMap,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final j = Jalali.fromDateTime(now);
    final daysInMonth = j.monthLength;
    final firstDayWeekDay = j.weekDay % 7;
    const monthNames = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${monthNames[j.month - 1]} ${j.year}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
              .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
              ).toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate((daysInMonth + firstDayWeekDay) ~/ 7 + 1, (week) {
          return Row(
            children: List.generate(7, (dayOfWeek) {
              final dayIndex = week * 7 + dayOfWeek - firstDayWeekDay + 1;
              if (dayIndex < 1 || dayIndex > daysInMonth) return const Expanded(child: SizedBox());
              final dateStr = '${j.year}/${j.month.toString().padLeft(2, '0')}/${dayIndex.toString().padLeft(2, '0')}';
              final status = attendanceMap[dateStr];
              final color = status == 'present' ? AppColors.present : status == 'absent' ? AppColors.absent : null;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (status == null) {
                      onDayTap(dateStr, 'present');
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    height: 36,
                    decoration: BoxDecoration(
                      color: color ?? AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(child: Text('$dayIndex', style: const TextStyle(fontSize: 12))),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
