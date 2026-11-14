import 'package:flutter/material.dart';

/// Raw colour palette for one brightness of a theme.
@immutable
class PosPalette {
  const PosPalette({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceHigh,
    required this.onSurface,
    required this.textMuted,
    required this.border,
    required this.borderStrong,
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
    required this.sidebarBg,
    required this.sidebarFg,
    required this.sidebarMuted,
    required this.sidebarActiveBg,
    required this.sidebarActiveFg,
    required this.sidebarBorder,
    required this.chart,
    this.primaryContainer,
    this.onPrimaryContainer,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;

  /// App background behind content.
  final Color canvas;

  /// Cards, sheets, dialogs.
  final Color surface;

  /// Table headers, input fills, hover rows.
  final Color surfaceMuted;

  /// Menus / popovers / elevated layers.
  final Color surfaceHigh;
  final Color onSurface;
  final Color textMuted;
  final Color border;
  final Color borderStrong;

  final Color success;
  final Color warning;
  final Color info;
  final Color danger;

  final Color sidebarBg;
  final Color sidebarFg;
  final Color sidebarMuted;
  final Color sidebarActiveBg;
  final Color sidebarActiveFg;
  final Color sidebarBorder;

  final List<Color> chart;

  final Color? primaryContainer;
  final Color? onPrimaryContainer;
}

/// Shape language of a theme.
@immutable
class PosShapeSpec {
  const PosShapeSpec({
    required this.radiusXs,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.buttonRadius,
    this.borderWidth = 1,
    this.shadows = PosShadowStyle.soft,
    this.cardBordered = true,
  });

  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double buttonRadius;
  final double borderWidth;
  final PosShadowStyle shadows;
  final bool cardBordered;
}

enum PosShadowStyle {
  /// No shadows at all, depth from borders only.
  none,

  /// Low, diffuse neutral shadows.
  soft,

  /// Shadows tinted with a brand colour.
  tinted,
}

/// Complete definition of a POS theme (both brightnesses).
@immutable
class PosThemeSpec {
  const PosThemeSpec({
    required this.id,
    required this.name,
    required this.tagline,
    required this.light,
    required this.dark,
    required this.bodyFont,
    required this.displayFont,
    required this.shape,
    this.filledInputs = true,
    this.buttonLetterSpacing = 0.1,
    this.headingWeight = FontWeight.w700,
    this.compactDensity = false,
  });

  final String id;
  final String name;
  final String tagline;
  final PosPalette light;
  final PosPalette dark;

  /// Google Fonts family names.
  final String bodyFont;
  final String displayFont;
  final PosShapeSpec shape;

  /// Filled inputs (true) vs. outlined-on-surface inputs (false).
  final bool filledInputs;
  final double buttonLetterSpacing;
  final FontWeight headingWeight;
  final bool compactDensity;

  PosPalette palette(Brightness b) => b == Brightness.dark ? dark : light;
}
