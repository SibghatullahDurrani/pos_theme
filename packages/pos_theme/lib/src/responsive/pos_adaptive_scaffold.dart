import 'package:flutter/material.dart';

import '../tokens/pos_tokens.dart';
import 'pos_breakpoints.dart';

/// A navigation destination for [PosSideMenu] / [PosAdaptiveScaffold].
@immutable
class PosNavItem {
  const PosNavItem({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.children = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  /// Optional count badge (e.g. open orders).
  final int? badge;
  final List<PosNavItem> children;

  bool containsId(String id) => this.id == id || children.any((c) => c.containsId(id));
}

/// A titled group of [PosNavItem]s in the side menu.
@immutable
class PosNavGroup {
  const PosNavGroup({this.title, required this.items});
  final String? title;
  final List<PosNavItem> items;
}

/// Collapsible, grouped, nested side menu.
class PosSideMenu extends StatefulWidget {
  const PosSideMenu({
    super.key,
    required this.groups,
    required this.selectedId,
    required this.onSelect,
    this.collapsed = false,
    this.onToggleCollapsed,
    this.header,
    this.footer,
    this.width = 268,
    this.collapsedWidth = 80,
  });

  final List<PosNavGroup> groups;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final bool collapsed;
  final VoidCallback? onToggleCollapsed;

  /// Brand area; receives the collapsed state.
  final Widget Function(BuildContext context, bool collapsed)? header;
  final Widget Function(BuildContext context, bool collapsed)? footer;
  final double width;
  final double collapsedWidth;

  @override
  State<PosSideMenu> createState() => _PosSideMenuState();
}

class _PosSideMenuState extends State<PosSideMenu> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _expandSelected();
  }

