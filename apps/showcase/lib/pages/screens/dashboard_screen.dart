import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Set<String> _range = {'week'};

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Good afternoon, Jordan',
      subtitle: 'Here’s how Store #12 is doing today.',
      action: context.window.atLeastMedium
          ? SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'day', label: Text('Today')),
                ButtonSegment(value: 'week', label: Text('Week')),
                ButtonSegment(value: 'month', label: Text('Month')),
              ],
              selected: _range,
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _range = s),
            )
          : null,
      children: [
        const PosAlert(
          tone: PosToneKind.warning,
          title: '4 items low on stock',
          message: 'Cold Brew, Fresh Orange Juice, Ceramic Mug and Almond Danish need reordering.',
        ),
        const PosGrid(
          children: [
            PosGridItem(
              compact: 2,
              medium: 4,
              expanded: 3,
              child: PosStatCard(
                label: 'Net sales',
                value: '\$4,180',
                delta: 0.124,
                icon: Icons.payments_outlined,
                spark: salesThisWeek,
              ),
            ),
            PosGridItem(
              compact: 2,
              medium: 4,
              expanded: 3,
              child: PosStatCard(
                label: 'Orders',
                value: '214',
                delta: 0.081,
                icon: Icons.receipt_long_outlined,
                tone: PosToneKind.info,
              ),
            ),
            PosGridItem(
              compact: 2,
              medium: 4,
              expanded: 3,
              child: PosStatCard(
                label: 'Avg. ticket',
                value: '\$19.53',
                delta: -0.021,
                icon: Icons.shopping_basket_outlined,
                tone: PosToneKind.warning,
              ),
            ),
            PosGridItem(
              compact: 2,
              medium: 4,
              expanded: 3,
              child: PosStatCard(
                label: 'New customers',
                value: '38',
                delta: 0.27,
                icon: Icons.person_add_alt,
                tone: PosToneKind.success,
              ),
            ),
          ],
        ),
        PosGrid(
          children: [
            const PosGridItem(
              medium: 8,
              expanded: 8,
              child: DemoSection(
                title: 'Revenue',
                description: 'This week vs last week',
                child: PosLineChart(
                  series: [salesThisWeek, salesLastWeek],
                  labels: weekLabels,
                  legend: ['This week', 'Last week'],
                  height: 240,
                ),
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 4,
              child: DemoSection(
                title: 'Payment mix',
                child: PosDonutChart(
                  values: const [46, 31, 15, 8],
                  labels: const ['Card', 'Cash', 'Wallet', 'Gift'],
                  centerValue: posMoney(4180, decimals: 0),
                  centerLabel: 'Today',
                  size: 150,
                ),
              ),
            ),
          ],
        ),
        PosGrid(
          children: [
            PosGridItem(
              medium: 8,
              expanded: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Recent orders', style: context.text.titleMedium),
                  const SizedBox(height: 10),
                  PosDataTable<Order>(
                    rows: orders.take(6).toList(),
                    rowId: (o) => o.id,
                    minTableWidth: 600,
                    onRowTap: (o) {},
                    columns: [
                      PosColumn(
                        label: 'Order',
                        primary: true,
                        width: 90,
                        cell: (c, o) => Text('#${o.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      PosColumn(label: 'Customer', flex: 3, cell: (c, o) => Text(o.customer)),
                      PosColumn(label: 'Status', flex: 2, cell: (c, o) => PosStatusPill.order(o.status, dense: true)),
                      PosColumn(label: 'Total', width: 90, numeric: true, cell: (c, o) => Text(posMoney(o.total))),
                    ],
                  ),
                ],
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DemoSection(
                    title: 'Sales by hour',
                    child: PosBarChart(values: hourlySales, labels: hourlyLabels, highlightIndex: 4, height: 160),
                  ),
                  const SizedBox(height: 20),
                  DemoSection(
                    title: 'Top products',
                    child: Column(
                      children: [
                        for (final (i, p) in products.take(5).indexed)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  child: Text(
                                    '${i + 1}',
                                    style: context.text.labelLarge!.copyWith(color: context.pos.textMuted),
                                  ),
                                ),
                                Expanded(child: Text(p.name, style: context.text.bodyMedium)),
                                SizedBox(width: 80, child: LinearProgressIndicator(value: 1 - i * 0.17)),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '${120 - i * 19}',
                                    textAlign: TextAlign.end,
                                    style: context.text.labelMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
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
