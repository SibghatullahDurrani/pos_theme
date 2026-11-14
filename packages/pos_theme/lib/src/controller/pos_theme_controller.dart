import 'package:flutter/material.dart';

import '../theme_builder.dart';
import '../themes/pos_theme_spec.dart';
import '../themes/pos_themes.dart';

/// Holds the active theme + mode and caches the built [ThemeData]s.
///
/// Framework-agnostic: works with Provider, Riverpod, Bloc or plain
/// [PosThemeScope]. Persist [spec.id] / [mode] however your app prefers.
class PosThemeController extends ChangeNotifier {
  PosThemeController({PosThemeSpec spec = PosThemes.corporateBlue, ThemeMode mode = ThemeMode.system})
    : _spec = spec,
      _mode = mode;

  PosThemeSpec _spec;
  ThemeMode _mode;
  final Map<String, ThemeData> _cache = {};

  PosThemeSpec get spec => _spec;
  ThemeMode get mode => _mode;

  ThemeData get light => themeFor(_spec, Brightness.light);
  ThemeData get dark => themeFor(_spec, Brightness.dark);

  ThemeData themeFor(PosThemeSpec spec, Brightness b) =>
      _cache.putIfAbsent('${spec.id}/${b.name}', () => buildPosTheme(spec, b));

  set spec(PosThemeSpec value) {
    if (value.id == _spec.id) return;
    _spec = value;
    notifyListeners();
  }

  set mode(ThemeMode value) {
    if (value == _mode) return;
    _mode = value;
    notifyListeners();
  }

  /// Cycles light → dark → system.
  void toggleMode() {
    mode = switch (_mode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
  }
}

/// Exposes a [PosThemeController] to the widget tree.
class PosThemeScope extends InheritedNotifier<PosThemeController> {
  const PosThemeScope({super.key, required PosThemeController controller, required super.child})
    : super(notifier: controller);

  static PosThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PosThemeScope>();
    assert(scope != null, 'No PosThemeScope found in context');
    return scope!.notifier!;
  }

  static PosThemeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PosThemeScope>()?.notifier;
}
