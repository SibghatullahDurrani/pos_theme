import 'package:flutter/material.dart';

import '../tokens/pos_tokens.dart';
import '../utils/pos_format.dart';
import 'pos_badge.dart';
import 'pos_button.dart';
import 'pos_inputs.dart';

/// Product tile for the sell grid.
class PosProductTile extends StatelessWidget {
  const PosProductTile({
    super.key,
    required this.name,
    required this.price,
    this.category,
    this.stock,
    this.icon = Icons.local_mall_outlined,
    this.image,
    this.onTap,
    this.quantityInCart = 0,
    this.lowStockThreshold = 5,
    this.tag,
  });

  final String name;
  final double price;
  final String? category;
  final int? stock;
  final IconData icon;
  final ImageProvider? image;
  final VoidCallback? onTap;
  final int quantityInCart;
  final int lowStockThreshold;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final cs = context.colors;
    final shape = context.shape;
    final tint = posHashColor(name, pos.chart);
    final out = stock != null && stock! <= 0;
    final low = !out && stock != null && stock! <= lowStockThreshold;
    final selected = quantityInCart > 0;

    return Opacity(
      opacity: out ? 0.55 : 1,
      child: AnimatedContainer(
        duration: PosMotion.fast,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: shape.lg,
          border: Border.all(color: selected ? cs.primary : pos.border, width: selected ? 2 : shape.borderWidth),
          boxShadow: shape.cardBordered ? null : shape.shadowsSm,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: shape.lg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: out ? null : onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(tint.withValues(alpha: 0.16), cs.surface),
                          borderRadius: BorderRadius.circular((shape.radiusLg - 4).clamp(0, 99)),
                          image: image == null ? null : DecorationImage(image: image!, fit: BoxFit.cover),
                        ),
                        child: image == null
                            ? Icon(icon, size: 34, color: posContrast(tint, cs.surface) > 2.5 ? tint : cs.onSurface)
                            : null,
                      ),
                      if (tag != null || out || low)
                        PositionedDirectional(
                          top: 12,
                          start: 12,
                          child: PosStatusPill(
                            label: out ? 'Out of stock' : (low ? 'Low: $stock' : tag!),
                            tone: out ? PosToneKind.danger : (low ? PosToneKind.warning : PosToneKind.brand),
                            style: PosPillStyle.solid,
                            dense: true,
                          ),
                        ),
                      if (selected)
                        PositionedDirectional(
                          top: 10,
                          end: 10,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 26),
                            height: 26,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(99)),
                            alignment: Alignment.center,
                            child: Text(
                              '$quantityInCart',
                              style: context.text.labelMedium!.copyWith(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category ?? (stock != null ? '$stock in stock' : ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall,
                            ),
                          ),
                          Text(
                            posMoney(price),
                            style: posTabular(
                              context.text.titleSmall!.copyWith(
                                fontWeight: FontWeight.w800,
                                color:
                                    context.theme.brightness == Brightness.dark ||
                                        posContrast(cs.primary, cs.surface) >= 4.5
                                    ? cs.primary
                                    : cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Line in the cart / order panel.
class PosCartLine extends StatelessWidget {
  const PosCartLine({
    super.key,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.onQuantityChanged,
    this.modifiers = const [],
    this.note,
    this.discount = 0,
    this.onRemove,
    this.onTap,
  });

  final String name;
  final int quantity;
  final double unitPrice;
  final ValueChanged<int> onQuantityChanged;
  final List<String> modifiers;
  final String? note;

  /// Absolute discount on the line.
  final double discount;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final total = unitPrice * quantity - discount;
    final content = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${posMoney(unitPrice)} each', style: context.text.bodySmall),
                  if (modifiers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        modifiers.map((m) => '+ $m').join('\n'),
                        style: context.text.bodySmall!.copyWith(color: pos.textMuted),
                      ),
                    ),
                  if (note != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.sticky_note_2_outlined, size: 13, color: pos.warning.color),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              note!,
                              style: context.text.bodySmall!.copyWith(
                                color: pos.warning.onContainer,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  PosQuantityStepper(value: quantity, min: 1, compact: true, onChanged: onQuantityChanged),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  posMoney(total),
                  style: posTabular(context.text.titleSmall!.copyWith(fontWeight: FontWeight.w800)),
                ),
                if (discount > 0)
                  Text(
                    posMoney(unitPrice * quantity),
                    style: context.text.bodySmall!.copyWith(decoration: TextDecoration.lineThrough),
                  ),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(Icons.delete_outline_rounded, color: context.colors.error, size: 20),
                    tooltip: 'Remove',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (onRemove == null) return content;
    return Dismissible(
      key: ValueKey('cart-$name-$modifiers'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove!(),
      background: Container(
        color: pos.danger.color,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        child: Icon(Icons.delete_outline_rounded, color: pos.danger.onColor),
      ),
      child: content,
    );
  }
}

/// Totals block at the bottom of a cart.
class PosCartSummary extends StatelessWidget {
  const PosCartSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    this.discount = 0,
    this.serviceCharge = 0,
    this.taxLabel = 'Tax',
    this.onDiscountTap,
  });

  final double subtotal;
  final double tax;
  final double discount;
  final double serviceCharge;
  final String taxLabel;
  final VoidCallback? onDiscountTap;

  double get total => subtotal - discount + serviceCharge + tax;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    Widget row(String l, String v, {Color? color, VoidCallback? onTap}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: onTap == null
                ? Text(l, style: context.text.bodyMedium!.copyWith(color: pos.textMuted))
                : InkWell(
                    onTap: onTap,
                    child: Text(
                      l,
                      style: context.text.bodyMedium!.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: context.colors.primary,
                      ),
                    ),
                  ),
          ),
          Text(
            v,
            style: posTabular(context.text.bodyMedium!.copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row('Subtotal', posMoney(subtotal)),
        row(
          discount > 0 ? 'Discount' : 'Add discount',
          discount > 0 ? '-${posMoney(discount)}' : '—',
          color: discount > 0 ? pos.success.onContainer : null,
          onTap: onDiscountTap,
        ),
        if (serviceCharge > 0) row('Service charge', posMoney(serviceCharge)),
        row(taxLabel, posMoney(tax)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CustomPaint(size: const Size(double.infinity, 1), painter: _DashPainter(pos.borderStrong)),
        ),
        Row(
          children: [
            Expanded(child: Text('Total', style: context.text.titleLarge)),
            Text(posMoney(total), style: posTabular(context.text.headlineSmall!.copyWith(fontWeight: FontWeight.w800))),
          ],
        ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

/// Payment method option.
@immutable
class PosPaymentMethod {
  const PosPaymentMethod(this.id, this.label, this.icon, {this.subtitle});
  final String id;
  final String label;
  final IconData icon;
  final String? subtitle;

  static const cash = PosPaymentMethod('cash', 'Cash', Icons.payments_outlined);
  static const card = PosPaymentMethod('card', 'Card', Icons.credit_card_rounded, subtitle: 'Tap, chip or swipe');
  static const wallet = PosPaymentMethod('wallet', 'Wallet / QR', Icons.qr_code_2_rounded);
  static const split = PosPaymentMethod('split', 'Split', Icons.call_split_rounded);
  static const giftCard = PosPaymentMethod('gift', 'Gift card', Icons.card_giftcard_rounded);
  static const account = PosPaymentMethod('account', 'On account', Icons.account_balance_wallet_outlined);
  static const defaults = [cash, card, wallet, split, giftCard, account];
}

/// Grid of selectable payment methods.
class PosPaymentMethodSelector extends StatelessWidget {
  const PosPaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.methods = PosPaymentMethod.defaults,
  });

  final String? selected;
  final ValueChanged<String> onChanged;
  final List<PosPaymentMethod> methods;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final pos = context.pos;
    final shape = context.shape;
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 520 ? 3 : 2;
        final w = (c.maxWidth - (cols - 1) * 10) / cols;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final m in methods)
              SizedBox(
                width: w,
                height: 84,
                child: Material(
                  color: selected == m.id ? cs.primaryContainer : cs.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: shape.md,
                    side: BorderSide(
                      color: selected == m.id ? cs.primary : pos.border,
                      width: selected == m.id ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    customBorder: RoundedRectangleBorder(borderRadius: shape.md),
                    onTap: () => onChanged(m.id),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(m.icon, size: 28, color: selected == m.id ? cs.onPrimaryContainer : pos.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.label,
                                  style: context.text.titleSmall!.copyWith(
                                    color: selected == m.id ? cs.onPrimaryContainer : cs.onSurface,
                                  ),
                                ),
                                if (m.subtitle != null)
                                  Text(
                                    m.subtitle!,
                                    style: context.text.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          if (selected == m.id) Icon(Icons.check_circle_rounded, color: cs.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Cash tender panel: due amount, tendered entry with quick-cash buttons,
/// numpad and change due.
class PosCashTender extends StatefulWidget {
  const PosCashTender({super.key, required this.amountDue, required this.onConfirm});
  final double amountDue;
  final ValueChanged<double> onConfirm;

  @override
  State<PosCashTender> createState() => _PosCashTenderState();
}

class _PosCashTenderState extends State<PosCashTender> {
  String _entry = '';

  double get _tendered => double.tryParse(_entry) ?? 0;

  List<double> get _quick {
    final due = widget.amountDue;
    final set = <double>{
      due.ceilToDouble(),
      (due / 5).ceil() * 5,
      (due / 10).ceil() * 10,
      (due / 20).ceil() * 20,
      (due / 50).ceil() * 50,
    };
    return set.where((v) => v >= due).take(4).toList()..sort();
  }

  void _key(String k) {
    setState(() {
      if (k == '.' && _entry.contains('.')) return;
      if (_entry.contains('.') && _entry.split('.').last.length >= 2) return;
      _entry = (_entry == '0' && k != '.') ? k : _entry + k;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final change = _tendered - widget.amountDue;
    final enough = change >= -0.0001;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(label: 'Amount due', value: posMoney(widget.amountDue)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Metric(
                label: enough ? 'Change' : 'Remaining',
                value: posMoney(change.abs()),
                tone: _tendered == 0 ? null : (enough ? pos.success : pos.warning),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: pos.surfaceMuted,
            borderRadius: context.shape.md,
            border: Border.all(color: context.colors.primary, width: 2),
          ),
          child: Row(
            children: [
              Text('Tendered', style: context.text.bodyMedium!.copyWith(color: pos.textMuted)),
              const Spacer(),
              Text(
                _entry.isEmpty ? posMoney(0) : '\$$_entry',
                style: posTabular(context.text.headlineMedium!.copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < _quick.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: PosButton.outline(
                  label: posMoney(_quick[i], decimals: _quick[i] % 1 == 0 ? 0 : 2),
                  size: PosButtonSize.sm,
                  onPressed: () => setState(() => _entry = _quick[i].toStringAsFixed(2)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        PosNumpad(
          onKey: _key,
          keyHeight: 56,
          onBackspace: () => setState(() => _entry = _entry.isEmpty ? '' : _entry.substring(0, _entry.length - 1)),
          onClear: () => setState(() => _entry = ''),
        ),
        const SizedBox(height: 14),
        PosButton(
          label: enough && _tendered > 0 ? 'Complete · change ${posMoney(change)}' : 'Enter amount',
          icon: Icons.check_rounded,
          size: PosButtonSize.xl,
          expand: true,
          variant: PosButtonVariant.success,
          onPressed: enough && _tendered > 0 ? () => widget.onConfirm(_tendered) : null,
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.tone});
  final String label;
  final String value;
  final PosTone? tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: tone?.container ?? context.pos.surfaceMuted, borderRadius: context.shape.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodySmall!.copyWith(color: tone?.onContainer)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: posTabular(
                context.text.headlineSmall!.copyWith(color: tone?.onContainer, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Receipt line for [PosReceipt].
@immutable
class PosReceiptLine {
  const PosReceiptLine(this.name, this.qty, this.total);
  final String name;
  final int qty;
  final double total;
}

/// Paper-style receipt preview.
class PosReceipt extends StatelessWidget {
  const PosReceipt({
    super.key,
    required this.storeName,
    required this.lines,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.address,
    this.orderNo,
    this.cashier,
    this.paidWith,
    this.footer = 'Thank you! Please come again.',
  });

  final String storeName;
  final String? address;
  final String? orderNo;
  final String? cashier;
  final List<PosReceiptLine> lines;
  final double subtotal;
  final double tax;
  final double total;
  final String? paidWith;
  final String footer;

  @override
  Widget build(BuildContext context) {
    const paper = Color(0xFFFFFEFB);
    const ink = Color(0xFF1C1C1C);
    final mono = context.text.bodySmall!.copyWith(fontFamily: 'monospace', color: ink, height: 1.5, fontSize: 12.5);
    Widget kv(String k, String v, {bool bold = false}) => Row(
      children: [
        Expanded(
          child: Text(k, style: mono.copyWith(fontWeight: bold ? FontWeight.w800 : null)),
        ),
        Text(v, style: mono.copyWith(fontWeight: bold ? FontWeight.w800 : null)),
      ],
    );
    Widget dash() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: CustomPaint(size: const Size(double.infinity, 1), painter: _DashPainter(ink.withValues(alpha: 0.4))),
    );
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            storeName.toUpperCase(),
            textAlign: TextAlign.center,
            style: mono.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          if (address != null) Text(address!, textAlign: TextAlign.center, style: mono),
          dash(),
          if (orderNo != null) kv('Order', orderNo!),
          if (cashier != null) kv('Cashier', cashier!),
          dash(),
          for (final l in lines) kv('${l.qty} x ${l.name}', posMoney(l.total)),
          dash(),
          kv('Subtotal', posMoney(subtotal)),
          kv('Tax', posMoney(tax)),
          kv('TOTAL', posMoney(total), bold: true),
          if (paidWith != null) kv('Paid', paidWith!),
          dash(),
          const SizedBox(height: 4),
          Center(
            child: CustomPaint(size: const Size(180, 36), painter: _BarcodePainter(ink)),
          ),
          const SizedBox(height: 8),
          Text(footer, textAlign: TextAlign.center, style: mono),
        ],
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  _BarcodePainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      final w = [1.0, 2.0, 1.0, 3.0, 1.0, 2.0][i % 6];
      if (i.isEven) canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), p);
      x += w + 1;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) => false;
}

/// Customer row (picker results, CRM lists).
class PosCustomerTile extends StatelessWidget {
  const PosCustomerTile({
    super.key,
    required this.name,
    this.phone,
    this.points,
    this.tier,
    this.onTap,
    this.selected = false,
  });

  final String name;
  final String? phone;
  final int? points;
  final String? tier;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: PosAvatar(name: name, size: 40),
      title: Text(name),
      subtitle: phone == null ? null : Text(phone!),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (tier != null) PosStatusPill(label: tier!, tone: PosToneKind.brand, dense: true),
          if (points != null) ...[const SizedBox(height: 4), Text('$points pts', style: context.text.bodySmall)],
        ],
      ),
    );
  }
}
