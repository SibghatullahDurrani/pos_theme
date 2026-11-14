import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import 'pages/components/buttons_page.dart';
import 'pages/components/data_viz_page.dart';
import 'pages/components/feedback_page.dart';
import 'pages/components/inputs_page.dart';
import 'pages/components/navigation_page.dart';
import 'pages/components/overlays_page.dart';
import 'pages/components/pos_components_page.dart';
import 'pages/components/tables_page.dart';
import 'pages/foundations/foundations_page.dart';
import 'pages/gallery_page.dart';
import 'pages/screens/checkout_screen.dart';
import 'pages/screens/customers_screen.dart';
import 'pages/screens/dashboard_screen.dart';
import 'pages/screens/floor_screen.dart';
import 'pages/screens/inventory_screen.dart';
import 'pages/screens/kitchen_screen.dart';
import 'pages/screens/lock_screen.dart';
import 'pages/screens/settings_screen.dart';
import 'widgets/theme_switcher.dart';

const navGroups = [
  PosNavGroup(
    items: [
      PosNavItem(
        id: 'gallery',
        label: 'Theme Gallery',
        icon: Icons.palette_outlined,
        selectedIcon: Icons.palette_rounded,
      ),
    ],
  ),
  PosNavGroup(
    title: 'Sample screens',
    items: [
      PosNavItem(
        id: 'dashboard',
        label: 'Dashboard',
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard_rounded,
      ),
      PosNavItem(
        id: 'checkout',
        label: 'Checkout',
        icon: Icons.point_of_sale_outlined,
        selectedIcon: Icons.point_of_sale_rounded,
      ),
      PosNavItem(
        id: 'floor',
        label: 'Floor plan',
        icon: Icons.table_restaurant_outlined,
        selectedIcon: Icons.table_restaurant_rounded,
        badge: 4,
      ),
      PosNavItem(
        id: 'kitchen',
        label: 'Kitchen display',
        icon: Icons.soup_kitchen_outlined,
        selectedIcon: Icons.soup_kitchen_rounded,
        badge: 6,
      ),
      PosNavItem(
        id: 'inventory',
        label: 'Inventory',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
      ),
      PosNavItem(
        id: 'customers',
        label: 'Customers',
        icon: Icons.people_alt_outlined,
        selectedIcon: Icons.people_alt_rounded,
      ),
      PosNavItem(
        id: 'settings',
        label: 'Settings',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
      ),
      PosNavItem(id: 'lock', label: 'Lock screen', icon: Icons.lock_outline_rounded),
    ],
  ),
  PosNavGroup(
    title: 'Design system',
    items: [
      PosNavItem(
        id: 'foundations',
        label: 'Foundations',
        icon: Icons.format_paint_outlined,
        selectedIcon: Icons.format_paint_rounded,
      ),
      PosNavItem(
        id: 'components',
        label: 'Components',
        icon: Icons.widgets_outlined,
        selectedIcon: Icons.widgets_rounded,
        children: [
          PosNavItem(id: 'buttons', label: 'Buttons', icon: Icons.smart_button_outlined),
          PosNavItem(id: 'inputs', label: 'Inputs & selects', icon: Icons.edit_note_rounded),
          PosNavItem(id: 'tables', label: 'Data tables', icon: Icons.table_chart_outlined),
          PosNavItem(id: 'navigation', label: 'Navigation', icon: Icons.menu_open_rounded),
          PosNavItem(id: 'overlays', label: 'Dialogs & popups', icon: Icons.layers_outlined),
          PosNavItem(id: 'feedback', label: 'Feedback & status', icon: Icons.notifications_none_rounded),
          PosNavItem(id: 'dataviz', label: 'Charts & KPIs', icon: Icons.insert_chart_outlined),
          PosNavItem(id: 'pos', label: 'POS components', icon: Icons.storefront_outlined),
        ],
      ),
    ],
  ),
];

