import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';

class _Line {
  _Line(this.product, this.qty, {this.mods = const [], this.extra = 0});
  final Product product;
  int qty;
  final List<String> mods;
  final double extra;
  double get unit => product.price + extra;
}

/// Retail / café register: product grid + cart. Cart is a side panel on wide
/// screens and a bottom sheet behind a sticky "View cart" bar on phones.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _cat = 0;
  String _query = '';
  String _orderType = 'dine';
  String? _customer = 'Ava Thompson';
  double _discount = 0;
  final List<_Line> _lines = [];

  @override
  void initState() {
    super.initState();
    _lines.addAll([
      _Line(products[0], 2, mods: ['Large', 'Oat'], extra: 1.50),
      _Line(products[3], 1),
      _Line(products[7], 1),
    ]);
  }

  double get _subtotal => _lines.fold(0, (a, l) => a + l.unit * l.qty);
  double get _tax => (_subtotal - _discount) * 0.085;
  double get _total => _subtotal - _discount + _tax;
  int get _count => _lines.fold(0, (a, l) => a + l.qty);

  List<Product> get _filtered => products
      .where((p) => _cat == 0 || p.category == productCategories[_cat])
      .where((p) => _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  int _qtyOf(Product p) => _lines.where((l) => l.product.id == p.id).fold(0, (a, l) => a + l.qty);

  void _add(Product p) {
    if (p.category == 'Coffee') {
      showPosSheet<void>(
        context,
        builder: (ctx) => PosModifierPicker(
          itemName: p.name,
          basePrice: p.price,
          groups: coffeeModifiers,
          onAdd: (r) {
            Navigator.pop(ctx);
            final labels = <String>[
              for (final g in coffeeModifiers)
                for (final o in g.options)
                  if (r.selected[g.id]!.contains(o.id)) o.label,
            ];
            setState(() => _lines.add(_Line(p, r.quantity, mods: labels, extra: r.total / r.quantity - p.price)));
          },
        ),
      );
      return;
    }
    setState(() {
      final existing = _lines.where((l) => l.product.id == p.id && l.mods.isEmpty).firstOrNull;
      if (existing != null) {
        existing.qty++;
      } else {
        _lines.add(_Line(p, 1));
      }
    });
  }

  Future<void> _pay() async {
    final done = await showPosAdaptiveDialog<bool>(
      context,
      barrierDismissible: false,
      builder: (ctx) => _PaymentDialog(total: _total, lines: _lines, subtotal: _subtotal, tax: _tax),
    );
    if (done == true && mounted) {
      setState(() {
        _lines.clear();
        _discount = 0;
      });
      PosToast.success(context, 'Sale completed · receipt printed', title: 'Payment approved');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final products = _productArea(context, c.maxWidth - (wide ? 400 : 0));
        if (wide) {
          return Row(
            children: [
              Expanded(child: products),
              Container(
                width: c.maxWidth >= 1300 ? 420 : 380,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: BorderDirectional(start: BorderSide(color: context.pos.border)),
                ),
                child: _cart(context, inSheet: false),
              ),
            ],
          );
        }
        return Column(
          children: [
            Expanded(child: products),
            _cartBar(context),
          ],
        );
      },
    );
  }

  Widget _productArea(BuildContext context, double width) {
    final g = context.window.gutter;
    final cols = (width / (width < 600 ? 150 : 180)).floor().clamp(2, 7);
    final items = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(g, g, g, 12),
          child: Row(
            children: [
              Expanded(
                child: PosSearchField(hint: 'Search products', onChanged: (v) => setState(() => _query = v)),
              ),
              const SizedBox(width: 8),
              PosIconButton(
                icon: Icons.qr_code_scanner_rounded,
                style: PosIconButtonStyle.tonal,
                tooltip: 'Scan barcode',
                onPressed: () => _add(products[11]),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: g),
          child: PosCategoryTabs(items: productCategories, selected: _cat, onSelected: (i) => setState(() => _cat = i)),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: items.isEmpty
              ? const PosEmptyState(
                  title: 'No products found',
                  message: 'Try a different search or category.',
                  icon: Icons.search_off_rounded,
                )
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(g, 0, g, g),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return PosProductTile(
                      name: p.name,
                      price: p.price,
                      category: p.category,
                      stock: p.stock,
                      icon: p.icon,
                      tag: p.tag,
                      quantityInCart: _qtyOf(p),
                      onTap: () => _add(p),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _cartBar(BuildContext context) {
    final cs = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: context.pos.border)),
      ),
      child: SafeArea(
        top: false,
        child: PosButton(
          label: _count == 0 ? 'Cart is empty' : 'View cart · $_count items · ${posMoney(_total)}',
          icon: Icons.shopping_cart_outlined,
          size: PosButtonSize.lg,
          expand: true,
          onPressed: _count == 0
              ? null
              : () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (ctx) => StatefulBuilder(
                    builder: (ctx, setSheet) => SizedBox(
                      height: MediaQuery.sizeOf(ctx).height * 0.88,
                      child: _cart(
                        ctx,
                        inSheet: true,
                        refresh: () {
                          setSheet(() {});
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _cart(BuildContext context, {required bool inSheet, VoidCallback? refresh}) {
    void update(VoidCallback fn) {
      setState(fn);
      refresh?.call();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, inSheet ? 0 : 16, 8, 8),
          child: Row(
            children: [
              Expanded(child: Text('Current order', style: context.text.titleLarge)),
              const PosStatusPill(label: '#1049', tone: PosToneKind.neutral, dense: true),
              PopupMenuButton<String>(
                tooltip: 'Order actions',
                onSelected: (v) async {
                  if (v == 'clear') {
                    final ok = await showPosConfirm(
                      context,
                      title: 'Clear cart?',
                      message: 'All items will be removed.',
                      confirmLabel: 'Clear',
                      destructive: true,
                    );
                    if (ok) update(_lines.clear);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'park', child: Text('Park sale')),
                  PopupMenuItem(value: 'note', child: Text('Add order note')),
                  PopupMenuItem(value: 'clear', child: Text('Clear cart')),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'dine', label: Text('Dine-in')),
              ButtonSegment(value: 'take', label: Text('Takeaway')),
              ButtonSegment(value: 'del', label: Text('Delivery')),
            ],
            selected: {_orderType},
            showSelectedIcon: false,
            onSelectionChanged: (s) => update(() => _orderType = s.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ListTile(
            leading: _customer == null
                ? CircleAvatar(
                    backgroundColor: context.pos.surfaceMuted,
                    child: Icon(Icons.person_add_alt, color: context.pos.textMuted),
                  )
                : PosAvatar(name: _customer!, size: 40),
            title: Text(_customer ?? 'Add customer'),
            subtitle: Text(_customer == null ? 'Earn loyalty points' : 'Gold · 1,240 pts'),
            trailing: _customer == null
                ? const Icon(Icons.chevron_right)
                : IconButton(
                    onPressed: () => update(() => _customer = null),
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove',
                  ),
            onTap: () => update(() => _customer ??= 'Ava Thompson'),
          ),
        ),
        const Divider(),
        Expanded(
          child: _lines.isEmpty
              ? const PosEmptyState(
                  compact: true,
                  title: 'Cart is empty',
                  message: 'Tap a product or scan a barcode.',
                  icon: Icons.shopping_cart_outlined,
                )
              : ListView.separated(
                  itemCount: _lines.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) {
                    final l = _lines[i];
                    return PosCartLine(
                      key: ObjectKey(l),
                      name: l.product.name,
                      quantity: l.qty,
                      unitPrice: l.unit,
                      modifiers: l.mods,
                      onQuantityChanged: (v) => update(() => l.qty = v),
                      onRemove: () => update(() => _lines.remove(l)),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.pos.surfaceMuted.withValues(alpha: 0.5),
            border: Border(top: BorderSide(color: context.pos.border)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                PosCartSummary(
                  subtotal: _subtotal,
                  discount: _discount,
                  tax: _tax,
                  taxLabel: 'Tax (8.5%)',
                  onDiscountTap: () => update(() => _discount = _discount > 0 ? 0 : (_subtotal * 0.1)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    PosIconButton(
                      icon: Icons.pause_circle_outline,
                      style: PosIconButtonStyle.outlined,
                      tooltip: 'Park',
                      size: 64,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PosButton(
                        label: 'Charge ${posMoney(_total)}',
                        size: PosButtonSize.xl,
                        expand: true,
                        onPressed: _lines.isEmpty
                            ? null
                            : () {
                                if (inSheet) Navigator.pop(context);
                                _pay();
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.total, required this.lines, required this.subtotal, required this.tax});
  final double total;
  final double subtotal;
  final double tax;
  final List<_Line> lines;
  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  int _step = 0; // 0 method, 1 tender, 2 done
  String? _method = 'card';
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    final content = switch (_step) {
      0 => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PosSteps(steps: const ['Method', 'Tender', 'Receipt'], current: _step),
          const SizedBox(height: 20),
          PosPaymentMethodSelector(selected: _method, onChanged: (v) => setState(() => _method = v)),
        ],
      ),
      1 when _method == 'cash' => PosCashTender(amountDue: widget.total, onConfirm: (_) => setState(() => _step = 2)),
      1 => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: context.colors.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.contactless_rounded, size: 52, color: context.colors.onPrimaryContainer),
            ),
            const SizedBox(height: 18),
            Text('Tap, insert or swipe card', style: context.text.titleLarge),
            const SizedBox(height: 6),
            Text(posMoney(widget.total), style: posTabular(context.text.displaySmall!)),
            const SizedBox(height: 18),
            if (_processing) const LinearProgressIndicator(),
          ],
        ),
      ),
      _ => Column(
        children: [
          Icon(Icons.check_circle_rounded, size: 64, color: context.pos.success.color),
          const SizedBox(height: 10),
          Text('Payment approved', style: context.text.headlineSmall),
          const SizedBox(height: 16),
          PosReceipt(
            storeName: 'Nova Café',
            orderNo: '#1049',
            cashier: 'Jordan R.',
            lines: [for (final l in widget.lines) PosReceiptLine(l.product.name, l.qty, l.unit * l.qty)],
            subtotal: widget.subtotal,
            tax: widget.tax,
            total: widget.total,
            paidWith: _method == 'cash' ? 'Cash' : 'Visa •••• 4242',
          ),
        ],
      ),
    };

    final actions = switch (_step) {
      0 => [
        PosButton.outline(label: 'Cancel', onPressed: () => Navigator.pop(context, false)),
        PosButton(
          label: 'Continue',
          trailingIcon: Icons.arrow_forward,
          onPressed: _method == null ? null : () => setState(() => _step = 1),
        ),
      ],
      1 when _method == 'cash' => [PosButton.ghost(label: 'Back', onPressed: () => setState(() => _step = 0))],
      1 => [
        PosButton.ghost(label: 'Back', onPressed: _processing ? null : () => setState(() => _step = 0)),
        PosButton(
          label: _processing ? 'Authorising…' : 'Simulate approval',
          loading: _processing,
          onPressed: () {
            setState(() => _processing = true);
            Future.delayed(const Duration(milliseconds: 1400), () {
              if (mounted) setState(() => _step = 2);
            });
          },
        ),
      ],
      _ => [
        PosButton.outline(
          label: 'Email receipt',
          icon: Icons.email_outlined,
          onPressed: () => Navigator.pop(context, true),
        ),
        PosButton(label: 'New sale', icon: Icons.add, onPressed: () => Navigator.pop(context, true)),
      ],
    };

    return PosDialog(
      title: _step == 2 ? 'Done' : 'Charge ${posMoney(widget.total)}',
      maxWidth: 560,
      showClose: _step == 0,
      content: AnimatedSize(duration: PosMotion.medium, child: content),
      actions: actions,
    );
  }
}
