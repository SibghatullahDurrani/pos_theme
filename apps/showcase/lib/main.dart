import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final controller = PosThemeController(
    spec: PosThemes.byId(prefs.getString('theme')),
    mode: ThemeMode.values.byName(prefs.getString('mode') ?? ThemeMode.light.name),
  );
  controller.addListener(() {
    prefs.setString('theme', controller.spec.id);
    prefs.setString('mode', controller.mode.name);
  });
  runApp(ShowcaseApp(controller: controller));
}

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key, required this.controller});
  final PosThemeController controller;

  @override
  Widget build(BuildContext context) {
    return PosThemeScope(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => MaterialApp(
          title: 'POS Theme Studio',
          debugShowCheckedModeBanner: false,
          theme: controller.light,
          darkTheme: controller.dark,
          themeMode: controller.mode,
          themeAnimationDuration: PosMotion.slow,
          home: const AppShell(),
        ),
      ),
    );
  }
}
