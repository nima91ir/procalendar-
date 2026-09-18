import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/platform/file_transfer.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/backup/domain/backup_models.dart';
import 'package:fitness_trainer_app/features/backup/providers/backup_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

class ImportBackupScreen extends ConsumerStatefulWidget {
  const ImportBackupScreen({super.key});

  @override
  ConsumerState<ImportBackupScreen> createState() => _ImportBackupScreenState();
}

class _ImportBackupScreenState extends ConsumerState<ImportBackupScreen> {
  final _controller = TextEditingController();
  BackupCounts? _counts;
  bool _invalid = false;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recount(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      setState(() {
        _counts = null;
        _invalid = false;
      });
      return;
    }
    try {
      final counts = ref.read(backupServiceProvider).previewCounts(text);
      setState(() {
        _counts = counts;
        _invalid = false;
      });
    } catch (_) {
      setState(() {
        _counts = null;
        _invalid = true;
      });
    }
  }

  Future<void> _chooseFile() async {
    final content = await pickTextFile();
    if (content == null || !mounted) return;
    _controller.text = content;
    _recount(content);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;
    _controller.text = text;
    _recount(text);
  }

  Future<void> _apply(BackupImportMode mode) async {
    final s = AppStrings.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final raw = _controller.text.trim();

    if (raw.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(s.noBackupContent)));
      return;
    }

    if (mode == BackupImportMode.replace) {
      final ok = await AppConfirmDialog.show(
        context,
        title: s.replaceConfirmTitle,
        message: s.replaceConfirmMessage,
        confirmLabel: s.replaceData,
        cancelLabel: s.cancel,
      );
      if (!ok || !mounted) return;
    }

    setState(() => _busy = true);
    try {
      final result = await ref
          .read(backupServiceProvider)
          .importJson(raw, mode: mode);
      ref.invalidateAppData();
      ref.invalidate(trainerNameProvider);
      ref.invalidate(themeModeProvider);
      ref.invalidate(languageProvider);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(s.importDone(result.added.total))));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(s.importFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final t = context.tones;
    final canApply = !_busy && _counts != null;

    return Scaffold(
      appBar: AppBar(title: Text(s.importTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.importHint, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  minLines: 6,
                  maxLines: 12,
                  onChanged: _recount,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                if (_invalid) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(s.importInvalid, style: AppTypography.bodySmall.copyWith(color: t.error)),
                ],
                if (_counts != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    s.importSummary(_counts!.clients, _counts!.plans, _counts!.attendance),
                    style: AppTypography.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (isFilePickerSupported)
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _chooseFile,
                        icon: const Icon(Icons.folder_open),
                        label: Text(s.chooseFile),
                      ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _pasteFromClipboard,
                      icon: const Icon(Icons.content_paste),
                      label: Text(s.pasteFromClipboard),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.mergeHint, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: canApply ? () => _apply(BackupImportMode.merge) : null,
                  icon: const Icon(Icons.merge_type),
                  label: Text(s.mergeData),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(s.replaceWarning, style: AppTypography.bodySmall.copyWith(color: t.error)),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: canApply ? () => _apply(BackupImportMode.replace) : null,
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: Text(s.replaceData),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
