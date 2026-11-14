import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class DataVizPage extends StatelessWidget {
  const DataVizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Charts & KPIs',
      subtitle: 'Dependency-free charts painted with each theme\'s chart palette.',
      children: [
        const PosGrid(
          children: [
            PosGridItem(
              compact: 4,
              medium: 4,
              expanded: 3,
              child: PosStatCard(
                label: 'Net sales',
                value: '\$24,510',
                delta: 0.124,
                icon: Icons.payments_outlined,
                spark: salesThisWeek,
              ),
            ),
            PosGridItem(
              compact: 4,
              medium: 4,
              expanded: 3,
              child: PosStatCard(
                label: 'Orders',
                value: '1,284',
                delta: 0.061,
                icon: Icons.receipt_long_outlined,
                tone: PosToneKind.info,
              ),
            ),
            PosGridItem(
              compact: 4,
              medium: 4,
              expanded: 3,
              child: PosStatCard(
                label: 'Avg. ticket',
                value: '\$19.08',
                delta: -0.023,
                icon: Icons.shopping_basket_outlined,
                tone: PosToneKind.warning,
              ),
            ),
            PosGridItem(
              compact: 4,
              medium: 4,
              expanded: 3,
              child: PosStatCard(
                label: 'Refunds',
                value: '\$312',
                delta: -0.18,
                icon: Icons.undo_rounded,
                tone: PosToneKind.danger,
                caption: 'vs last month',
              ),
            ),
          ],
        ),
        const DemoSection(
          title: 'Line / area',
          child: PosLineChart(
            series: [salesThisWeek, salesLastWeek],
            labels: weekLabels,
            legend: ['This week', 'Last week'],
          ),
        ),
        PosGrid(
          children: [
            const PosGridItem(
              medium: 8,
              expanded: 7,
              child: DemoSection(
                title: 'Bar',
                description: 'Sales by hour',
                child: PosBarChart(values: hourlySales, labels: hourlyLabels, highlightIndex: 4),
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 5,
              child: DemoSection(
                title: 'Donut',
                description: 'Payment mix',
                child: PosDonutChart(
                  values: const [46, 31, 15, 8],
                  labels: const ['Card', 'Cash', 'Wallet', 'Gift card'],
                  centerValue: posMoney(24510, decimals: 0),
                  centerLabel: 'Total',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
