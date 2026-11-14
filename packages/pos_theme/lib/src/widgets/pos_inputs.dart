import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/pos_tokens.dart';
import '../utils/pos_format.dart';

/// Label rendered above a field (clearer than floating labels on POS screens).
class PosFieldLabel extends StatelessWidget {
  const PosFieldLabel(this.label, {super.key, this.required = false, this.trailing});
  final String label;
  final bool required;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Flexible(
            child: Text(label, style: context.text.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (required) Text(' *', style: context.text.labelLarge!.copyWith(color: context.colors.error)),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}

/// Text input with label above, helper/error text, prefix/suffix and clear.
class PosTextField extends StatefulWidget {
  const PosTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.obscure = false,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.clearable = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
    this.autofocus = false,
    this.onTap,
    this.prefixText,
  });

  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final bool clearable;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final VoidCallback? onTap;
  final String? prefixText;

  @override
  State<PosTextField> createState() => _PosTextFieldState();
}

class _PosTextFieldState extends State<PosTextField> {
  late TextEditingController _c = widget.controller ?? TextEditingController(text: widget.initialValue);
  late bool _obscured = widget.obscure;

  @override
  void didUpdateWidget(covariant PosTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _c) _c = widget.controller!;
  }

  @override
  void dispose() {
    if (widget.controller == null) _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? suffix = widget.suffix;
    if (widget.obscure) {
      suffix = IconButton(
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
        tooltip: _obscured ? 'Show' : 'Hide',
      );
    } else if (widget.clearable) {
      suffix = ListenableBuilder(
        listenable: _c,
        builder: (context, _) => _c.text.isEmpty
            ? (widget.suffix ?? const SizedBox.shrink())
            : IconButton(
                onPressed: () {
                  _c.clear();
                  widget.onChanged?.call('');
                },
                icon: const Icon(Icons.cancel_rounded, size: 18),
                tooltip: 'Clear',
              ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) PosFieldLabel(widget.label!, required: widget.required),
        TextField(
          controller: _c,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          obscureText: _obscured,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          onTap: widget.onTap,
          style: context.text.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.error == null ? widget.helper : null,
            errorText: widget.error,
            prefixText: widget.prefixText,
            prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Compact search input with leading icon and optional keyboard hint.
class PosSearchField extends StatelessWidget {
  const PosSearchField({
    super.key,
    this.hint = 'Search…',
    this.onChanged,
    this.controller,
    this.shortcutHint,
    this.onSubmitted,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;

  /// e.g. "⌘K" – shown as a keycap on the right.
  final String? shortcutHint;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      hintText: hint,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      leading: Icon(Icons.search_rounded, size: 20, color: context.pos.textMuted),
      trailing: [
        if (shortcutHint != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(color: context.pos.border),
              borderRadius: context.shape.xs,
            ),
            child: Text(shortcutHint!, style: context.text.labelSmall!.copyWith(color: context.pos.textMuted)),
          ),
      ],
    );
  }
}

/// Barcode / SKU entry with scan affordance.
class PosBarcodeField extends StatelessWidget {
  const PosBarcodeField({super.key, this.onSubmitted, this.onScan, this.label});
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onScan;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return PosTextField(
      label: label,
      hint: 'Scan or type barcode / SKU',
      prefixIcon: Icons.qr_code_scanner_rounded,
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      suffix: Padding(
        padding: const EdgeInsetsDirectional.only(end: 6),
        child: IconButton.filledTonal(
          onPressed: onScan,
          icon: const Icon(Icons.photo_camera_outlined, size: 20),
          tooltip: 'Scan with camera',
        ),
      ),
    );
  }
}

/// Option for dropdowns and selects.
@immutable
class PosOption<T> {
  const PosOption(this.value, this.label, {this.icon, this.subtitle, this.enabled = true});
  final T value;
  final String label;
  final IconData? icon;
  final String? subtitle;
  final bool enabled;
}

/// Single-select dropdown built on Material 3 [DropdownMenu].
class PosDropdown<T> extends StatelessWidget {
  const PosDropdown({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
    this.enabled = true,
    this.error,
    this.searchable = false,
    this.required = false,
  });

  final List<PosOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final bool enabled;
  final String? error;
  final bool searchable;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) PosFieldLabel(label!, required: required),
            DropdownMenu<T>(
              width: c.maxWidth.isFinite ? c.maxWidth : null,
              initialSelection: value,
              enabled: enabled,
              hintText: hint,
              errorText: error,
              enableFilter: searchable,
              enableSearch: searchable,
              requestFocusOnTap: searchable,
              menuHeight: 320,
              leadingIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
              trailingIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up_rounded),
              onSelected: onChanged,
              dropdownMenuEntries: [
                for (final o in options)
                  DropdownMenuEntry<T>(
                    value: o.value,
                    label: o.label,
                    enabled: o.enabled,
                    leadingIcon: o.icon == null ? null : Icon(o.icon, size: 20),
                    trailingIcon: o.value == value
                        ? Icon(Icons.check_rounded, size: 18, color: context.colors.primary)
                        : null,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Searchable select that opens a filterable list in an anchored overlay.
/// Supports single and multi selection (chips).
class PosSelect<T> extends StatefulWidget {
  const PosSelect({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.label,
    this.hint = 'Select…',
    this.multiple = false,
    this.searchHint = 'Search…',
    this.prefixIcon,
  });

  final List<PosOption<T>> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final String? label;
  final String hint;
  final bool multiple;
  final String searchHint;
  final IconData? prefixIcon;

  @override
  State<PosSelect<T>> createState() => _PosSelectState<T>();
}

class _PosSelectState<T> extends State<PosSelect<T>> {
  final _menu = MenuController();
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggle(T v) {
    final next = {...widget.selected};
    if (widget.multiple) {
      next.contains(v) ? next.remove(v) : next.add(v);
    } else {
      next
        ..clear()
        ..add(v);
      _menu.close();
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final selectedOpts = widget.options.where((o) => widget.selected.contains(o.value)).toList();
    final filtered = widget.options.where((o) => o.label.toLowerCase().contains(_query.toLowerCase())).toList();
    final input = context.theme.inputDecorationTheme;

    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.isFinite ? c.maxWidth : 320.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) PosFieldLabel(widget.label!),
            MenuAnchor(
              controller: _menu,
              crossAxisUnconstrained: false,
              alignmentOffset: const Offset(0, 4),
              onClose: () => setState(() {
                _query = '';
                _search.clear();
              }),
              style: MenuStyle(
                minimumSize: WidgetStatePropertyAll(Size(width, 0)),
                maximumSize: WidgetStatePropertyAll(Size(width, 380)),
              ),
              menuChildren: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                  child: SizedBox(
                    width: width - 16,
                    child: TextField(
                      controller: _search,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        isDense: true,
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      ),
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No matches', style: context.text.bodyMedium!.copyWith(color: context.pos.textMuted)),
                  ),
                for (final o in filtered)
                  MenuItemButton(
                    closeOnActivate: !widget.multiple,
                    onPressed: o.enabled ? () => _toggle(o.value) : null,
                    leadingIcon: widget.multiple
                        ? IgnorePointer(
                            child: Checkbox(value: widget.selected.contains(o.value), onChanged: (_) {}),
                          )
                        : (o.icon == null ? null : Icon(o.icon, size: 20)),
                    trailingIcon: !widget.multiple && widget.selected.contains(o.value)
                        ? Icon(Icons.check_rounded, size: 18, color: context.colors.primary)
                        : null,
                    child: SizedBox(
                      width: width - 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(o.label, overflow: TextOverflow.ellipsis),
                          if (o.subtitle != null) Text(o.subtitle!, style: context.text.bodySmall),
                        ],
                      ),
                    ),
                  ),
              ],
              builder: (context, controller, _) => InkWell(
                borderRadius: context.shape.md,
                onTap: () => controller.isOpen ? controller.close() : controller.open(),
                child: InputDecorator(
                  isFocused: controller.isOpen,
                  isEmpty: selectedOpts.isEmpty,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon, size: 20),
                    suffixIcon: Icon(
                      controller.isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    ),
                    contentPadding: widget.multiple && selectedOpts.isNotEmpty
                        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 9)
                        : input.contentPadding,
                  ),
                  child: selectedOpts.isEmpty
                      ? null
                      : widget.multiple
                      ? Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final o in selectedOpts)
                              InputChip(
                                label: Text(o.label),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onDeleted: () => _toggle(o.value),
                              ),
                          ],
                        )
                      : Text(selectedOpts.first.label, style: context.text.bodyLarge),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Date field that opens the themed date picker.
