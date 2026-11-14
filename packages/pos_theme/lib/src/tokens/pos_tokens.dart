import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Spacing scale shared by every theme (4pt grid).
abstract final class PosSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Minimum touch target for POS (larger than Material's 48 on terminals).
  static const double touchTarget = 48;
  static const double touchTargetLarge = 56;
}

/// Motion tokens.
abstract final class PosMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}

/// A semantic tone: a strong colour, the colour that sits on it, a soft
/// container and the text colour that sits on the container.
@immutable
class PosTone {
  const PosTone({required this.color, required this.onColor, required this.container, required this.onContainer});

  /// Derives a tone from a single base colour for the given surface.
  factory PosTone.derive(Color base, Color surface, Brightness brightness) {
    final hsl = HSLColor.fromColor(base);
    final isDark = brightness == Brightness.dark;
    final container = Color.alphaBlend(base.withValues(alpha: isDark ? 0.20 : 0.12), surface);
    final onContainer = isDark
        ? hsl.withLightness((hsl.lightness + 0.25).clamp(0.72, 0.88)).toColor()
        : hsl.withLightness((hsl.lightness - 0.22).clamp(0.18, 0.32)).toColor();
    return PosTone(color: base, onColor: posOnColor(base), container: container, onContainer: onContainer);
  }

  final Color color;
  final Color onColor;
  final Color container;
  final Color onContainer;

  static PosTone lerp(PosTone a, PosTone b, double t) => PosTone(
    color: Color.lerp(a.color, b.color, t)!,
    onColor: Color.lerp(a.onColor, b.onColor, t)!,
    container: Color.lerp(a.container, b.container, t)!,
    onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
  );
}

/// Colours not covered by [ColorScheme]: status tones, sidebar, borders,
/// chart series.
@immutable
class PosColors extends ThemeExtension<PosColors> {
  const PosColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
    required this.neutral,
    required this.brand,
    required this.canvas,
    required this.surfaceMuted,
    required this.border,
    required this.borderStrong,
    required this.textMuted,
    required this.sidebarBg,
    required this.sidebarFg,
    required this.sidebarMuted,
    required this.sidebarActiveBg,
    required this.sidebarActiveFg,
    required this.sidebarBorder,
    required this.chart,
  });

  final PosTone success;
  final PosTone warning;
  final PosTone info;
  final PosTone danger;
  final PosTone neutral;
  final PosTone brand;

  /// Page background behind cards.
  final Color canvas;
  final Color surfaceMuted;
  final Color border;
  final Color borderStrong;
  final Color textMuted;

  final Color sidebarBg;
  final Color sidebarFg;
  final Color sidebarMuted;
  final Color sidebarActiveBg;
  final Color sidebarActiveFg;
  final Color sidebarBorder;

  /// Ordered chart series colours.
  final List<Color> chart;

  @override
  PosColors copyWith({
    PosTone? success,
    PosTone? warning,
    PosTone? info,
    PosTone? danger,
    PosTone? neutral,
    PosTone? brand,
    Color? canvas,
    Color? surfaceMuted,
    Color? border,
    Color? borderStrong,
    Color? textMuted,
    Color? sidebarBg,
    Color? sidebarFg,
    Color? sidebarMuted,
    Color? sidebarActiveBg,
    Color? sidebarActiveFg,
    Color? sidebarBorder,
    List<Color>? chart,
  }) => PosColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    info: info ?? this.info,
    danger: danger ?? this.danger,
    neutral: neutral ?? this.neutral,
    brand: brand ?? this.brand,
    canvas: canvas ?? this.canvas,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    textMuted: textMuted ?? this.textMuted,
    sidebarBg: sidebarBg ?? this.sidebarBg,
    sidebarFg: sidebarFg ?? this.sidebarFg,
    sidebarMuted: sidebarMuted ?? this.sidebarMuted,
    sidebarActiveBg: sidebarActiveBg ?? this.sidebarActiveBg,
    sidebarActiveFg: sidebarActiveFg ?? this.sidebarActiveFg,
    sidebarBorder: sidebarBorder ?? this.sidebarBorder,
    chart: chart ?? this.chart,
  );

  @override
  PosColors lerp(ThemeExtension<PosColors>? other, double t) {
    if (other is! PosColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return PosColors(
      success: PosTone.lerp(success, other.success, t),
      warning: PosTone.lerp(warning, other.warning, t),
      info: PosTone.lerp(info, other.info, t),
      danger: PosTone.lerp(danger, other.danger, t),
      neutral: PosTone.lerp(neutral, other.neutral, t),
      brand: PosTone.lerp(brand, other.brand, t),
      canvas: c(canvas, other.canvas),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      textMuted: c(textMuted, other.textMuted),
      sidebarBg: c(sidebarBg, other.sidebarBg),
      sidebarFg: c(sidebarFg, other.sidebarFg),
      sidebarMuted: c(sidebarMuted, other.sidebarMuted),
      sidebarActiveBg: c(sidebarActiveBg, other.sidebarActiveBg),
      sidebarActiveFg: c(sidebarActiveFg, other.sidebarActiveFg),
      sidebarBorder: c(sidebarBorder, other.sidebarBorder),
      chart: [for (var i = 0; i < chart.length; i++) i < other.chart.length ? c(chart[i], other.chart[i]) : chart[i]],
    );
  }
}

