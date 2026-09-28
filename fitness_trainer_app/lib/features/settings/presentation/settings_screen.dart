import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/app_links.dart';
import 'package:fitness_trainer_app/core/dev/demo_data.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_theme_spec.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/platform/file_transfer.dart';
import 'package:fitness_trainer_app/core/platform/link_opener.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/core/widgets/ui_scale.dart';
import 'package:fitness_trainer_app/core/utils/date_format.dart';
import 'package:fitness_trainer_app/core/utils/jalali_calendar.dart';
import 'package:fitness_trainer_app/features/backup/data/backup_service.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_reminder.dart';
import 'package:fitness_trainer_app/features/backup/providers/backup_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/routing/routes.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _seeding = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final name = await ref.read(settingsServiceProvider).getTrainerName();
    if (name != null && mounted) {
      setState(() => _nameController.text = name);
    }
  }

  Future<void> _saveTrainerName() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(settingsServiceProvider).setTrainerName(_nameController.text.trim());
      if (mounted) {
        ref.invalidateAppData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.of(context).saved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.of(context).errorText(e))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Debug-only: fills the database with a realistic sample so the dashboard,
  /// plans, queue and attendance can be tested without manual entry.
  Future<void> _seedDemoData() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _seeding = true);
    try {
      final summary = await ref.read(demoDataServiceProvider).seed();
      if (!mounted) return;
      // The whole graph, not a hand-picked list. The list this replaced had
      // already gone stale: `dataHealthProvider` (the stored-record counts) was
      // not in it, so Settings went on reporting 0 clients while four sat in the
      // list — exactly the wrong signal from the line that exists to be trusted.
      // Anything new added to `app_refresh.dart` would have hit the same trap.
      ref.invalidateAppData();
      if (mounted) _loadSettings();
      messenger.showSnackBar(SnackBar(content: Text(summary)));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(AppStrings.of(context).errorText(e))));
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  /// Debug-only: rebuilds the database as roughly a year of real use (120
  /// clients, ~10k attendance records) so the app can be judged against a
  /// realistic amount of data instead of four clients.
  ///
  /// DESTRUCTIVE — it clears the data tables first, so it confirms up front.
  /// `app_settings` is deliberately left alone, so the chosen language and
  /// theme survive the rebuild.
  Future<void> _seedLargeDemoData() async {
    final s = AppStrings.of(context);
    final confirmed = await AppConfirmDialog.show(
      context,
      title: s.replaceConfirmTitle,
      message: s.seedLargeDemoDataConfirm,
      confirmLabel: s.replaceData,
      cancelLabel: s.cancel,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _seeding = true);
    try {
      final summary = await ref.read(demoDataServiceProvider).seedLarge();
      if (!mounted) return;
      // Everything changed, so refresh the whole data graph rather than
      // listing providers one by one.
      ref.invalidateAppData();
      _loadSettings();
      messenger.showSnackBar(SnackBar(content: Text(summary)));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(AppStrings.of(context).errorText(e))));
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  Future<void> _exportJson() async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(backupServiceProvider).exportJson();
      final name = 'procalendar-backup-${BackupService.timestampSuffix()}.json';
      final saved = await saveTextFile(name, json);
      // Remember when this happened so the dashboard reminder can go quiet.
      // Only on a non-null result: the IO implementation returns null when the
      // save was cancelled, and recording that would silence the nudge without
      // a backup actually existing.
      if (saved != null) {
        await ref.read(settingsServiceProvider).setLastBackupDate(jalaliToday());
        ref.invalidate(backupReminderProvider);
      }
      messenger.showSnackBar(SnackBar(content: Text(s.backupSaved(saved ?? name))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(s.backupFailed('$e'))));
    }
  }

  /// Where the slider is being dragged to, while the drag is in progress.
  ///
  /// Non-null only during a drag. The display size itself is applied on release,
  /// so this is what the percentage label follows in the meantime — the live
  /// feedback, without the control moving under the finger.
  double? _uiScaleDrag;

  /// Back to the default display size, persisted like any other change.
  Future<void> _resetUiScale() async {
    setState(() => _uiScaleDrag = null);
    final notifier = ref.read(uiScaleProvider.notifier);
    notifier.preview(kUiScaleDefault);
    await notifier.persist();
  }

  /// Opens the support channel — or copies the address when there is nothing to
  /// open it with, which is the case on native builds. A tap that does nothing
  /// at all is the one outcome worth avoiding.
  Future<void> _openSupport() async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (await openExternalLink(supportTelegramUrl)) return;
    await Clipboard.setData(const ClipboardData(text: supportTelegramUrl));
    messenger.showSnackBar(SnackBar(content: Text(s.contactLinkCopied)));
  }

  Future<void> _openCsvSheet() async {
    final s = AppStrings.of(context);
    final kind = await AppBottomSheet.show<_CsvKind>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Shown at the moment the user reaches for CSV, which is the one place
          // they are most likely to mistake a spreadsheet for a backup. The CSV
          // exports cannot be imported back, so say so before they choose.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: context.tones.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    s.csvNotBackupNote,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.tones.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text(s.csvClients),
            onTap: () => Navigator.of(context).pop(_CsvKind.clients),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(s.csvPlans),
            onTap: () => Navigator.of(context).pop(_CsvKind.plans),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(s.csvAttendance),
            onTap: () => Navigator.of(context).pop(_CsvKind.attendance),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(s.csvTransactions),
            onTap: () => Navigator.of(context).pop(_CsvKind.transactions),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
    if (kind == null || !mounted) return;
    await _exportCsv(kind);
  }

  Future<void> _exportCsv(_CsvKind kind) async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final suffix = BackupService.timestampSuffix();
    try {
      final service = ref.read(backupServiceProvider);
      final (contents, name) = switch (kind) {
        _CsvKind.clients => (
            await service.exportClientsCsv(),
            'procalendar-clients-$suffix.csv',
          ),
        _CsvKind.plans => (
            await service.exportPlansCsv(),
            'procalendar-plans-$suffix.csv',
          ),
        _CsvKind.attendance => (
            await service.exportAttendanceCsv(),
            'procalendar-attendance-$suffix.csv',
          ),
        _CsvKind.transactions => (
            await service.exportTransactionsCsv(),
            'procalendar-transactions-$suffix.csv',
          ),
      };
      final saved = await saveTextFile(name, contents);
      messenger.showSnackBar(SnackBar(content: Text(s.backupSaved(saved ?? name))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(s.backupFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final uiScale = ref.watch(uiScaleProvider);
    final language = ref.watch(languageProvider);
    final tones = context.tones;
    // Shown next to the backup buttons so the state is visible where the user
    // would act on it, whether or not the dashboard banner was dismissed.
    final lastBackup = ref.watch(backupReminderProvider).value?.lastBackup;
    final dataHealth = ref.watch(dataHealthProvider).value;
    final backupDays = BackupReminder.daysSince(lastBackup, jalaliToday());
    final backupOverdue =
        backupDays != null && backupDays >= BackupReminder.intervalDays;
    final lastBackupText = lastBackup == null
        ? s.lastBackupNever
        : backupDays == null
            ? formatDateShort(lastBackup, language)
            : '${formatDateShort(lastBackup, language)} · ${s.daysAgo(backupDays)}';

    return Scaffold(
      appBar: AppBar(title: Text(s.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionHeader(title: s.trainerInfo),
          AppCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: s.trainerNameLabel),
                ),
                const SizedBox(height: AppSpacing.md),
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                    : ElevatedButton.icon(
                        onPressed: _saveTrainerName,
                        icon: const Icon(Icons.save),
                        label: Text(s.saveName),
                      ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: s.appearance),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.themeLabel, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final theme in AppThemes.all)
                      _ThemeChoice(
                        theme: theme,
                        // Each theme carries its own name in both languages, so
                        // adding one is a single entry in `AppThemes.all` and
                        // never a trip through the localisation file.
                        label: ref.watch(languageProvider) == 'fa'
                            ? theme.nameFa
                            : theme.nameEn,
                        selected: theme.id == ref.watch(themeProvider).id,
                        onTap: () => ref.read(themeProvider.notifier).setTheme(theme),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: ThemeMode.system, label: Text(s.themeSystem), icon: const Icon(Icons.brightness_auto)),
                    ButtonSegment(value: ThemeMode.light, label: Text(s.themeLight), icon: const Icon(Icons.light_mode_outlined)),
                    ButtonSegment(value: ThemeMode.dark, label: Text(s.themeDark), icon: const Icon(Icons.dark_mode_outlined)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    ref.read(themeModeProvider.notifier).setThemeMode(selection.first);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(s.uiScaleLabel, style: AppTypography.bodySmall),
                    ),
                    Text(
                      s.uiScalePercent(((_uiScaleDrag ?? uiScale) * 100).round()),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tones.onSurface,
                      ),
                    ),
                    if (_uiScaleDrag != null || uiScale != kUiScaleDefault)
                      TextButton(
                        onPressed: _resetUiScale,
                        child: Text(s.uiScaleReset),
                      ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.text_decrease, size: 18),
                    Expanded(
                      child: Slider(
                        value: _uiScaleDrag ?? uiScale,
                        min: kUiScaleMin,
                        max: kUiScaleMax,
                        // Applied on RELEASE, deliberately. Resizing the app
                        // live resizes this very slider — measured: dragging it
                        // grew it 1.24x and pushed it 118px down the page — so
                        // the control slid out from under the finger and the
                        // value could not be fine-tuned. The percentage above is
                        // the live feedback instead.
                        onChanged: (value) =>
                            setState(() => _uiScaleDrag = value),
                        onChangeEnd: (value) async {
                          final notifier = ref.read(uiScaleProvider.notifier);
                          notifier.preview(value);
                          await notifier.persist();
                          if (mounted) setState(() => _uiScaleDrag = null);
                        },
                      ),
                    ),
                    const Icon(Icons.text_increase, size: 18),
                  ],
                ),
                Text(
                  s.uiScaleHint,
                  style: AppTypography.caption.copyWith(color: tones.onSurfaceVar),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: s.languageLabel),
          AppCard(
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'fa', label: Text(s.languageFa)),
                ButtonSegment(value: 'en', label: Text(s.languageEn)),
              ],
              selected: {language},
              onSelectionChanged: (selection) {
                ref.read(languageProvider.notifier).setLanguage(selection.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: s.navTags),
          AppCard(
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(s.manageTags),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.pushNamed(context, AppRoutes.tags),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: s.backupSection),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.lastBackupLabel, style: AppTypography.bodySmall),
                    Flexible(
                      child: Text(
                        lastBackupText,
                        textAlign: TextAlign.end,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: backupOverdue ? tones.warning : tones.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // What the database actually holds, right beside the buttons that
                // protect it. When a live user's storage was wiped the app still
                // looked perfectly normal and nobody could tell whether the
                // zeros were real; this is the number that answers that.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.dataHealthLabel, style: AppTypography.bodySmall),
                    Flexible(
                      child: Text(
                        dataHealth == null
                            ? '—'
                            : s.dataHealthCounts(
                                dataHealth.clients,
                                dataHealth.plans,
                                dataHealth.attendance,
                              ),
                        textAlign: TextAlign.end,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tones.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(s.backupDescription, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: _exportJson,
                  icon: const Icon(Icons.save_alt),
                  label: Text(s.exportBackupJson),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.importBackup),
                  icon: const Icon(Icons.upload_file),
                  label: Text(s.importBackupJson),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _openCsvSheet,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: Text(s.exportCsv),
                ),
              ],
            ),
          ),
          // Hidden while the channel handle is unset rather than pointing users
          // at a link that does not exist. See core/app_links.dart.
          if (supportTelegramUrl.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(title: s.contactSection),
            AppCard(
              padding: EdgeInsets.zero,
              child: Material(
                type: MaterialType.transparency,
                child: ListTile(
                  leading: const Icon(Icons.support_agent_outlined),
                  title: Text(s.contactTelegramTitle),
                  subtitle: Text(s.contactTelegramSubtitle),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: _openSupport,
                ),
              ),
            ),
          ],
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(title: s.devTools),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.devToolsDescription,
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _seeding
                      ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                      : Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _seedDemoData,
                              icon: const Icon(Icons.science_outlined),
                              label: Text(s.seedDemoData),
                            ),
                            OutlinedButton.icon(
                              onPressed: _seedLargeDemoData,
                              icon: const Icon(Icons.dataset_outlined),
                              label: Text(s.seedLargeDemoData),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _CsvKind { clients, plans, attendance, transactions }

/// One theme in the picker.
///
/// The swatch shows the theme's own background and accent — its light palette,
/// never the one currently active — so every option previews itself. Colour
/// alone is not the only signal: the selected one also carries a check mark, so
/// the choice is not conveyed by colour alone.
class _ThemeChoice extends StatelessWidget {
  final AppThemeSpec theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final p = theme.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? t.primaryDark : t.outline,
                  width: selected ? 3 : 1,
                ),
              ),
              child: Center(
                child: selected
                    ? Icon(Icons.check, size: 20, color: p.onSurface)
                    : Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: p.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.labelMedium),
          ],
        ),
      ),
    );
  }
}