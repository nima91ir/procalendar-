import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';
import 'package:fitness_trainer_app/core/utils/thousands_input_formatter.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/widgets/attendance_calendar.dart';
import 'package:fitness_trainer_app/features/templates/presentation/add_edit_template_screen.dart';
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
  final _priceController = TextEditingController();
  final _shareController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  /// Price entered as toman digits (commas ignored), 0 when empty/invalid.
  int get _price =>
      int.tryParse(toLatinDigits(_priceController.text.trim().replaceAll(',', ''))) ?? 0;

  /// Gym share percent entered, 0 when empty/invalid (clamped 0..100).
  int get _sharePercent =>
      (_shareController.text.trim().isEmpty ||
              int.tryParse(toLatinDigits(_shareController.text.trim())) == null
          ? 0
          : int.tryParse(toLatinDigits(_shareController.text.trim()))!)
      .clamp(0, 100);

  /// Approximate end date: start + (duration days - 1), e.g. a 30-day course
  /// starting 1403/01/01 ends 1403/01/30.
  String _endDateFor(int days) => addJalaliDays(_startDateKey, days > 0 ? days - 1 : 0);

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final templatesAsync = ref.watch(allTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.selectPlanTemplate)),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(message: e.toString()),
        data: (templates) {
          if (templates.isEmpty) {
            final s = AppStrings.of(context);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            t.primaryLight.withValues(alpha: 0.55),
                            t.surfaceVariant,
                          ],
                        ),
                      ),
                      child: Icon(Icons.fitness_center, size: 44, color: t.primaryDark),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(s.noTemplatesTitle, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddEditTemplateScreen()),
                        );
                        if (!mounted) return;
                        ref.invalidateAppData();
                        final fresh = await ref.read(allTemplatesProvider.future);
                        if (fresh.isNotEmpty) {
                          setState(() => _selectedTemplateId = fresh.last.id!);
                        }
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(s.addTemplate),
                    ),
                  ],
                ),
              ),
            );
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
                accentColor: isSelected ? t.primary : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(template.name, style: AppTypography.headlineMedium),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: t.primary),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        AppPill(label: s.sessionsCount(template.sessions), color: t.primaryLight),
                        const SizedBox(width: AppSpacing.sm),
                        AppPill(label: s.daysCount(template.days), color: t.surfaceVariant),
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
                          Icon(Icons.event_available, size: 16, color: t.onSurfaceVar),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              s.approximateEnd(formatJalali(_endDateFor(template.days))),
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PriceFields(
                        priceController: _priceController,
                        shareController: _shareController,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _confirmAndAssign(template),
                          child: Text(s.chooseThisTemplate),
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
    final s = AppStrings.of(context);
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
                    child: Text(s.chooseStartDate, style: AppTypography.headlineMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: AttendanceCalendar(
                      year: year,
                      month: month,
attendanceMap: const <String, List<String>>{},
            onDayTapped: (_) {},
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
                            child: Text(s.cancel),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(sheetContext, picked),
                            child: Text(s.confirmDate),
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
    final s = AppStrings.of(context);
    final t = context.tones;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.reviewStartDate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConfirmRow(label: s.planTemplateLabel, value: template.name),
              _ConfirmRow(label: s.startDateLabel, value: formatJalali(_startDateKey)),
              _ConfirmRow(label: s.endDateLabel, value: formatJalali(_endDateFor(template.days))),
              _ConfirmRow(
                label: s.sessionsLabel,
                value: s.isPersian ? toPersian(template.sessions.toString()) : '${template.sessions}',
              ),
              if (_price > 0) ...[
                _ConfirmRow(
                  label: s.planPriceLabel,
                  value: s.money(_price),
                ),
                _ConfirmRow(
                  label: s.planShareLabel,
                  value: s.shareRate(_sharePercent),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              if (hasCurrent) ...[
                Text(
                  s.queuedPlanWarning,
                  style: AppTypography.bodySmall.copyWith(color: t.warning),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                s.confirmStartDateMessage,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(s.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(s.yesSavePlan),
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
      price: _price,
      sharePercent: _sharePercent,
      startDate: _startDateKey,
    );
    if (mounted) {
      ref.invalidateAppData();
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(s.planAddedWithStart(formatJalali(_startDateKey)))),
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
    final t = context.tones;
    final s = AppStrings.of(context);
    return InkWell(
      onTap: onChange,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: t.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: t.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.event, color: t.today, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.startDateLabel, style: AppTypography.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    formatJalali(startDateKey),
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Text(s.change, style: AppTypography.labelMedium.copyWith(color: t.primary)),
          ],
        ),
      ),
    );
  }
}

class _PriceFields extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController shareController;

  const _PriceFields({
    required this.priceController,
    required this.shareController,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Column(
      children: [
        TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          inputFormatters: const [ThousandsSeparatorInputFormatter()],
          decoration: InputDecoration(
            labelText: s.planPriceLabel,
            helperText: s.planPriceHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: shareController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: s.planShareLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        ),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: t.onSurfaceVar)),
          Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
