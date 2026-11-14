import 'package:flutter/material.dart';

import '../responsive/pos_breakpoints.dart';
import '../tokens/pos_tokens.dart';

/// Home › Inventory › Products
class PosBreadcrumbs extends StatelessWidget {
  const PosBreadcrumbs({super.key, required this.items, this.onTap});
  final List<String> items;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final muted = context.pos.textMuted;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_right_rounded, size: 16, color: muted),
            ),
          i == items.length - 1
              ? Text(
                  items[i],
                  style: context.text.bodySmall!.copyWith(color: context.colors.onSurface, fontWeight: FontWeight.w600),
                )
              : InkWell(
                  onTap: onTap == null ? null : () => onTap!(i),
                  borderRadius: context.shape.xs,
                  child: Text(items[i], style: context.text.bodySmall!.copyWith(color: muted)),
                ),
        ],
      ],
    );
  }
}

/// Horizontal step indicator (vertical on compact).
class PosSteps extends StatelessWidget {
  const PosSteps({super.key, required this.steps, required this.current});
  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final pos = context.pos;
    final compact = PosWindow.of(context).isCompact;
    Widget dot(int i) {
      final done = i < current;
      final active = i == current;
      return AnimatedContainer(
        duration: PosMotion.medium,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: done ? cs.primary : (active ? cs.primaryContainer : cs.surface),
          shape: context.shape.radiusMd <= 2 ? BoxShape.rectangle : BoxShape.circle,
          border: Border.all(color: done || active ? cs.primary : pos.borderStrong, width: 2),
        ),
        child: Center(
          child: done
              ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimary)
              : Text(
                  '${i + 1}',
                  style: context.text.labelMedium!.copyWith(color: active ? cs.onPrimaryContainer : pos.textMuted),
                ),
        ),
      );
    }

    Text label(int i) => Text(
      steps[i],
      style: context.text.labelLarge!.copyWith(
        color: i <= current ? cs.onSurface : pos.textMuted,
        fontWeight: i == current ? FontWeight.w700 : FontWeight.w500,
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Row(children: [dot(i), const SizedBox(width: 12), label(i)]),
            if (i < steps.length - 1)
              Container(
                margin: const EdgeInsetsDirectional.only(start: 14),
                width: 2,
                height: 18,
                color: i < current ? cs.primary : pos.border,
              ),
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          dot(i),
          const SizedBox(width: 10),
          label(i),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                height: 2,
                color: i < current ? cs.primary : pos.border,
              ),
            ),
        ],
      ],
    );
  }
}

/// Pill-style category tabs that scroll horizontally (product categories, floors).
class PosCategoryTabs extends StatelessWidget {
  const PosCategoryTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.counts,
  });
  final List<String> items;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<int>? counts;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final r = context.shape.buttonRadius > 20 ? 999.0 : context.shape.radiusMd;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == selected;
          return Material(
            color: active ? cs.primary : cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r),
              side: BorderSide(color: active ? cs.primary : context.pos.border),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
              onTap: () => onSelected(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      items[i],
                      style: context.text.labelLarge!.copyWith(color: active ? cs.onPrimary : cs.onSurface),
                    ),
                    if (counts != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${counts![i]}',
                        style: context.text.labelMedium!.copyWith(
                          color: active ? cs.onPrimary.withValues(alpha: 0.8) : context.pos.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
