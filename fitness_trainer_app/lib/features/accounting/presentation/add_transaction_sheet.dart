import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/widgets/attendance_calendar.dart';

/// Bottom sheet that collects the fields of one ledger entry and pops with a
/// [TransactionEntry] (id/createdAt left for the caller to fill). Pass
/// [initial] to edit an existing row — the fields prefill and the popped entry
/// carries the original id/createdAt so the caller can update in place.
class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key, this.initial});

  final TransactionEntry? initial;

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late String _type;
  late String _category;
  late String _date;
  late int? _clientId;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial?.type ?? TransactionTypes.income;
    final validCategories = initial == null
        ? null
        : (initial.isIncome
            ? TransactionCategories.income
            : TransactionCategories.expense);
    _category = (initial != null && validCategories!.contains(initial.category))
        ? initial.category
        : (initial?.isIncome == true ? TransactionCategories.plan : TransactionCategories.rent);
    _date = initial?.date ?? jalaliToday();
    _clientId = initial?.clientId;
    _amountController = TextEditingController(text: initial == null ? '' : '${initial.amount}');
    _noteController = TextEditingController(text: initial?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(String type) {
    setState(() {
      _type = type;
      _category = TransactionCategories.income.contains(type)
          ? TransactionCategories.plan
          : TransactionCategories.rent;
    });
  }

  Future<void> _pickDate() async {
    var year = int.parse(_date.split('/')[0]);
    var month = int.parse(_date.split('/')[1]);
    String? picked;
    await AppBottomSheet.show(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AttendanceCalendar(
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
                selectionKey: _date,
                onDaySelected: (key) => setSheetState(() => picked = key),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppStrings.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, picked),
                      child: Text(AppStrings.of(context).confirm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _date = picked!);
  }

  Future<void> _save() async {
    final amount =
        int.tryParse(toLatinDigits(_amountController.text.trim().replaceAll(',', '')));
    if (amount == null || amount <= 0) {
      final s = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${s.errorPrefix}${s.amountRequired}')),
      );
      return;
    }
    Navigator.pop(
      context,
      TransactionEntry(
        id: widget.initial?.id,
        createdAt: widget.initial?.createdAt ?? '',
        clientId: _clientId,
        type: _type,
        category: _category,
        amount: amount,
        date: _date,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final clientsAsync = ref.watch(allClientsProvider);
    final clients = clientsAsync.value;
    final isIncome = _type == TransactionTypes.income;
    final categories = isIncome
        ? TransactionCategories.income
        : TransactionCategories.expense;
    // A row may link a client that was deleted (legacy orphan). The dropdown
    // would assert on an initialValue that is not among its items, so fall
    // back to "no client" for display while keeping the stored link intact.
    final clientStillExists =
        _clientId != null && (clients ?? const []).any((c) => c.id == _clientId);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                widget.initial == null ? s.addTransaction : s.editTransaction,
                style: AppTypography.headlineMedium,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: TransactionTypes.income,
                icon: const Icon(Icons.trending_up),
                label: Text(s.incomeTypeLabel),
              ),
              ButtonSegment(
                value: TransactionTypes.expense,
                icon: const Icon(Icons.trending_down),
                label: Text(s.expenseTypeLabel),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (value) => _onTypeChanged(value.first),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: InputDecoration(
              labelText: s.categoryLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            items: [
              for (final category in categories)
                DropdownMenuItem(value: category, child: Text(s.transactionCategory(category))),
            ],
            onChanged: (value) => setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: s.amountLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: s.dateLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_date, style: AppTypography.bodyMedium),
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int?>(
            initialValue: clientStillExists ? _clientId : null,
            decoration: InputDecoration(
              labelText: s.clientOptionalLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(s.noClientSelected)),
              if (clients != null)
                for (final client in clients)
                  DropdownMenuItem<int?>(
                    value: client.id,
                    child: Text(client.name, overflow: TextOverflow.ellipsis),
                  ),
            ],
            onChanged: (value) => setState(() => _clientId = value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: s.note,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(widget.initial == null ? s.addTransaction : s.save),
          ),
        ],
      ),
    );
  }
}