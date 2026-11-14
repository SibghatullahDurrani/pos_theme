import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../widgets/page_scaffold.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  String _menuSel = 'orders';
  bool _collapsed = false;
  int _page = 2;
  int _step = 1;
  int _cat = 0;
  int _rail = 0;
  int _bottom = 0;

  static const _demoGroups = [
    PosNavGroup(
      items: [PosNavItem(id: 'home', label: 'Home', icon: Icons.home_outlined)],
    ),
    PosNavGroup(
      title: 'Sales',
      items: [
        PosNavItem(id: 'register', label: 'Register', icon: Icons.point_of_sale_outlined),
        PosNavItem(id: 'orders', label: 'Orders', icon: Icons.receipt_long_outlined, badge: 12),
        PosNavItem(
          id: 'catalog',
          label: 'Catalog',
          icon: Icons.category_outlined,
          children: [
            PosNavItem(id: 'products', label: 'Products', icon: Icons.circle),
            PosNavItem(id: 'modifiers', label: 'Modifiers', icon: Icons.circle),
            PosNavItem(id: 'discounts', label: 'Discounts', icon: Icons.circle),
          ],
        ),
      ],
    ),
    PosNavGroup(
      title: 'Admin',
      items: [
        PosNavItem(id: 'staff', label: 'Staff', icon: Icons.badge_outlined),
        PosNavItem(id: 'settings', label: 'Settings', icon: Icons.settings_outlined),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: ShowcasePage(
        title: 'Navigation',
        subtitle: 'Side menu (grouped, nested, collapsible), top bar, tabs, breadcrumbs, steps, pagination.',
        children: [
          DemoSection(
            title: 'Side menu',
            description:
                'Full on desktop, rail on tablets, drawer on phones. Resize the window to see the main shell adapt.',
            trailing: PosButton.outline(
              label: _collapsed ? 'Expand' : 'Collapse',
              size: PosButtonSize.sm,
              onPressed: () => setState(() => _collapsed = !_collapsed),
            ),
            child: ClipRRect(
              borderRadius: context.shape.md,
              child: SizedBox(
                height: 520,
                child: Row(
                  children: [
                    PosSideMenu(
                      groups: _demoGroups,
                      selectedId: _menuSel,
                      collapsed: _collapsed,
                      onSelect: (id) => setState(() => _menuSel = id),
                      onToggleCollapsed: () => setState(() => _collapsed = !_collapsed),
                    ),
                    Expanded(
                      child: Container(
                        color: context.pos.canvas,
                        alignment: Alignment.center,
                        child: Text('Selected: $_menuSel', style: context.text.titleMedium),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          DemoSection(
            title: 'Top bar',
            child: ClipRRect(
              borderRadius: context.shape.md,
              child: PosTopBar(
                title: 'Orders',
                subtitle: const PosBreadcrumbs(items: ['Home', 'Sales', 'Orders']),
                search: const PosSearchField(),
                actions: [
                  PosIconButton(icon: Icons.notifications_none, badge: '2', onPressed: () {}),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: PosAvatar(name: 'Jordan Rivera', size: 34),
                  ),
                ],
              ),
            ),
          ),
          DemoSection(
            title: 'Tabs',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'All orders'),
                    Tab(text: 'Open (12)'),
                    Tab(text: 'Completed'),
                    Tab(text: 'Refunded'),
                  ],
                ),
                const SizedBox(height: 20),
                const DemoLabel('Category pills'),
                PosCategoryTabs(
                  items: const ['All', 'Coffee', 'Bakery', 'Food', 'Drinks', 'Retail', 'Seasonal'],
                  counts: const [64, 12, 9, 18, 14, 8, 3],
                  selected: _cat,
                  onSelected: (i) => setState(() => _cat = i),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Breadcrumbs, steps & pagination',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PosBreadcrumbs(items: const ['Home', 'Inventory', 'Products', 'Flat White'], onTap: (_) {}),
                const SizedBox(height: 24),
                PosSteps(steps: const ['Cart', 'Customer', 'Payment', 'Receipt'], current: _step),
                const SizedBox(height: 12),
                Row(
                  children: [
                    PosButton.ghost(label: 'Back', onPressed: _step > 0 ? () => setState(() => _step--) : null),
                    PosButton.ghost(label: 'Next', onPressed: _step < 3 ? () => setState(() => _step++) : null),
                  ],
                ),
                const SizedBox(height: 16),
                PosPagination(
                  page: _page,
                  pageCount: 12,
                  onChanged: (p) => setState(() => _page = p),
                  summary: 'Page ${_page + 1} of 12',
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Navigation rail & bottom bar',
            child: Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                ClipRRect(
                  borderRadius: context.shape.md,
                  child: SizedBox(
                    height: 300,
                    child: NavigationRail(
                      selectedIndex: _rail,
                      onDestinationSelected: (i) => setState(() => _rail = i),
                      destinations: const [
                        NavigationRailDestination(icon: Icon(Icons.point_of_sale_outlined), label: Text('Sell')),
                        NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), label: Text('Orders')),
                        NavigationRailDestination(icon: Icon(Icons.inventory_2_outlined), label: Text('Stock')),
                      ],
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: context.shape.md,
                    child: NavigationBar(
                      selectedIndex: _bottom,
                      onDestinationSelected: (i) => setState(() => _bottom = i),
                      destinations: const [
                        NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), label: 'Sell'),
                        NavigationDestination(
                          icon: Badge(label: Text('3'), child: Icon(Icons.receipt_long_outlined)),
                          label: 'Orders',
                        ),
                        NavigationDestination(icon: Icon(Icons.people_outline), label: 'Customers'),
                        NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
