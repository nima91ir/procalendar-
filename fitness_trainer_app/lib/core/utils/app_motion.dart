import 'package:flutter/material.dart';

/// Motion durations that respect the platform's "reduce motion" setting.
///
/// Flutter honours `MediaQuery.disableAnimations` for some of its own built-ins,
/// but any animation we write has to check it itself. Someone who has asked the
/// OS to reduce motion — commonly for vestibular sensitivity — should get the
/// state change without the movement, not a slower version of it.
///
/// Durations are deliberately short. This app is used under time pressure, so
/// motion decorates a result that has already appeared rather than delaying it.
class AppMotion {
  const AppMotion._();

  /// A state change: a value updating, a chip selecting.
  static const Duration standard = Duration(milliseconds: 220);

  /// The duration to actually use — [Duration.zero] when motion is off, which
  /// makes the animation instant rather than merely faster.
  static Duration of(BuildContext context, [Duration duration = standard]) =>
      MediaQuery.of(context).disableAnimations ? Duration.zero : duration;

  /// Fade plus a small rise, for a value that has just changed.
  ///
  /// Transform and opacity only: both are cheap for the GPU, unlike animating
  /// layout, which is what makes list animations stutter on modest phones.
  static Widget valueChange(BuildContext context, Widget child, Key key) {
    return AnimatedSwitcher(
      duration: of(context),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.22),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      // The outgoing value is kept out of the semantics tree.
      //
      // The default layout stacks the previous child under the new one, so for
      // the length of the crossfade the tree holds *both* values — measured as
      // "۸۷ ۸۸" in the accessibility output, which a screen reader would then
      // read out twice. Only the current value should be announced.
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.center,
        children: [
          ...previousChildren.map((child) => ExcludeSemantics(child: child)),
          ?currentChild,
        ],
      ),
      child: KeyedSubtree(key: key, child: child),
    );
  }
}