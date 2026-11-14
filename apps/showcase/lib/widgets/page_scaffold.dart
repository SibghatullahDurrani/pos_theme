import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

/// Standard scrolling page body with responsive gutters and max width.
class ShowcasePage extends StatelessWidget {
  const ShowcasePage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.action,
    this.maxWidth = 1400,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? action;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final g = context.window.gutter;
    return ListView(
      padding: EdgeInsets.fromLTRB(g, g, g, g + 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PosSectionHeader(title: title, subtitle: subtitle, action: action),
                const SizedBox(height: 8),
                for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 20), child: c),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A titled demo block.
class DemoSection extends StatelessWidget {
  const DemoSection({super.key, required this.title, this.description, required this.child, this.trailing});
  final String title;
  final String? description;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return PosCard(
      title: title,
      subtitle: description,
      trailing: trailing,
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

/// Wrap with standard spacing.
class DemoWrap extends StatelessWidget {
  const DemoWrap({super.key, required this.children, this.spacing = 12});
  final List<Widget> children;
  final double spacing;
  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: spacing, runSpacing: spacing, crossAxisAlignment: WrapCrossAlignment.center, children: children);
}

/// Small caption label above a demo.
class DemoLabel extends StatelessWidget {
  const DemoLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text.toUpperCase(),
      style: context.text.labelSmall!.copyWith(color: context.pos.textMuted, letterSpacing: 1),
    ),
  );
}
