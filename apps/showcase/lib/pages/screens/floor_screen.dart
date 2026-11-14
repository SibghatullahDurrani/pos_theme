import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';

/// Restaurant floor plan with table detail panel (side panel on wide, sheet on phones).
class FloorScreen extends StatefulWidget {
  const FloorScreen({super.key});
  @override
  State<FloorScreen> createState() => _FloorScreenState();
}

class _FloorScreenState extends State<FloorScreen> {
  int _floor = 0;
  DiningTable? _sel = tables[3];
  PosTableStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 1000;
        final map = _map(context, wide);
        if (!wide) return map;
        return Row(
          children: [
            Expanded(child: map),
            Container(
              width: 360,
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: BorderDirectional(start: BorderSide(color: context.pos.border)),
              ),
              child: _sel == null
                  ? const PosEmptyState(
                      title: 'Select a table',
                      message: 'Tap a table to see its order.',
                      icon: Icons.table_restaurant_outlined,
                    )
                  : _detail(context, _sel!),
            ),
          ],
        );
      },
    );
  }

  Widget _map(BuildContext context, bool wide) {
    final g = context.window.gutter;
    final visible = tables.where((t) => _filter == null || t.status == _filter).toList();
    final counts = {for (final s in PosTableStatus.values) s: tables.where((t) => t.status == s).length};
    return ListView(
      padding: EdgeInsets.all(g),
      children: [
        PosCategoryTabs(
          items: floors,
          selected: _floor,
          onSelected: (i) => setState(() => _floor = i),
          counts: const [12, 8, 6],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text('All ${tables.length}'),
              selected: _filter == null,
              onSelected: (_) => setState(() => _filter = null),
            ),
            for (final s in PosTableStatus.values)
              ChoiceChip(
                avatar: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: s.tone.of(context).color, shape: BoxShape.circle),
                ),
                label: Text('${s.label} ${counts[s]}'),
                selected: _filter == s,
                onSelected: (_) => setState(() => _filter = s),
              ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final cols = (c.maxWidth / 180).floor().clamp(2, 6);
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.25,
              children: [
                for (final t in visible)
                  Center(
                    child: PosTableTile(
                      name: t.name,
                      seats: t.seats,
                      status: t.status,
                      guests: t.guests,
                      elapsed: t.minutes == null ? null : Duration(minutes: t.minutes!),
                      amount: t.amount,
                      round: t.round,
                      selected: _sel == t,
                      onTap: () {
                        setState(() => _sel = t);
                        if (!wide) {
                          showPosSheet<void>(
                            context,
                            builder: (ctx) =>
                                SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.7, child: _detail(ctx, t)),
                          );
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _detail(BuildContext context, DiningTable t) {
    final busy = t.amount != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Table ${t.name}', style: context.text.headlineSmall),
                    Text(
                      '${t.guests ?? 0} of ${t.seats} guests${t.minutes != null ? ' · ${t.minutes} min' : ''}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              PosStatusPill.table(t.status),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: busy
              ? ListView(
                  children: [
                    for (final (q, n, p) in [
                      (2, 'Margherita Pizza', 13.0),
                      (1, 'Caesar Salad', 10.9),
                      (3, 'Sparkling Water', 2.5),
                    ])
                      ListTile(
                        leading: Text('$q×', style: context.text.titleSmall),
                        title: Text(n),
                        trailing: Text(posMoney(q * p), style: posTabular(context.text.bodyMedium!)),
                      ),
                  ],
                )
              : PosEmptyState(
                  compact: true,
                  title: t.status == PosTableStatus.reserved ? 'Reserved 19:30' : 'Table is free',
                  message: t.status == PosTableStatus.reserved ? 'Party of 4 · Chen' : 'Seat guests to start an order.',
                  icon: Icons.event_seat_outlined,
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.pos.border)),
          ),
          child: busy
              ? Column(
                  children: [
                    PosCartSummary(subtotal: t.amount! / 1.085, tax: t.amount! - t.amount! / 1.085, serviceCharge: 0),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PosButton.outline(
                            label: 'Split bill',
                            icon: Icons.call_split,
                            onPressed: () => _split(context, t),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PosButton(label: 'Pay', icon: Icons.payments_outlined, onPressed: () {}),
                        ),
                      ],
                    ),
                  ],
                )
              : PosButton(
                  label: 'Seat guests',
                  icon: Icons.group_add_outlined,
                  size: PosButtonSize.lg,
                  expand: true,
                  onPressed: () {},
                ),
        ),
      ],
    );
  }

  void _split(BuildContext context, DiningTable t) {
    showPosAdaptiveDialog<void>(context, builder: (ctx) => _SplitDialog(total: t.amount!));
  }
}

class _SplitDialog extends StatefulWidget {
  const _SplitDialog({required this.total});
  final double total;
  @override
  State<_SplitDialog> createState() => _SplitDialogState();
}

class _SplitDialogState extends State<_SplitDialog> {
  int _ways = 2;
  Set<String> _mode = {'even'};

  @override
  Widget build(BuildContext context) {
    final each = widget.total / _ways;
    return PosDialog(
      title: 'Split bill',
      message: 'Total ${posMoney(widget.total)}',
      maxWidth: 460,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'even', label: Text('Evenly')),
              ButtonSegment(value: 'item', label: Text('By item')),
              ButtonSegment(value: 'seat', label: Text('By seat')),
            ],
            selected: _mode,
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _mode = s),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text('Number of guests', style: context.text.titleSmall)),
              PosQuantityStepper(value: _ways, min: 2, max: 12, onChanged: (v) => setState(() => _ways = v)),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _ways; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PosCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    PosAvatar(name: 'Guest ${i + 1}', size: 32),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Guest ${i + 1}')),
                    Text(posMoney(each), style: posTabular(context.text.titleSmall!)),
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: [
        PosButton.outline(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        PosButton(label: 'Create $_ways checks', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