class PosDateField extends StatelessWidget {
  const PosDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.firstDate,
    this.lastDate,
  });
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  String _fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return PosTextField(
      key: ValueKey(value),
      label: label,
      initialValue: value == null ? '' : _fmt(value!),
      hint: 'YYYY-MM-DD',
      readOnly: true,
      prefixIcon: Icons.calendar_today_outlined,
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        );
        if (d != null) onChanged(d);
      },
    );
  }
}

/// −  qty  +  stepper used in carts.
class PosQuantityStepper extends StatelessWidget {
  const PosQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 40.0;
    final r = context.shape.buttonRadius > 20 ? 999.0 : context.shape.radiusSm;
    Widget btn(IconData icon, VoidCallback? onTap, String tip) => SizedBox.square(
      dimension: size,
      child: IconButton(
        onPressed: onTap,
        tooltip: tip,
        padding: EdgeInsets.zero,
        iconSize: compact ? 16 : 20,
        style: IconButton.styleFrom(
          minimumSize: Size.square(size),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        ),
        icon: Icon(icon),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.pos.borderStrong),
        borderRadius: BorderRadius.circular(r),
        color: context.colors.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, value > min ? () => onChanged(value - 1) : null, 'Decrease'),
          SizedBox(
            width: compact ? 28 : 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: posTabular((compact ? context.text.labelLarge : context.text.titleMedium)!),
            ),
          ),
          btn(Icons.add_rounded, value < max ? () => onChanged(value + 1) : null, 'Increase'),
        ],
      ),
    );
  }
}

