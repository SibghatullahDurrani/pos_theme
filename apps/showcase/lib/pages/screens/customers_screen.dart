import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

/// Master–detail: list + profile side by side on wide, push on phones.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  Customer _sel = customers.first;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final list = ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 12),
              child: PosSearchField(hint: 'Search customers'),
            ),
            for (final cu in customers)
              PosCustomerTile(
                name: cu.name,
                phone: cu.phone,
                points: cu.points,
                tier: cu.tier,
                selected: wide && cu == _sel,
                onTap: () {
                  setState(() => _sel = cu);
                  if (!wide) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: Text(cu.name)),
                          body: _Profile(customer: cu),
                        ),
                      ),
                    );
                  }
                },
              ),
          ],
        );
        if (!wide) return list;
        return Row(
          children: [
            Container(
              width: 360,
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: BorderDirectional(end: BorderSide(color: context.pos.border)),
              ),
              child: list,
            ),
            Expanded(child: _Profile(customer: _sel)),
          ],
        );
      },
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final c = customer;
    return ShowcasePage(
      title: c.name,
      subtitle: '${c.email} · ${c.phone}',
      action: context.window.atLeastMedium
          ? PosButton(label: 'New sale', icon: Icons.point_of_sale, onPressed: () {})
          : null,
      children: [
        PosCard(
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PosAvatar(name: c.name, size: 72, online: true),
              _Stat('Tier', c.tier),
              _Stat('Points', '${c.points}'),
              _Stat('Visits', '${c.visits}'),
              _Stat('Lifetime spend', posMoney(c.spent)),
            ],
          ),
        ),
        PosCard(
          title: 'Loyalty progress',
          subtitle: '${2000 - c.points.clamp(0, 2000)} points to Platinum',
          child: LinearProgressIndicator(value: (c.points / 2000).clamp(0, 1)),
        ),
        PosCard(
          title: 'Order history',
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Column(
            children: [
              for (final o in orders.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text('#${o.id} · ${o.items} items'),
                  subtitle: Text('${o.channel} · ${o.time}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(posMoney(o.total), style: posTabular(context.text.titleSmall!)),
                      PosStatusPill.order(o.status, dense: true),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: context.text.bodySmall),
      Text(value, style: posTabular(context.text.titleLarge!)),
    ],
  );
}