  @override
  void didUpdateWidget(covariant PosSideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) _expandSelected();
  }

  void _expandSelected() {
    for (final g in widget.groups) {
      for (final i in g.items) {
        if (i.children.isNotEmpty && i.containsId(widget.selectedId)) _expanded.add(i.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final collapsed = widget.collapsed;
    return AnimatedContainer(
      duration: PosMotion.medium,
      curve: PosMotion.standard,
      width: collapsed ? widget.collapsedWidth : widget.width,
      decoration: BoxDecoration(
        color: pos.sidebarBg,
        border: BorderDirectional(end: BorderSide(color: pos.sidebarBorder)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            if (widget.header != null) widget.header!(context, collapsed),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 12, vertical: 8),
                children: [
                  for (final g in widget.groups) ...[
                    if (g.title != null)
                      collapsed
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              child: Divider(color: pos.sidebarBorder, height: 1),
                            )
                          : Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(12, 18, 12, 6),
                              child: Text(
                                g.title!.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: context.text.labelSmall!.copyWith(
                                  color: pos.sidebarMuted,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    for (final item in g.items) ..._buildItem(context, item, 0),
                  ],
                ],
              ),
            ),
            if (widget.footer != null) widget.footer!(context, collapsed),
            if (widget.onToggleCollapsed != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: _MenuTile(
                  icon: collapsed
                      ? Icons.keyboard_double_arrow_right_rounded
                      : Icons.keyboard_double_arrow_left_rounded,
                  label: 'Collapse',
                  collapsed: collapsed,
                  selected: false,
                  onTap: widget.onToggleCollapsed!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItem(BuildContext context, PosNavItem item, int depth) {
    final hasChildren = item.children.isNotEmpty;
    final expanded = _expanded.contains(item.id);
    final selected = hasChildren
        ? (widget.collapsed && item.containsId(widget.selectedId))
        : item.id == widget.selectedId;
    final childActive = hasChildren && item.containsId(widget.selectedId);
    return [
      _MenuTile(
        icon: selected && item.selectedIcon != null ? item.selectedIcon! : item.icon,
        label: item.label,
        badge: item.badge,
        depth: depth,
        collapsed: widget.collapsed,
        selected: selected,
        highlighted: childActive && !widget.collapsed,
        trailing: hasChildren && !widget.collapsed
            ? AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: PosMotion.fast,
                child: Icon(Icons.expand_more_rounded, size: 18, color: context.pos.sidebarMuted),
              )
            : null,
        onTap: () {
          if (hasChildren) {
            if (widget.collapsed) {
              widget.onSelect(item.children.first.id);
            } else {
              setState(() => expanded ? _expanded.remove(item.id) : _expanded.add(item.id));
            }
          } else {
            widget.onSelect(item.id);
          }
        },
      ),
      if (hasChildren && !widget.collapsed)
        AnimatedSize(
          duration: PosMotion.medium,
          curve: PosMotion.standard,
          alignment: Alignment.topCenter,
          child: expanded
              ? Column(children: [for (final c in item.children) ..._buildItem(context, c, depth + 1)])
              : const SizedBox(width: double.infinity),
        ),
    ];
  }
}

class _MenuTile extends StatefulWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.collapsed,
    required this.selected,
    required this.onTap,
    this.highlighted = false,
    this.badge,
    this.depth = 0,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool collapsed;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;
  final int? badge;
  final int depth;
  final Widget? trailing;

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final shape = context.shape;
    final fg = widget.selected
        ? pos.sidebarActiveFg
        : (widget.highlighted ? pos.sidebarFg : pos.sidebarFg.withValues(alpha: 0.86));
    final bg = widget.selected
        ? pos.sidebarActiveBg
        : _hover
        ? pos.sidebarFg.withValues(alpha: 0.07)
        : Colors.transparent;

    final badge = widget.badge == null
        ? null
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            constraints: const BoxConstraints(minWidth: 22),
            decoration: BoxDecoration(
              color: widget.selected ? pos.sidebarActiveFg : context.colors.error,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '${widget.badge}',
              textAlign: TextAlign.center,
              style: context.text.labelSmall!.copyWith(
                color: widget.selected ? pos.sidebarActiveBg : context.colors.onError,
                fontWeight: FontWeight.w800,
              ),
            ),
          );

    final content = widget.collapsed
        ? Center(
            child: Badge(
              isLabelVisible: widget.badge != null,
              label: Text('${widget.badge ?? ''}'),
              child: Icon(widget.icon, color: widget.selected ? fg : pos.sidebarMuted, size: 22),
            ),
          )
        : Row(
            children: [
              SizedBox(width: 12.0 + widget.depth * 22),
              Icon(
                widget.depth > 0 ? Icons.circle : widget.icon,
                size: widget.depth > 0 ? 6 : 20,
                color: widget.selected ? fg : pos.sidebarMuted,
              ),
              SizedBox(width: widget.depth > 0 ? 14 : 12),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium!.copyWith(
                    color: fg,
                    fontWeight: widget.selected || widget.highlighted ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              ?badge,
              if (widget.trailing != null) widget.trailing!,
              const SizedBox(width: 10),
            ],
          );

    final tile = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        selected: widget.selected,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: PosMotion.fast,
            height: widget.depth > 0 ? 40 : 46,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(color: bg, borderRadius: shape.md),
            child: content,
          ),
        ),
      ),
    );
    return widget.collapsed ? Tooltip(message: widget.label, preferBelow: false, child: tile) : tile;
  }
}

/// Top bar used inside [PosAdaptiveScaffold].
class PosTopBar extends StatelessWidget {
  const PosTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onMenu,
    this.search,
    this.actions = const [],
    this.leading,
  });

  final String title;
  final Widget? subtitle;

  /// Shown as a hamburger button on compact layouts.
  final VoidCallback? onMenu;

  /// Search widget, shown inline on expanded windows.
  final Widget? search;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final w = PosWindow.of(context);
    return Material(
      color: context.colors.surface,
      child: Container(
        height: 64,
        padding: EdgeInsetsDirectional.only(start: onMenu != null ? 4 : w.gutter, end: w.gutter - 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.pos.border)),
        ),
        child: Row(
          children: [
            if (onMenu != null) IconButton(onPressed: onMenu, icon: const Icon(Icons.menu_rounded), tooltip: 'Menu'),
            ?leading,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleLarge),
                  if (subtitle != null && w.atLeastMedium)
                    ClipRect(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: DefaultTextStyle(style: context.text.bodySmall!, maxLines: 1, child: subtitle!),
                      ),
                    ),
                ],
              ),
            ),
            if (search != null && w.atLeastExpanded) ...[
              SizedBox(width: w.isLarge ? 360 : 280, child: search),
              const SizedBox(width: 8),
            ],
            ...actions,
          ],
        ),
      ),
    );
  }
}

