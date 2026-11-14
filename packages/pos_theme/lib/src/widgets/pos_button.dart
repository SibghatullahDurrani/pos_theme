import 'package:flutter/material.dart';

import '../tokens/pos_tokens.dart';

enum PosButtonVariant { primary, secondary, outline, ghost, danger, success }

enum PosButtonSize { sm, md, lg, xl }

/// The single button API for the suite. Wraps Material buttons so every
/// theme's shape/typography applies automatically.
class PosButton extends StatelessWidget {
  const PosButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PosButtonVariant.primary,
    this.size = PosButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.tooltip,
  });

  const PosButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = PosButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.tooltip,
  }) : variant = PosButtonVariant.secondary;

  const PosButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = PosButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.tooltip,
  }) : variant = PosButtonVariant.outline;

  const PosButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = PosButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.tooltip,
  }) : variant = PosButtonVariant.ghost;

  const PosButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = PosButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.tooltip,
  }) : variant = PosButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final PosButtonVariant variant;
  final PosButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final cs = context.colors;
    final (height, hPad, fontSize, iconSize) = switch (size) {
      PosButtonSize.sm => (36.0, 14.0, 13.0, 16.0),
      PosButtonSize.md => (44.0, 18.0, 14.0, 18.0),
      PosButtonSize.lg => (52.0, 22.0, 15.5, 20.0),
      PosButtonSize.xl => (64.0, 28.0, 18.0, 24.0),
    };
    final base = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(expand ? double.infinity : 0, height)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: hPad)),
      textStyle: WidgetStatePropertyAll(
        context.theme.filledButtonTheme.style!.textStyle!.resolve({})!.copyWith(fontSize: fontSize),
      ),
      iconSize: WidgetStatePropertyAll(iconSize),
    );

    final fgForLoader = switch (variant) {
      PosButtonVariant.primary => cs.onPrimary,
      PosButtonVariant.secondary => cs.onSecondaryContainer,
      PosButtonVariant.danger => pos.danger.onColor,
      PosButtonVariant.success => pos.success.onColor,
      _ => cs.onSurface,
    };
    final effectiveOnPressed = loading ? () {} : onPressed;

    final Widget child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox.square(
            dimension: iconSize - 2,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: fgForLoader, backgroundColor: Colors.transparent),
          )
        else if (icon != null)
          Icon(icon, size: iconSize),
        if (loading || icon != null) SizedBox(width: size == PosButtonSize.sm ? 6 : 8),
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (trailingIcon != null) ...[
          SizedBox(width: size == PosButtonSize.sm ? 6 : 8),
          Icon(trailingIcon, size: iconSize),
        ],
      ],
    );

    Widget button = switch (variant) {
      PosButtonVariant.primary => FilledButton(onPressed: effectiveOnPressed, style: base, child: child),
      PosButtonVariant.secondary => FilledButton(
        onPressed: effectiveOnPressed,
        style: base.merge(
          FilledButton.styleFrom(backgroundColor: cs.secondaryContainer, foregroundColor: cs.onSecondaryContainer),
        ),
        child: child,
      ),
      PosButtonVariant.outline => OutlinedButton(onPressed: effectiveOnPressed, style: base, child: child),
      PosButtonVariant.ghost => TextButton(onPressed: effectiveOnPressed, style: base, child: child),
      PosButtonVariant.danger => FilledButton(
        onPressed: effectiveOnPressed,
        style: base.merge(
          FilledButton.styleFrom(backgroundColor: pos.danger.color, foregroundColor: pos.danger.onColor),
        ),
        child: child,
      ),
      PosButtonVariant.success => FilledButton(
        onPressed: effectiveOnPressed,
        style: base.merge(
          FilledButton.styleFrom(backgroundColor: pos.success.color, foregroundColor: pos.success.onColor),
        ),
        child: child,
      ),
    };
    if (expand) button = SizedBox(width: double.infinity, child: button);
    if (tooltip != null) button = Tooltip(message: tooltip, child: button);
    return button;
  }
}

/// Square/round icon button with optional tonal/outlined look and badge.
class PosIconButton extends StatelessWidget {
  const PosIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge,
    this.style = PosIconButtonStyle.plain,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? badge;
  final PosIconButtonStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final btnStyle = IconButton.styleFrom(
      minimumSize: Size.square(size),
      fixedSize: Size.square(size),
      backgroundColor: switch (style) {
        PosIconButtonStyle.filled => cs.primary,
        PosIconButtonStyle.tonal => cs.primaryContainer,
        _ => null,
      },
      foregroundColor: switch (style) {
        PosIconButtonStyle.filled => cs.onPrimary,
        PosIconButtonStyle.tonal => cs.onPrimaryContainer,
        _ => cs.onSurface,
      },
      side: style == PosIconButtonStyle.outlined ? BorderSide(color: context.pos.borderStrong) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.shape.buttonRadius > 20 ? 999 : context.shape.radiusMd),
      ),
    );
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: btnStyle,
      icon: Badge(
        isLabelVisible: badge != null,
        label: Text(badge ?? ''),
        child: Icon(icon, size: size * 0.48),
      ),
    );
  }
}

enum PosIconButtonStyle { plain, tonal, filled, outlined }

/// Primary action + dropdown of secondary actions.
class PosSplitButton extends StatelessWidget {
  const PosSplitButton({super.key, required this.label, required this.onPressed, required this.items, this.icon});

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final List<PopupMenuEntry<VoidCallback>> items;

  @override
  Widget build(BuildContext context) {
    final r = context.shape.buttonRadius;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: onPressed,
          icon: icon == null ? null : Icon(icon, size: 18),
          label: Text(label),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.horizontal(
                start: Radius.circular(r),
              ).resolve(Directionality.of(context)),
            ),
          ),
        ),
        const SizedBox(width: 1.5),
        PopupMenuButton<VoidCallback>(
          tooltip: 'More actions',
          onSelected: (cb) => cb(),
          itemBuilder: (_) => items,
          child: Container(
            height: 44,
            width: 40,
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadiusDirectional.horizontal(
                end: Radius.circular(r),
              ).resolve(Directionality.of(context)),
            ),
            child: Icon(Icons.expand_more_rounded, color: context.colors.onPrimary),
          ),
        ),
      ],
    );
  }
}
