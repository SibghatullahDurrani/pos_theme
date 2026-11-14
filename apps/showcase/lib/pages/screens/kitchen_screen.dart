import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

/// Kitchen display: masonry-like columns of tickets.
class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});
  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  int _station = 0;
  late final List<(String, String?, String, int, List<PosTicketItem>)> _tickets = [
    (
      '1049',
      'T4',
      'Dine-in',
      2,
      [PosTicketItem(2, 'Margherita Pizza'), PosTicketItem(1, 'Caesar Salad', note: 'No croutons')],
    ),
    (
      '1048',
      'T1',
      'Dine-in',
      6,
      [
        PosTicketItem(2, 'Flat White', modifiers: ['Oat', 'Large']),
        PosTicketItem(1, 'Avocado Toast', done: true),
      ],
    ),
    (
      '1046',
      null,
      'Delivery',
      9,
      [PosTicketItem(3, 'Club Sandwich'), PosTicketItem(2, 'Fresh Orange Juice'), PosTicketItem(1, 'Almond Danish')],
    ),
    (
      '1045',
      'T7',
      'Dine-in',
      13,
      [
        PosTicketItem(4, 'Margherita Pizza', modifiers: ['Extra mozzarella']),
        PosTicketItem(2, 'Caesar Salad'),
      ],
    ),
    (
      '1044',
      null,
      'Takeaway',
      17,
      [PosTicketItem(1, 'Iced Matcha'), PosTicketItem(1, 'Butter Croissant', note: 'Warm it up')],
    ),
    ('1043', 'T11', 'Dine-in', 21, [PosTicketItem(2, 'Club Sandwich', done: true), PosTicketItem(1, 'Avocado Toast')]),
  ];

  @override
  Widget build(BuildContext context) {
    final g = context.window.gutter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(g, g, g, 8),
          child: LayoutBuilder(
            builder: (context, c) => Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: c.maxWidth < 420 ? c.maxWidth : 420,
                  child: PosCategoryTabs(
                    items: const ['All stations', 'Grill', 'Pizza', 'Bar'],
                    selected: _station,
                    onSelected: (i) => setState(() => _station = i),
                  ),
                ),
                const PosStatusPill(label: '< 8 min', tone: PosToneKind.success, dot: true),
                const PosStatusPill(label: '8–15 min', tone: PosToneKind.warning, dot: true),
                const PosStatusPill(label: '> 15 min', tone: PosToneKind.danger, dot: true),
              ],
            ),
          ),
        ),
        Expanded(
          child: _tickets.isEmpty
              ? const PosEmptyState(
                  title: 'All caught up',
                  message: 'New tickets will appear here.',
                  icon: Icons.soup_kitchen_outlined,
                )
              : LayoutBuilder(
                  builder: (context, c) {
                    final cols = (c.maxWidth / 300).floor().clamp(1, 5);
                    final columns = List.generate(cols, (_) => <Widget>[]);
                    for (var i = 0; i < _tickets.length; i++) {
                      final (no, table, ch, min, items) = _tickets[i];
                      columns[i % cols].add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: PosKitchenTicket(
                            orderNo: no,
                            table: table,
                            channel: ch,
                            elapsed: Duration(minutes: min),
                            items: items,
                            onItemToggle: (j) => setState(() => items[j].done = !items[j].done),
                            onBump: () {
                              if (items.every((e) => e.done)) {
                                setState(() => _tickets.removeAt(i));
                                PosToast.success(context, 'Order #$no bumped');
                              } else {
                                setState(() {
                                  for (final e in items) {
                                    e.done = true;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(g, 8, g, g),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < cols; i++) ...[
                            if (i > 0) const SizedBox(width: 14),
                            Expanded(child: Column(children: columns[i])),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
