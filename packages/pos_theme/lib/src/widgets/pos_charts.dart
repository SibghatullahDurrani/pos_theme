import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/pos_tokens.dart';
import '../utils/pos_format.dart';
import 'pos_badge.dart';
import 'pos_card.dart';

/// KPI tile: label, big value, delta vs. previous period, optional sparkline.
class PosStatCard extends StatelessWidget {
  const PosStatCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.icon,
    this.tone = PosToneKind.brand,
    this.spark,
    this.caption = 'vs last week',
  });

  final String label;
  final String value;

  /// Fractional change, e.g. 0.124 = +12.4%.
  final double? delta;
  final IconData? icon;
  final PosToneKind tone;
  final List<double>? spark;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final t = tone.of(context);
    final pos = context.pos;
    final up = (delta ?? 0) >= 0;
    final dt = up ? pos.success : pos.danger;
    return PosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium!.copyWith(color: pos.textMuted),
                ),
              ),
              if (icon != null)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: t.container, borderRadius: context.shape.md),
                  child: Icon(icon, size: 20, color: t.onContainer),
                ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: posTabular(context.text.headlineLarge!)),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, c) {
              // Narrow tiles (2-up on phones) drop the caption & sparkline.
              final narrow = c.maxWidth < 230;
              return Row(
                children: [
                  if (delta != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: dt.container, borderRadius: context.shape.xs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            size: 14,
                            color: dt.onContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${up ? '+' : ''}${(delta! * 100).toStringAsFixed(1)}%',
                            style: context.text.labelMedium!.copyWith(
                              color: dt.onContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!narrow) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          caption,
                          style: context.text.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                  if (spark != null && !narrow) ...[
                    const Spacer(),
                    SizedBox(
                      width: 72,
                      height: 28,
                      child: PosSparkline(values: spark!, color: t.color),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Minimal sparkline.
class PosSparkline extends StatelessWidget {
  const PosSparkline({super.key, required this.values, this.color});
  final List<double> values;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _LinePainter(series: [values], colors: [color ?? context.colors.primary], fill: true, grid: null),
  );
}

/// Line / area chart with optional multiple series.
class PosLineChart extends StatelessWidget {
  const PosLineChart({
    super.key,
    required this.series,
    required this.labels,
    this.height = 220,
    this.legend,
    this.area = true,
  });
  final List<List<double>> series;
  final List<String> labels;
  final double height;
  final List<String>? legend;
  final bool area;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (legend != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 16,
              children: [
                for (var i = 0; i < legend!.length; i++)
                  _LegendDot(color: pos.chart[i % pos.chart.length], label: legend![i]),
              ],
            ),
          ),
        SizedBox(
          height: height,
          child: CustomPaint(
            size: Size.infinite,
            painter: _LinePainter(
              series: series,
              colors: pos.chart,
              fill: area,
              grid: pos.border,
              labelStyle: context.text.labelSmall!.copyWith(color: pos.textMuted),
              labels: labels,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 6),
      Text(label, style: context.text.bodySmall),
    ],
  );
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.series,
    required this.colors,
    required this.fill,
    required this.grid,
    this.labelStyle,
    this.labels,
  });
  final List<List<double>> series;
  final List<Color> colors;
  final bool fill;
  final Color? grid;
  final TextStyle? labelStyle;
  final List<String>? labels;

  @override
  void paint(Canvas canvas, Size size) {
    final all = series.expand((s) => s).toList();
    if (all.isEmpty) return;
    final maxV = all.reduce(math.max) * 1.1;
    const minV = 0.0;
    final bottomPad = labels != null ? 20.0 : 0.0;
    final leftPad = grid != null ? 36.0 : 0.0;
    final chart = Rect.fromLTWH(leftPad, 4, size.width - leftPad, size.height - bottomPad - 4);

    if (grid != null) {
      final gp = Paint()
        ..color = grid!
        ..strokeWidth = 1;
      for (var i = 0; i <= 4; i++) {
        final y = chart.top + chart.height * i / 4;
        canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gp);
        final v = maxV - (maxV - minV) * i / 4;
        final tp = TextPainter(
          text: TextSpan(
            text: v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0),
            style: labelStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(0, y - tp.height / 2));
      }
    }
    if (labels != null) {
      final n = labels!.length;
      final step = (n / 7).ceil().clamp(1, n);
      for (var i = 0; i < n; i += step) {
        final x = chart.left + (n == 1 ? 0 : chart.width * i / (n - 1));
        final tp = TextPainter(
          text: TextSpan(text: labels![i], style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset((x - tp.width / 2).clamp(chart.left, size.width - tp.width), size.height - tp.height));
      }
    }

    for (var s = 0; s < series.length; s++) {
      final data = series[s];
      if (data.length < 2) continue;
      final color = colors[s % colors.length];
      final pts = [
        for (var i = 0; i < data.length; i++)
          Offset(
            chart.left + chart.width * i / (data.length - 1),
            chart.bottom - chart.height * ((data[i] - minV) / (maxV - minV)),
          ),
      ];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        final p0 = pts[i - 1];
        final p1 = pts[i];
        final cx = (p0.dx + p1.dx) / 2;
        path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
      }
      if (fill && s == 0) {
        final area = Path.from(path)
          ..lineTo(pts.last.dx, chart.bottom)
          ..lineTo(pts.first.dx, chart.bottom)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
            ).createShader(chart),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = grid == null ? 2 : 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.series != series || old.colors != colors || old.grid != grid || old.labels != labels;
}

/// Vertical bar chart.
class PosBarChart extends StatelessWidget {
  const PosBarChart({super.key, required this.values, required this.labels, this.height = 220, this.highlightIndex});
  final List<double> values;
  final List<String> labels;
  final double height;
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final maxV = values.isEmpty ? 1.0 : values.reduce(math.max);
    final r = context.shape.radiusSm;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Tooltip(
                message: '${labels[i]}: ${posMoney(values[i], decimals: 0)}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: maxV == 0 ? 0 : values[i] / maxV,
                          child: Container(
                            decoration: BoxDecoration(
                              color: highlightIndex == null || highlightIndex == i
                                  ? context.colors.primary
                                  : context.colors.primary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(r)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(labels[i], style: context.text.labelSmall!.copyWith(color: pos.textMuted), maxLines: 1),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Donut chart with centre label and legend.
class PosDonutChart extends StatelessWidget {
  const PosDonutChart({
    super.key,
    required this.values,
    required this.labels,
    this.centerLabel,
    this.centerValue,
    this.size = 160,
  });
  final List<double> values;
  final List<String> labels;
  final String? centerLabel;
  final String? centerValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final total = values.fold<double>(0, (a, b) => a + b);
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _DonutPainter(values: values, colors: pos.chart, track: pos.surfaceMuted),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (centerValue != null) Text(centerValue!, style: posTabular(context.text.titleLarge!)),
                  if (centerLabel != null) Text(centerLabel!, style: context.text.bodySmall),
                ],
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < values.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendDot(color: pos.chart[i % pos.chart.length], label: labels[i]),
                    const SizedBox(width: 10),
                    Text(
                      total == 0 ? '0%' : '${(values[i] / total * 100).toStringAsFixed(0)}%',
                      style: context.text.labelMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.values, required this.colors, required this.track});
  final List<double> values;
  final List<Color> colors;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.14;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      canvas.drawArc(
        rect,
        start + 0.02,
        math.max(0, sweep - 0.04),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = colors[i % colors.length],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.values != values || old.colors != colors;
}