/// Responsive app shell:
/// * compact → top bar + drawer + bottom navigation bar
/// * medium  → collapsed side rail
/// * expanded/large → full collapsible side menu
class PosAdaptiveScaffold extends StatefulWidget {
  const PosAdaptiveScaffold({
    super.key,
    required this.groups,
    required this.selectedId,
    required this.onSelect,
    required this.body,
    required this.topBarBuilder,
    this.bottomNavIds = const [],
    this.header,
    this.footer,
    this.floatingActionButton,
  });

  final List<PosNavGroup> groups;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final Widget body;

  /// Builds the top bar. `openMenu` is non-null on compact layouts.
  final Widget Function(BuildContext context, PosWindow window, VoidCallback? openMenu) topBarBuilder;

  /// Up to 4 item ids for the compact bottom bar. A "More" item opening the
  /// drawer is appended automatically.
  final List<String> bottomNavIds;
  final Widget Function(BuildContext context, bool collapsed)? header;
  final Widget Function(BuildContext context, bool collapsed)? footer;
  final Widget? floatingActionButton;

  @override
  State<PosAdaptiveScaffold> createState() => _PosAdaptiveScaffoldState();
}

class _PosAdaptiveScaffoldState extends State<PosAdaptiveScaffold> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _userCollapsed = false;

  List<PosNavItem> get _flat => [
    for (final g in widget.groups)
      for (final i in g.items) ...[i, ...i.children],
  ];

  @override
  Widget build(BuildContext context) {
    final w = PosWindow.of(context);
    final showRail = w.atLeastMedium;
    final collapsed = w.isMedium || (_userCollapsed && w.atLeastExpanded);

    Widget menu({required bool collapsed, VoidCallback? onToggle, bool closeOnSelect = false}) => PosSideMenu(
      groups: widget.groups,
      selectedId: widget.selectedId,
      collapsed: collapsed,
      onToggleCollapsed: onToggle,
      header: widget.header,
      footer: widget.footer,
      onSelect: (id) {
        if (closeOnSelect) Navigator.of(context).maybePop();
        widget.onSelect(id);
      },
    );

    final bottomItems = [
      for (final id in widget.bottomNavIds.take(4)) ..._flat.where((i) => i.id == id && i.children.isEmpty),
    ];
    final bottomIndex = bottomItems.indexWhere((i) => i.id == widget.selectedId);

    return Scaffold(
      key: _scaffoldKey,
      drawer: showRail ? null : Drawer(child: menu(collapsed: false, closeOnSelect: true)),
      floatingActionButton: widget.floatingActionButton,
      body: Row(
        children: [
          if (showRail)
            menu(
              collapsed: collapsed,
              onToggle: w.atLeastExpanded ? () => setState(() => _userCollapsed = !_userCollapsed) : null,
            ),
          Expanded(
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  left: !showRail,
                  child: widget.topBarBuilder(
                    context,
                    w,
                    showRail ? null : () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
                Expanded(child: widget.body),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !showRail && bottomItems.isNotEmpty
          ? NavigationBar(
              selectedIndex: bottomIndex < 0 ? bottomItems.length : bottomIndex,
              onDestinationSelected: (i) {
                if (i == bottomItems.length) {
                  _scaffoldKey.currentState?.openDrawer();
                } else {
                  widget.onSelect(bottomItems[i].id);
                }
              },
              destinations: [
                for (final i in bottomItems)
                  NavigationDestination(
                    icon: Badge(isLabelVisible: i.badge != null, label: Text('${i.badge ?? ''}'), child: Icon(i.icon)),
                    selectedIcon: Icon(i.selectedIcon ?? i.icon),
                    label: i.label,
                  ),
                const NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'More'),
              ],
            )
          : null,
    );
  }
}
