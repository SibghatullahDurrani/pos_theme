import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../widgets/page_scaffold.dart';

class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final pos = context.pos;
    final shape = context.shape;
    final spec = PosThemeScope.of(context).spec;
    final tt = context.text;

    return ShowcasePage(
      title: 'Foundations',
      subtitle: '${spec.name}: colour, type, shape and elevation tokens. Every component reads from these.',
      children: [
        DemoSection(
          title: 'Brand & surfaces',
          child: DemoWrap(
            children: [
              _Swatch('Primary', cs.primary, cs.onPrimary),
              _Swatch('Primary container', cs.primaryContainer, cs.onPrimaryContainer),
              _Swatch('Secondary', cs.secondary, cs.onSecondary),
              _Swatch('Tertiary', cs.tertiary, cs.onTertiary),
              _Swatch('Canvas', pos.canvas, cs.onSurface),
              _Swatch('Surface', cs.surface, cs.onSurface),
              _Swatch('Surface muted', pos.surfaceMuted, cs.onSurface),
              _Swatch('Border', pos.border, cs.onSurface),
              _Swatch('Border strong', pos.borderStrong, cs.onSurface),
              _Swatch('Text muted', pos.textMuted, cs.surface),
              _Swatch('Sidebar', pos.sidebarBg, pos.sidebarFg),
              _Swatch('Sidebar active', pos.sidebarActiveBg, pos.sidebarActiveFg),
            ],
          ),
        ),
        DemoSection(
          title: 'Semantic tones',
          description: 'Used by status pills, alerts, toasts, table & order statuses.',
          child: DemoWrap(
            children: [
              for (final (n, t) in [
                ('Success', pos.success),
                ('Warning', pos.warning),
                ('Info', pos.info),
                ('Danger', pos.danger),
                ('Neutral', pos.neutral),
                ('Brand', pos.brand),
              ])
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Swatch(n, t.color, t.onColor, width: 200, height: 60),
                      _Swatch('$n container', t.container, t.onContainer, width: 200, height: 60),
                    ],
                  ),
                ),
            ],
          ),
        ),
        DemoSection(
          title: 'Chart palette',
          child: Row(
            children: [for (final c in pos.chart) Expanded(child: Container(height: 48, color: c))],
          ),
        ),
        DemoSection(
          title: 'Typography',
          description: 'Display: ${spec.displayFont} · Body: ${spec.bodyFont}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (n, s) in [
                ('Display L', tt.displayLarge),
                ('Display M', tt.displayMedium),
                ('Headline L', tt.headlineLarge),
                ('Headline M', tt.headlineMedium),
                ('Headline S', tt.headlineSmall),
                ('Title L', tt.titleLarge),
                ('Title M', tt.titleMedium),
                ('Body L', tt.bodyLarge),
                ('Body M', tt.bodyMedium),
                ('Body S', tt.bodySmall),
                ('Label L', tt.labelLarge),
                ('Label S', tt.labelSmall),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          '$n\n${s!.fontSize!.toStringAsFixed(0)}/${s.fontWeight!.value}',
                          style: tt.labelSmall!.copyWith(color: pos.textMuted),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          n.startsWith('Display') ? '\$1,284.50' : 'Flat white with oat milk',
                          style: s,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        DemoSection(
          title: 'Radius & elevation',
          child: DemoWrap(
            spacing: 20,
            children: [
              for (final (n, r, sh) in [
                ('xs', shape.radiusXs, <BoxShadow>[]),
                ('sm', shape.radiusSm, shape.shadowsSm),
                ('md', shape.radiusMd, shape.shadowsSm),
                ('lg', shape.radiusLg, shape.shadowsMd),
                ('xl', shape.radiusXl, shape.shadowsLg),
                ('button', shape.buttonRadius.clamp(0, 48).toDouble(), shape.shadowsSm),
              ])
                Container(
                  width: 120,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(r),
                    border: Border.all(color: pos.border),
                    boxShadow: sh,
                  ),
                  child: Text('$n\n${r.toInt()}px', textAlign: TextAlign.center, style: tt.labelLarge),
                ),
            ],
          ),
        ),
        DemoSection(
          title: 'Spacing (4pt grid) & breakpoints',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (n, v) in [
                ('xs', PosSpace.xs),
                ('sm', PosSpace.sm),
                ('md', PosSpace.md),
                ('lg', PosSpace.lg),
                ('xl', PosSpace.xl),
                ('xxl', PosSpace.xxl),
                ('xxxl', PosSpace.xxxl),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(width: 60, child: Text(n, style: tt.labelMedium)),
                      Container(width: v * 3, height: 14, color: cs.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Text('${v.toInt()}', style: tt.bodySmall),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Current window: ${context.window.name} (${MediaQuery.sizeOf(context).width.toInt()}px)',
                style: tt.titleSmall,
              ),
              const SizedBox(height: 4),
              Text('compact < 600 · medium 600–1023 · expanded 1024–1439 · large ≥ 1440', style: tt.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, this.on, {this.width = 150, this.height = 84});
  final String name;
  final Color color;
  final Color on;
  final double width;
  final double height;

  String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: context.shape.md,
        border: Border.all(color: context.pos.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            name,
            style: context.text.labelMedium!.copyWith(color: on),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${_hex(color)} · ${posContrast(color, on).toStringAsFixed(1)}:1',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall!.copyWith(color: on.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}
