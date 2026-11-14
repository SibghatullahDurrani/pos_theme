import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_theme/pos_theme.dart';

void main() {
  setUpAll(() => PosFonts.useGoogleFonts = false);

  for (final spec in PosThemes.all) {
    for (final b in Brightness.values) {
      group('${spec.name} ${b.name}', () {
        final theme = buildPosTheme(spec, b);
        final cs = theme.colorScheme;
        final pos = theme.extension<PosColors>()!;

        test('builds with extensions', () {
          expect(theme.brightness, b);
          expect(theme.extension<PosShape>(), isNotNull);
        });

        test('body text contrast ≥ 7 (AAA)', () {
          expect(posContrast(cs.onSurface, cs.surface), greaterThanOrEqualTo(7));
          expect(posContrast(cs.onSurface, pos.canvas), greaterThanOrEqualTo(7));
        });

        test('muted text contrast ≥ 4.5 (AA)', () {
          expect(posContrast(pos.textMuted, cs.surface), greaterThanOrEqualTo(4.5));
          expect(posContrast(pos.textMuted, pos.surfaceMuted), greaterThanOrEqualTo(4.0));
        });

        test('primary button label contrast ≥ 4.5', () {
          expect(posContrast(cs.onPrimary, cs.primary), greaterThanOrEqualTo(4.5));
        });

        test('sidebar contrast', () {
          expect(posContrast(pos.sidebarFg, pos.sidebarBg), greaterThanOrEqualTo(7));
          expect(posContrast(pos.sidebarMuted, pos.sidebarBg), greaterThanOrEqualTo(3.5));
          expect(posContrast(pos.sidebarActiveFg, pos.sidebarActiveBg), greaterThanOrEqualTo(4.5));
        });

        test('status pills readable ≥ 4.5', () {
          for (final t in [pos.success, pos.warning, pos.info, pos.danger, pos.brand, pos.neutral]) {
            expect(posContrast(t.onContainer, t.container), greaterThanOrEqualTo(4.5),
                reason: 'tone ${t.color} onContainer');
          }
        });

        test('solid tone labels ≥ 3 (large/bold text)', () {
          for (final t in [pos.success, pos.warning, pos.info, pos.danger]) {
            expect(posContrast(t.onColor, t.color), greaterThanOrEqualTo(3), reason: 'tone ${t.color}');
          }
        });
      });
    }
  }

  test('breakpoints', () {
    expect(PosWindow.fromWidth(360), PosWindow.compact);
    expect(PosWindow.fromWidth(768), PosWindow.medium);
    expect(PosWindow.fromWidth(1280), PosWindow.expanded);
    expect(PosWindow.fromWidth(1920), PosWindow.large);
  });

  test('money format', () {
    expect(posMoney(1234.5), '\$1,234.50');
    expect(posMoney(-3), '-\$3.00');
  });
}
