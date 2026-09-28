import 'package:flutter/material.dart';

/// Bounds and default for the global display size.
///
/// The range is deliberately narrow. Below [kUiScaleMin] the 44px touch targets
/// this app deliberately adopted start shrinking back towards the sizes that
/// were hard to hit; above [kUiScaleMax] the fixed-height widgets (calendar day
/// cells, avatar tiles) begin to clip.
const double kUiScaleMin = 0.7;
const double kUiScaleDefault = 1.0;
const double kUiScaleMax = 1.3;

/// Parses a stored display size, falling back to the default for anything
/// missing, unreadable, or out of range — a value written by a newer build must
/// never be able to leave the app unreadable or unusable.
double parseUiScale(String? stored) {
  final value = double.tryParse(stored ?? '');
  if (value == null) return kUiScaleDefault;
  return value.clamp(kUiScaleMin, kUiScaleMax);
}

/// Draws [child] at [scale], so every screen shrinks or grows together.
///
/// This is the only way to resize *everything* — text, padding and controls —
/// without rewriting every `AppSpacing`/`AppTypography` constant in the app. The
/// content is laid out on a larger logical canvas (`size / scale`) and then drawn
/// at [scale], exactly like browser zoom.
///
/// Insets are divided by the same factor, so the keyboard and the system bars
/// still take up the same *physical* space; without that they would appear to
/// grow as the content shrank.
///
/// Hit testing needs no special handling: `Transform` maps pointer positions
/// through the inverse transform, so taps land where they look.
class UiScale extends StatelessWidget {
  const UiScale({super.key, required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The common case. Skipping the extra layout pass and the transform keeps
    // the default path exactly as it was before this existed.
    if (scale == kUiScaleDefault) return child;

    final media = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final logical = Size(
          constraints.maxWidth / scale,
          constraints.maxHeight / scale,
        );
        // WIDGET ORDER MATTERS HERE, and getting it wrong breaks hit testing
        // rather than looks.
        //
        // Every render box rejects a position outside its own `size`, so the box
        // whose child is the oversized canvas must be sized by its parent alone.
        // `Transform` is the exception: it maps the position through the inverse
        // transform and then hit-tests the child, with no size check of its own.
        // So the constraints are relaxed *above* the Transform, and the
        // logical-sized box is the Transform's direct child.
        //
        // With the OverflowBox below the Transform instead, its own box was only
        // the physical size, so the bottom `1 - scale` of every screen was dead:
        // taps were rejected before reaching the app, and the bottom navigation
        // bar became unclickable.
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Transform.scale(
              scale: scale,
              // Physical, not directional: the scaled box is exactly the
              // physical size, so anchoring to `topLeft` fills the screen.
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: logical.width,
                height: logical.height,
                child: MediaQuery(
                  data: media.copyWith(
                    size: logical,
                    padding: media.padding / scale,
                    viewPadding: media.viewPadding / scale,
                    viewInsets: media.viewInsets / scale,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
