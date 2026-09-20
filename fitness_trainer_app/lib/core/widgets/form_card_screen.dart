import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/widgets/app_widgets.dart';

class FormCardScreen extends ConsumerWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;
  final bool isLoading;
  final String? saveLabel;

  const FormCardScreen({
    super.key,
    required this.title,
    required this.children,
    this.onSave,
    this.isLoading = false,
    this.saveLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tones;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTypography.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...children,
              if (onSave != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: isLoading ? null : onSave,
                  child: isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: t.onSurface))
                      : Text(saveLabel ?? AppStrings.of(context).save),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
