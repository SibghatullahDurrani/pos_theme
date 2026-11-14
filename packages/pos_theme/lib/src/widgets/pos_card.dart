import 'package:flutter/material.dart';

import '../tokens/pos_tokens.dart';

/// Themed surface card honouring each theme's border/shadow language.
class PosCard extends StatelessWidget {
  const PosCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
    this.color,
    this.elevated = false,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;
  final Color? color;

  /// Use the larger shadow (for floating panels).
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final shape = context.shape;
    final pos = context.pos;
    final cs = context.colors;
    final header = title == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: context.text.titleMedium!.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: context.text.bodySmall),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          );

    return AnimatedContainer(
      duration: PosMotion.fast,
      decoration: BoxDecoration(
        color: color ?? cs.surface,
        borderRadius: shape.lg,
        border: selected
            ? Border.all(color: cs.primary, width: 2)
            : shape.cardBordered
            ? Border.all(color: pos.border, width: shape.borderWidth)
            : null,
        boxShadow: elevated ? shape.shadowsMd : shape.shadowsSm,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: shape.lg,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: header == null
                ? child
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [header, child],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Section header with optional action, used above groups of content.
class PosSectionHeader extends StatelessWidget {
  const PosSectionHeader({super.key, required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: context.text.bodyMedium!.copyWith(color: context.pos.textMuted)),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, c) {
          // Stack the action under the title on narrow widths.
          if (action == null) return heading;
          if (c.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 12), action!],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: heading),
              const SizedBox(width: 16),
              action!,
            ],
          );
        },
      ),
    );
  }
}
