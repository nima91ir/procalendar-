import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_trainer_app/core/widgets/ui_scale.dart';

/// The display-size slider resizes every screen at once, so the two things worth
/// pinning are that a stored value can never make the app unusable, and that the
/// child really is laid out on a larger canvas.
void main() {
  group('parseUiScale', () {
    test('falls back to the default for missing or unreadable values', () {
      expect(parseUiScale(null), kUiScaleDefault);
      expect(parseUiScale(''), kUiScaleDefault);
      expect(parseUiScale('not-a-number'), kUiScaleDefault);
    });

    test('clamps to the supported range', () {
      // A value written by a newer build, or a corrupted row, must not be able
      // to leave the app unreadably small or clipped.
      expect(parseUiScale('0.1'), kUiScaleMin);
      expect(parseUiScale('9'), kUiScaleMax);
    });

    test('keeps a value inside the range', () {
      expect(parseUiScale('0.85'), 0.85);
      expect(parseUiScale('1'), kUiScaleDefault);
    });
  });

  /// Renders [scale] inside a fixed 400x800 box and reports the size the child
  /// is actually laid out in.
  ///
  /// The constraints are captured through a `LayoutBuilder`, not read from the
  /// `MediaQuery` this widget sets itself — asserting the value we just wrote
  /// would pass even if the child never received a larger canvas, which is
  /// exactly the bug that shipped first time round.
  Future<Size> logicalSizeFor(WidgetTester tester, double scale) async {
    // The default test surface is 800x600, which would clamp the 800-tall box
    // below and quietly change the constraints being asserted on.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Size? got;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Center(
            child: SizedBox(
              width: 400,
              height: 800,
              child: UiScale(
                scale: scale,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    got = constraints.biggest;
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return got!;
  }

  testWidgets('lays the child out on a larger canvas when shrunk', (
    tester,
  ) async {
    final got = await logicalSizeFor(tester, 0.8);

    // 400 / 0.8 and 800 / 0.8 — the constraints the child really receives, not
    // just a MediaQuery value. This is the assertion that would have caught the
    // first implementation, where the child was clamped to the physical size and
    // the whole app was painted smaller into a corner.
    expect(got.width, closeTo(500, 0.01));
    expect(got.height, closeTo(1000, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaves the child alone at the default scale', (tester) async {
    final got = await logicalSizeFor(tester, kUiScaleDefault);

    // The default path skips the transform and the extra layout pass entirely,
    // so it is exactly what the app did before the slider existed.
    expect(got, const Size(400, 800));
  });

  testWidgets('a control at the bottom of the canvas is still tappable', (
    tester,
  ) async {
    // Regression guard for a real bug: with the constraint relaxation placed
    // *below* the transform, the box hosting the oversized canvas was only the
    // physical size — so every tap in the bottom `1 - scale` of the screen was
    // rejected before reaching the app, and the bottom navigation bar became
    // unclickable. Layout looked perfect; only hit testing was broken, which is
    // why the layout assertions above did not catch it.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var tapped = false;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: UiScale(
            scale: 0.8,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () => tapped = true,
                      child: const Text('bottom'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // `tap` hit-tests through the real pipeline at the widget's transformed
    // position, which is exactly the path that was broken.
    await tester.tap(find.text('bottom'), warnIfMissed: false);
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('divides insets by the same factor', (tester) async {
    // Otherwise the on-screen keyboard would appear to grow as the content
    // shrank, swallowing more of the screen than it should.
    const keyboard = 300.0;
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    double? inset;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: Center(
            child: SizedBox(
              width: 400,
              height: 800,
              child: UiScale(
                scale: 0.6,
                child: Builder(
                  builder: (context) {
                    inset = MediaQuery.of(context).viewInsets.bottom;
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // 300 physical pixels stay 300 physical pixels: 300 / scale in the child's
    // larger logical coordinates.
    expect(inset, closeTo(keyboard / 0.6, 0.01));
  });
}
