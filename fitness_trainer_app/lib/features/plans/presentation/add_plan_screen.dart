import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_colors.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/widgets/attendance_calendar.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';

class AddPlanScreen extends ConsumerStatefulWidget {
  final int clientId;
  const AddPlanScreen({super.key, required this.clientId});

  @override
  ConsumerState<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends ConsumerState<AddPlanScreen> {
  int? _selectedTemplateId;
  /// Jalali `yyyy/MM/dd` start date, defaulting to today.
  String _startDateKey = jalaliToday();
  /// Month currently displayed by the picker sheet.
  int _pickerYear = Jalali.fromDateTime(DateTime.now()).year;
  int _pickerMonth = Jalali.fromDateTime(DateTime.now()).month;

  /// Approximate end date: start + (duration days - 1), e.g. a 30-day course
  /// starting 1403/01/01 ends 1403/01/30.
  String _endDateFor(int days) => addJalaliDays(_startDateKey, days > 0 ? days - 1 : 0);

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(allTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('انتخاب قالب برنامه')),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (templates) {
          if (templates.isEmpty) {
            return const AppEmptyState(icon: Icons.fitness_center, title: 'قالبی تعریف نشده');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final isSelected = _selectedTemplateId == template.id;
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                onTap: () => setState(() => _selectedTemplateId = template.id),
                accentColor: isSelected ? AppColors.primary : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(template.name, style: AppTypography.headlineMedium),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        AppPill(label: '${toPersian(template.sessions.toString())} جلسه', color: AppColors.primaryLight),
                        const SizedBox(width: AppSpacing.sm),
                        AppPill(label: '${toPersian(template.days.toString())} روز', color: AppColors.surfaceVariant),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: AppSpacing.md),
                      _StartDateTile(
                        startDateKey: _startDateKey,
                        onChange: _pickStartDate,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.event_available, size: 16, color: AppColors.onSurfaceVar),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'پایان تقریبی دوره: ${formatJalali(_endDateFor(template.days))}',
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _confirmAndAssign(template),
                          child: const Text('انتخاب این قالب'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Bottom-sheet Jalali date picker (the calendar doubles as a picker).
  Future<void> _pickStartDate() async {
    var picked = _startDateKey;
    var year = _pickerYear;
    var month = _pickerMonth;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text('انتخاب تاریخ شروع', style: AppTypography.headlineMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: AttendanceCalendar(
                      year: year,
                      month: month,
                      attendanceMap: const {},
                      onDayChanged: (_, _) {},
                      onPreviousMonth: () => setSheetState(() {
                        month--;
                        if (month < 1) {
                          month = 12;
                          year--;
                        }
                      }),
                      onNextMonth: () => setSheetState(() {
                        month++;
                        if (month > 12) {
                          month = 1;
                          year++;
                        }
                      }),
                      todayKey: jalaliToday(),
                      selectionKey: picked,
                      onDaySelected: (key) => setSheetState(() => picked = key),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('انصراف'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(sheetContext, picked),
                            child: const Text('تأیید تاریخ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result == null) return;
    final parts = result.split('/');
    if (parts.length != 3) return;
    setState(() {
      _startDateKey = result;
      _pickerYear = int.parse(parts[0]);
      _pickerMonth = int.parse(parts[1]);
    });
  }

  /// Asks the user to double-check the start date before creating the plan.
  Future<void> _confirmAndAssign(dynamic template) async {
    final plans = await ref.read(clientPlansProvider(widget.clientId).future);
    if (!mounted) return;
    final hasCurrent = plans.any((p) => p.isActive || p.isFrozen);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('بررسی تاریخ شروع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConfirmRow(label: 'قالب', value: template.name),
              _ConfirmRow(label: 'تاریخ شروع', value: formatJalali(_startDateKey)),
              _ConfirmRow(label: 'تاریخ پایان', value: formatJalali(_endDateFor(template.days))),
              _ConfirmRow(label: 'تعداد جلسات', value: toPersian(template.sessions.toString())),
              const SizedBox(height: AppSpacing.sm),
              if (hasCurrent) ...[
                Text(
                  'این مشتری برنامه فعال دارد؛ برنامه جدید «در صف» ثبت می‌شود و تاریخ شروع آن هنگام فعال شدن به‌روز می‌شود.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                'مطمئنید تاریخ شروع را درست انتخاب کرده‌اید؟',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('بله، ثبت شود'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final navigator = Navigator.of(context);
    await ref.read(plansServiceProvider).assignPlan(
      widget.clientId,
      template.id,
      template.sessions,
      template.days,
      startDate: _startDateKey,
    );
    if (mounted) {
      ref.invalidateAppData();
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('برنامه اضافه شد (شروع: ${formatJalali(_startDateKey)})')),
      );
    }
  }
}

/// Tappable start-date row; opens the Jalali picker sheet.
class _StartDateTile extends StatelessWidget {
  final String startDateKey;
  final VoidCallback onChange;

  const _StartDateTile({required this.startDateKey, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChange,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.event, color: AppColors.today, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تاریخ شروع', style: AppTypography.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    formatJalali(startDateKey),
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Text('تغییر', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVar)),
          Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
