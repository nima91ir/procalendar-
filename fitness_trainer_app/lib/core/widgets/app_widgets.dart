import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_tokens.dart';

class AppCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? accentColor;

  const AppCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.lg);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTypography.headlineMedium),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class AppPill extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;

  const AppPill({
    super.key,
    required this.label,
    this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? (color ?? AppColors.primary) : AppColors.surfaceVariant;
    final fg = isSelected ? Colors.white : AppColors.onSurface;
    final border = isSelected ? BorderSide.none : const BorderSide(color: AppColors.outline);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        border: Border.fromBorderSide(border),
      ),
      child: Text(label, style: AppTypography.labelMedium.copyWith(color: fg)),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.outline),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle!, style: AppTypography.bodySmall, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.lg),
              Text(message, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(onPressed: onRetry, child: const Text('تلاش مجدد')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String? cancelLabel;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (cancelLabel != null)
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(cancelLabel!)),
        ElevatedButton(onPressed: () { onConfirm(); Navigator.of(context).pop(); }, child: Text(confirmLabel)),
      ],
    );
  }

  static Future<bool> show(BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'تایید',
    String? cancelLabel = 'لغو',
    VoidCallback? onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (cancelLabel != null)
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(cancelLabel)),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(confirmLabel)),
        ],
      ),
    );
    // Previously this helper discarded the dialog result and always
    // reported "not confirmed", so every caller got `null`/false.
    if (result == true) {
      onConfirm?.call();
      return true;
    }
    return false;
  }
}

class AppBottomSheet {
  static Future<T?> show<T>(BuildContext context, Widget child) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}

class MiniTag extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onRemove;

  const MiniTag({
    super.key,
    required this.label,
    this.color,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return RawChip(
      label: Text(label, style: AppTypography.labelMedium),
      backgroundColor: color ?? AppColors.primaryLight,
      labelStyle: TextStyle(color: AppColors.onSurface),
      onDeleted: onRemove,
      deleteIconColor: AppColors.onSurfaceVar,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
    );
  }
}
