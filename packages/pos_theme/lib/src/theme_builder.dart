import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'themes/pos_theme_spec.dart';
import 'tokens/pos_tokens.dart';

/// Font loading switch. Set [useGoogleFonts] to false in widget tests or
/// fully-offline builds that don't bundle the font files.
abstract final class PosFonts {
  static bool useGoogleFonts = true;
}

/// Builds a complete Material 3 [ThemeData] for [spec] in [brightness].
ThemeData buildPosTheme(PosThemeSpec spec, Brightness brightness) {
  final p = spec.palette(brightness);
  final isDark = brightness == Brightness.dark;
  final s = spec.shape;

  // ---- Semantic tones -------------------------------------------------------
  PosTone tone(Color c) => PosTone.derive(c, p.surface, brightness);
  final success = tone(p.success);
  final warning = tone(p.warning);
  final info = tone(p.info);
  final danger = tone(p.danger);
  final neutral = PosTone(
    color: p.textMuted,
    onColor: posOnColor(p.textMuted),
    container: p.surfaceMuted,
    onContainer: p.onSurface,
  );
  final primaryContainer =
      p.primaryContainer ?? Color.alphaBlend(p.primary.withValues(alpha: isDark ? 0.22 : 0.12), p.surface);
  final onPrimaryContainer = p.onPrimaryContainer ?? posShift(p.primary, isDark ? 0.22 : -0.18);
  final brand = PosTone(
    color: p.primary,
    onColor: p.onPrimary,
    container: primaryContainer,
    onContainer: onPrimaryContainer,
  );

  Color container(Color c) => Color.alphaBlend(c.withValues(alpha: isDark ? 0.22 : 0.12), p.surface);

  var inversePrimary = posShift(p.primary, isDark ? -0.2 : 0.25);
  if (posContrast(inversePrimary, p.onSurface) < 3) inversePrimary = p.surface;

  final cs = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: p.secondary,
    onSecondary: p.onSecondary,
    secondaryContainer: container(p.secondary),
    onSecondaryContainer: p.onSurface,
    tertiary: p.tertiary,
    onTertiary: posOnColor(p.tertiary),
    tertiaryContainer: container(p.tertiary),
    onTertiaryContainer: posShift(p.tertiary, isDark ? 0.2 : -0.2),
    error: p.danger,
    onError: danger.onColor,
    errorContainer: danger.container,
    onErrorContainer: danger.onContainer,
    surface: p.surface,
    onSurface: p.onSurface,
    onSurfaceVariant: p.textMuted,
    surfaceDim: p.canvas,
    surfaceBright: p.surfaceHigh,
    surfaceContainerLowest: p.surface,
    surfaceContainerLow: Color.lerp(p.surface, p.surfaceMuted, 0.5),
    surfaceContainer: p.surfaceMuted,
    surfaceContainerHigh: p.surfaceHigh,
    surfaceContainerHighest: Color.lerp(p.surfaceMuted, p.border, 0.5),
    outline: p.borderStrong,
    outlineVariant: p.border,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: p.onSurface,
    onInverseSurface: p.surface,
    inversePrimary: inversePrimary,
    surfaceTint: Colors.transparent,
  );

  // ---- Shadows --------------------------------------------------------------
  final shadowBase = switch (s.shadows) {
    PosShadowStyle.tinted => isDark ? Colors.black : const Color(0xFF6B3410),
    _ => isDark ? Colors.black : const Color(0xFF0F172A),
  };
  List<BoxShadow> shadow(double y, double blur, double alpha) => s.shadows == PosShadowStyle.none
      ? const []
      : [
          BoxShadow(
            color: shadowBase.withValues(alpha: isDark ? alpha * 4 : alpha),
            offset: Offset(0, y),
            blurRadius: blur,
          ),
          BoxShadow(
            color: shadowBase.withValues(alpha: isDark ? alpha * 2 : alpha / 2),
            offset: Offset(0, y / 3),
            blurRadius: blur / 3,
          ),
        ];

  final posShape = PosShape(
    radiusXs: s.radiusXs,
    radiusSm: s.radiusSm,
    radiusMd: s.radiusMd,
    radiusLg: s.radiusLg,
    radiusXl: s.radiusXl,
    buttonRadius: s.buttonRadius,
    borderWidth: s.borderWidth,
    shadowsSm: shadow(1, 3, 0.06),
    shadowsMd: shadow(4, 14, 0.08),
    shadowsLg: shadow(12, 36, 0.14),
    cardBordered: s.cardBordered,
  );

  final posColors = PosColors(
    success: success,
    warning: warning,
    info: info,
    danger: danger,
    neutral: neutral,
    brand: brand,
    canvas: p.canvas,
    surfaceMuted: p.surfaceMuted,
    border: p.border,
    borderStrong: p.borderStrong,
    textMuted: p.textMuted,
    sidebarBg: p.sidebarBg,
    sidebarFg: p.sidebarFg,
    sidebarMuted: p.sidebarMuted,
    sidebarActiveBg: p.sidebarActiveBg,
    sidebarActiveFg: p.sidebarActiveFg,
    sidebarBorder: p.sidebarBorder,
    chart: p.chart,
  );

  // ---- Typography -----------------------------------------------------------
  final textTheme = _buildTextTheme(spec, p);

  // ---- Shapes ---------------------------------------------------------------
  RoundedRectangleBorder rr(double r, [BorderSide side = BorderSide.none]) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r), side: side);
  final borderSide = BorderSide(color: p.border, width: s.borderWidth);
  final buttonShape = rr(s.buttonRadius);
  final buttonText = textTheme.labelLarge!.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: spec.buttonLetterSpacing,
  );
  const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 12);
  const buttonMinSize = Size(64, 44);
  final disabledBg = p.onSurface.withValues(alpha: 0.08);
  final disabledFg = p.onSurface.withValues(alpha: 0.38);

  // ---- Inputs ---------------------------------------------------------------
  OutlineInputBorder ob(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(s.radiusMd),
    borderSide: BorderSide(color: c, width: w),
  );
  final inputTheme = InputDecorationThemeData(
    filled: true,
    fillColor: spec.filledInputs ? p.surfaceMuted : p.surface,
    hoverColor: p.onSurface.withValues(alpha: 0.03),
    isDense: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: ob(spec.filledInputs ? p.border : p.borderStrong),
    enabledBorder: ob(spec.filledInputs ? p.border : p.borderStrong),
    focusedBorder: ob(p.primary, 2),
    errorBorder: ob(p.danger),
    focusedErrorBorder: ob(p.danger, 2),
    disabledBorder: ob(p.border.withValues(alpha: 0.6)),
    labelStyle: textTheme.bodyMedium!.copyWith(color: p.textMuted),
    floatingLabelStyle: textTheme.bodyMedium!.copyWith(color: p.primary, fontWeight: FontWeight.w600),
    hintStyle: textTheme.bodyMedium!.copyWith(color: p.textMuted.withValues(alpha: 0.8)),
    helperStyle: textTheme.bodySmall!.copyWith(color: p.textMuted),
    errorStyle: textTheme.bodySmall!.copyWith(color: p.danger, fontWeight: FontWeight.w600),
    prefixIconColor: p.textMuted,
    suffixIconColor: p.textMuted,
    iconColor: p.textMuted,
  );

  final menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(p.surfaceHigh),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(s.shadows == PosShadowStyle.none ? 0 : 8),
    shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: isDark ? 0.5 : 0.18)),
    shape: WidgetStatePropertyAll(rr(s.radiusMd, borderSide)),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6)),
  );

  final overlay = WidgetStateProperty.resolveWith<Color?>((st) {
    if (st.contains(WidgetState.pressed)) return p.onSurface.withValues(alpha: 0.10);
    if (st.contains(WidgetState.hovered)) return p.onSurface.withValues(alpha: 0.05);
    if (st.contains(WidgetState.focused)) return p.primary.withValues(alpha: 0.12);
    return null;
  });

  final snackBg = isDark ? p.surfaceHigh : p.onSurface;
  final snackFg = isDark ? p.onSurface : p.surface;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: cs,
    textTheme: textTheme,
    primaryTextTheme: textTheme.apply(bodyColor: p.onPrimary, displayColor: p.onPrimary),
    scaffoldBackgroundColor: p.canvas,
    canvasColor: p.surface,
    cardColor: p.surface,
    dividerColor: p.border,
    hoverColor: p.onSurface.withValues(alpha: 0.04),
    focusColor: p.primary.withValues(alpha: 0.12),
    highlightColor: Colors.transparent,
    splashFactory: InkRipple.splashFactory,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: spec.compactDensity ? VisualDensity.compact : VisualDensity.standard,
    extensions: [posColors, posShape],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    iconTheme: IconThemeData(color: p.onSurface, size: 22),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.primary,
      selectionColor: p.primary.withValues(alpha: 0.28),
      selectionHandleColor: p.primary,
    ),

    // App chrome
    appBarTheme: AppBarThemeData(
      backgroundColor: p.surface,
      foregroundColor: p.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: 64,
      titleTextStyle: textTheme.titleLarge,
      shape: Border(bottom: borderSide),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: p.sidebarBg,
      indicatorColor: p.sidebarActiveBg,
      indicatorShape: rr(s.radiusMd),
      selectedIconTheme: IconThemeData(color: p.sidebarActiveFg, size: 22),
      unselectedIconTheme: IconThemeData(color: p.sidebarMuted, size: 22),
      selectedLabelTextStyle: textTheme.labelMedium!.copyWith(color: p.sidebarFg, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: textTheme.labelMedium!.copyWith(color: p.sidebarMuted),
      labelType: NavigationRailLabelType.all,
      minWidth: 80,
      groupAlignment: -1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryContainer,
      indicatorShape: rr(s.buttonRadius > 20 ? 999 : s.radiusMd),
      height: 68,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (st) => IconThemeData(color: st.contains(WidgetState.selected) ? onPrimaryContainer : p.textMuted),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (st) => textTheme.labelMedium!.copyWith(
          color: st.contains(WidgetState.selected) ? p.onSurface : p.textMuted,
          fontWeight: st.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: p.sidebarBg,
      surfaceTintColor: Colors.transparent,
      width: 288,
      shape: const RoundedRectangleBorder(),
      endShape: const RoundedRectangleBorder(),
      scrimColor: Colors.black.withValues(alpha: 0.45),
    ),
    bottomAppBarTheme: BottomAppBarThemeData(color: p.surface, elevation: 0, surfaceTintColor: Colors.transparent),

    // Surfaces
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: !s.cardBordered && s.shadows != PosShadowStyle.none ? 1 : 0,
      shadowColor: shadowBase.withValues(alpha: 0.25),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: rr(s.radiusLg, s.cardBordered ? borderSide : BorderSide.none),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      elevation: s.shadows == PosShadowStyle.none ? 0 : 12,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: rr(s.radiusXl, isDark || s.shadows == PosShadowStyle.none ? borderSide : BorderSide.none),
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium!.copyWith(color: p.textMuted),
      barrierColor: Colors.black.withValues(alpha: isDark ? 0.65 : 0.45),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surfaceHigh,
      modalBackgroundColor: p.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      showDragHandle: true,
      dragHandleColor: p.borderStrong,
      dragHandleSize: const Size(40, 4),
      modalBarrierColor: Colors.black.withValues(alpha: isDark ? 0.65 : 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(s.radiusXl))),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: snackBg,
      contentTextStyle: textTheme.bodyMedium!.copyWith(color: snackFg, fontWeight: FontWeight.w500),
      actionTextColor: inversePrimary,
      closeIconColor: snackFg,
      elevation: 6,
      shape: rr(s.radiusMd, isDark ? borderSide : BorderSide.none),
      insetPadding: const EdgeInsets.all(16),
      width: null,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: snackBg, borderRadius: BorderRadius.circular(s.radiusSm)),
      textStyle: textTheme.bodySmall!.copyWith(color: snackFg, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      waitDuration: const Duration(milliseconds: 400),
      preferBelow: false,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      elevation: s.shadows == PosShadowStyle.none ? 0 : 8,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
      shape: rr(s.radiusMd, borderSide),
      textStyle: textTheme.bodyMedium,
      labelTextStyle: WidgetStatePropertyAll(textTheme.bodyMedium),
      menuPadding: const EdgeInsets.symmetric(vertical: 6),
      position: PopupMenuPosition.under,
    ),
    menuTheme: MenuThemeData(style: menuStyle),
    menuButtonTheme: MenuButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(160, 44)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
        textStyle: WidgetStatePropertyAll(textTheme.bodyMedium),
        overlayColor: overlay,
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: inputTheme,
      menuStyle: menuStyle,
      textStyle: textTheme.bodyLarge,
    ),
    inputDecorationTheme: inputTheme,
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(p.surfaceMuted),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: overlay,
      side: WidgetStateProperty.resolveWith(
        (st) => BorderSide(
          color: st.contains(WidgetState.focused) ? p.primary : p.border,
          width: st.contains(WidgetState.focused) ? 2 : 1,
        ),
      ),
      shape: WidgetStatePropertyAll(rr(s.buttonRadius > 20 ? 999 : s.radiusMd)),
      hintStyle: WidgetStatePropertyAll(textTheme.bodyMedium!.copyWith(color: p.textMuted)),
      textStyle: WidgetStatePropertyAll(textTheme.bodyMedium),
      constraints: const BoxConstraints(minHeight: 44, maxHeight: 48),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
    ),
    searchViewTheme: SearchViewThemeData(
      backgroundColor: p.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      dividerColor: p.border,
      shape: rr(s.radiusLg),
    ),

    // Buttons
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.disabled) ? disabledBg : p.primary,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.disabled) ? disabledFg : p.onPrimary,
        ),
        overlayColor: WidgetStateProperty.resolveWith((st) {
          if (st.contains(WidgetState.pressed)) return p.onPrimary.withValues(alpha: 0.16);
          if (st.contains(WidgetState.hovered)) return p.onPrimary.withValues(alpha: 0.08);
          return null;
        }),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: WidgetStatePropertyAll(buttonText),
        padding: const WidgetStatePropertyAll(buttonPadding),
        minimumSize: const WidgetStatePropertyAll(buttonMinSize),
        shape: WidgetStatePropertyAll(buttonShape),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.disabled) ? disabledBg : p.surfaceHigh,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.disabled) ? disabledFg : p.onSurface,
        ),
        overlayColor: overlay,
        elevation: WidgetStateProperty.resolveWith((st) {
          if (s.shadows == PosShadowStyle.none) return 0;
          return st.contains(WidgetState.hovered) ? 3 : 1;
        }),
        shadowColor: WidgetStatePropertyAll(shadowBase.withValues(alpha: 0.3)),
        side: WidgetStatePropertyAll(borderSide),
        textStyle: WidgetStatePropertyAll(buttonText),
        padding: const WidgetStatePropertyAll(buttonPadding),
        minimumSize: const WidgetStatePropertyAll(buttonMinSize),
        shape: WidgetStatePropertyAll(buttonShape),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.disabled) ? disabledFg : p.onSurface,
        ),
        overlayColor: overlay,
        side: WidgetStateProperty.resolveWith(
          (st) => BorderSide(
            color: st.contains(WidgetState.disabled)
                ? p.border
                : st.contains(WidgetState.hovered)
                ? p.onSurface.withValues(alpha: 0.5)
                : p.borderStrong,
            width: s.borderWidth,
          ),
        ),
        textStyle: WidgetStatePropertyAll(buttonText),
        padding: const WidgetStatePropertyAll(buttonPadding),
        minimumSize: const WidgetStatePropertyAll(buttonMinSize),
        shape: WidgetStatePropertyAll(buttonShape),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.disabled)
              ? disabledFg
              : (isDark || posContrast(p.primary, p.surface) >= 4.5 ? p.primary : p.onSurface),
        ),
        overlayColor: WidgetStateProperty.resolveWith((st) {
          if (st.contains(WidgetState.pressed)) return p.primary.withValues(alpha: 0.14);
          if (st.contains(WidgetState.hovered)) return p.primary.withValues(alpha: 0.07);
          return null;
        }),
        textStyle: WidgetStatePropertyAll(buttonText),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
        minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
        shape: WidgetStatePropertyAll(buttonShape),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        overlayColor: overlay,
        shape: WidgetStatePropertyAll(rr(s.buttonRadius > 20 ? 999 : s.radiusSm)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.onPrimary,
      elevation: s.shadows == PosShadowStyle.none ? 0 : 3,
      hoverElevation: s.shadows == PosShadowStyle.none ? 0 : 6,
      focusElevation: 0,
      highlightElevation: 2,
      shape: rr(s.buttonRadius > 20 ? 999 : s.radiusLg),
      extendedTextStyle: buttonText,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? primaryContainer : p.surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? onPrimaryContainer : p.onSurface,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: p.borderStrong, width: s.borderWidth)),
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w600)),
        shape: WidgetStatePropertyAll(rr(s.buttonRadius)),
        minimumSize: const WidgetStatePropertyAll(Size(48, 44)),
        overlayColor: overlay,
      ),
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      borderRadius: BorderRadius.circular(s.radiusMd),
      borderColor: p.borderStrong,
      selectedBorderColor: p.primary,
      selectedColor: onPrimaryContainer,
      fillColor: primaryContainer,
      color: p.onSurface,
      constraints: const BoxConstraints(minHeight: 44, minWidth: 48),
    ),

    // Selection controls
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((st) {
        if (st.contains(WidgetState.disabled)) {
          return st.contains(WidgetState.selected) ? disabledFg : Colors.transparent;
        }
        if (st.contains(WidgetState.error)) return p.danger;
        return st.contains(WidgetState.selected) ? p.primary : Colors.transparent;
      }),
      checkColor: WidgetStatePropertyAll(p.onPrimary),
      side: WidgetStateBorderSide.resolveWith(
        (st) => st.contains(WidgetState.selected)
            ? BorderSide.none
            : BorderSide(color: st.contains(WidgetState.error) ? p.danger : p.borderStrong, width: 1.6),
      ),
      shape: rr(s.radiusXs + 2 > 6 ? 6 : s.radiusXs + 2),
      overlayColor: overlay,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((st) {
        if (st.contains(WidgetState.disabled)) return disabledFg;
        return st.contains(WidgetState.selected) ? p.primary : p.borderStrong;
      }),
      overlayColor: overlay,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((st) {
        if (st.contains(WidgetState.disabled)) return p.surfaceMuted;
        return st.contains(WidgetState.selected) ? p.onPrimary : p.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((st) {
        if (st.contains(WidgetState.disabled)) return disabledBg;
        return st.contains(WidgetState.selected) ? p.primary : p.surfaceMuted;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (st) => st.contains(WidgetState.selected) ? Colors.transparent : p.borderStrong,
      ),
      overlayColor: overlay,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.primary,
      inactiveTrackColor: p.primary.withValues(alpha: 0.18),
      thumbColor: p.primary,
      overlayColor: p.primary.withValues(alpha: 0.12),
      valueIndicatorColor: snackBg,
      valueIndicatorTextStyle: textTheme.labelMedium!.copyWith(color: snackFg),
      trackHeight: 4,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.primary,
      linearTrackColor: p.primary.withValues(alpha: 0.15),
      circularTrackColor: p.primary.withValues(alpha: 0.12),
      linearMinHeight: 6,
      borderRadius: BorderRadius.circular(99),
    ),

    // Data display
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      selectedColor: primaryContainer,
      disabledColor: disabledBg,
      deleteIconColor: p.textMuted,
      checkmarkColor: onPrimaryContainer,
      labelStyle: textTheme.labelLarge!.copyWith(color: p.onSurface, fontWeight: FontWeight.w600),
      secondaryLabelStyle: textTheme.labelLarge!.copyWith(color: onPrimaryContainer),
      side: WidgetStateBorderSide.resolveWith(
        (st) => BorderSide(
          color: st.contains(WidgetState.selected) ? p.primary.withValues(alpha: 0.5) : p.borderStrong,
          width: s.borderWidth,
        ),
      ),
      shape: rr(s.buttonRadius > 20 ? 999 : s.radiusSm),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      showCheckmark: true,
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: p.danger,
      textColor: danger.onColor,
      textStyle: textTheme.labelSmall!.copyWith(fontWeight: FontWeight.w800),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(p.surfaceMuted),
      headingTextStyle: textTheme.labelMedium!.copyWith(
        color: p.textMuted,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      dataTextStyle: textTheme.bodyMedium,
      dataRowColor: WidgetStateProperty.resolveWith((st) {
        if (st.contains(WidgetState.selected)) return primaryContainer.withValues(alpha: 0.7);
        if (st.contains(WidgetState.hovered)) return p.surfaceMuted.withValues(alpha: 0.7);
        return null;
      }),
      headingRowHeight: 46,
      dataRowMinHeight: 52,
      dataRowMaxHeight: 64,
      horizontalMargin: 16,
      columnSpacing: 24,
      dividerThickness: 1,
      decoration: const BoxDecoration(),
    ),
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: p.textMuted,
      textColor: p.onSurface,
      selectedColor: onPrimaryContainer,
      selectedTileColor: primaryContainer,
      shape: rr(s.radiusSm),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 10,
      titleTextStyle: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
      subtitleTextStyle: textTheme.bodyMedium!.copyWith(color: p.textMuted),
      leadingAndTrailingTextStyle: textTheme.bodyMedium,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      shape: const RoundedRectangleBorder(),
      collapsedShape: const RoundedRectangleBorder(),
      iconColor: p.onSurface,
      collapsedIconColor: p.textMuted,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: isDark || posContrast(p.primary, p.surface) >= 4.5 ? p.primary : p.onSurface,
      unselectedLabelColor: p.textMuted,
      indicatorColor: p.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: p.border,
      labelStyle: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500),
      overlayColor: overlay,
      tabAlignment: TabAlignment.start,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(p.borderStrong),
      radius: const Radius.circular(8),
      thickness: const WidgetStatePropertyAll(6),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      elevation: s.shadows == PosShadowStyle.none ? 0 : 12,
      shape: rr(s.radiusXl, borderSide),
      headerBackgroundColor: p.primary,
      headerForegroundColor: p.onPrimary,
      headerHeadlineStyle: textTheme.headlineMedium!.copyWith(color: p.onPrimary),
      dividerColor: p.border,
      todayBorder: BorderSide(color: p.primary),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (st) => st.contains(WidgetState.selected) ? p.onPrimary : p.primary,
      ),
      dayShape: WidgetStatePropertyAll(rr(s.buttonRadius > 20 ? 999 : s.radiusSm)),
      rangeSelectionBackgroundColor: primaryContainer,
      rangePickerBackgroundColor: p.surfaceHigh,
      rangePickerHeaderBackgroundColor: p.primary,
      rangePickerHeaderForegroundColor: p.onPrimary,
      inputDecorationTheme: inputTheme,
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: p.textMuted),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: p.surfaceHigh,
      elevation: s.shadows == PosShadowStyle.none ? 0 : 12,
      shape: rr(s.radiusXl, borderSide),
      hourMinuteShape: rr(s.radiusMd),
      dayPeriodShape: rr(s.radiusMd),
      dialBackgroundColor: p.surfaceMuted,
      dialHandColor: p.primary,
      hourMinuteColor: WidgetStateColor.resolveWith(
        (st) => st.contains(WidgetState.selected) ? primaryContainer : p.surfaceMuted,
      ),
      hourMinuteTextColor: WidgetStateColor.resolveWith(
        (st) => st.contains(WidgetState.selected) ? onPrimaryContainer : p.onSurface,
      ),
      dayPeriodBorderSide: BorderSide(color: p.borderStrong),
      inputDecorationTheme: inputTheme,
    ),
  );
}

