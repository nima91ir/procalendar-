import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/dev/demo_data.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/dashboard/providers/dashboard_providers.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';

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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ذخیره شد')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
    } finally {
      setState(() => _isLoading = false);
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
      ref.invalidate(attendanceByDateProvider);
      ref.invalidate(clientNamesProvider);
      messenger.showSnackBar(SnackBar(content: Text(summary)));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text('خطا در درج داده نمونه: $e')));
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionHeader(title: 'اطلاعات مربی'),
          AppCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'نام مربی'),
                ),
                const SizedBox(height: AppSpacing.md),
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                    : ElevatedButton.icon(
                        onPressed: _saveTrainerName,
                        icon: const Icon(Icons.save),
                        label: const Text('ذخیره نام'),
                      ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(title: 'ظاهر برنامه'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('پوسته برنامه', style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('سیستم'), icon: Icon(Icons.brightness_auto)),
                    ButtonSegment(value: ThemeMode.light, label: Text('روشن'), icon: Icon(Icons.light_mode_outlined)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('تیره'), icon: Icon(Icons.dark_mode_outlined)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    ref.read(themeModeProvider.notifier).setThemeMode(selection.first);
                  },
                ),
              ],
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(title: 'ابزار توسعه'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'چند مشتری، قالب، برچسب و دو هفته حضور و غیاب نمونه اضافه می‌کند تا داشبورد، برنامه‌ها و مصرف جلسات قابل بررسی باشد.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _seeding
                      ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                      : OutlinedButton.icon(
                          onPressed: _seedDemoData,
                          icon: const Icon(Icons.science_outlined),
                          label: const Text('درج داده نمونه'),
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