/// Shape & elevation language of a theme.
@immutable
class PosShape extends ThemeExtension<PosShape> {
  const PosShape({
    required this.radiusXs,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.buttonRadius,
    required this.borderWidth,
    required this.shadowsSm,
    required this.shadowsMd,
    required this.shadowsLg,
    required this.cardBordered,
  });

  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double buttonRadius;
  final double borderWidth;
  final List<BoxShadow> shadowsSm;
  final List<BoxShadow> shadowsMd;
  final List<BoxShadow> shadowsLg;

  /// Whether cards draw an outline (flat styles) in addition to/instead of shadows.
  final bool cardBordered;

  BorderRadius get xs => BorderRadius.circular(radiusXs);
  BorderRadius get sm => BorderRadius.circular(radiusSm);
  BorderRadius get md => BorderRadius.circular(radiusMd);
  BorderRadius get lg => BorderRadius.circular(radiusLg);
  BorderRadius get xl => BorderRadius.circular(radiusXl);
  BorderRadius get button => BorderRadius.circular(buttonRadius);

  @override
  PosShape copyWith({
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? buttonRadius,
    double? borderWidth,
    List<BoxShadow>? shadowsSm,
    List<BoxShadow>? shadowsMd,
    List<BoxShadow>? shadowsLg,
    bool? cardBordered,
  }) => PosShape(
    radiusXs: radiusXs ?? this.radiusXs,
    radiusSm: radiusSm ?? this.radiusSm,
    radiusMd: radiusMd ?? this.radiusMd,
    radiusLg: radiusLg ?? this.radiusLg,
    radiusXl: radiusXl ?? this.radiusXl,
    buttonRadius: buttonRadius ?? this.buttonRadius,
    borderWidth: borderWidth ?? this.borderWidth,
    shadowsSm: shadowsSm ?? this.shadowsSm,
    shadowsMd: shadowsMd ?? this.shadowsMd,
    shadowsLg: shadowsLg ?? this.shadowsLg,
    cardBordered: cardBordered ?? this.cardBordered,
  );

  @override
  PosShape lerp(ThemeExtension<PosShape>? other, double t) {
    if (other is! PosShape) return this;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    return PosShape(
      radiusXs: d(radiusXs, other.radiusXs),
      radiusSm: d(radiusSm, other.radiusSm),
      radiusMd: d(radiusMd, other.radiusMd),
      radiusLg: d(radiusLg, other.radiusLg),
      radiusXl: d(radiusXl, other.radiusXl),
      buttonRadius: d(buttonRadius, other.buttonRadius),
      borderWidth: d(borderWidth, other.borderWidth),
      shadowsSm: BoxShadow.lerpList(shadowsSm, other.shadowsSm, t) ?? const [],
      shadowsMd: BoxShadow.lerpList(shadowsMd, other.shadowsMd, t) ?? const [],
      shadowsLg: BoxShadow.lerpList(shadowsLg, other.shadowsLg, t) ?? const [],
      cardBordered: t < 0.5 ? cardBordered : other.cardBordered,
    );
  }
}

/// Convenience accessors.
extension PosThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  PosColors get pos => Theme.of(this).extension<PosColors>()!;
  PosShape get shape => Theme.of(this).extension<PosShape>()!;
}

/// WCAG contrast ratio between two opaque colours (1.0 – 21.0).
double posContrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Lighten (positive) or darken (negative) a colour in HSL space.
Color posShift(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// Picks whichever of [light]/[dark] contrasts more with [background].
Color posOnColor(Color background, {Color light = Colors.white, Color dark = const Color(0xFF0B0F14)}) {
  return posContrast(background, light) >= posContrast(background, dark) ? light : dark;
}
