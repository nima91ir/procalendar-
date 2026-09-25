import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_trainer_app/core/l10n/app_strings.dart';
import 'package:fitness_trainer_app/core/platform/build_info.dart';
import 'package:fitness_trainer_app/core/providers/app_update.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import 'package:fitness_trainer_app/core/theme/app_tokens.dart';
import 'package:fitness_trainer_app/core/theme/app_typography.dart';

/// Tells the user that a newer build has been published.
///
/// The web service worker does replace the app on its own, but only when the
/// page is loaded again — a tab left open keeps running the old code, so a user
/// could be sitting on a stale version for days with no way to tell. This
/// compares the build this page is running with the one the site is serving.
///
/// Reloading is deliberately a tap, not automatic: a silent reload would throw
/// away a half-filled form.
///
/// It renders nothing unless [pendingUpdateProvider] says an update exists, so
/// it is invisible in a local `flutter run` (no build id injected) and on
/// native, where the check is a no-op.
class AppUpdateBanner extends ConsumerStatefulWidget {
  const AppUpdateBanner({super.key});

  @override
  ConsumerState<AppUpdateBanner> createState() => _AppUpdateBannerState();
}

class _AppUpdateBannerState extends ConsumerState<AppUpdateBanner> {
  /// Dismissed for this session only. Nothing needs persisting: reloading the
  /// page loads the new build, so the banner then stops appearing by itself.
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    // `.value` keeps this silent while loading, and a failed check simply hides
    // the banner — a version notice must never block the app.
    final pending = ref.watch(pendingUpdateProvider).value ?? false;
    if (!pending || _dismissed) return const SizedBox.shrink();

    final s = AppStrings.of(context);
    final t = context.tones;

    return Material(
      color: t.primaryLight,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            // `onSurface` rather than the accent's own `primaryDark`: that pair
            // is only ~2.4:1 against `primaryLight`, which is not readable.
            Icon(Icons.system_update_alt_rounded, size: 20, color: t.onSurface),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                s.updateAvailable,
                style: AppTypography.bodySmall.copyWith(
                  color: t.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: reloadApp,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                minimumSize: const Size(0, 40),
              ),
              child: Text(s.updateReload),
            ),
            IconButton(
              onPressed: () => setState(() => _dismissed = true),
              icon: Icon(Icons.close, size: 18, color: t.onSurface),
              tooltip: s.updateLater,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
