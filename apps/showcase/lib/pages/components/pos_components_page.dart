import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class PosComponentsPage extends StatefulWidget {
  const PosComponentsPage({super.key});
  @override
  State<PosComponentsPage> createState() => _PosComponentsPageState();
}

class _PosComponentsPageState extends State<PosComponentsPage> {
  String? _pay = 'card';
  int _q1 = 2, _q2 = 1;
  String? _table = 'T4';
  final _ticket = [
    PosTicketItem(2, 'Flat White', modifiers: ['Oat milk', 'Large']),
    PosTicketItem(1, 'Avocado Toast', note: 'No chilli', done: true),
    PosTicketItem(1, 'Butter Croissant'),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'POS components',
      subtitle: 'Retail and restaurant building blocks shared across every app in the suite.',
      children: [
        DemoSection(
          title: 'Product tiles',
          description: 'Stock badges, cart quantity, out-of-stock state.',
          child: LayoutBuilder(
            builder: (context, c) {
              final cols = (c.maxWidth / 170).floor().clamp(2, 6);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
                children: [
                  for (final (i, p) in products.take(6).indexed)
                    PosProductTile(
                      name: p.name,
                      price: p.price,
                      category: p.category,
                      stock: p.stock,
                      icon: p.icon,
                      tag: p.tag,
                      quantityInCart: i == 0 ? 2 : 0,
                      onTap: () {},
                    ),
                ],
              );
            },
          ),
        ),
        PosGrid(
          children: [
            PosGridItem(
              medium: 8,
              expanded: 6,
              child: PosCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    PosCartLine(
                      key: const ValueKey('l1'),
                      name: 'Flat White',
                      quantity: _q1,
                      unitPrice: 4.70,
                      modifiers: const ['Large', 'Oat milk'],
                      onQuantityChanged: (v) => setState(() => _q1 = v),
                      onRemove: () {},
                    ),
                    const Divider(),
                    PosCartLine(
                      key: const ValueKey('l2'),
                      name: 'Club Sandwich',
                      quantity: _q2,
                      unitPrice: 11.50,
                      discount: 1.15,
                      note: 'Toasted, no mayo',
                      onQuantityChanged: (v) => setState(() => _q2 = v),
                      onRemove: () {},
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: PosCartSummary(
                        subtotal: _q1 * 4.70 + _q2 * 11.50,
                        discount: 1.15,
                        tax: (_q1 * 4.70 + _q2 * 11.50) * 0.085,
                        onDiscountTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 6,
              child: DemoSection(
                title: 'Payment method',
                child: PosPaymentMethodSelector(selected: _pay, onChanged: (v) => setState(() => _pay = v)),
              ),
            ),
            PosGridItem(
              medium: 4,
              expanded: 4,
              child: DemoSection(
                title: 'Cash tender',
                child: PosCashTender(
                  amountDue: 23.47,
                  onConfirm: (t) => PosToast.success(context, 'Change due ${posMoney(t - 23.47)}'),
                ),
              ),
            ),
            const PosGridItem(
              medium: 4,
              expanded: 4,
              child: DemoSection(
                title: 'Receipt',
                child: Center(
                  child: PosReceipt(
                    storeName: 'Nova Café',
                    address: '12 Market St, San Francisco',
                    orderNo: '#1048',
                    cashier: 'Jordan R.',
                    lines: [PosReceiptLine('Flat White', 2, 9.40), PosReceiptLine('Club Sandwich', 1, 10.35)],
                    subtotal: 19.75,
                    tax: 1.68,
                    total: 21.43,
                    paidWith: 'Visa •••• 4242',
                  ),
                ),
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 4,
              child: PosShiftCard(
                cashier: 'Jordan Rivera',
                openedAt: '08:02',
                openingFloat: 200,
                cashSales: 842.60,
                cardSales: 2310.40,
                onCloseShift: () {},
                onCashMovement: () {},
              ),
            ),
          ],
        ),
        DemoSection(
          title: 'Tables (floor map)',
          child: LayoutBuilder(
            builder: (context, c) {
              final cols = (c.maxWidth / 170).floor().clamp(2, 6);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  for (final t in tables.take(6))
                    Center(
                      child: PosTableTile(
                        name: t.name,
                        seats: t.seats,
                        status: t.status,
                        guests: t.guests,
                        elapsed: t.minutes == null ? null : Duration(minutes: t.minutes!),
                        amount: t.amount,
                        round: t.round,
                        selected: _table == t.name,
                        onTap: () => setState(() => _table = t.name),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        PosGrid(
          children: [
            PosGridItem(
              medium: 4,
              expanded: 4,
              child: PosKitchenTicket(
                orderNo: '1048',
                table: 'T4',
                elapsed: const Duration(minutes: 4),
                items: _ticket,
                onItemToggle: (i) => setState(() => _ticket[i].done = !_ticket[i].done),
                onBump: () {},
              ),
            ),
            PosGridItem(
              medium: 4,
              expanded: 4,
              child: PosKitchenTicket(
                orderNo: '1044',
                channel: 'Takeaway',
                elapsed: const Duration(minutes: 11),
                items: [
                  PosTicketItem(1, 'Margherita Pizza', modifiers: ['Extra basil']),
                  PosTicketItem(2, 'Iced Matcha'),
                ],
                onBump: () {},
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 4,
              child: PosKitchenTicket(
                orderNo: '1039',
                table: 'T7',
                elapsed: const Duration(minutes: 19),
                items: [
                  PosTicketItem(3, 'Caesar Salad', note: 'Dressing on side'),
                  PosTicketItem(2, 'Club Sandwich'),
                ],
                onBump: () {},
              ),
            ),
          ],
        ),
        PosGrid(
          children: [
            PosGridItem(
              medium: 8,
              expanded: 6,
              child: PosCard(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 560,
                  child: PosModifierPicker(
                    itemName: 'Cappuccino',
                    basePrice: 4.00,
                    groups: coffeeModifiers,
                    onAdd: (r) => PosToast.success(context, 'Added ${r.quantity} × Cappuccino · ${posMoney(r.total)}'),
                  ),
                ),
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 6,
              child: DemoSection(
                title: 'Customer tiles',
                child: Column(
                  children: [
                    for (final (i, c) in customers.take(4).indexed)
                      PosCustomerTile(
                        name: c.name,
                        phone: c.phone,
                        points: c.points,
                        tier: c.tier,
                        selected: i == 0,
                        onTap: () {},
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
