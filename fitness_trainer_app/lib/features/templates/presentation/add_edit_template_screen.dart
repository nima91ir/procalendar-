import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/features/templates/providers/templates_providers.dart';

class AddEditTemplateScreen extends ConsumerStatefulWidget {
  final int? templateId;
  const AddEditTemplateScreen({super.key, this.templateId});

  @override
  ConsumerState<AddEditTemplateScreen> createState() => _AddEditTemplateScreenState();
}

class _AddEditTemplateScreenState extends ConsumerState<AddEditTemplateScreen> {
  final _nameController = TextEditingController();
  final _sessionsController = TextEditingController();
  final _daysController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      _loadTemplate();
    }
  }

  Future<void> _loadTemplate() async {
    final template = await ref.read(templatesServiceProvider).getTemplate(widget.templateId!);
    if (template != null && mounted) {
      setState(() {
        _nameController.text = template.name;
        _sessionsController.text = template.sessions.toString();
        _daysController.text = template.days.toString();
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام قالب الزامی است')));
      return;
    }
    final sessions = int.tryParse(_sessionsController.text);
    final days = int.tryParse(_daysController.text);
    if (sessions == null || days == null || sessions <= 0 || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جلسات و روزها باید عدد صحیح و بزرگتر از صفر باشند')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (widget.templateId == null) {
        await ref.read(templatesServiceProvider).createTemplate(_nameController.text.trim(), sessions, days);
      } else {
        await ref.read(templatesServiceProvider).updateTemplate(widget.templateId!, _nameController.text.trim(), sessions, days);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templateId == null ? 'قالب جدید' : 'ویرایش قالب'),
        actions: [
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            TextButton(onPressed: _save, child: const Text('ذخیره')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'نام قالب *'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _sessionsController,
                  decoration: const InputDecoration(labelText: 'تعداد جلسات *'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _daysController,
                  decoration: const InputDecoration(labelText: 'تعداد روزها *'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
    );
  }
}
