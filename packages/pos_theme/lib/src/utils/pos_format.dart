import 'package:flutter/material.dart';

/// Lightweight money formatter (swap for `intl` NumberFormat in production apps).
String posMoney(num value, {String symbol = '\$', int decimals = 2}) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final whole = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  final out = decimals > 0 ? '$symbol$whole.${parts[1]}' : '$symbol$whole';
  return negative ? '-$out' : out;
}

/// Stable pleasant colour derived from a string (for placeholders/avatars).
Color posHashColor(String seed, List<Color> palette) {
  var h = 0;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return palette[h % palette.length];
}

String posInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// Tabular-figure text style helper for prices and quantities.
TextStyle posTabular(TextStyle style) => style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
