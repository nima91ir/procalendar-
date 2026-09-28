import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/utils/app_motion.dart';
import 'package:fitness_trainer_app/core/utils/date_format.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/attendance/domain/attendance_record.dart';
import 'package:fitness_trainer_app/features/attendance/presentation/widgets/attendance_calendar.dart';
import 'package:fitness_trainer_app/features/attendance/providers/attendance_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/plans/providers/plans_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

/// Attendance history + marking screen for a single client.
///
/// A client can have several attendance records per day (past or today).
/// Adding a record consumes a session from the active plan (or a bonus
/// session when the plan has none left); deleting a record refunds it, so
/// this screen is also where the plan/session bookkeeping can be verified.
class PastAttendanceScreen extends ConsumerStatefulWidget {
  final int clientId;
  final int? planId;
  const PastAttendanceScreen({super.key, required this.clientId, this.planId});

  @override
  ConsumerState<PastAttendanceScreen> createState() => _PastAttendanceScreenState();
}

class _PastAttendanceScreenState extends ConsumerState<PastAttendanceScreen> {
  late int _year;
  late int _month;

  /// Set once the user pages the calendar themselves, so a load that lands
  /// afterwards cannot move the month out from under them.
  bool _monthChosenByUser = false;

  @override
  void initState() {
    super.initState();
    final now = Jalali.fromDateTime(DateTime.now());
    _year = now.year;
    _month = now.month;
    // An expired plan's sessions are history, usually months old, so opening on
    // the current month shows an empty calendar. Active and queued plans are the
    // ones the client is on now, and that is where marking happens — they keep
    // today.
    if (widget.planId != null) _startOnExpiredPlanHistory();
  }

