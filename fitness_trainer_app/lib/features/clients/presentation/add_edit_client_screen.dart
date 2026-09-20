import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/form_card_screen.dart';
import 'package:fitness_trainer_app/core/widgets/styled_text_field.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';
import 'package:fitness_trainer_app/features/tags/domain/tag.dart' as domain;
import 'package:fitness_trainer_app/features/tags/providers/tags_providers.dart';
import 'package:fitness_trainer_app/features/tags/presentation/widgets/client_tag_picker.dart';

class AddEditClientScreen extends ConsumerStatefulWidget {
  final int? clientId;
  const AddEditClientScreen({super.key, this.clientId});

  @override
  ConsumerState<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends ConsumerState<AddEditClientScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _noteController = TextEditingController();
  final _bonusController = TextEditingController();
  bool _isLoading = false;
  final Set<int> _selectedTagIds = {};
  Set<int> _originalTagIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) {
      _loadClient();
    }
  }

  Future<void> _loadClient() async {
    final client = await ref.read(clientsServiceProvider).getClient(widget.clientId!);
    final tagIds = await ref.read(tagsServiceProvider).getClientTagIds(widget.clientId!);
    if (client != null && mounted) {
      setState(() {
        _nameController.text = client.name;
        _contactController.text = client.contact ?? '';
        _noteController.text = client.note;
        _bonusController.text = client.bonusSessions.toString();
        _originalTagIds = tagIds.toSet();
        _selectedTagIds
          ..clear()
          ..addAll(tagIds);
      });
    }
  }

  Future<void> _pickTags() async {
    final selected = await showClientTagPicker(context, ref, _selectedTagIds);
    if (selected != null && mounted) {
      setState(() {
        _selectedTagIds
          ..clear()
          ..addAll(selected);
      });
    }
  }

  Future<void> _save() async {
    final s = AppStrings.of(context);
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.clientNameRequired)));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final bonus = int.tryParse(_bonusController.text) ?? 0;
      final tagsService = ref.read(tagsServiceProvider);
      if (widget.clientId == null) {
        final newId = await ref.read(clientsServiceProvider).createClient(
          _nameController.text.trim(),
          contact: _contactController.text.trim(),
          note: _noteController.text.trim(),
          bonusSessions: bonus,
        );
        for (final tagId in _selectedTagIds) {
          await tagsService.assignTagToClient(newId, tagId);
        }
      } else {
        await ref.read(clientsServiceProvider).updateClient(
          widget.clientId!,
          _nameController.text.trim(),
          contact: _contactController.text.trim(),
          note: _noteController.text.trim(),
          bonusSessions: bonus,
        );
        for (final tagId in _selectedTagIds.difference(_originalTagIds)) {
          await tagsService.assignTagToClient(widget.clientId!, tagId);
        }
        for (final tagId in _originalTagIds.difference(_selectedTagIds)) {
          await tagsService.removeTagFromClient(widget.clientId!, tagId);
        }
      }
      if (mounted) {
        ref.invalidateAppData();
        if (Navigator.canPop(context)) Navigator.pop(context, true);
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
    final tags = ref.watch(allTagsProvider).value ?? const <domain.Tag>[];
    return FormCardScreen(
      title: widget.clientId == null ? s.addClient : s.editClient,
      onSave: _save,
      isLoading: _isLoading,
      children: [
        StyledTextField(
          label: s.clientNameLabel,
          controller: _nameController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        StyledTextField(
          label: s.contactLabel,
          controller: _contactController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.lg),
        StyledTextField(
          label: s.note,
          controller: _noteController,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.lg),
        StyledTextField(
          label: s.bonusSessionsLabel,
          controller: _bonusController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(s.tagsSection, style: Theme.of(context).textTheme.titleSmall),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final tag in tags)
              if (_selectedTagIds.contains(tag.id))
                Chip(
                  label: Text(tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name),
                  onDeleted: () => setState(() => _selectedTagIds.remove(tag.id)),
                ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(s.addTag),
              onPressed: _pickTags,
            ),
          ],
        ),
      ],
    );
  }
}