TextTheme _buildTextTheme(PosThemeSpec spec, PosPalette p) {
  final h = spec.headingWeight;
  final on = p.onSurface;
  final muted = p.textMuted;
  TextStyle t(double size, FontWeight w, double height, [double ls = 0, Color? color]) =>
      TextStyle(fontSize: size, fontWeight: w, height: height, letterSpacing: ls, color: color ?? on);

  final display = <String, TextStyle>{
    'displayLarge': t(48, h, 1.1, -1.2),
    'displayMedium': t(38, h, 1.12, -0.8),
    'displaySmall': t(30, h, 1.15, -0.5),
    'headlineLarge': t(28, h, 1.2, -0.4),
    'headlineMedium': t(24, h, 1.25, -0.3),
    'headlineSmall': t(20, h, 1.3, -0.2),
  };
  final body = <String, TextStyle>{
    'titleLarge': t(18, FontWeight.w700, 1.3, -0.1),
    'titleMedium': t(16, FontWeight.w600, 1.4),
    'titleSmall': t(14, FontWeight.w600, 1.4),
    'bodyLarge': t(16, FontWeight.w400, 1.5),
    'bodyMedium': t(14, FontWeight.w400, 1.45),
    'bodySmall': t(12.5, FontWeight.w400, 1.4, 0.1, muted),
    'labelLarge': t(14, FontWeight.w600, 1.2, 0.1),
    'labelMedium': t(12, FontWeight.w600, 1.2, 0.2),
    'labelSmall': t(11, FontWeight.w600, 1.2, 0.4),
  };

  TextStyle font(String family, TextStyle base) {
    if (!PosFonts.useGoogleFonts) return base;
    try {
      return GoogleFonts.getFont(family, textStyle: base);
    } catch (_) {
      return base;
    }
  }

  final d = display.map((k, v) => MapEntry(k, font(spec.displayFont, v)));
  final b = body.map((k, v) => MapEntry(k, font(spec.bodyFont, v)));
  return TextTheme(
    displayLarge: d['displayLarge'],
    displayMedium: d['displayMedium'],
    displaySmall: d['displaySmall'],
    headlineLarge: d['headlineLarge'],
    headlineMedium: d['headlineMedium'],
    headlineSmall: d['headlineSmall'],
    titleLarge: b['titleLarge'],
    titleMedium: b['titleMedium'],
    titleSmall: b['titleSmall'],
    bodyLarge: b['bodyLarge'],
    bodyMedium: b['bodyMedium'],
    bodySmall: b['bodySmall'],
    labelLarge: b['labelLarge'],
    labelMedium: b['labelMedium'],
    labelSmall: b['labelSmall'],
  );
}

/// Extension on spec for ergonomic access.
extension PosThemeSpecX on PosThemeSpec {
  ThemeData get lightTheme => buildPosTheme(this, Brightness.light);
  ThemeData get darkTheme => buildPosTheme(this, Brightness.dark);
}
