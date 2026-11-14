import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../widgets/page_scaffold.dart';
import '../../widgets/theme_switcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _print = true, _tips = false, _offline = true, _sound = true;
  String? _currency = 'usd';
  String? _printer = 'epson';

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Settings',
      subtitle: 'Store, register, hardware and appearance.',
      maxWidth: 960,
      children: [
        const DemoSection(
          title: 'Appearance',
          description: 'Applies to every terminal in this store.',
          child: ThemePickerPanel(),
        ),
        DemoSection(
          title: 'Store',
          child: PosGrid(
            spacing: 12,
            runSpacing: 14,
            children: [
              const PosGridItem(
                medium: 8,
                expanded: 6,
                child: PosTextField(label: 'Store name', initialValue: 'Nova Café — Downtown'),
              ),
              const PosGridItem(
                medium: 4,
                expanded: 3,
                child: PosTextField(label: 'Tax rate', initialValue: '8.5', prefixText: '% '),
              ),
              PosGridItem(
                medium: 4,
                expanded: 3,
                child: PosDropdown<String>(
                  label: 'Currency',
                  value: _currency,
                  onChanged: (v) => setState(() => _currency = v),
                  options: const [
                    PosOption('usd', 'USD \$'),
                    PosOption('eur', 'EUR €'),
                    PosOption('gbp', 'GBP £'),
                    PosOption('pkr', 'PKR ₨'),
                  ],
                ),
              ),
              const PosGridItem(
                medium: 8,
                expanded: 12,
                child: PosTextField(
                  label: 'Receipt footer',
                  initialValue: 'Thank you! Please come again.',
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Register',
          child: Column(
            children: [
              SwitchListTile(
                value: _print,
                onChanged: (v) => setState(() => _print = v),
                title: const Text('Auto-print receipts'),
                subtitle: const Text('Print after every completed sale'),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              SwitchListTile(
                value: _tips,
                onChanged: (v) => setState(() => _tips = v),
                title: const Text('Tipping'),
                subtitle: const Text('Show tip screen on card payments'),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              SwitchListTile(
                value: _offline,
                onChanged: (v) => setState(() => _offline = v),
                title: const Text('Offline mode'),
                subtitle: const Text('Queue sales when the network drops'),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              SwitchListTile(
                value: _sound,
                onChanged: (v) => setState(() => _sound = v),
                title: const Text('Sounds'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Hardware',
          child: Column(
            children: [
              PosDropdown<String>(
                label: 'Receipt printer',
                value: _printer,
                prefixIcon: Icons.print_outlined,
                onChanged: (v) => setState(() => _printer = v),
                options: const [
                  PosOption('epson', 'Epson TM-m30III (LAN)'),
                  PosOption('star', 'Star mC-Print3 (USB)'),
                  PosOption('none', 'None'),
                ],
              ),
              const SizedBox(height: 12),
              for (final (icon, name, ok) in [
                (Icons.credit_card, 'Card reader · Stripe S700', true),
                (Icons.qr_code_scanner, 'Barcode scanner · Zebra DS2208', true),
                (Icons.point_of_sale, 'Cash drawer', false),
                (Icons.scale_outlined, 'Scale', false),
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon),
                  title: Text(name),
                  trailing: PosStatusPill(
                    label: ok ? 'Connected' : 'Not found',
                    tone: ok ? PosToneKind.success : PosToneKind.neutral,
                    dot: true,
                  ),
                ),
            ],
          ),
        ),
        DemoSection(
          title: 'Danger zone',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PosButton.outline(label: 'Sign out of register', icon: Icons.logout, onPressed: () {}),
              PosButton.danger(
                label: 'Reset device',
                icon: Icons.restart_alt,
                onPressed: () => showPosConfirm(
                  context,
                  title: 'Reset this device?',
                  message: 'All local data and pairing will be erased.',
                  destructive: true,
                  confirmLabel: 'Reset',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
