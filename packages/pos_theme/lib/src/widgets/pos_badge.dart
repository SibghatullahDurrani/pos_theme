import 'package:flutter/material.dart';

import '../tokens/pos_tokens.dart';
import '../utils/pos_format.dart';

enum PosToneKind { brand, success, warning, info, danger, neutral }

extension PosToneKindX on PosToneKind {
  PosTone of(BuildContext context) {
    final p = context.pos;
    return switch (this) {
      PosToneKind.brand => p.brand,
      PosToneKind.success => p.success,
      PosToneKind.warning => p.warning,
      PosToneKind.info => p.info,
      PosToneKind.danger => p.danger,
      PosToneKind.neutral => p.neutral,
    };
  }
}

/// Order lifecycle shared by retail & restaurant apps.
enum PosOrderStatus {
  draft('Draft', PosToneKind.neutral),
  pending('Pending', PosToneKind.warning),
  preparing('Preparing', PosToneKind.info),
  ready('Ready', PosToneKind.success),
  served('Served', PosToneKind.brand),
  paid('Paid', PosToneKind.success),
  refunded('Refunded', PosToneKind.neutral),
  voided('Void', PosToneKind.danger);

  const PosOrderStatus(this.label, this.tone);
  final String label;
  final PosToneKind tone;
}

/// Restaurant table status.
enum PosTableStatus {
  free('Available', PosToneKind.success),
  occupied('Occupied', PosToneKind.brand),
  reserved('Reserved', PosToneKind.warning),
  billing('Billing', PosToneKind.info),
  cleaning('Cleaning', PosToneKind.neutral);

  const PosTableStatus(this.label, this.tone);
  final String label;
  final PosToneKind tone;
}

enum PosPillStyle { soft, solid, outline }

/// Status pill / tag.
class PosStatusPill extends StatelessWidget {
  const PosStatusPill({
    super.key,
    required this.label,
    this.tone = PosToneKind.neutral,
    this.icon,
    this.dot = false,
    this.style = PosPillStyle.soft,
    this.dense = false,
  });

  factory PosStatusPill.order(PosOrderStatus s, {Key? key, bool dense = false}) =>
      PosStatusPill(key: key, label: s.label, tone: s.tone, dot: true, dense: dense);

  factory PosStatusPill.table(PosTableStatus s, {Key? key, bool dense = false}) =>
      PosStatusPill(key: key, label: s.label, tone: s.tone, dot: true, dense: dense);

  final String label;
  final PosToneKind tone;
  final IconData? icon;
  final bool dot;
  final PosPillStyle style;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final t = tone.of(context);
    final (bg, fg, border) = switch (style) {
      PosPillStyle.soft => (t.container, t.onContainer, Colors.transparent),
      PosPillStyle.solid => (t.color, t.onColor, Colors.transparent),
      PosPillStyle.outline => (Colors.transparent, t.onContainer, t.color.withValues(alpha: 0.6)),
    };
    final r = context.shape.radiusSm >= 6 ? 99.0 : context.shape.radiusXs;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: style == PosPillStyle.solid ? t.onColor : t.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[Icon(icon, size: dense ? 12 : 14, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (dense ? context.text.labelSmall : context.text.labelMedium)!.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar with initials fallback and optional presence dot.
class PosAvatar extends StatelessWidget {
  const PosAvatar({super.key, required this.name, this.size = 40, this.online, this.image});

  final String name;
  final double size;
  final bool? online;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final bg = posHashColor(name, pos.chart);
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color.alphaBlend(bg.withValues(alpha: 0.22), context.colors.surface),
        shape: context.shape.radiusMd <= 2 ? BoxShape.rectangle : BoxShape.circle,
        image: image == null ? null : DecorationImage(image: image!, fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: image != null
          ? null
          : Text(
              posInitials(name),
              style: context.text.labelLarge!.copyWith(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w800,
                color: posContrast(bg, context.colors.surface) > 3 ? bg : context.colors.onSurface,
              ),
            ),
    );
    if (online == null) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: online! ? pos.success.color : pos.neutral.color,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small count badge for inline use.
class PosCountBadge extends StatelessWidget {
  const PosCountBadge({super.key, required this.count, this.tone = PosToneKind.danger});
  final int count;
  final PosToneKind tone;

  @override
  Widget build(BuildContext context) {
    final t = tone.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: t.color, borderRadius: BorderRadius.circular(99)),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: context.text.labelSmall!.copyWith(color: t.onColor, fontWeight: FontWeight.w800),
      ),
    );
  }
}
