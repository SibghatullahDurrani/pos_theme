import 'dart:async';

import 'package:flutter/material.dart';

import '../responsive/pos_breakpoints.dart';
import '../tokens/pos_tokens.dart';
import 'pos_badge.dart';
import 'pos_button.dart';

/// Standard dialog body: optional tone icon, title, message/content, actions.
class PosDialog extends StatelessWidget {
  const PosDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.actions = const [],
    this.icon,
    this.tone,
    this.maxWidth = 480,
    this.showClose = true,
  });

  final String title;
  final String? message;
  final Widget? content;
  final List<Widget> actions;
  final IconData? icon;
  final PosToneKind? tone;
  final double maxWidth;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    final compact = PosWindow.of(context).isCompact;
    final t = tone?.of(context);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: t?.container ?? context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(context.shape.radiusMd <= 2 ? 2 : 99),
                ),
                child: Icon(icon, color: t?.color ?? context.colors.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: icon != null ? 8 : 0),
                child: Text(title, style: context.text.headlineSmall),
              ),
            ),
            if (showClose)
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: 10),
          Text(message!, style: context.text.bodyMedium!.copyWith(color: context.pos.textMuted)),
        ],
        if (content != null) ...[const SizedBox(height: 18), Flexible(child: SingleChildScrollView(child: content!))],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 22),
          if (compact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final a in actions.reversed) Padding(padding: const EdgeInsets.only(top: 8), child: a)],
            )
          else
            Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 8, children: actions),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 14, 20),
      child: _EndInset(child: body),
    ).constrained(maxWidth);
  }
}

class _EndInset extends StatelessWidget {
  const _EndInset({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: child);
}

extension on Widget {
  Widget constrained(double maxWidth) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth),
    child: this,
  );
}

/// Shows [child] as a centred dialog on medium+ and as a bottom sheet on
/// compact screens. Set [fullscreenOnCompact] for long forms.
Future<T?> showPosAdaptiveDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool fullscreenOnCompact = false,
  bool barrierDismissible = true,
}) {
  final compact = PosWindow.of(context).isCompact;
  if (compact && fullscreenOnCompact) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          backgroundColor: ctx.colors.surface,
          body: SafeArea(child: builder(ctx)),
        ),
      ),
    );
  }
  if (compact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: barrierDismissible,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.9),
          child: builder(ctx),
        ),
      ),
    );
  }
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Theme.of(context).dialogTheme.barrierColor ?? Colors.black54,
    transitionDuration: PosMotion.medium,
    pageBuilder: (ctx, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _DialogSurface(child: builder(ctx)),
        ),
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: PosMotion.standard);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

class _DialogSurface extends StatelessWidget {
  const _DialogSurface({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final shape = context.shape;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: shape.xl,
        border: shape.shadowsLg.isEmpty || context.theme.brightness == Brightness.dark
            ? Border.all(color: context.pos.border)
            : null,
        boxShadow: shape.shadowsLg,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(borderRadius: shape.xl, child: child),
      ),
    );
  }
}

/// Confirmation dialog. Returns true when confirmed.
Future<bool> showPosConfirm(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showPosAdaptiveDialog<bool>(
    context,
    builder: (ctx) => PosDialog(
      title: title,
      message: message,
      icon: icon ?? (destructive ? Icons.delete_outline_rounded : Icons.help_outline_rounded),
      tone: destructive ? PosToneKind.danger : PosToneKind.brand,
      maxWidth: 440,
      actions: [
        PosButton.outline(label: cancelLabel, onPressed: () => Navigator.pop(ctx, false)),
        destructive
            ? PosButton.danger(label: confirmLabel, onPressed: () => Navigator.pop(ctx, true))
            : PosButton(label: confirmLabel, onPressed: () => Navigator.pop(ctx, true)),
      ],
    ),
  );
  return result ?? false;
}

/// Shows a themed modal bottom sheet with an optional title row.
Future<T?> showPosSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  List<Widget> actions = const [],
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(title, style: ctx.text.titleLarge),
            ),
          Flexible(child: builder(ctx)),
          if (actions.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: ctx.pos.border)),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Toasts
// ---------------------------------------------------------------------------

