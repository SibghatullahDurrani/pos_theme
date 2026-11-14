import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});
  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  Set<Object> _sel = {'1046'};
  bool _loading = false;
  bool _empty = false;

  @override
  Widget build(BuildContext context) {
    final columns = <PosColumn<Order>>[
      PosColumn(
        label: 'Order',
        primary: true,
        width: 110,
        sortBy: (o) => o.id,
        cell: (c, o) => Text('#${o.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      PosColumn(
        label: 'Customer',
        flex: 3,
        sortBy: (o) => o.customer,
        cell: (c, o) => Row(
          children: [
            PosAvatar(name: o.customer, size: 28),
            const SizedBox(width: 10),
            Flexible(child: Text(o.customer, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      PosColumn(label: 'Channel', flex: 2, sortBy: (o) => o.channel, cell: (c, o) => Text(o.channel)),
      PosColumn(label: 'Time', width: 80, sortBy: (o) => o.time, cell: (c, o) => Text(o.time)),
      PosColumn(
        label: 'Status',
        flex: 2,
        sortBy: (o) => o.status.index,
        cell: (c, o) => PosStatusPill.order(o.status, dense: true),
      ),
      PosColumn(label: 'Payment', flex: 2, showInCard: false, cell: (c, o) => Text(o.payment)),
      PosColumn(
        label: 'Total',
        width: 100,
        numeric: true,
        sortBy: (o) => o.total,
        cell: (c, o) => Text(posMoney(o.total), style: posTabular(const TextStyle(fontWeight: FontWeight.w700))),
      ),
    ];
    final actions = [
      PosRowAction<Order>(
        label: 'View',
        icon: Icons.visibility_outlined,
        onTap: (o) => PosToast.info(context, 'Open #${o.id}'),
      ),
      PosRowAction<Order>(
        label: 'Print receipt',
        icon: Icons.print_outlined,
        onTap: (o) => PosToast.success(context, 'Printing #${o.id}'),
      ),
      PosRowAction<Order>(label: 'Refund', icon: Icons.undo_rounded, onTap: (o) {}),
      PosRowAction<Order>(label: 'Void', icon: Icons.block_rounded, destructive: true, onTap: (o) {}),
    ];
    return ShowcasePage(
      title: 'Data tables',
      subtitle: 'Sortable, selectable, paginated. Scrolls horizontally on tablets and becomes cards on phones.',
      action: Wrap(
        spacing: 8,
        children: [
          FilterChip(label: const Text('Loading'), selected: _loading, onSelected: (v) => setState(() => _loading = v)),
          FilterChip(label: const Text('Empty'), selected: _empty, onSelected: (v) => setState(() => _empty = v)),
        ],
      ),
      children: [
        if (_sel.isNotEmpty)
          PosAlert(
            tone: PosToneKind.brand,
            message: '${_sel.length} order(s) selected',
            action: Wrap(
              spacing: 8,
              children: [
                PosButton.outline(
                  label: 'Export',
                  size: PosButtonSize.sm,
                  icon: Icons.download_outlined,
                  onPressed: () {},
                ),
                PosButton.ghost(label: 'Clear', size: PosButtonSize.sm, onPressed: () => setState(() => _sel = {})),
              ],
            ),
          ),
        PosDataTable<Order>(
          columns: columns,
          rows: _empty ? const [] : orders,
          rowId: (o) => o.id,
          selectable: true,
          selected: _sel,
          onSelectionChanged: (s) => setState(() => _sel = s),
          onRowTap: (o) => PosToast.show(context, message: 'Order #${o.id} · ${posMoney(o.total)}'),
          actions: actions,
          pageSize: 6,
          loading: _loading,
          emptyTitle: 'No orders yet',
          emptyMessage: 'Orders appear here as soon as the first sale is rung up.',
        ),
        DemoSection(
          title: 'Dense, striped variant',
          child: PosDataTable<Customer>(
            dense: true,
            striped: true,
            rowId: (c) => c.name,
            rows: customers,
            minTableWidth: 600,
            columns: [
              PosColumn(label: 'Name', primary: true, flex: 3, sortBy: (c) => c.name, cell: (ctx, c) => Text(c.name)),
              PosColumn(
                label: 'Tier',
                flex: 2,
                cell: (ctx, c) => PosStatusPill(label: c.tier, tone: PosToneKind.brand, dense: true),
              ),
              PosColumn(
                label: 'Visits',
                width: 80,
                numeric: true,
                sortBy: (c) => c.visits,
                cell: (ctx, c) => Text('${c.visits}'),
              ),
              PosColumn(
                label: 'Spent',
                width: 110,
                numeric: true,
                sortBy: (c) => c.spent,
                cell: (ctx, c) => Text(posMoney(c.spent)),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Material DataTable (themed)',
          description: 'The stock widget also picks up the theme.',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Stock'), numeric: true),
                DataColumn(label: Text('Price'), numeric: true),
              ],
              rows: [
                for (final p in products.take(5))
                  DataRow(
                    cells: [
                      DataCell(Text(p.sku ?? '')),
                      DataCell(Text(p.name)),
                      DataCell(Text('${p.stock}')),
                      DataCell(Text(posMoney(p.price))),
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
