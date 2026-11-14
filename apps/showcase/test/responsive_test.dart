import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_showcase/app_shell.dart';
import 'package:pos_showcase/main.dart';
import 'package:pos_theme/pos_theme.dart';

const pages = [
  'gallery',
  'dashboard',
  'checkout',
  'floor',
  'kitchen',
  'inventory',
  'customers',
  'settings',
  'foundations',
  'buttons',
  'inputs',
  'tables',
  'navigation',
  'overlays',
  'feedback',
  'dataviz',
  'pos',
];

const sizes = {
  'phone': Size(360, 780),
  'tablet': Size(820, 1180),
  'desktop': Size(1280, 800),
  'wide': Size(1920, 1080),
};

Future<void> pumpPage(WidgetTester tester, PosThemeController c, String page, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    PosThemeScope(
      controller: c,
      child: ListenableBuilder(
        listenable: c,
        builder: (context, _) => MaterialApp(
          theme: c.light,
          darkTheme: c.dark,
          themeMode: c.mode,
          home: AppShell(key: ValueKey('$page-$size'), initial: page),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(() => PosFonts.useGoogleFonts = false);

  group('every page renders without overflow at every size', () {
    for (final page in pages) {
      for (final e in sizes.entries) {
        testWidgets('$page @ ${e.key}', (tester) async {
          final c = PosThemeController(spec: PosThemes.corporateBlue, mode: ThemeMode.light);
          await pumpPage(tester, c, page, e.value);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('every theme × mode renders key screens', () {
    for (final spec in PosThemes.all) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        for (final page in ['gallery', 'checkout', 'pos', 'inputs', 'floor']) {
          for (final s in ['phone', 'desktop']) {
            testWidgets('${spec.id} ${mode.name} $page @ $s', (tester) async {
              final c = PosThemeController(spec: spec, mode: mode);
              await pumpPage(tester, c, page, sizes[s]!);
              expect(tester.takeException(), isNull);
            });
          }
        }
      }
    }
  });

  testWidgets('theme switching updates the app', (tester) async {
    final c = PosThemeController(mode: ThemeMode.light);
    await pumpPage(tester, c, 'gallery', sizes['desktop']!);
    c.spec = PosThemes.midnightPro;
    c.mode = ThemeMode.dark;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    final ctx = tester.element(find.byType(AppShell));
    expect(Theme.of(ctx).brightness, Brightness.dark);
    expect(Theme.of(ctx).colorScheme.primary, PosThemes.midnightPro.dark.primary);
  });

  test('ShowcaseApp constructs', () {
    expect(ShowcaseApp(controller: PosThemeController()), isA<Widget>());
  });
}