/// Large-key numeric keypad for amounts, quantities and PINs.
class PosNumpad extends StatelessWidget {
  const PosNumpad({
    super.key,
    required this.onKey,
    this.onBackspace,
    this.onClear,
    this.showDecimal = true,
    this.keyHeight = 64,
    this.extraKey,
  });

  final ValueChanged<String> onKey;
  final VoidCallback? onBackspace;
  final VoidCallback? onClear;
  final bool showDecimal;
  final double keyHeight;

  /// Replaces the bottom-left key (e.g. "00" or a custom action).
  final String? extraKey;

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', extraKey ?? (showDecimal ? '.' : 'C'), '0', '⌫'];
    return LayoutBuilder(
      builder: (context, c) {
        // Keep keys at [keyHeight] whatever the available width.
        final w = ((c.maxWidth.isFinite ? c.maxWidth : 300) - 16) / 3;
        return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: w / keyHeight,
          padding: EdgeInsets.zero,
          children: [
            for (final k in keys)
              _NumKey(
                label: k,
                muted: k == '⌫' || k == 'C',
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (k == '⌫') {
                    onBackspace?.call();
                  } else if (k == 'C') {
                    onClear?.call();
                  } else {
                    onKey(k);
                  }
                },
                onLongPress: k == '⌫' ? onClear : null,
              ),
          ],
        );
      },
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.label, required this.onTap, this.muted = false, this.onLongPress});
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final shape = context.shape;
    return Material(
      color: muted ? context.pos.surfaceMuted : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape.buttonRadius > 20 ? shape.radiusLg : shape.radiusMd),
        side: BorderSide(color: context.pos.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Center(
          child: label == '⌫'
              ? Icon(Icons.backspace_outlined, color: cs.onSurface)
              : Text(label, style: posTabular(context.text.headlineSmall!.copyWith(fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }
}

/// PIN entry: dots + numpad. Calls [onCompleted] when [length] digits entered.
class PosPinPad extends StatefulWidget {
  const PosPinPad({super.key, required this.onCompleted, this.length = 4, this.error, this.title = 'Enter PIN'});
  final ValueChanged<String> onCompleted;
  final int length;
  final String? error;
  final String title;

  @override
  State<PosPinPad> createState() => _PosPinPadState();
}

class _PosPinPadState extends State<PosPinPad> {
  String _pin = '';

  @override
  void didUpdateWidget(covariant PosPinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.error != null && oldWidget.error != widget.error) _pin = '';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final err = widget.error != null;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: context.text.titleLarge),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.length; i++)
                AnimatedContainer(
                  duration: PosMotion.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: context.shape.radiusMd <= 2 ? BoxShape.rectangle : BoxShape.circle,
                    color: i < _pin.length ? (err ? cs.error : cs.primary) : Colors.transparent,
                    border: Border.all(color: err ? cs.error : context.pos.borderStrong, width: 2),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 28,
            child: err
                ? Center(
                    child: Text(
                      widget.error!,
                      style: context.text.bodySmall!.copyWith(color: cs.error, fontWeight: FontWeight.w700),
                    ),
                  )
                : null,
          ),
          PosNumpad(
            showDecimal: false,
            onKey: (k) {
              if (_pin.length >= widget.length) return;
              setState(() => _pin += k);
              if (_pin.length == widget.length) widget.onCompleted(_pin);
            },
            onBackspace: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
            onClear: () => setState(() => _pin = ''),
          ),
        ],
      ),
    );
  }
}
