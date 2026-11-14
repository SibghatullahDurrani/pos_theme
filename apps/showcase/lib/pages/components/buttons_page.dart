import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../widgets/page_scaffold.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});
  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _loading = false;
  Set<String> _seg = {'day'};
  int _toggle = 0;

  void _fakeLoad() {
    setState(() => _loading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    void tap() => PosToast.show(context, message: 'Button pressed');
    return ShowcasePage(
      title: 'Buttons',
      subtitle: 'One PosButton API with 6 variants × 4 sizes, icon, loading and disabled states.',
      children: [
        DemoSection(
          title: 'Variants',
          child: DemoWrap(
            children: [
              PosButton(label: 'Primary', onPressed: tap),
              PosButton.secondary(label: 'Secondary', onPressed: tap),
              PosButton.outline(label: 'Outline', onPressed: tap),
              PosButton.ghost(label: 'Ghost', onPressed: tap),
              PosButton.danger(label: 'Void order', icon: Icons.block_rounded, onPressed: tap),
              PosButton(
                label: 'Complete',
                variant: PosButtonVariant.success,
                icon: Icons.check_rounded,
                onPressed: tap,
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Sizes',
          description: 'XL is for primary register actions (Pay, Charge) on touch terminals.',
          child: DemoWrap(
            children: [
              PosButton(label: 'Small', size: PosButtonSize.sm, onPressed: tap),
              PosButton(label: 'Medium', size: PosButtonSize.md, onPressed: tap),
              PosButton(label: 'Large', size: PosButtonSize.lg, icon: Icons.print_outlined, onPressed: tap),
              PosButton(label: 'Charge \$48.20', size: PosButtonSize.xl, icon: Icons.payments_rounded, onPressed: tap),
            ],
          ),
        ),
        DemoSection(
          title: 'States',
          child: DemoWrap(
            children: [
              PosButton(label: 'With icon', icon: Icons.add_rounded, onPressed: tap),
              PosButton(label: 'Trailing', trailingIcon: Icons.arrow_forward_rounded, onPressed: tap),
              PosButton(label: _loading ? 'Processing…' : 'Click to load', loading: _loading, onPressed: _fakeLoad),
              const PosButton(label: 'Disabled', onPressed: null),
              const PosButton.outline(label: 'Disabled', onPressed: null),
              PosSplitButton(
                label: 'Save',
                icon: Icons.save_outlined,
                onPressed: tap,
                items: [
                  PopupMenuItem(value: tap, child: const Text('Save & print')),
                  PopupMenuItem(value: tap, child: const Text('Save as draft')),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Full width',
          child: Column(
            children: [
              PosButton(
                label: 'Pay now',
                icon: Icons.lock_rounded,
                size: PosButtonSize.lg,
                expand: true,
                onPressed: tap,
              ),
              const SizedBox(height: 10),
              PosButton.outline(label: 'Park sale', size: PosButtonSize.lg, expand: true, onPressed: tap),
            ],
          ),
        ),
        DemoSection(
          title: 'Icon buttons & FAB',
          child: DemoWrap(
            children: [
              PosIconButton(icon: Icons.edit_outlined, onPressed: tap, tooltip: 'Plain'),
              PosIconButton(
                icon: Icons.print_outlined,
                onPressed: tap,
                style: PosIconButtonStyle.outlined,
                tooltip: 'Outlined',
              ),
              PosIconButton(
                icon: Icons.qr_code_scanner,
                onPressed: tap,
                style: PosIconButtonStyle.tonal,
                tooltip: 'Tonal',
              ),
              PosIconButton(icon: Icons.add, onPressed: tap, style: PosIconButtonStyle.filled, tooltip: 'Filled'),
              PosIconButton(
                icon: Icons.shopping_cart_outlined,
                onPressed: tap,
                badge: '4',
                style: PosIconButtonStyle.outlined,
              ),
              FloatingActionButton(onPressed: tap, child: const Icon(Icons.add)),
              FloatingActionButton.extended(onPressed: tap, icon: const Icon(Icons.add), label: const Text('New sale')),
            ],
          ),
        ),
        DemoSection(
          title: 'Segmented & toggle',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'day', label: Text('Today')),
                    ButtonSegment(value: 'week', label: Text('Week')),
                    ButtonSegment(value: 'month', label: Text('Month')),
                    ButtonSegment(value: 'year', label: Text('Year')),
                  ],
                  selected: _seg,
                  onSelectionChanged: (s) => setState(() => _seg = s),
                ),
              ),
              const SizedBox(height: 16),
              ToggleButtons(
                isSelected: [for (var i = 0; i < 3; i++) i == _toggle],
                onPressed: (i) => setState(() => _toggle = i),
                children: const [
                  Icon(Icons.grid_view_rounded),
                  Icon(Icons.view_list_rounded),
                  Icon(Icons.view_module_outlined),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
