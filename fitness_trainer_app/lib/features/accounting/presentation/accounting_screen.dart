import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/utils/date_format.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';
import 'package:fitness_trainer_app/features/accounting/presentation/add_transaction_sheet.dart';
import 'package:fitness_trainer_app/features/accounting/providers/transactions_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/plans/data/plans_service.dart';
import 'package:fitness_trainer_app/features/plans/domain/client_plan.dart' as domain;
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

/// Fifth tab — the money ledger.
///
/// Straightforward append-only accounting: every income/expense is a row on the
/// local database. The header summarises income, expense, the gym's share
/// (deducted per plan, the plan's `sharePercent` of its `price`) and the
/// trainer's net balance.
class AccountingScreen extends ConsumerStatefulWidget {
  const AccountingScreen({super.key});

  @override
  ConsumerState<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends ConsumerState<AccountingScreen> {
  Future<void> _addTransaction() async {
    final s = AppStrings.of(context);
    final entry = await AppBottomSheet.show(
      context,
      const AddTransactionSheet(),
    );
    if (entry == null || !mounted) return;
    try {
      await ref.read(transactionServiceProvider).addTransaction(entry);
      ref.invalidateAppData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.transactionSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${s.errorPrefix}$e')));
    }
  }

  Future<void> _editTransaction(TransactionEntry tx) async {
    final s = AppStrings.of(context);
    final updated = await AppBottomSheet.show(
      context,
      AddTransactionSheet(initial: tx),
    );
    if (updated == null || !mounted) return;
    try {
      await ref.read(transactionServiceProvider).updateTransaction(updated);
      ref.invalidateAppData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.transactionUpdated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${s.errorPrefix}$e')));
    }
  }

  Future<void> _deleteTransaction(int id) async {
    final s = AppStrings.of(context);
    final confirmed = await AppConfirmDialog.show(
      context,
      title: s.deleteTransactionTitle,
      message: s.deleteTransactionMessage,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    if (!confirmed) return;
    try {
      await ref.read(transactionServiceProvider).deleteTransaction(id);
      ref.invalidateAppData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.transactionDeleted)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${s.errorPrefix}$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final lang = ref.watch(languageProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final clientNamesAsync = ref.watch(clientNamesProvider);
    final plansAsync = ref.watch(allPlansProvider);
    final templatesAsync = ref.watch(allTemplatesProvider);
    final plansService = ref.read(plansServiceProvider);

    final transactions = transactionsAsync.value ?? const [];
    var income = 0;
    var expense = 0;
    for (final tx in transactions) {
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    final pricedPlans = (plansAsync.value ?? const [])
        .where((p) => p.price > 0)
        .toList();
    final gymShare = pricedPlans.fold<int>(
      0,
      (sum, plan) => sum + plansService.planShareDeduction(plan),
    );
    final net = income - gymShare - expense;
    final clientNames = clientNamesAsync.value ?? const <int, String>{};
    final templateNames = {
      for (final template in templatesAsync.value ?? const []) template.id: template.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(s.navAccounting),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.reports),
            icon: const Icon(Icons.bar_chart_outlined),
            label: Text(s.openReports),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: s.addTransaction,
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidateAppData(),
        child: ListView(
          // Bottom padding clears the floating FAB so the last ledger row is
          // not hidden behind it.
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 88),
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.transactionsLabel, style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _SummaryTile(
                        label: s.totalIncome,
                        value: s.money(income),
                        color: t.present,
                      )),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _SummaryTile(
                        label: s.totalExpense,
                        value: s.money(expense),
                        color: t.absent,
                      )),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: _SummaryTile(
                        label: s.gymShareLabel,
                        value: s.money(gymShare),
                        color: t.onSurfaceVar,
                      )),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _SummaryTile(
                        label: s.netIncomeLabel,
                        value: s.money(net),
                        color: net >= 0 ? t.primary : t.error,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            if (pricedPlans.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              SectionHeader(title: s.perPlanShareTitle),
              for (final plan in pricedPlans)
                _PlanShareTile(
                  templateName: templateNames[plan.templateId] ?? '${s.addPlan} #${plan.templateId}',
                  clientName: clientNames[plan.clientId],
                  priceText: s.money(plan.price),
                  shareText: s.shareRate(plan.sharePercent),
                  deductionText: s.gymShareDeduction(plansService.planShareDeduction(plan)),
                  remainingText: planRemainingText(plansService, plan, s),
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            SectionHeader(title: s.transactionsLabel),
            if (transactionsAsync.isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (transactions.isEmpty)
              AppEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: s.noTransactionsTitle,
                subtitle: s.noTransactionsSubtitle,
              )
            else
              for (final tx in transactions)
                _TransactionTile(
                  tx: tx,
                  clientName: tx.clientId == null
                      ? null
                      : clientNames[tx.clientId],
                  categoryLabel: s.transactionCategory(tx.category),
                  dateText: formatDateShort(tx.date, lang),
                  amountText: s.money(tx.amount),
                  onEdit: () => _editTransaction(tx),
                  onDelete: () => _deleteTransaction(tx.id!),
                ),
          ],
        ),
      ),
    );
  }

  static String planRemainingText(
      PlansService plansService, domain.ClientPlan plan, AppStrings s) {
    final days = plansService.getRemainingDays(plan);
    return days == null ? '—' : s.remainingDays(days);
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: t.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.titleLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntry tx;
  final String? clientName;
  final String categoryLabel;
  final String dateText;
  final String amountText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.tx,
    required this.clientName,
    required this.categoryLabel,
    required this.dateText,
    required this.amountText,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final isIncome = tx.isIncome;
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            isIncome ? Icons.trending_up : Icons.trending_down,
            color: isIncome ? t.present : t.absent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(categoryLabel, style: AppTypography.labelLarge),
                const SizedBox(height: 2),
                Text(
                  [
                    dateText,
                    ?clientName,
                    if (tx.note.isNotEmpty) tx.note,
                  ].join(' · '),
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: AppTypography.titleLarge.copyWith(
              color: isIncome ? t.present : t.absent,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppStrings.of(context).edit,
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: t.error),
            tooltip: AppStrings.of(context).deleteTransactionTitle,
          ),
        ],
      ),
    );
  }
}

class _PlanShareTile extends StatelessWidget {
  final String templateName;
  final String? clientName;
  final String priceText;
  final String shareText;
  final String deductionText;
  final String remainingText;

  const _PlanShareTile({
    required this.templateName,
    required this.clientName,
    required this.priceText,
    required this.shareText,
    required this.deductionText,
    required this.remainingText,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.fitness_center, size: 20, color: t.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(templateName, style: AppTypography.labelLarge),
                const SizedBox(height: 2),
                Text(
                  [
                    priceText,
                    ?clientName,
                    remainingText,
                  ].join(' · '),
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(shareText, style: AppTypography.labelMedium.copyWith(color: t.onSurfaceVar)),
              const SizedBox(height: 2),
              Text(deductionText, style: AppTypography.labelLarge.copyWith(color: t.error)),
            ],
          ),
        ],
      ),
    );
  }
}