  /// Moves the calendar to the newest record's month, for an expired plan only.
  ///
  /// Runs after the first frame because it awaits providers; until it resolves
  /// the calendar sits on today, which is a harmless default rather than a
  /// wrong one.
  Future<void> _startOnExpiredPlanHistory() async {
    try {
      final plan = await ref.read(plansServiceProvider).getPlan(widget.planId!);
      if (plan == null || plan.status != 'expired') return;

      final records = await ref.read(planAttendanceProvider(widget.planId!).future);
      if (!mounted || _monthChosenByUser || records.isEmpty) return;

      // Newest: reviewing a finished plan usually means seeing how it ended.
      final newest = records
          .map((r) => r.date)
          .reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
      final parts = newest.split('/');
      if (parts.length != 3) return;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year == null || month == null) return;

      setState(() {
        _year = year;
        _month = month;
      });
    } catch (_) {
      // Leave the calendar on today rather than failing the screen.
    }
  }

  void _shiftMonth(int delta) {
    setState(() {
      // Once the user has paged, the month is theirs: a late-arriving load must
      // not jump them somewhere else.
      _monthChosenByUser = true;
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

  String _localizedDate(String date, AppStrings s, String lang) => formatDateLong(date, lang);

  /// Adds a present/absent record for the client; shows success/error via
  /// snackbar (errors are also stored on [attendanceProvider] for the progress
  /// indicator listeners).
  Future<void> _addRecord(String status, {String? date}) async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final day = date ?? jalaliToday();
    final lang = ref.read(languageProvider);
    try {
      await ref.read(attendanceProvider.notifier).addSession(widget.clientId, day, status: status);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.recordAdded(status == 'present' ? s.present : s.absent, _localizedDate(day, s, lang)))));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.errorText(e))));
    }
  }

  /// Deletes exactly the tapped record (by id) and refunds its session.
  Future<void> _deleteRecord(AttendanceRecord record) async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final lang = ref.read(languageProvider);
    final confirmed = await AppConfirmDialog.show(
      context,
      title: s.deleteSession,
      message: s.deleteSessionMessage,
      confirmLabel: s.delete,
      cancelLabel: s.cancel,
    );
    if (!confirmed) return;
    try {
      final refund = await ref.read(attendanceProvider.notifier).removeSessionById(record.id!);
      if (!mounted) return;
      // Says where the session went — it can be restored as a bonus session,
      // or refunded nowhere at all. Staying silent there is what made removals
      // look like they were mixing attendance and bonus sessions up.
      messenger.showSnackBar(SnackBar(
        content: Text(s.sessionRemovalMessage(refund, _localizedDate(record.date, s, lang))),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.errorText(e))));
    }
  }

  void _openDaySheet(String date) {
    final s = AppStrings.of(context);
    final lang = ref.read(languageProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DayAttendanceSheet(
        clientId: widget.clientId,
        planId: widget.planId,
        date: date,
        dateLabel: _localizedDate(date, s, lang),
        s: s,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final s = AppStrings.of(context);
    final lang = ref.watch(languageProvider);
    final attendanceMapAsync = widget.planId != null
        ? ref.watch(planAttendanceMapProvider(widget.planId!))
        : ref.watch(clientAttendanceMapProvider(widget.clientId));
    final recordsAsync = widget.planId != null
        ? ref.watch(planAttendanceProvider(widget.planId!))
        : ref.watch(clientAttendanceProvider(widget.clientId));
    final plansAsync = ref.watch(clientPlansProvider(widget.clientId));
    final clientsAsync = ref.watch(allClientsProvider);
    final busy = ref.watch(attendanceProvider).isLoading;

    final client = clientsAsync.value?.where((c) => c.id == widget.clientId).firstOrNull;
    final plans = plansAsync.value;
    final activePlan = plans?.where((p) => p.isActive).firstOrNull;
    final queuedCount = plans?.where((p) => p.isQueued).length ?? 0;
    final bonusSessions = client?.bonusSessions ?? 0;
    final attendanceMap = attendanceMapAsync.value ?? const <String, List<String>>{};
    final records = recordsAsync.value ?? const <AttendanceRecord>[];

    final groupedRecords = <String, List<AttendanceRecord>>{};
    for (final record in records) {
      groupedRecords.putIfAbsent(record.date, () => []).add(record);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(client?.name ?? s.appTitle),
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
            s: s,
            activePlanRemaining: activePlan?.remaining,
            activePlanSessions: activePlan?.sessions,
            bonusSessions: bonusSessions,
            queuedCount: queuedCount,
            recordedCount: records.length,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: s.quickAddToday),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addRecord('present'),
                  icon: const Icon(Icons.add),
                  label: Text('${s.present} +'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addRecord('absent'),
                  icon: const Icon(Icons.add),
                  label: Text('${s.absent} +'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AttendanceCalendar(
            year: _year,
            month: _month,
            attendanceMap: attendanceMap,
            onDayTapped: _openDaySheet,
            onPreviousMonth: () => _shiftMonth(-1),
            onNextMonth: () => _shiftMonth(1),
            todayKey: jalaliToday(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: s.attendanceHistory),
          if (records.isEmpty)
            AppEmptyState(
              icon: Icons.history,
              title: s.noHistoryYet,
              subtitle: s.noHistorySubtitle,
            )
          else
            ...groupedRecords.entries.map((entry) {
              final dateRecords = entry.value;
              final date = entry.key;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Text(formatDateLong(date, lang), style: AppTypography.bodyMedium),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: t.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            s.isPersian
                                ? toPersian(dateRecords.length.toString())
                                : dateRecords.length.toString(),
                            style: AppTypography.labelMedium.copyWith(color: t.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...dateRecords.map((record) {
                    final isPresent = record.isPresent;
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm, right: AppSpacing.lg),
                      child: ListTile(
                        leading: Icon(
                          isPresent ? Icons.check_circle : Icons.cancel,
                          color: isPresent ? t.present : t.absent,
                        ),
                        title: Text(isPresent ? s.present : s.absent),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppPill(
                              label: isPresent ? s.present : s.absent,
                              color: isPresent ? t.successSoft : t.errorSoft,
                            ),
                            IconButton(
                              onPressed: () => _deleteRecord(record),
                              icon: Icon(Icons.delete_outline, color: t.error),
                              tooltip: s.deleteSession,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
        ],
      ),
    );
  }
}

/// Bottom sheet for a single day: shows that day's records and lets the user
/// add another present/absent record or delete an existing one.
class _DayAttendanceSheet extends ConsumerWidget {
  final int clientId;
  final int? planId;
  final String date;
  final String dateLabel;
  final AppStrings s;

  const _DayAttendanceSheet({
    required this.clientId,
    required this.planId,
    required this.date,
    required this.dateLabel,
    required this.s,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tones;
    final recordsAsync = planId != null
        ? ref.watch(planAttendanceProvider(planId!))
        : ref.watch(clientAttendanceProvider(clientId));
    final records = recordsAsync.value ?? const <AttendanceRecord>[];
    final dayRecords = records.where((r) => r.date == date).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(dateLabel, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref.read(attendanceProvider.notifier).addSession(clientId, date, status: 'present');
                        if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(s.recordAdded(s.present, dateLabel))));
                      } catch (e) {
                        if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(s.errorText(e))));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text('${s.present} +'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref.read(attendanceProvider.notifier).addSession(clientId, date, status: 'absent');
                        if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(s.recordAdded(s.absent, dateLabel))));
                      } catch (e) {
                        if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(s.errorText(e))));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text('${s.absent} +'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (dayRecords.isEmpty)
              AppEmptyState(icon: Icons.event_busy, title: s.noHistoryYet)
            else
              ...dayRecords.map((record) {
                final isPresent = record.isPresent;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: Icon(
                      isPresent ? Icons.check_circle : Icons.cancel,
                      color: isPresent ? t.present : t.absent,
                    ),
                    title: Text(isPresent ? s.present : s.absent),
                    trailing: IconButton(
                      onPressed: () async {
                        // Removing a record refunds a plan or bonus session, so
                        // it must be confirmed here as well. This sheet is the
                        // one opened to *add* records, and its delete button
                        // sits directly under the add buttons.
                        final confirmed = await AppConfirmDialog.show(
                          context,
                          title: s.deleteSession,
                          message: s.deleteSessionMessage,
                          confirmLabel: s.delete,
                          cancelLabel: s.cancel,
                        );
                        if (!confirmed || !context.mounted) return;
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final refund = await ref.read(attendanceProvider.notifier).removeSessionById(record.id!);
                          if (!context.mounted) return;
                          messenger.showSnackBar(
                            SnackBar(content: Text(s.sessionRemovalMessage(refund, dateLabel))),
                          );
                        } catch (e) {
                          if (context.mounted) messenger.showSnackBar(SnackBar(content: Text(s.errorText(e))));
                        }
                      },
                      icon: Icon(Icons.delete_outline, color: t.error),
                      tooltip: s.deleteSession,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Shows the plan/bonus session position so the effect of marking attendance
/// (and removing it) is visible immediately.
class _SessionSummaryCard extends StatelessWidget {
  final AppStrings s;
  final int? activePlanRemaining;
  final int? activePlanSessions;
  final int bonusSessions;
  final int queuedCount;
  final int recordedCount;

  const _SessionSummaryCard({
    required this.s,
    required this.activePlanRemaining,
    required this.activePlanSessions,
    required this.bonusSessions,
    required this.queuedCount,
    required this.recordedCount,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final hasPlan = activePlanRemaining != null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.sessionStatusTitle, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: s.activePlanRemainingLabel,
            value: hasPlan
                ? s.remainingDetail(activePlanRemaining!, activePlanSessions!)
                : s.noActivePlanLabel,
            color: hasPlan ? t.success : t.onSurfaceVar,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: s.bonusSessions,
            value: s.isPersian ? toPersian(bonusSessions.toString()) : '$bonusSessions',
            color: bonusSessions > 0 ? t.warning : t.onSurfaceVar,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: s.queuedPlansLabel,
            value: s.isPersian ? toPersian(queuedCount.toString()) : '$queuedCount',
            color: queuedCount > 0 ? t.queued : t.onSurfaceVar,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: s.recordedSessionsLabel,
            value: s.isPersian ? toPersian(recordedCount.toString()) : '$recordedCount',
            color: t.primary,
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
        // The value eases in when it changes, so marking a session draws the eye
        // to the number that moved. It cannot delay anything: the figure is
        // already the new one, and the animation runs on top of it. Instant when
        // the platform asks for reduced motion.
        AppMotion.valueChange(
          context,
          Text(value, style: AppTypography.labelLarge.copyWith(color: color)),
          ValueKey(value),
        ),
      ],
    );
  }
}