import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/providers/app_refresh.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/features/clients/providers/clients_providers.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) {
      _loadClient();
    }
  }

  Future<void> _loadClient() async {
    final client = await ref.read(clientsServiceProvider).getClient(widget.clientId!);
    if (client != null && mounted) {
      setState(() {
        _nameController.text = client.name;
        _contactController.text = client.contact ?? '';
        _noteController.text = client.note;
        _bonusController.text = client.bonusSessions.toString();
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام مشتری الزامی است')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final bonus = int.tryParse(_bonusController.text) ?? 0;
      if (widget.clientId == null) {
        await ref.read(clientsServiceProvider).createClient(
          _nameController.text.trim(),
          contact: _contactController.text.trim(),
          note: _noteController.text.trim(),
          bonusSessions: bonus,
        );
      } else {
        await ref.read(clientsServiceProvider).updateClient(
          widget.clientId!,
          _nameController.text.trim(),
          contact: _contactController.text.trim(),
          note: _noteController.text.trim(),
          bonusSessions: bonus,
        );
      }
      if (mounted) {
        // Refresh every data provider (client lists, dashboard aggregates, ...)
        // so the new/updated client is visible everywhere immediately.
        ref.invalidateAppData();
        if (Navigator.canPop(context)) Navigator.pop(context, true);
      }
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
        title: Text(widget.clientId == null ? 'افزودن مشتری' : 'ویرایش مشتری'),
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
                  decoration: const InputDecoration(labelText: 'نام *'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _contactController,
                  decoration: const InputDecoration(labelText: 'شماره تماس'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'یادداشت'),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _bonusController,
                  decoration: const InputDecoration(labelText: 'جلسات اضافه'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
    );
  }
}
