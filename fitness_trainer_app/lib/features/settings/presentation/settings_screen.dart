import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';
import 'package:fitness_trainer_app/features/settings/providers/settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
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
            child: SwitchListTile(
              title: const Text('حالت شب'),
              subtitle: const Text('پوسته تیره'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
              },
            ),
          ),
        ],
      ),
    );
  }
}
