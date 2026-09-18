import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/dev/demo_data.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/platform/file_transfer.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/backup/data/backup_service.dart';
import 'package:fitness_trainer_app/features/backup/providers/backup_providers.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.of(context).saved)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.of(context).errorPrefix}$e')));
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
      ref.invalidate(allClientsProvider);
      ref.invalidate(allTagsProvider);
      ref.invalidate(allTemplatesProvider);
      ref.invalidate(totalClientsProvider);
      ref.invalidate(lowSessionPlansProvider);
      ref.invalidate(bonusSessionClientsProvider);
      ref.invalidate(todayAttendanceProvider);
      ref.invalidate(clientNamesProvider);
      messenger.showSnackBar(SnackBar(content: Text(summary)));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text('${AppStrings.of(context).errorPrefix}$e')));
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
      messenger.showSnackBar(SnackBar(content: Text(s.backupSaved(saved ?? name))));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(s.backupFailed('$e'))));
    }
  }

  Future<void> _openCsvSheet() async {
    final s = AppStrings.of(context);
    final kind = await AppBottomSheet.show<_CsvKind>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
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
    final language = ref.watch(languageProvider);

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
                      : OutlinedButton.icon(
                          onPressed: _seedDemoData,
                          icon: const Icon(Icons.science_outlined),
                          label: Text(s.seedDemoData),
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

enum _CsvKind { clients, plans, attendance }