const _titles = {
  'gallery': 'Theme Gallery',
  'dashboard': 'Dashboard',
  'checkout': 'Checkout',
  'floor': 'Floor plan',
  'kitchen': 'Kitchen display',
  'inventory': 'Inventory',
  'customers': 'Customers',
  'settings': 'Settings',
  'foundations': 'Foundations',
  'buttons': 'Buttons',
  'inputs': 'Inputs & selects',
  'tables': 'Data tables',
  'navigation': 'Navigation',
  'overlays': 'Dialogs & popups',
  'feedback': 'Feedback & status',
  'dataviz': 'Charts & KPIs',
  'pos': 'POS components',
};

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initial = 'gallery'});
  final String initial;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late String _selected = widget.initial;

  Widget _page(String id) => switch (id) {
    'dashboard' => const DashboardScreen(),
    'checkout' => const CheckoutScreen(),
    'floor' => const FloorScreen(),
    'kitchen' => const KitchenScreen(),
    'inventory' => const InventoryScreen(),
    'customers' => const CustomersScreen(),
    'settings' => const SettingsScreen(),
    'foundations' => const FoundationsPage(),
    'buttons' => const ButtonsPage(),
    'inputs' => const InputsPage(),
    'tables' => const TablesPage(),
    'navigation' => const NavigationPage(),
    'overlays' => const OverlaysPage(),
    'feedback' => const FeedbackPage(),
    'dataviz' => const DataVizPage(),
    'pos' => const PosComponentsPage(),
    _ => GalleryPage(onOpen: _select),
  };

  void _select(String id) {
    if (id == 'lock') {
      Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const LockScreen()));
      return;
    }
    setState(() => _selected = id);
  }

  @override
  Widget build(BuildContext context) {
    final spec = PosThemeScope.of(context).spec;
    return PosAdaptiveScaffold(
      groups: navGroups,
      selectedId: _selected,
      onSelect: _select,
      bottomNavIds: const ['dashboard', 'checkout', 'floor', 'gallery'],
      header: (context, collapsed) => _Brand(collapsed: collapsed, themeName: spec.name),
      footer: (context, collapsed) => _UserFooter(collapsed: collapsed),
      topBarBuilder: (context, window, openMenu) => PosTopBar(
        title: _titles[_selected] ?? '',
        subtitle: PosBreadcrumbs(items: ['Store #12', spec.name, _titles[_selected] ?? '']),
        onMenu: openMenu,
        search: const PosSearchField(hint: 'Search products, orders…', shortcutHint: 'Ctrl K'),
        actions: [
          if (window.atLeastMedium)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: PosStatusPill(label: 'Online', tone: PosToneKind.success, dot: true),
            ),
          const PosIconButton(
            icon: Icons.notifications_none_rounded,
            onPressed: _noop,
            badge: '3',
            tooltip: 'Notifications',
          ),
          const ThemeSwitcherButton(),
        ],
      ),
      body: AnimatedSwitcher(
        duration: PosMotion.medium,
        child: KeyedSubtree(key: ValueKey(_selected), child: _page(_selected)),
      ),
    );
  }
}

void _noop() {}

class _Brand extends StatelessWidget {
  const _Brand({required this.collapsed, required this.themeName});
  final bool collapsed;
  final String themeName;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final logo = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: pos.sidebarActiveBg,
        borderRadius: BorderRadius.circular(context.shape.radiusMd),
      ),
      child: Icon(Icons.storefront_rounded, color: pos.sidebarActiveFg),
    );
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 20),
      alignment: collapsed ? Alignment.center : AlignmentDirectional.centerStart,
      child: collapsed
          ? logo
          : Row(
              children: [
                logo,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nova POS',
                        style: context.text.titleMedium!.copyWith(color: pos.sidebarFg, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        themeName,
                        style: context.text.bodySmall!.copyWith(color: pos.sidebarMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _UserFooter extends StatelessWidget {
  const _UserFooter({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: EdgeInsets.all(collapsed ? 6 : 10),
      decoration: BoxDecoration(
        color: pos.sidebarFg.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(context.shape.radiusMd),
      ),
      child: collapsed
          ? const Center(child: PosAvatar(name: 'Jordan Rivera', size: 36, online: true))
          : Row(
              children: [
                const PosAvatar(name: 'Jordan Rivera', size: 36, online: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jordan Rivera',
                        style: context.text.labelLarge!.copyWith(color: pos.sidebarFg),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Manager · Register 2',
                        style: context.text.bodySmall!.copyWith(color: pos.sidebarMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
