import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _q = '';
  Set<String> _cats = {};
  String? _stock = 'all';
  Set<Object> _sel = {};

  List<Product> get _rows => products
      .where(
        (p) =>
            _q.isEmpty ||
            p.name.toLowerCase().contains(_q.toLowerCase()) ||
            (p.sku ?? '').toLowerCase().contains(_q.toLowerCase()),
      )
      .where((p) => _cats.isEmpty || _cats.contains(p.category))
      .where(
        (p) => switch (_stock) {
          'low' => p.stock > 0 && p.stock <= 5,
          'out' => p.stock <= 0,
          _ => true,
        },
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final low = products.where((p) => p.stock > 0 && p.stock <= 5).length;
    final out = products.where((p) => p.stock <= 0).length;
    return ShowcasePage(
      title: 'Inventory',
      subtitle: '${products.length} products across ${productCategories.length - 1} categories',
      action: PosButton(label: 'Add product', icon: Icons.add, onPressed: () => _edit(context, null)),
      children: [
        PosGrid(
          children: [
            PosGridItem(
              compact: 2,
              medium: 2,
              expanded: 3,
              child: _Kpi('Products', '${products.length}', Icons.inventory_2_outlined, PosToneKind.brand),
            ),
            PosGridItem(
              compact: 2,
              medium: 2,
              expanded: 3,
              child: _Kpi('Low stock', '$low', Icons.trending_down, PosToneKind.warning),
            ),
            PosGridItem(
              compact: 2,
              medium: 2,
              expanded: 3,
              child: _Kpi('Out of stock', '$out', Icons.remove_shopping_cart_outlined, PosToneKind.danger),
            ),
            const PosGridItem(
              compact: 2,
              medium: 2,
              expanded: 3,
              child: _Kpi('Stock value', '\$8,412', Icons.account_balance_wallet_outlined, PosToneKind.success),
            ),
          ],
        ),
        PosCard(
          child: PosGrid(
            spacing: 12,
            runSpacing: 12,
            children: [
              PosGridItem(
                medium: 8,
                expanded: 5,
                child: PosTextField(
                  hint: 'Search name or SKU',
                  prefixIcon: Icons.search,
                  clearable: true,
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
              PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosSelect<String>(
                  hint: 'All categories',
                  multiple: true,
                  selected: _cats,
                  onChanged: (s) => setState(() => _cats = s),
                  options: [for (final c in productCategories.skip(1)) PosOption(c, c)],
                ),
              ),
              PosGridItem(
                medium: 4,
                expanded: 3,
                child: PosDropdown<String>(
                  value: _stock,
                  onChanged: (v) => setState(() => _stock = v),
                  options: const [
                    PosOption('all', 'All stock levels'),
                    PosOption('low', 'Low stock'),
                    PosOption('out', 'Out of stock'),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_sel.isNotEmpty)
          PosAlert(
            tone: PosToneKind.brand,
            message: '${_sel.length} selected',
            action: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PosButton.outline(label: 'Adjust stock', size: PosButtonSize.sm, onPressed: () {}),
                PosButton.outline(label: 'Print labels', size: PosButtonSize.sm, onPressed: () {}),
                PosButton.danger(
                  label: 'Delete',
                  size: PosButtonSize.sm,
                  onPressed: () async {
                    final ok = await showPosConfirm(
                      context,
                      title: 'Delete ${_sel.length} products?',
                      destructive: true,
                      confirmLabel: 'Delete',
                    );
                    if (ok) setState(() => _sel = {});
                  },
                ),
              ],
            ),
          ),
        PosDataTable<Product>(
          rows: _rows,
          rowId: (p) => p.id,
          selectable: true,
          selected: _sel,
          onSelectionChanged: (s) => setState(() => _sel = s),
          onRowTap: (p) => _edit(context, p),
          pageSize: 8,
          emptyTitle: 'No products match',
          emptyMessage: 'Try clearing filters.',
          actions: [
            PosRowAction(label: 'Edit', icon: Icons.edit_outlined, onTap: (p) => _edit(context, p)),
            PosRowAction(label: 'Duplicate', icon: Icons.copy_outlined, onTap: (p) {}),
            PosRowAction(label: 'Delete', icon: Icons.delete_outline, destructive: true, onTap: (p) {}),
          ],
          columns: [
            PosColumn(
              label: 'Product',
              primary: true,
              flex: 4,
              sortBy: (p) => p.name,
              cell: (c, p) => Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        posHashColor(p.name, c.pos.chart).withValues(alpha: 0.18),
                        c.colors.surface,
                      ),
                      borderRadius: c.shape.sm,
                    ),
                    child: Icon(p.icon, size: 18, color: c.colors.onSurface),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      p.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            PosColumn(label: 'SKU', flex: 2, sortBy: (p) => p.sku ?? '', cell: (c, p) => Text(p.sku ?? '—')),
            PosColumn(label: 'Category', flex: 2, sortBy: (p) => p.category, cell: (c, p) => Text(p.category)),
            PosColumn(
              label: 'Stock',
              flex: 2,
              sortBy: (p) => p.stock,
              cell: (c, p) => p.stock <= 0
                  ? const PosStatusPill(label: 'Out', tone: PosToneKind.danger, dense: true)
                  : p.stock <= 5
                  ? PosStatusPill(label: '${p.stock} low', tone: PosToneKind.warning, dense: true)
                  : Text('${p.stock}'),
            ),
            PosColumn(
              label: 'Price',
              width: 90,
              numeric: true,
              sortBy: (p) => p.price,
              cell: (c, p) => Text(posMoney(p.price), style: posTabular(const TextStyle(fontWeight: FontWeight.w700))),
            ),
          ],
        ),
      ],
    );
  }

  void _edit(BuildContext context, Product? p) {
    showPosAdaptiveDialog<void>(
      context,
      fullscreenOnCompact: true,
      builder: (ctx) => PosDialog(
        title: p == null ? 'New product' : 'Edit ${p.name}',
        maxWidth: 640,
        content: PosGrid(
          spacing: 12,
          runSpacing: 14,
          children: [
            PosGridItem(
              medium: 8,
              expanded: 12,
              child: PosTextField(label: 'Name', initialValue: p?.name, required: true),
            ),
            PosGridItem(
              medium: 4,
              expanded: 6,
              child: PosTextField(label: 'SKU', initialValue: p?.sku),
            ),
            PosGridItem(
              medium: 4,
              expanded: 6,
              child: PosDropdown<String>(
                label: 'Category',
                value: p?.category ?? 'Coffee',
                onChanged: (_) {},
                options: [for (final c in productCategories.skip(1)) PosOption(c, c)],
              ),
            ),
            PosGridItem(
              medium: 4,
              expanded: 4,
              child: PosTextField(label: 'Price', prefixText: '\$ ', initialValue: p?.price.toStringAsFixed(2)),
            ),
            PosGridItem(
              medium: 4,
              expanded: 4,
              child: PosTextField(
                label: 'Cost',
                prefixText: '\$ ',
                initialValue: p == null ? null : (p.price * 0.35).toStringAsFixed(2),
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 4,
              child: PosTextField(label: 'Stock', initialValue: p?.stock.toString()),
            ),
            const PosGridItem(medium: 8, expanded: 12, child: PosTextField(label: 'Description', maxLines: 3)),
            PosGridItem(
              medium: 8,
              expanded: 12,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in ['Vegan', 'Gluten free', 'Seasonal', 'Best seller'])
                    FilterChip(label: Text(t), selected: t == 'Best seller', onSelected: (_) {}),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (p != null) PosButton.ghost(label: 'Delete', onPressed: () => Navigator.pop(ctx)),
          PosButton.outline(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
          PosButton(
            label: 'Save',
            icon: Icons.check,
            onPressed: () {
              Navigator.pop(ctx);
              PosToast.success(context, 'Product saved');
            },
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value, this.icon, this.tone);
  final String label;
  final String value;
  final IconData icon;
  final PosToneKind tone;

  @override
  Widget build(BuildContext context) {
    final t = tone.of(context);
    return PosCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: t.container, borderRadius: context.shape.md),
            child: Icon(icon, color: t.onContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(value, style: posTabular(context.text.titleLarge!)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
