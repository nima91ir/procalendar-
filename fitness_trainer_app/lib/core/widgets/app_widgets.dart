import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_tones.dart';
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
    final t = context.tones;
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.lg);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: t.primaryLight,
        highlightColor: t.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          margin: margin,
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: t.outlineVariant),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF1F2A1E).withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Padding(
            padding: effectivePadding,
            child: child,
          ),
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
    final t = context.tones;
    final bg = isSelected ? (color ?? t.primary) : t.surfaceVariant;
    final fg = isSelected ? t.onPrimary : t.onSurface;
    final border = isSelected ? BorderSide.none : BorderSide(color: t.outline);
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
    final t = context.tones;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    t.primaryLight.withValues(alpha: 0.55),
                    t.surfaceVariant,
                  ],
                ),
              ),
              child: Icon(icon, size: 44, color: t.primaryDark),
            ),
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
    final t = context.tones;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: t.error),
              const SizedBox(height: AppSpacing.lg),
              Text(message, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(onPressed: onRetry, child: Text(AppStrings.of(context).retryLabel)),
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
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
  }) async {
    final s = AppStrings.of(context);
    final confirm = confirmLabel ?? s.confirm;
    final cancel = cancelLabel ?? s.cancel;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(cancel)),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(confirm)),
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
    final t = context.tones;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        // Lift the sheet above the on-screen keyboard. `isScrollControlled`
        // only raises the height cap; it does not move the sheet, so without
        // this the submit button of every sheet sat behind the keyboard.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Material(
          color: t.surface,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
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
    final t = context.tones;
    return RawChip(
      label: Text(label, style: AppTypography.labelMedium),
      backgroundColor: color ?? t.primaryLight,
      labelStyle: TextStyle(color: t.onSurface),
      onDeleted: onRemove,
      deleteIconColor: t.onSurfaceVar,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
    );
  }
}

/// Gradient hero surface used at the top of primary screens.
///
/// Ensures on-gradient text contrast by deriving the foreground color from the
/// gradient's relative luminance instead of hardcoding it.
class AppHeroHeader extends StatelessWidget {
  final Widget child;
  final List<Color>? gradient;
  final EdgeInsetsGeometry padding;

  const AppHeroHeader({
    super.key,
    required this.child,
    this.gradient,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? context.tones.gradientPrimary;
    final luminance = colors.last.computeLuminance();
    final onGradient = luminance > 0.5 ? AppColors.onSurface : Colors.white;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: onGradient),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
