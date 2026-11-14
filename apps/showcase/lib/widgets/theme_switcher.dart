import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

/// Swatch that previews a theme's primary/sidebar/canvas colours.
class ThemeSwatch extends StatelessWidget {
  const ThemeSwatch({super.key, required this.spec, required this.selected, required this.onTap, this.size = 36});
  final PosThemeSpec spec;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = spec.palette(Theme.of(context).brightness);
    return Tooltip(
      message: spec.name,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: PosMotion.fast,
          width: size,
          height: size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? context.colors.onSurface : Colors.transparent, width: 2),
          ),
          child: ClipOval(
            child: Row(
              children: [
                Expanded(child: ColoredBox(color: p.primary)),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: ColoredBox(color: p.sidebarBg)),
                      Expanded(child: ColoredBox(color: p.canvas)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full theme picker panel (used in a popover/sheet and settings).
class ThemePickerPanel extends StatelessWidget {
  const ThemePickerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final c = PosThemeScope.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Theme', style: context.text.titleSmall),
        const SizedBox(height: 8),
        for (final spec in PosThemes.all)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              selected: spec.id == c.spec.id,
              onTap: () => c.spec = spec,
              leading: ThemeSwatch(spec: spec, selected: false, onTap: () => c.spec = spec, size: 34),
              title: Text(spec.name),
              subtitle: Text(spec.tagline, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: spec.id == c.spec.id ? Icon(Icons.check_circle_rounded, color: context.colors.primary) : null,
            ),
          ),
        const SizedBox(height: 10),
        Text('Mode', style: context.text.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('Auto')),
          ],
          selected: {c.mode},
          showSelectedIcon: false,
          onSelectionChanged: (s) => c.mode = s.first,
        ),
      ],
    );
  }
}

/// Top-bar button that opens the theme picker.
class ThemeSwitcherButton extends StatelessWidget {
  const ThemeSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = PosThemeScope.of(context);
    final w = context.window;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (w.atLeastExpanded)
          for (final s in PosThemes.all)
            ThemeSwatch(spec: s, selected: s.id == c.spec.id, onTap: () => c.spec = s, size: 30),
        IconButton(
          tooltip: 'Toggle light / dark',
          onPressed: () => c.mode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),
        IconButton(
          tooltip: 'Theme settings',
          icon: const Icon(Icons.palette_outlined),
          onPressed: () => showPosAdaptiveDialog<void>(
            context,
            builder: (ctx) => const PosDialog(
              title: 'Appearance',
              message: 'Every screen in the suite updates instantly.',
              icon: Icons.palette_outlined,
              content: ThemePickerPanel(),
            ),
          ),
        ),
      ],
    );
  }
}
