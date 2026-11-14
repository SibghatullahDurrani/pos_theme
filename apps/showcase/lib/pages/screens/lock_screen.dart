import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

/// Staff PIN lock. Split layout on wide screens, single column on phones.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String? _error;
  int _user = 0;
  static const _staff = ['Jordan Rivera', 'Priya Shah', 'Marco Bianchi', 'Lena Vogel'];

  void _check(String pin) {
    if (pin == '1234') {
      Navigator.pop(context);
      PosToast.success(context, 'Welcome back, ${_staff[_user].split(' ').first}');
    } else {
      setState(() => _error = 'Incorrect PIN (hint: 1234)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = context.pos;
    final w = context.window;
    final pad = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 96,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _staff.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => setState(() {
                _user = i;
                _error = null;
              }),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: PosMotion.fast,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: i == _user ? context.colors.primary : Colors.transparent, width: 2.5),
                    ),
                    child: PosAvatar(name: _staff[i], size: 52),
                  ),
                  const SizedBox(height: 4),
                  Text(_staff[i].split(' ').first, style: context.text.labelMedium),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PosPinPad(title: 'Hi ${_staff[_user].split(' ').first}, enter your PIN', error: _error, onCompleted: _check),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );

    final brand = Container(
      color: pos.sidebarBg,
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: pos.sidebarActiveBg, borderRadius: context.shape.lg),
            child: Icon(Icons.storefront_rounded, color: pos.sidebarActiveFg, size: 30),
          ),
          const Spacer(),
          Text('Nova POS', style: context.text.displayMedium!.copyWith(color: pos.sidebarFg)),
          const SizedBox(height: 8),
          Text('Store #12 · Register 2', style: context.text.titleMedium!.copyWith(color: pos.sidebarMuted)),
          const SizedBox(height: 24),
          Text('12:48', style: posTabular(context.text.displayLarge!.copyWith(color: pos.sidebarFg))),
          Text('Saturday, 14 November', style: context.text.bodyLarge!.copyWith(color: pos.sidebarMuted)),
        ],
      ),
    );

    return Scaffold(
      body: w.atLeastExpanded
          ? Row(
              children: [
                Expanded(child: brand),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: pad),
                  ),
                ),
              ],
            )
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: pad),
              ),
            ),
    );
  }
}
