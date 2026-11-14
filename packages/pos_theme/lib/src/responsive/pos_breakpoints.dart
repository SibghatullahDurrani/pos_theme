import 'package:flutter/widgets.dart';

/// Window size classes used across the POS suite.
enum PosWindow {
  /// < 600: phones, handheld scanners.
  compact,

  /// 600 – 1023: tablets, 10" POS.
  medium,

  /// 1024 – 1439: laptops, 15" terminals.
  expanded,

  /// >= 1440: desktops, wide displays.
  large;

  static const double mediumMin = 600;
  static const double expandedMin = 1024;
  static const double largeMin = 1440;

  static PosWindow fromWidth(double w) {
    if (w >= largeMin) return large;
    if (w >= expandedMin) return expanded;
    if (w >= mediumMin) return medium;
    return compact;
  }

  static PosWindow of(BuildContext context) => fromWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == compact;
  bool get isMedium => this == medium;
  bool get isExpanded => this == expanded;
  bool get isLarge => this == large;
  bool get atLeastMedium => index >= medium.index;
  bool get atLeastExpanded => index >= expanded.index;

  /// Page gutter for this size class.
  double get gutter => switch (this) {
    compact => 16,
    medium => 20,
    expanded => 24,
    large => 32,
  };

  /// Number of grid columns for dashboards/forms.
  int get columns => switch (this) {
    compact => 4,
    medium => 8,
    expanded => 12,
    large => 12,
  };
}

extension PosWindowContext on BuildContext {
  PosWindow get window => PosWindow.of(this);
}

/// Builds different layouts per window size, based on the *local* constraints
/// (so it also works inside split panes and dialogs).
class PosResponsive extends StatelessWidget {
  const PosResponsive({super.key, required this.compact, this.medium, this.expanded, this.large});

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = PosWindow.fromWidth(c.maxWidth);
        final builder = switch (w) {
          PosWindow.large => large ?? expanded ?? medium ?? compact,
          PosWindow.expanded => expanded ?? medium ?? compact,
          PosWindow.medium => medium ?? compact,
          PosWindow.compact => compact,
        };
        return builder(context);
      },
    );
  }
}

/// Picks a value by window size with fallbacks to the next smaller class.
T posValue<T>(BuildContext context, {required T compact, T? medium, T? expanded, T? large}) {
  return switch (PosWindow.of(context)) {
    PosWindow.large => large ?? expanded ?? medium ?? compact,
    PosWindow.expanded => expanded ?? medium ?? compact,
    PosWindow.medium => medium ?? compact,
    PosWindow.compact => compact,
  };
}

/// A wrap-based responsive grid: children declare spans per size class.
class PosGrid extends StatelessWidget {
  const PosGrid({super.key, required this.children, this.spacing = 16, this.runSpacing = 16});

  final List<PosGridItem> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = PosWindow.fromWidth(c.maxWidth);
        final cols = w.columns;
        final colW = (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final item in children)
              SizedBox(
                width: () {
                  final span = item.spanFor(w).clamp(1, cols);
                  return colW * span + spacing * (span - 1);
                }(),
                child: item.child,
              ),
          ],
        );
      },
    );
  }
}

class PosGridItem {
  const PosGridItem({required this.child, this.compact = 4, this.medium, this.expanded, this.large});

  final Widget child;
  final int compact;
  final int? medium;
  final int? expanded;
  final int? large;

  int spanFor(PosWindow w) => switch (w) {
    PosWindow.large => large ?? expanded ?? medium ?? compact * 3,
    PosWindow.expanded => expanded ?? medium ?? compact * 3,
    PosWindow.medium => medium ?? compact * 2,
    PosWindow.compact => compact,
  };
}
