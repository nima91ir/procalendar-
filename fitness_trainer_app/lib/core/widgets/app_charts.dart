import 'package:flutter/material.dart';
import 'package:fitness_trainer_app/core/theme/app_tones.dart';
import '../theme/app_typography.dart';
import '../theme/app_tokens.dart';

/// Circular progress ring drawn with a custom painter (no external charts
/// package). `value` is expected to be clamped to 0..1.
class AppProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? progressColor;
  final Widget? child;

  const AppProgressRing({
    super.key,
    required this.value,
    this.size = 88,
    this.strokeWidth = 10,
    this.trackColor,
    this.progressColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          trackColor: trackColor ?? t.surfaceVariant,
          progressColor: progressColor ?? t.primary,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, 2 * 3.141592653589793, false, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -0.5 * 3.141592653589793,
        endAngle: 1.5 * 3.141592653589793,
        colors: [progressColor, progressColor.withValues(alpha: 0.75)],
      ).createShader(rect);
    canvas.drawArc(rect, -0.5 * 3.141592653589793, value * 2 * 3.141592653589793, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}

class BarDatum {
  final String label;
  final double value;
  final Color? color;
  final bool highlighted;

  const BarDatum({
    required this.label,
    required this.value,
    this.color,
    this.highlighted = false,
  });
}

/// Simple vertical bars without dates or gridlines, suited to compact stat
/// panels (e.g. per-month revenue or attendance).
class AppMiniBarChart extends StatelessWidget {
  final List<BarDatum> data;
  final double height;
  final double? maxValue;

  const AppMiniBarChart({
    super.key,
    required this.data,
    this.height = 120,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    if (data.isEmpty) return const SizedBox.shrink();
    final max = maxValue ?? data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final safeMax = max <= 0 ? 1.0 : max;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final barHeight = height * 0.82 * (d.value / safeMax).clamp(0.0, 1.0);
          final color = d.color ?? t.primary;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      border: d.highlighted
                          ? Border.all(color: t.onSurface, width: 1.5)
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    d.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      fontWeight: d.highlighted ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ChartPoint {
  final String label;
  final double value;
  final bool highlight;

  const ChartPoint({required this.label, required this.value, this.highlight = false});
}

/// Polyline chart with optional area fill, drawn via CustomPainter.
class AppLineChart extends StatelessWidget {
  final List<ChartPoint> points;
  final double height;
  final Color? lineColor;
  final Color? fillColor;

  const AppLineChart({
    super.key,
    required this.points,
    this.height = 140,
    this.lineColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tones;
    final line = lineColor ?? t.primary;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _LineChartPainter(
          points: points,
          lineColor: line,
          fillColor: fillColor ?? line.withValues(alpha: 0.14),
          highlightColor: t.onSurface,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color highlightColor;

  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final values = points.map((p) => p.value).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final range = max - min;

    final padding = 12.0;
    final chartTop = padding;
    final chartBottom = size.height - padding;
    final chartHeight = chartBottom - chartTop;

    double xFor(int i) =>
        points.length == 1 ? size.width / 2 : padding + i * (size.width - 2 * padding) / (points.length - 1);
    double yFor(double v) =>
        range == 0 ? chartTop + chartHeight / 2 : chartBottom - ((v - min) / range) * chartHeight;

    final gridPaint = Paint()
      ..color = const Color(0x1A88A36B)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = chartTop + chartHeight * i / 3;
      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), gridPaint);
    }

    final areaPath = Path()..moveTo(xFor(0), chartBottom);
    final linePath = Path()..moveTo(xFor(0), yFor(values[0]));
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(xFor(i), yFor(values[i]));
      areaPath.lineTo(xFor(i), yFor(values[i]));
    }
    areaPath
      ..lineTo(xFor(points.length - 1), chartBottom)
      ..close();

    canvas.drawPath(areaPath, Paint()..color = fillColor);
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = lineColor,
    );

    for (var i = 0; i < points.length; i++) {
      final center = Offset(xFor(i), yFor(values[i]));
      canvas.drawCircle(
        center,
        points[i].highlight ? 4 : 2.5,
        Paint()..color = points[i].highlight ? highlightColor : lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.fillColor != fillColor;
}