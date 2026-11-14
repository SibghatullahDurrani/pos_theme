import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class OverlaysPage extends StatelessWidget {
  const OverlaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Dialogs & popups',
      subtitle:
          'Dialogs become bottom sheets on phones automatically. Toasts stack top-right on desktop, bottom on mobile.',
      children: [
        DemoSection(
          title: 'Dialogs',
          child: DemoWrap(
            children: [
              PosButton.outline(
                label: 'Info dialog',
                icon: Icons.info_outline,
                onPressed: () => showPosAdaptiveDialog<void>(
                  context,
                  builder: (ctx) => PosDialog(
                    title: 'End of day report ready',
                    message: 'Your Z-report for Register 2 has been generated and emailed to the store manager.',
                    icon: Icons.summarize_outlined,
                    tone: PosToneKind.info,
                    actions: [PosButton(label: 'Got it', onPressed: () => Navigator.pop(ctx))],
                  ),
                ),
              ),
              PosButton.outline(
                label: 'Confirm',
                icon: Icons.help_outline,
                onPressed: () async {
                  final ok = await showPosConfirm(
                    context,
                    title: 'Park this sale?',
                    message: 'You can resume it later from Orders → Parked.',
                    confirmLabel: 'Park sale',
                  );
                  if (context.mounted) {
                    PosToast.show(
                      context,
                      message: ok ? 'Sale parked' : 'Cancelled',
                      tone: ok ? PosToneKind.success : PosToneKind.neutral,
                    );
                  }
                },
              ),
              PosButton.danger(
                label: 'Destructive',
                icon: Icons.delete_outline,
                onPressed: () async {
                  final ok = await showPosConfirm(
                    context,
                    title: 'Void order #1048?',
                    message:
                        'This cannot be undone. The void will appear on the shift report and requires manager approval.',
                    confirmLabel: 'Void order',
                    destructive: true,
                  );
                  if (ok && context.mounted) PosToast.error(context, 'Order #1048 voided', title: 'Voided');
                },
              ),
              PosButton.outline(label: 'Form dialog', icon: Icons.edit_note, onPressed: () => _formDialog(context)),
              PosButton.outline(label: 'Discount', icon: Icons.percent, onPressed: () => _discountDialog(context)),
              PosButton.outline(
                label: 'Customer picker',
                icon: Icons.person_search_outlined,
                onPressed: () => _customerPicker(context),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Sheets',
          child: DemoWrap(
            children: [
              PosButton.outline(
                label: 'Modifier sheet',
                icon: Icons.tune,
                onPressed: () => showPosSheet<void>(
                  context,
                  builder: (ctx) => PosModifierPicker(
                    itemName: 'Flat White',
                    basePrice: 4.20,
                    groups: coffeeModifiers,
                    onAdd: (r) {
                      Navigator.pop(ctx);
                      PosToast.success(context, '${r.quantity} × Flat White added · ${posMoney(r.total)}');
                    },
                  ),
                ),
              ),
              PosButton.outline(
                label: 'Action sheet',
                icon: Icons.more_horiz,
                onPressed: () => showPosSheet<void>(
                  context,
                  title: 'Order #1048',
                  builder: (ctx) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (i, l) in [
                        (Icons.print_outlined, 'Reprint receipt'),
                        (Icons.email_outlined, 'Email receipt'),
                        (Icons.undo, 'Refund'),
                        (Icons.call_split, 'Split bill'),
                      ])
                        ListTile(leading: Icon(i), title: Text(l), onTap: () => Navigator.pop(ctx)),
                      ListTile(
                        leading: Icon(Icons.block, color: context.colors.error),
                        title: Text('Void order', style: TextStyle(color: context.colors.error)),
                        onTap: () => Navigator.pop(ctx),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Toasts & snackbars',
          child: DemoWrap(
            children: [
              PosButton.outline(
                label: 'Success',
                onPressed: () => PosToast.success(context, 'Payment of \$48.20 approved', title: 'Payment complete'),
              ),
              PosButton.outline(
                label: 'Error',
                onPressed: () => PosToast.error(context, 'Card reader disconnected', title: 'Reader offline'),
              ),
              PosButton.outline(
                label: 'Warning',
                onPressed: () => PosToast.warning(context, 'Cold Brew has 3 units left'),
              ),
              PosButton.outline(label: 'Info', onPressed: () => PosToast.info(context, 'New online order #1049')),
              PosButton.outline(
                label: 'With action',
                onPressed: () =>
                    PosToast.show(context, message: 'Item removed from cart', actionLabel: 'Undo', onAction: () {}),
              ),
              PosButton.outline(
                label: 'Snackbar',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Receipt sent to printer'),
                    action: SnackBarAction(label: 'Reprint', onPressed: () {}),
                  ),
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Menus, popovers & tooltips',
          child: DemoWrap(
            children: [
              PopupMenuButton<String>(
                tooltip: 'Popup menu',
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'a',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'b',
                    child: ListTile(
                      leading: Icon(Icons.copy_outlined),
                      title: Text('Duplicate'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'c',
                    child: ListTile(
                      leading: Icon(Icons.archive_outlined),
                      title: Text('Archive'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: const IgnorePointer(
                  child: PosButton.outline(label: 'Popup menu', trailingIcon: Icons.expand_more, onPressed: _noop),
                ),
              ),
              MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.print_outlined),
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyP, control: true),
                    onPressed: () {},
                    child: const Text('Print'),
                  ),
                  SubmenuButton(
                    menuChildren: [
                      MenuItemButton(onPressed: () {}, child: const Text('PDF')),
                      MenuItemButton(onPressed: () {}, child: const Text('CSV')),
                      MenuItemButton(onPressed: () {}, child: const Text('Excel')),
                    ],
                    leadingIcon: const Icon(Icons.download_outlined),
                    child: const Text('Export as'),
                  ),
                  const Divider(),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                    child: const Text('Preferences'),
                  ),
                ],
                builder: (context, c, _) => PosButton.outline(
                  label: 'Menu with submenu',
                  trailingIcon: Icons.expand_more,
                  onPressed: () => c.isOpen ? c.close() : c.open(),
                ),
              ),
              const Tooltip(
                message: 'Tooltips use the inverse surface',
                child: Chip(label: Text('Hover me'), avatar: Icon(Icons.info_outline, size: 18)),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Inline dialog previews',
          description: 'Static renders so you can compare layouts without opening them.',
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _Preview(
                child: PosDialog(
                  title: 'Delete product?',
                  message: '“Almond Danish” will be removed from all menus.',
                  icon: Icons.delete_outline,
                  tone: PosToneKind.danger,
                  showClose: false,
                  actions: [
                    PosButton.outline(label: 'Cancel', onPressed: () {}),
                    PosButton.danger(label: 'Delete', onPressed: () {}),
                  ],
                ),
              ),
              _Preview(
                child: PosDialog(
                  title: 'Sync complete',
                  message: '1,284 products and 32 customers synced from the cloud.',
                  icon: Icons.cloud_done_outlined,
                  tone: PosToneKind.success,
                  showClose: false,
                  actions: [PosButton(label: 'Done', onPressed: () {})],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void _formDialog(BuildContext context) {
    showPosAdaptiveDialog<void>(
      context,
      fullscreenOnCompact: true,
      builder: (ctx) => PosDialog(
        title: 'Add product',
        maxWidth: 560,
        content: Column(
          children: [
            const PosTextField(label: 'Name', hint: 'Product name', required: true, autofocus: true),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                  child: PosTextField(label: 'Price', prefixText: '\$ ', hint: '0.00'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: PosTextField(label: 'SKU', hint: 'Auto'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PosDropdown<String>(
              label: 'Category',
              value: 'Coffee',
              onChanged: (_) {},
              options: [for (final c in productCategories.skip(1)) PosOption(c, c)],
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Track inventory'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          PosButton.outline(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
          PosButton(
            label: 'Save product',
            icon: Icons.check,
            onPressed: () {
              Navigator.pop(ctx);
              PosToast.success(context, 'Product saved');
            },
          ),
        ],
      ),
    );
  }

  static void _discountDialog(BuildContext context) {
    showPosAdaptiveDialog<void>(context, builder: (ctx) => const _DiscountDialog());
  }

  static void _customerPicker(BuildContext context) {
    showPosAdaptiveDialog<void>(
      context,
      builder: (ctx) => PosDialog(
        title: 'Attach customer',
        maxWidth: 520,
        content: Column(
          children: [
            const PosSearchField(hint: 'Name, phone or email'),
            const SizedBox(height: 12),
            for (final c in customers.take(4))
              PosCustomerTile(
                name: c.name,
                phone: c.phone,
                points: c.points,
                tier: c.tier,
                onTap: () => Navigator.pop(ctx),
              ),
          ],
        ),
        actions: [
          PosButton.outline(label: 'New customer', icon: Icons.person_add_alt, onPressed: () => Navigator.pop(ctx)),
        ],
      ),
    );
  }
}

void _noop() {}

class _Preview extends StatelessWidget {
  const _Preview({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: 420,
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerHigh,
      borderRadius: context.shape.xl,
      border: Border.all(color: context.pos.border),
      boxShadow: context.shape.shadowsMd,
    ),
    child: child,
  );
}

class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog();
  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  String _type = 'pct';
  String _value = '10';

  @override
  Widget build(BuildContext context) {
    return PosDialog(
      title: 'Apply discount',
      maxWidth: 420,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'pct', label: Text('Percent %')),
              ButtonSegment(value: 'amt', label: Text('Amount \$')),
            ],
            selected: {_type},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: context.pos.surfaceMuted, borderRadius: context.shape.md),
            child: Text(
              _type == 'pct' ? '$_value%' : '\$$_value',
              textAlign: TextAlign.end,
              style: posTabular(context.text.headlineMedium!),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final v in ['5', '10', '15', '20', '25'])
                ChoiceChip(
                  label: Text(_type == 'pct' ? '$v%' : '\$$v'),
                  selected: _value == v,
                  onSelected: (_) => setState(() => _value = v),
                ),
            ],
          ),
          const SizedBox(height: 12),
          PosNumpad(
            keyHeight: 52,
            onKey: (k) => setState(() => _value = _value == '0' ? k : _value + k),
            onBackspace: () =>
                setState(() => _value = _value.length <= 1 ? '0' : _value.substring(0, _value.length - 1)),
          ),
          const SizedBox(height: 12),
          const PosTextField(label: 'Reason', hint: 'e.g. Staff, loyalty, damaged'),
        ],
      ),
      actions: [
        PosButton.outline(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        PosButton(label: 'Apply', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
