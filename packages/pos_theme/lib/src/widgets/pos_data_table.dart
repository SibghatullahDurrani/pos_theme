import 'package:flutter/material.dart';

import '../responsive/pos_breakpoints.dart';
import '../tokens/pos_tokens.dart';
import 'pos_feedback.dart';

/// Column definition for [PosDataTable].
class PosColumn<T> {
  const PosColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.width,
    this.numeric = false,
    this.sortBy,
    this.showInCard = true,
    this.primary = false,
  });

  final String label;
  final Widget Function(BuildContext context, T row) cell;

  /// Flex weight when [width] is null.
  final int flex;
  final double? width;
  final bool numeric;
  final Comparable<dynamic> Function(T row)? sortBy;

  /// Whether this column appears in the compact card layout.
  final bool showInCard;

  /// Primary column = card title on compact layouts.
  final bool primary;
}

/// Row action shown in the overflow menu.
class PosRowAction<T> {
  const PosRowAction({required this.label, required this.icon, required this.onTap, this.destructive = false});
  final String label;
  final IconData icon;
  final void Function(T row) onTap;
  final bool destructive;
}

/// Responsive data table:
/// * ≥ [minTableWidth] – full table
/// * medium – table scrolls horizontally
/// * compact – each row becomes a card
///
/// Supports sorting, row selection, row actions, pagination, loading & empty states.
class PosDataTable<T> extends StatefulWidget {
  const PosDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowId,
    this.selectable = false,
    this.selected = const {},
    this.onSelectionChanged,
    this.onRowTap,
    this.actions = const [],
    this.pageSize,
    this.loading = false,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.minTableWidth = 760,
    this.dense = false,
    this.striped = false,
  });

  final List<PosColumn<T>> columns;
  final List<T> rows;
  final Object Function(T row) rowId;
  final bool selectable;
  final Set<Object> selected;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final ValueChanged<T>? onRowTap;
  final List<PosRowAction<T>> actions;
  final int? pageSize;
  final bool loading;
  final String emptyTitle;
  final String? emptyMessage;
  final double minTableWidth;
  final bool dense;
  final bool striped;

  @override
  State<PosDataTable<T>> createState() => _PosDataTableState<T>();
}

class _PosDataTableState<T> extends State<PosDataTable<T>> {
  int? _sortCol;
  bool _asc = true;
  int _page = 0;

  List<T> get _sorted {
    final rows = [...widget.rows];
    final col = _sortCol == null ? null : widget.columns[_sortCol!];
    if (col?.sortBy != null) {
      rows.sort((a, b) {
        final r = col!.sortBy!(a).compareTo(col.sortBy!(b));
        return _asc ? r : -r;
      });
    }
    return rows;
  }

  int get _pageCount {
    final ps = widget.pageSize;
    if (ps == null || widget.rows.isEmpty) return 1;
    return (widget.rows.length / ps).ceil();
  }

  List<T> get _visible {
    final rows = _sorted;
    final ps = widget.pageSize;
    if (ps == null) return rows;
    final page = _page.clamp(0, _pageCount - 1);
    return rows.skip(page * ps).take(ps).toList();
  }

  void _sort(int i) {
    setState(() {
      if (_sortCol == i) {
        _asc = !_asc;
      } else {
        _sortCol = i;
        _asc = true;
      }
    });
  }

  void _toggle(Object id) {
    final next = {...widget.selected};
    next.contains(id) ? next.remove(id) : next.add(id);
    widget.onSelectionChanged?.call(next);
  }

