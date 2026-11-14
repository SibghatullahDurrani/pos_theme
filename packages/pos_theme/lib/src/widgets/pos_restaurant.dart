import 'package:flutter/material.dart';

import '../tokens/pos_tokens.dart';
import '../utils/pos_format.dart';
import 'pos_badge.dart';
import 'pos_button.dart';
import 'pos_inputs.dart';

String _elapsed(Duration d) {
  final m = d.inMinutes;
  if (m < 60) return '${m}m';
  return '${d.inHours}h ${m % 60}m';
}

/// Table on the floor map.
class PosTableTile extends StatelessWidget {
  const PosTableTile({
    super.key,
    required this.name,
    required this.seats,
    required this.status,
    this.guests,
    this.elapsed,
    this.amount,
    this.server,
    this.round = false,
    this.onTap,
    this.selected = false,
  });

  final String name;
  final int seats;
  final PosTableStatus status;
  final int? guests;
  final Duration? elapsed;
  final double? amount;
  final String? server;
  final bool round;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = status.tone.of(context);
    final cs = context.colors;
    final shape = context.shape;
    final radius = round ? BorderRadius.circular(999) : shape.lg;
    final busy = status == PosTableStatus.occupied || status == PosTableStatus.billing;
    return AspectRatio(
      aspectRatio: round ? 1 : 1.25,
      child: AnimatedContainer(
        duration: PosMotion.fast,
        decoration: BoxDecoration(
          color: busy ? t.container : cs.surface,
          borderRadius: radius,
          border: Border.all(
            color: selected ? cs.primary : t.color.withValues(alpha: busy ? 0.6 : 0.45),
            width: selected ? 3 : 1.5,
          ),
          boxShadow: shape.shadowsSm,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                if (!round)
                  PositionedDirectional(top: 0, start: 0, bottom: 0, child: Container(width: 5, color: t.color)),
                Padding(
                  padding: EdgeInsets.all(round ? 8 : 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: round ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: round ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: context.text.titleLarge!.copyWith(color: busy ? t.onContainer : cs.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!round) ...[
                            const Spacer(),
                            Icon(Icons.people_alt_outlined, size: 14, color: context.pos.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              guests != null ? '$guests/$seats' : '$seats',
                              style: context.text.labelMedium,
                              maxLines: 1,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: FittedBox(fit: BoxFit.scaleDown, child: PosStatusPill.table(status, dense: true)),
                      ),
                      if (!round && (elapsed != null || amount != null)) ...[
                        const Spacer(),
                        Row(
                          children: [
                            if (elapsed != null) ...[
                              Icon(Icons.schedule_rounded, size: 13, color: context.pos.textMuted),
                              const SizedBox(width: 3),
                              Flexible(child: Text(_elapsed(elapsed!), style: context.text.labelMedium, maxLines: 1)),
                            ],
                            const Spacer(),
                            if (amount != null)
                              Flexible(
                                flex: 3,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: Text(
                                    posMoney(amount!),
                                    style: posTabular(context.text.labelLarge!.copyWith(fontWeight: FontWeight.w800)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
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

/// A line on a kitchen ticket.
class PosTicketItem {
  PosTicketItem(this.qty, this.name, {this.modifiers = const [], this.note, this.done = false});
  final int qty;
  final String name;
  final List<String> modifiers;
  final String? note;
  bool done;
}

/// Kitchen display (KDS) ticket. Header colour escalates with elapsed time.
class PosKitchenTicket extends StatelessWidget {
  const PosKitchenTicket({
    super.key,
    required this.orderNo,
    required this.items,
    required this.elapsed,
    this.table,
    this.channel = 'Dine-in',
    this.onBump,
    this.onItemToggle,
    this.warnAfter = const Duration(minutes: 8),
    this.lateAfter = const Duration(minutes: 15),
  });

  final String orderNo;
  final String? table;
  final String channel;
  final Duration elapsed;
  final List<PosTicketItem> items;
  final VoidCallback? onBump;
  final ValueChanged<int>? onItemToggle;
  final Duration warnAfter;
  final Duration lateAfter;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final tone = elapsed >= lateAfter
        ? pos.danger
        : elapsed >= warnAfter
        ? pos.warning
        : pos.success;
    final shape = context.shape;
    final allDone = items.every((i) => i.done);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: shape.lg,
        border: Border.all(color: tone.color.withValues(alpha: 0.7), width: 1.5),
        boxShadow: shape.shadowsSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: tone.color,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Text(
                  '#$orderNo',
                  style: context.text.titleMedium!.copyWith(color: tone.onColor, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    [channel, ?table].join(' · '),
                    style: context.text.labelLarge!.copyWith(color: tone.onColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.timer_outlined, size: 16, color: tone.onColor),
                const SizedBox(width: 4),
                Text(
                  _elapsed(elapsed),
                  style: posTabular(
                    context.text.labelLarge!.copyWith(color: tone.onColor, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++)
            InkWell(
              onTap: onItemToggle == null ? null : () => onItemToggle!(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: i == 0 ? null : Border(top: BorderSide(color: pos.border)),
                ),
                child: Opacity(
                  opacity: items[i].done ? 0.45 : 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${items[i].qty}×',
                          style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].name,
                              style: context.text.titleSmall!.copyWith(
                                decoration: items[i].done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            for (final m in items[i].modifiers) Text('• $m', style: context.text.bodySmall),
                            if (items[i].note != null)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: pos.warning.container, borderRadius: shape.xs),
                                child: Text(
                                  items[i].note!,
                                  style: context.text.labelMedium!.copyWith(color: pos.warning.onContainer),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (items[i].done) Icon(Icons.check_circle_rounded, color: pos.success.color, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          if (onBump != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: PosButton(
                label: allDone ? 'Bump order' : 'Mark all ready',
                icon: allDone ? Icons.done_all_rounded : Icons.check_rounded,
                variant: allDone ? PosButtonVariant.success : PosButtonVariant.secondary,
                expand: true,
                onPressed: onBump,
              ),
            ),
        ],
      ),
    );
  }
}

/// Modifier option.
@immutable
class PosModifierOption {
  const PosModifierOption(this.id, this.label, {this.price = 0});
  final String id;
  final String label;
  final double price;
}

/// Modifier group (e.g. "Size" required single, "Extras" optional multi).
@immutable
class PosModifierGroup {
  const PosModifierGroup({
    required this.id,
    required this.title,
    required this.options,
    this.required = false,
    this.multiple = false,
    this.max,
  });
  final String id;
  final String title;
  final List<PosModifierOption> options;
  final bool required;
  final bool multiple;
  final int? max;
}

/// Result returned by [PosModifierPicker].
class PosModifierResult {
  PosModifierResult(this.quantity, this.selected, this.note, this.total);
  final int quantity;
  final Map<String, Set<String>> selected;
  final String note;
  final double total;
}

/// Item customisation panel: groups of modifiers, quantity, note, add button.
class PosModifierPicker extends StatefulWidget {
  const PosModifierPicker({
    super.key,
    required this.itemName,
    required this.basePrice,
    required this.groups,
    required this.onAdd,
  });

  final String itemName;
  final double basePrice;
  final List<PosModifierGroup> groups;
  final ValueChanged<PosModifierResult> onAdd;

  @override
  State<PosModifierPicker> createState() => _PosModifierPickerState();
}

class _PosModifierPickerState extends State<PosModifierPicker> {
  late final Map<String, Set<String>> _sel = {
    for (final g in widget.groups) g.id: {if (g.required && !g.multiple) g.options.first.id},
  };
  int _qty = 1;
  String _note = '';

  double get _unit {
    var t = widget.basePrice;
    for (final g in widget.groups) {
      for (final o in g.options) {
        if (_sel[g.id]!.contains(o.id)) t += o.price;
      }
    }
    return t;
  }

  bool get _valid => widget.groups.every((g) => !g.required || _sel[g.id]!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              Text(widget.itemName, style: context.text.headlineSmall),
              Text(posMoney(widget.basePrice), style: context.text.bodyMedium!.copyWith(color: pos.textMuted)),
              for (final g in widget.groups) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: Text(g.title, style: context.text.titleMedium)),
                    PosStatusPill(
                      label: g.required ? 'Required' : (g.max != null ? 'Up to ${g.max}' : 'Optional'),
                      tone: g.required
                          ? (_sel[g.id]!.isEmpty ? PosToneKind.danger : PosToneKind.success)
                          : PosToneKind.neutral,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final o in g.options)
                      FilterChip(
                        selected: _sel[g.id]!.contains(o.id),
                        showCheckmark: g.multiple,
                        label: Text(o.price == 0 ? o.label : '${o.label}  +${posMoney(o.price)}'),
                        onSelected: (v) => setState(() {
                          final s = _sel[g.id]!;
                          if (g.multiple) {
                            if (v && (g.max == null || s.length < g.max!)) {
                              s.add(o.id);
                            } else {
                              s.remove(o.id);
                            }
                          } else {
                            if (v) {
                              s
                                ..clear()
                                ..add(o.id);
                            } else if (!g.required) {
                              s.remove(o.id);
                            }
                          }
                        }),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              PosTextField(label: 'Kitchen note', hint: 'e.g. no onions, allergy…', onChanged: (v) => _note = v),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: pos.border)),
          ),
          child: Row(
            children: [
              PosQuantityStepper(value: _qty, min: 1, onChanged: (v) => setState(() => _qty = v)),
              const SizedBox(width: 12),
              Expanded(
                child: PosButton(
                  label: 'Add · ${posMoney(_unit * _qty)}',
                  icon: Icons.add_shopping_cart_rounded,
                  size: PosButtonSize.lg,
                  expand: true,
                  onPressed: _valid ? () => widget.onAdd(PosModifierResult(_qty, _sel, _note, _unit * _qty)) : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shift / cash drawer summary card.
class PosShiftCard extends StatelessWidget {
  const PosShiftCard({
    super.key,
    required this.cashier,
    required this.openedAt,
    required this.openingFloat,
    required this.cashSales,
    required this.cardSales,
    this.onCloseShift,
    this.onCashMovement,
  });

  final String cashier;
  final String openedAt;
  final double openingFloat;
  final double cashSales;
  final double cardSales;
  final VoidCallback? onCloseShift;
  final VoidCallback? onCashMovement;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final shape = context.shape;
    Widget kv(String k, double v, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(k, style: context.text.bodyMedium!.copyWith(color: strong ? null : pos.textMuted)),
          ),
          Text(
            posMoney(v),
            style: posTabular(
              (strong ? context.text.titleMedium : context.text.bodyMedium)!.copyWith(
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: shape.lg,
        border: Border.all(color: pos.border),
        boxShadow: shape.shadowsSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PosAvatar(name: cashier, size: 40, online: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cashier, style: context.text.titleSmall),
                    Text('Shift opened $openedAt', style: context.text.bodySmall),
                  ],
                ),
              ),
              const PosStatusPill(label: 'Open', tone: PosToneKind.success, dot: true),
            ],
          ),
          const SizedBox(height: 14),
          kv('Opening float', openingFloat),
          kv('Cash sales', cashSales),
          kv('Card sales', cardSales),
          const Divider(height: 20),
          kv('Expected in drawer', openingFloat + cashSales, strong: true),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PosButton.outline(
                  label: 'Cash in/out',
                  icon: Icons.swap_vert_rounded,
                  onPressed: onCashMovement,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PosButton.danger(
                  label: 'Close shift',
                  icon: Icons.lock_outline_rounded,
                  onPressed: onCloseShift,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
