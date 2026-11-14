import 'package:flutter/material.dart';

import '../tokens/pos_tokens.dart';
import 'pos_badge.dart';
import 'pos_button.dart';

IconData _toneIcon(PosToneKind t) => switch (t) {
  PosToneKind.success => Icons.check_circle_rounded,
  PosToneKind.warning => Icons.warning_amber_rounded,
  PosToneKind.danger => Icons.error_rounded,
  PosToneKind.info => Icons.info_rounded,
  _ => Icons.notifications_rounded,
};

/// Inline alert banner.
class PosAlert extends StatelessWidget {
  const PosAlert({
    super.key,
    required this.message,
    this.title,
    this.tone = PosToneKind.info,
    this.action,
    this.onClose,
  });

  final String message;
  final String? title;
  final PosToneKind tone;
  final Widget? action;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final t = tone.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.container,
        borderRadius: context.shape.md,
        border: BorderDirectional(start: BorderSide(color: t.color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_toneIcon(tone), color: t.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: context.text.titleSmall!.copyWith(color: t.onContainer, fontWeight: FontWeight.w700),
                  ),
                Text(message, style: context.text.bodyMedium!.copyWith(color: t.onContainer)),
                if (action != null) ...[const SizedBox(height: 8), action!],
              ],
            ),
          ),
          if (onClose != null)
            InkResponse(
              onTap: onClose,
              radius: 18,
              child: Icon(Icons.close_rounded, size: 18, color: t.onContainer),
            ),
        ],
      ),
    );
  }
}

/// Empty state for lists, tables, carts.
class PosEmptyState extends StatelessWidget {
  const PosEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 56 : 72,
                height: compact ? 56 : 72,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(context.shape.radiusMd <= 2 ? 2 : 99),
                ),
                child: Icon(icon, size: compact ? 26 : 34, color: cs.onPrimaryContainer),
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(title, textAlign: TextAlign.center, style: context.text.titleMedium),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium!.copyWith(color: context.pos.textMuted),
                ),
              ],
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state with retry.
class PosErrorState extends StatelessWidget {
  const PosErrorState({super.key, required this.title, this.message, this.onRetry});
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.pos.danger;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: t.container, shape: BoxShape.circle),
              child: Icon(Icons.cloud_off_rounded, size: 34, color: t.color),
            ),
            const SizedBox(height: 18),
            Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                style: context.text.bodyMedium!.copyWith(color: context.pos.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              PosButton.outline(label: 'Try again', icon: Icons.refresh_rounded, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmering skeleton placeholder.
class PosSkeleton extends StatefulWidget {
  const PosSkeleton({super.key, this.width, this.height = 14, this.radius, this.circle = false});
  final double? width;
  final double height;
  final double? radius;
  final bool circle;

  @override
  State<PosSkeleton> createState() => _PosSkeletonState();
}

class _PosSkeletonState extends State<PosSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.pos.surfaceMuted;
    final hi = Color.lerp(base, context.colors.onSurface, 0.06)!;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = _c.value * 3 - 1;
        return Container(
          width: widget.circle ? widget.height : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.circle ? null : BorderRadius.circular(widget.radius ?? context.shape.radiusSm),
            gradient: LinearGradient(begin: Alignment(x - 1, 0), end: Alignment(x + 1, 0), colors: [base, hi, base]),
          ),
        );
      },
    );
  }
}

/// Covers its child with a blocking loader while [loading] is true.
class PosLoadingOverlay extends StatelessWidget {
  const PosLoadingOverlay({super.key, required this.loading, required this.child, this.message});
  final bool loading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !loading,
            child: AnimatedOpacity(
              opacity: loading ? 1 : 0,
              duration: PosMotion.medium,
              child: ColoredBox(
                color: context.colors.surface.withValues(alpha: 0.72),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox.square(dimension: 36, child: CircularProgressIndicator(strokeWidth: 3.5)),
                      if (message != null) ...[
                        const SizedBox(height: 14),
                        Text(message!, style: context.text.titleSmall),
                      ],
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
}