  void _toggleAll(List<T> visible) {
    final ids = visible.map(widget.rowId).toSet();
    final all = ids.every(widget.selected.contains);
    final next = {...widget.selected};
    all ? next.removeAll(ids) : next.addAll(ids);
    widget.onSelectionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final shape = context.shape;
    final pos = context.pos;
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < PosWindow.mediumMin;
        final visible = _visible;

        Widget body;
        if (widget.loading) {
          body = _loading(context, compact);
        } else if (widget.rows.isEmpty) {
          body = PosEmptyState(title: widget.emptyTitle, message: widget.emptyMessage, icon: Icons.table_rows_outlined);
        } else if (compact) {
          body = _cards(context, visible);
        } else {
          final table = _table(context, visible);
          body = c.maxWidth < widget.minTableWidth
              ? Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(width: widget.minTableWidth, child: table),
                  ),
                )
              : table;
        }

        final footer = widget.pageSize != null && widget.rows.isNotEmpty && !widget.loading
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: compact
                    ? null
                    : BoxDecoration(
                        border: Border(top: BorderSide(color: pos.border)),
                      ),
                child: PosPagination(
                  page: _page.clamp(0, _pageCount - 1),
                  pageCount: _pageCount,
                  onChanged: (p) => setState(() => _page = p),
                  summary: () {
                    final ps = widget.pageSize!;
                    final start = _page * ps + 1;
                    final end = (start + ps - 1).clamp(0, widget.rows.length);
                    return '$start–$end of ${widget.rows.length}';
                  }(),
                ),
              )
            : null;

        if (compact) {
          return Column(mainAxisSize: MainAxisSize.min, children: [body, ?footer]);
        }
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: shape.lg,
            border: Border.all(color: pos.border, width: shape.borderWidth),
            boxShadow: shape.cardBordered ? null : shape.shadowsSm,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(mainAxisSize: MainAxisSize.min, children: [body, ?footer]),
        );
      },
    );
  }

  Widget _cellBox(PosColumn<T> col, Widget child) {
    final aligned = Align(
      alignment: col.numeric ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: child,
    );
    return col.width != null ? SizedBox(width: col.width, child: aligned) : Expanded(flex: col.flex, child: aligned);
  }

  Widget _table(BuildContext context, List<T> visible) {
    final pos = context.pos;
    final cs = context.colors;
    final dt = context.theme.dataTableTheme;
    final rowH = widget.dense ? 48.0 : 58.0;
    final allSelected = visible.isNotEmpty && visible.every((r) => widget.selected.contains(widget.rowId(r)));
    final someSelected = visible.any((r) => widget.selected.contains(widget.rowId(r)));

    final header = Container(
      height: 46,
      color: pos.surfaceMuted,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (widget.selectable)
            SizedBox(
              width: 44,
              child: Checkbox(
                tristate: true,
                value: allSelected ? true : (someSelected ? null : false),
                onChanged: (_) => _toggleAll(visible),
              ),
            ),
          for (var i = 0; i < widget.columns.length; i++)
            _cellBox(
              widget.columns[i],
              _HeaderCell(
                label: widget.columns[i].label,
                numeric: widget.columns[i].numeric,
                sortable: widget.columns[i].sortBy != null,
                active: _sortCol == i,
                ascending: _asc,
                onTap: widget.columns[i].sortBy == null ? null : () => _sort(i),
                style: dt.headingTextStyle!,
              ),
            ),
          if (widget.actions.isNotEmpty) const SizedBox(width: 48),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        for (var r = 0; r < visible.length; r++)
          _TableRow(
            height: rowH,
            selected: widget.selected.contains(widget.rowId(visible[r])),
            striped: widget.striped && r.isOdd,
            onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(visible[r]),
            child: Row(
              children: [
                if (widget.selectable)
                  SizedBox(
                    width: 44,
                    child: Checkbox(
                      value: widget.selected.contains(widget.rowId(visible[r])),
                      onChanged: (_) => _toggle(widget.rowId(visible[r])),
                    ),
                  ),
                for (final col in widget.columns)
                  _cellBox(
                    col,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DefaultTextStyle.merge(
                        style: dt.dataTextStyle!.copyWith(color: cs.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: col.cell(context, visible[r]),
                      ),
                    ),
                  ),
                if (widget.actions.isNotEmpty) SizedBox(width: 48, child: _actionsMenu(visible[r])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _actionsMenu(T row) => PopupMenuButton<PosRowAction<T>>(
    tooltip: 'Row actions',
    icon: const Icon(Icons.more_vert_rounded, size: 20),
    onSelected: (a) => a.onTap(row),
    itemBuilder: (context) => [
      for (final a in widget.actions)
        PopupMenuItem(
          value: a,
          child: Row(
            children: [
              Icon(a.icon, size: 18, color: a.destructive ? context.colors.error : context.pos.textMuted),
              const SizedBox(width: 12),
              Text(a.label, style: TextStyle(color: a.destructive ? context.colors.error : null)),
            ],
          ),
        ),
    ],
  );

  Widget _cards(BuildContext context, List<T> visible) {
    final primary = widget.columns.firstWhere((c) => c.primary, orElse: () => widget.columns.first);
    final rest = widget.columns.where((c) => c != primary && c.showInCard).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: context.shape.lg,
                border: Border.all(
                  color: widget.selected.contains(widget.rowId(row)) ? context.colors.primary : context.pos.border,
                  width: widget.selected.contains(widget.rowId(row)) ? 2 : 1,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: context.shape.lg,
                  onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(row),
                  onLongPress: widget.selectable ? () => _toggle(widget.rowId(row)) : null,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 4, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            if (widget.selectable)
                              Checkbox(
                                value: widget.selected.contains(widget.rowId(row)),
                                onChanged: (_) => _toggle(widget.rowId(row)),
                              ),
                            Expanded(
                              child: DefaultTextStyle.merge(
                                style: context.text.titleSmall!,
                                child: primary.cell(context, row),
                              ),
                            ),
                            if (widget.actions.isNotEmpty) _actionsMenu(row) else const SizedBox(width: 10),
                          ],
                        ),
                        const SizedBox(height: 6),
                        for (final col in rest)
                          Padding(
                            padding: const EdgeInsets.only(right: 10, top: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    col.label,
                                    style: context.text.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: DefaultTextStyle.merge(
                                      style: context.text.bodyMedium!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      child: col.cell(context, row),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _loading(BuildContext context, bool compact) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const PosSkeleton(height: 32, circle: true),
                  const SizedBox(width: 12),
                  const Expanded(flex: 3, child: PosSkeleton(height: 14)),
                  const SizedBox(width: 24),
                  if (!compact) ...[const Expanded(flex: 2, child: PosSkeleton(height: 14)), const SizedBox(width: 24)],
                  const Expanded(child: PosSkeleton(height: 14)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.numeric,
    required this.sortable,
    required this.active,
    required this.ascending,
    required this.style,
    this.onTap,
  });
  final String label;
  final bool numeric;
  final bool sortable;
  final bool active;
  final bool ascending;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? context.colors.onSurface : style.color;
    final text = Text(
      label.toUpperCase(),
      style: style.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (!sortable) return Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: text);
    return InkWell(
      onTap: onTap,
      borderRadius: context.shape.xs,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: text),
            const SizedBox(width: 4),
            Icon(
              active
                  ? (ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded)
                  : Icons.unfold_more_rounded,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  const _TableRow({
    required this.child,
    required this.height,
    required this.selected,
    required this.striped,
    this.onTap,
  });
  final Widget child;
  final double height;
  final bool selected;
  final bool striped;
  final VoidCallback? onTap;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final cs = context.colors;
    final bg = widget.selected
        ? cs.primaryContainer.withValues(alpha: 0.6)
        : _hover
        ? pos.surfaceMuted.withValues(alpha: 0.8)
        : widget.striped
        ? pos.surfaceMuted.withValues(alpha: 0.4)
        : Colors.transparent;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border(top: BorderSide(color: pos.border)),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Page navigator: ‹ 1 2 … 9 ›
class PosPagination extends StatelessWidget {
  const PosPagination({super.key, required this.page, required this.pageCount, required this.onChanged, this.summary});
  final int page;
  final int pageCount;
  final ValueChanged<int> onChanged;
  final String? summary;

  List<int?> _pages() {
    if (pageCount <= 7) return List.generate(pageCount, (i) => i);
    final out = <int?>{
      0,
      page - 1,
      page,
      page + 1,
      pageCount - 1,
    }.where((p) => p == null || (p >= 0 && p < pageCount)).toList()..sort((a, b) => a!.compareTo(b!));
    final withGaps = <int?>[];
    for (var i = 0; i < out.length; i++) {
      if (i > 0 && out[i]! - out[i - 1]! > 1) withGaps.add(null);
      withGaps.add(out[i]);
    }
    return withGaps;
  }

  @override
  Widget build(BuildContext context) {
    final compact = PosWindow.of(context).isCompact;
    final cs = context.colors;
    final r = context.shape.buttonRadius > 20 ? 999.0 : context.shape.radiusSm;
    Widget pageBtn(int p) {
      final active = p == page;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(r),
          child: InkWell(
            borderRadius: BorderRadius.circular(r),
            onTap: () => onChanged(p),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text(
                  '${p + 1}',
                  style: context.text.labelLarge!.copyWith(color: active ? cs.onPrimary : cs.onSurface),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        if (summary != null) Expanded(child: Text(summary!, style: context.text.bodySmall)) else const Spacer(),
        IconButton(
          onPressed: page > 0 ? () => onChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Previous page',
        ),
        if (compact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('${page + 1} / $pageCount', style: context.text.labelLarge),
          )
        else
          for (final p in _pages()) p == null ? const SizedBox(width: 24, child: Center(child: Text('…'))) : pageBtn(p),
        IconButton(
          onPressed: page < pageCount - 1 ? () => onChanged(page + 1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Next page',
        ),
      ],
    );
  }
}
