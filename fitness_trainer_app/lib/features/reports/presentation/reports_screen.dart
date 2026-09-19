import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/widgets/app_charts.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/accounting/domain/transaction_entry.dart';
import 'package:fitness_trainer_app/features/accounting/providers/transactions_providers.dart';
import 'package:fitness_trainer_app/features/reports/data/reports_service.dart';
import 'package:fitness_trainer_app/features/reports/domain/report_models.dart';
import 'package:fitness_trainer_app/features/reports/providers/reports_providers.dart';

enum _ReportPeriod { weekly, monthly, yearly }

/// Income/expense drill-down: period totals (weekly / monthly / yearly) plus a
/// Jalali monthly income chart and a 7-day trend.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _ReportPeriod _period = _ReportPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final transactionsAsync = ref.watch(transactionsProvider);
    final service = ref.watch(reportsServiceProvider);
    final transactions = transactionsAsync.value ?? const <TransactionEntry>[];

    return Scaffold(
      appBar: AppBar(title: Text(s.reportsTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(transactionsProvider),
        child: transactions.isEmpty
            ? AppEmptyState(
                icon: Icons.bar_chart_outlined,
                title: s.noReportsTitle,
                subtitle: s.noReportsSubtitle,
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  SegmentedButton<_ReportPeriod>(
                    segments: [
                      ButtonSegment(
                        value: _ReportPeriod.weekly,
                        label: Text(s.weeklyLabel),
                      ),
                      ButtonSegment(
                        value: _ReportPeriod.monthly,
                        label: Text(s.monthlyLabel),
                      ),
                      ButtonSegment(
                        value: _ReportPeriod.yearly,
                        label: Text(s.yearlyLabel),
                      ),
                    ],
                    selected: {_period},
                    onSelectionChanged: (value) =>
                        setState(() => _period = value.first),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _periodTitle(s),
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(child: _ReportTile(
                              label: s.totalIncome,
                              value: s.money(_periodTotals(service, transactions).income),
                              color: t.present,
                            )),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _ReportTile(
                              label: s.totalExpense,
                              value: s.money(_periodTotals(service, transactions).expense),
                              color: t.absent,
                            )),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ReportTile(
                          label: s.balanceLabel,
                          value: s.money(_periodTotals(service, transactions).balance),
                          color: t.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.monthlyChartTitle, style: AppTypography.titleLarge),
                        const SizedBox(height: AppSpacing.md),
                        AppMiniBarChart(
                          data: [
                            for (final bucket in service.monthlyBuckets(transactions))
                              BarDatum(
                                label: _monthLabel(s, bucket),
                                value: bucket.income.toDouble(),
                                highlighted: bucket.isCurrent,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.weeklyChartTitle, style: AppTypography.titleLarge),
                        const SizedBox(height: AppSpacing.md),
                        AppLineChart(
                          points: [
                            for (final bucket in service.dailyBuckets(transactions))
                              ChartPoint(
                                label: _dayLabel(s, bucket),
                                value: bucket.income.toDouble(),
                                highlight: bucket.isCurrent,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  PeriodTotals _periodTotals(ReportsService service, List<TransactionEntry> transactions) {
    final now = Jalali.fromDateTime(DateTime.now());
    final todayKey = jalaliToday();
    switch (_period) {
      case _ReportPeriod.weekly:
        final buckets = service.dailyBuckets(transactions);
        return PeriodTotals(
          buckets.fold<int>(0, (sum, b) => sum + b.income),
          buckets.fold<int>(0, (sum, b) => sum + b.expense),
        );
      case _ReportPeriod.monthly:
        final start = '${now.year}/${now.month.toString().padLeft(2, '0')}/01';
        return service.totalsBetween(transactions, startKey: start, endKey: todayKey);
      case _ReportPeriod.yearly:
        return service.totalsBetween(
          transactions,
          startKey: '${now.year}/01/01',
          endKey: todayKey,
        );
    }
  }

  String _periodTitle(AppStrings s) {
    switch (_period) {
      case _ReportPeriod.weekly:
        return s.weeklyLabel;
      case _ReportPeriod.monthly:
        return s.monthlyLabel;
      case _ReportPeriod.yearly:
        return s.yearlyLabel;
    }
  }

  String _monthLabel(AppStrings s, JalaliBucket bucket) {
    final parts = bucket.key.split('/');
    return s.monthShort(int.parse(parts[1]));
  }

  String _dayLabel(AppStrings s, JalaliBucket bucket) {
    final parts = bucket.key.split('/');
    final weekday = Jalali(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    ).weekDay;
    return s.weekdayShort(weekday);
  }
}

class _ReportTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ReportTile({required this.label, required this.value, required this.color});

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