/// Stacked, auto-dismissing toasts. Top-right on medium+, bottom on compact.
abstract final class PosToast {
  static final List<_ToastEntry> _entries = [];
  static OverlayEntry? _overlay;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    PosToneKind tone = PosToneKind.neutral,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = _ToastEntry(
      key: UniqueKey(),
      message: message,
      title: title,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
    );
    _entries.add(entry);
    if (_entries.length > 4) _entries.removeAt(0);
    _overlay ??= OverlayEntry(builder: (_) => _ToastHost(entries: List.of(_entries)));
    if (!_overlay!.mounted) overlay.insert(_overlay!);
    _overlay!.markNeedsBuild();
    entry.timer = Timer(duration, () => dismiss(entry.key));
  }

  static void success(BuildContext c, String m, {String? title}) =>
      show(c, message: m, title: title, tone: PosToneKind.success);
  static void error(BuildContext c, String m, {String? title}) =>
      show(c, message: m, title: title, tone: PosToneKind.danger);
  static void warning(BuildContext c, String m, {String? title}) =>
      show(c, message: m, title: title, tone: PosToneKind.warning);
  static void info(BuildContext c, String m, {String? title}) =>
      show(c, message: m, title: title, tone: PosToneKind.info);

  static void dismiss(Key key) {
    final i = _entries.indexWhere((e) => e.key == key);
    if (i < 0) return;
    _entries[i].timer?.cancel();
    _entries.removeAt(i);
    if (_entries.isEmpty) {
      if (_overlay?.mounted ?? false) _overlay!.remove();
      _overlay = null;
    } else {
      _overlay?.markNeedsBuild();
    }
  }

  /// Removes every toast (e.g. in tests or when logging out).
  static void clear() {
    for (final e in [..._entries]) {
      dismiss(e.key);
    }
  }
}

class _ToastEntry {
  _ToastEntry({
    required this.key,
    required this.message,
    required this.tone,
    this.title,
    this.actionLabel,
    this.onAction,
  });
  final Key key;
  final String message;
  final String? title;
  final PosToneKind tone;
  final String? actionLabel;
  final VoidCallback? onAction;
  Timer? timer;
}

class _ToastHost extends StatelessWidget {
  const _ToastHost({required this.entries});
  final List<_ToastEntry> entries;

  @override
  Widget build(BuildContext context) {
    final compact = PosWindow.of(context).isCompact;
    final children = [for (final e in entries) _ToastCard(key: e.key, entry: e)];
    return SafeArea(
      child: Align(
        alignment: compact ? Alignment.bottomCenter : AlignmentDirectional.topEnd,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, compact ? 16 : 76, 16, compact ? 88 : 16),
          child: SizedBox(
            width: compact ? double.infinity : 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              verticalDirection: compact ? VerticalDirection.up : VerticalDirection.down,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({super.key, required this.entry});
  final _ToastEntry entry;
  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: PosMotion.medium)..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final t = e.tone.of(context);
    final shape = context.shape;
    final icon = switch (e.tone) {
      PosToneKind.success => Icons.check_circle_rounded,
      PosToneKind.danger => Icons.error_rounded,
      PosToneKind.warning => Icons.warning_rounded,
      PosToneKind.info => Icons.info_rounded,
      _ => Icons.notifications_rounded,
    };
    final curved = CurvedAnimation(parent: _c, curve: PosMotion.standard);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, -0.2), end: Offset.zero).animate(curved),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: e.key,
            onDismissed: (_) => PosToast.dismiss(e.key),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHigh,
                borderRadius: shape.md,
                border: Border.all(color: context.pos.border),
                boxShadow: shape.shadowsLg,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: t.color,
                          borderRadius: BorderRadiusDirectional.horizontal(
                            start: Radius.circular(shape.radiusMd),
                          ).resolve(Directionality.of(context)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
                        child: Icon(icon, color: t.color, size: 22),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (e.title != null) Text(e.title!, style: context.text.titleSmall),
                              Text(e.message, style: context.text.bodyMedium!.copyWith(color: context.pos.textMuted)),
                            ],
                          ),
                        ),
                      ),
                      if (e.actionLabel != null)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              e.onAction?.call();
                              PosToast.dismiss(e.key);
                            },
                            child: Text(e.actionLabel!),
                          ),
                        ),
                      IconButton(
                        onPressed: () => PosToast.dismiss(e.key),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        tooltip: 'Dismiss',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
