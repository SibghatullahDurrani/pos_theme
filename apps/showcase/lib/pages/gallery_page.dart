import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../widgets/page_scaffold.dart';

/// All five themes side by side, each rendered with its own ThemeData.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key, required this.onOpen});
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final c = PosThemeScope.of(context);
    final b = Theme.of(context).brightness;
    return ShowcasePage(
      title: 'Five themes, one system',
      subtitle:
          'Each theme ships light + dark, the same components and the same responsive layouts. '
          'Tap a card to apply it to the whole suite.',
      children: [
        PosGrid(
          children: [
            for (final spec in PosThemes.all)
              PosGridItem(
                compact: 4,
                medium: 4,
                expanded: 6,
                large: 4,
                child: _ThemeCard(
                  spec: spec,
                  theme: c.themeFor(spec, b),
                  active: spec.id == c.spec.id,
                  onApply: () => c.spec = spec,
                ),
              ),
          ],
        ),
        DemoSection(
          title: 'Same component, five personalities',
          description: 'Primary action, status pill, input and toggle rendered in every theme.',
          child: Column(
            children: [
              for (final spec in PosThemes.all)
                Theme(
                  data: c.themeFor(spec, b),
                  child: Builder(
                    builder: (context) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.pos.canvas,
                        borderRadius: context.shape.lg,
                        border: Border.all(color: context.pos.border),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(width: 150, child: Text(spec.name, style: context.text.titleSmall)),
                          PosButton(label: 'Charge \$24.60', icon: Icons.payments_outlined, onPressed: () {}),
                          PosButton.outline(label: 'Hold', onPressed: () {}),
                          PosStatusPill.order(PosOrderStatus.preparing),
                          PosStatusPill.order(PosOrderStatus.paid),
                          const SizedBox(width: 200, child: PosTextField(hint: 'Customer name')),
                          Switch(value: true, onChanged: (_) {}),
                          const Checkbox(value: true, onChanged: _noop),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        DemoSection(
          title: 'Jump into a sample screen',
          child: DemoWrap(
            children: [
              PosButton.outline(
                label: 'Dashboard',
                icon: Icons.space_dashboard_outlined,
                onPressed: () => onOpen('dashboard'),
              ),
              PosButton.outline(
                label: 'Checkout',
                icon: Icons.point_of_sale_outlined,
                onPressed: () => onOpen('checkout'),
              ),
              PosButton.outline(
                label: 'Floor plan',
                icon: Icons.table_restaurant_outlined,
                onPressed: () => onOpen('floor'),
              ),
              PosButton.outline(
                label: 'Kitchen display',
                icon: Icons.soup_kitchen_outlined,
                onPressed: () => onOpen('kitchen'),
              ),
              PosButton.outline(
                label: 'Inventory',
                icon: Icons.inventory_2_outlined,
                onPressed: () => onOpen('inventory'),
              ),
              PosButton.outline(label: 'Lock screen', icon: Icons.lock_outline, onPressed: () => onOpen('lock')),
            ],
          ),
        ),
      ],
    );
  }
}

void _noop(bool? _) {}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.spec, required this.theme, required this.active, required this.onApply});
  final PosThemeSpec spec;
  final ThemeData theme;
  final bool active;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final pos = context.pos;
          final cs = context.colors;
          final shape = context.shape;
          return PosCard(
            padding: EdgeInsets.zero,
            selected: active,
            onTap: onApply,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mini app preview
                SizedBox(
                  height: 190,
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        color: pos.sidebarBg,
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            for (var i = 0; i < 5; i++)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: i == 1 ? pos.sidebarActiveBg : Colors.transparent,
                                  borderRadius: BorderRadius.circular(shape.radiusSm),
                                ),
                                child: Icon(
                                  [
                                    Icons.dashboard_outlined,
                                    Icons.point_of_sale,
                                    Icons.table_restaurant_outlined,
                                    Icons.inventory_2_outlined,
                                    Icons.settings_outlined,
                                  ][i],
                                  size: 16,
                                  color: i == 1 ? pos.sidebarActiveFg : pos.sidebarMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: pos.canvas,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _mini(context, 'Sales', '\$4,180', pos.brand)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _mini(context, 'Orders', '214', pos.success)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: shape.md,
                                    border: shape.cardBordered ? Border.all(color: pos.border) : null,
                                    boxShadow: shape.shadowsSm,
                                  ),
                                  child: PosSparkline(values: const [3, 5, 4, 7, 6, 9, 8, 11], color: cs.primary),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(color: cs.primary, borderRadius: shape.button),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Pay',
                                        style: context.text.labelMedium!.copyWith(color: cs.onPrimary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    height: 30,
                                    width: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: shape.button,
                                      border: Border.all(color: pos.borderStrong),
                                      color: cs.surface,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('Hold', style: context.text.labelMedium),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(spec.name, style: context.text.titleLarge)),
                          if (active) const PosStatusPill(label: 'Active', tone: PosToneKind.brand, dot: true),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(spec.tagline, style: context.text.bodyMedium!.copyWith(color: pos.textMuted)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (final c in [
                            cs.primary,
                            cs.secondary,
                            cs.tertiary,
                            pos.success.color,
                            pos.warning.color,
                            pos.danger.color,
                          ])
                            Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsetsDirectional.only(end: 5),
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(shape.radiusXs + 2),
                                border: Border.all(color: pos.border),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${spec.displayFont} · r${shape.radiusMd.toInt()}',
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelSmall!.copyWith(color: pos.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mini(BuildContext context, String l, String v, PosTone t) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: context.shape.md,
      border: context.shape.cardBordered ? Border.all(color: context.pos.border) : null,
      boxShadow: context.shape.shadowsSm,
    ),
    child: Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(color: t.color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l, style: context.text.labelSmall!.copyWith(color: context.pos.textMuted)),
              Text(v, style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    ),
  );
}
