import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/utils/persian_numbers.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/widgets/form_card_screen.dart';
import 'package:fitness_trainer_app/core/widgets/styled_text_field.dart';
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
    final s = AppStrings.of(context);
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.templateNameRequired)));
      return;
    }
    final sessions = int.tryParse(toLatinDigits(_sessionsController.text));
    final days = int.tryParse(toLatinDigits(_daysController.text));
    if (sessions == null || days == null || sessions <= 0 || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.templateInvalidNumbers)));
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (widget.templateId == null) {
        await ref.read(templatesServiceProvider).createTemplate(_nameController.text.trim(), sessions, days);
      } else {
        await ref.read(templatesServiceProvider).updateTemplate(widget.templateId!, _nameController.text.trim(), sessions, days);
      }
      if (mounted) {
        ref.invalidateAppData();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.errorPrefix}$e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return FormCardScreen(
      title: widget.templateId == null ? s.addTemplate : s.editTemplateTitle,
      onSave: _save,
      isLoading: _isLoading,
      children: [
        StyledTextField(
          label: s.templateNameLabel,
          controller: _nameController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        StyledTextField(
          label: s.templateSessionsLabel,
          controller: _sessionsController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        StyledTextField(
          label: s.templateDaysLabel,
          controller: _daysController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
