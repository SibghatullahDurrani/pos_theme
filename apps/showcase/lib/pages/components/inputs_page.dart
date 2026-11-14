import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../widgets/page_scaffold.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});
  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  String? _store = 'downtown';
  String? _tax = 'std';
  Set<String> _single = {'card'};
  Set<String> _tags = {'vegan', 'gf'};
  DateTime? _date = DateTime.now();
  bool _sw1 = true, _sw2 = false;
  bool? _cb1 = true, _cb2 = false, _cb3;
  String _radio = 'dine';
  double _slider = 15;
  RangeValues _range = const RangeValues(10, 60);
  int _qty = 2;
  final Set<String> _chips = {'Coffee'};

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Inputs & selects',
      subtitle: 'Text fields, dropdowns, searchable & multi selects, date/time pickers, selection controls, steppers.',
      children: [
        DemoSection(
          title: 'Text fields',
          child: PosGrid(
            children: [
              const PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosTextField(label: 'Product name', hint: 'e.g. Flat white', required: true),
              ),
              const PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosTextField(
                  label: 'Price',
                  hint: '0.00',
                  prefixText: '\$ ',
                  keyboardType: TextInputType.number,
                  helper: 'Tax inclusive',
                ),
              ),
              const PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosTextField(
                  label: 'Email',
                  prefixIcon: Icons.mail_outline,
                  initialValue: 'ava@',
                  error: 'Enter a valid email',
                ),
              ),
              const PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosTextField(label: 'Password', obscure: true, initialValue: 'secret123'),
              ),
              const PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosTextField(
                  label: 'Search',
                  prefixIcon: Icons.search,
                  clearable: true,
                  initialValue: 'Croissant',
                ),
              ),
              const PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosTextField(label: 'Disabled', initialValue: 'Register 2', enabled: false),
              ),
              const PosGridItem(
                medium: 8,
                expanded: 8,
                child: PosTextField(label: 'Notes', hint: 'Order notes for the kitchen…', maxLines: 3),
              ),
              PosGridItem(
                medium: 8,
                expanded: 4,
                child: PosBarcodeField(label: 'Barcode', onScan: () => PosToast.info(context, 'Camera scanner opened')),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Dropdowns & selects',
          child: PosGrid(
            children: [
              PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosDropdown<String>(
                  label: 'Store',
                  value: _store,
                  prefixIcon: Icons.store_outlined,
                  onChanged: (v) => setState(() => _store = v),
                  options: const [
                    PosOption('downtown', 'Downtown', icon: Icons.location_city),
                    PosOption('airport', 'Airport T2', icon: Icons.flight),
                    PosOption('mall', 'Westfield Mall', icon: Icons.local_mall_outlined),
                    PosOption('closed', 'Harbour (closed)', enabled: false),
                  ],
                ),
              ),
              PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosDropdown<String>(
                  label: 'Tax rate (searchable)',
                  value: _tax,
                  searchable: true,
                  onChanged: (v) => setState(() => _tax = v),
                  options: const [
                    PosOption('std', 'Standard 8.5%'),
                    PosOption('red', 'Reduced 5%'),
                    PosOption('zero', 'Zero rated'),
                    PosOption('exempt', 'Exempt'),
                  ],
                ),
              ),
              PosGridItem(
                medium: 4,
                expanded: 4,
                child: PosSelect<String>(
                  label: 'Payment (search + single)',
                  selected: _single,
                  onChanged: (s) => setState(() => _single = s),
                  options: const [
                    PosOption('cash', 'Cash', icon: Icons.payments_outlined),
                    PosOption('card', 'Card', icon: Icons.credit_card),
                    PosOption('wallet', 'Wallet', icon: Icons.qr_code_2),
                    PosOption('gift', 'Gift card', icon: Icons.card_giftcard),
                  ],
                ),
              ),
              PosGridItem(
                medium: 8,
                expanded: 6,
                child: PosSelect<String>(
                  label: 'Dietary tags (multi select)',
                  multiple: true,
                  selected: _tags,
                  onChanged: (s) => setState(() => _tags = s),
                  options: const [
                    PosOption('vegan', 'Vegan', subtitle: 'No animal products'),
                    PosOption('veg', 'Vegetarian'),
                    PosOption('gf', 'Gluten free'),
                    PosOption('df', 'Dairy free'),
                    PosOption('nuts', 'Contains nuts'),
                    PosOption('spicy', 'Spicy'),
                  ],
                ),
              ),
              PosGridItem(
                medium: 4,
                expanded: 3,
                child: PosDateField(label: 'Date', value: _date, onChanged: (d) => setState(() => _date = d)),
              ),
              PosGridItem(
                medium: 4,
                expanded: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PosFieldLabel('Time & range'),
                    Row(
                      children: [
                        Expanded(
                          child: PosButton.outline(
                            label: 'Time',
                            icon: Icons.schedule,
                            onPressed: () => showTimePicker(context: context, initialTime: TimeOfDay.now()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PosButton.outline(
                            label: 'Range',
                            icon: Icons.date_range,
                            onPressed: () => showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Selection controls',
          child: PosGrid(
            children: [
              PosGridItem(
                medium: 4,
                expanded: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DemoLabel('Switches'),
                    SwitchListTile(
                      value: _sw1,
                      onChanged: (v) => setState(() => _sw1 = v),
                      title: const Text('Print receipt automatically'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      value: _sw2,
                      onChanged: (v) => setState(() => _sw2 = v),
                      title: const Text('Ask for tip'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SwitchListTile(
                      value: true,
                      onChanged: null,
                      title: Text('Disabled'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              PosGridItem(
                medium: 4,
                expanded: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DemoLabel('Checkboxes'),
                    CheckboxListTile(
                      value: _cb1,
                      onChanged: (v) => setState(() => _cb1 = v),
                      title: const Text('Include tax'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _cb2,
                      onChanged: (v) => setState(() => _cb2 = v),
                      title: const Text('Gift wrap'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      tristate: true,
                      value: _cb3,
                      onChanged: (v) => setState(() => _cb3 = v),
                      title: const Text('Partial (tristate)'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              PosGridItem(
                medium: 8,
                expanded: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DemoLabel('Radio'),
                    RadioGroup<String>(
                      groupValue: _radio,
                      onChanged: (v) => setState(() => _radio = v!),
                      child: const Column(
                        children: [
                          RadioListTile(value: 'dine', title: Text('Dine-in'), contentPadding: EdgeInsets.zero),
                          RadioListTile(value: 'take', title: Text('Takeaway'), contentPadding: EdgeInsets.zero),
                          RadioListTile(value: 'del', title: Text('Delivery'), contentPadding: EdgeInsets.zero),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Sliders, chips & quantity',
          child: PosGrid(
            children: [
              PosGridItem(
                medium: 4,
                expanded: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DemoLabel('Tip ${_slider.round()}%'),
                    Slider(
                      value: _slider,
                      max: 30,
                      divisions: 6,
                      label: '${_slider.round()}%',
                      onChanged: (v) => setState(() => _slider = v),
                    ),
                    DemoLabel('Price range \$${_range.start.round()} – \$${_range.end.round()}'),
                    RangeSlider(values: _range, max: 100, onChanged: (v) => setState(() => _range = v)),
                  ],
                ),
              ),
              PosGridItem(
                medium: 4,
                expanded: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DemoLabel('Filter chips'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in ['Coffee', 'Bakery', 'Food', 'Drinks'])
                          FilterChip(
                            label: Text(c),
                            selected: _chips.contains(c),
                            onSelected: (v) => setState(() => v ? _chips.add(c) : _chips.remove(c)),
                          ),
                        const ActionChip(avatar: Icon(Icons.add, size: 18), label: Text('Add'), onPressed: null),
                        InputChip(label: const Text('Removable'), onDeleted: () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const DemoLabel('Quantity stepper'),
                    Row(
                      children: [
                        PosQuantityStepper(value: _qty, min: 1, onChanged: (v) => setState(() => _qty = v)),
                        const SizedBox(width: 16),
                        PosQuantityStepper(
                          value: _qty,
                          min: 1,
                          compact: true,
                          onChanged: (v) => setState(() => _qty = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Numpad & PIN',
          description: 'Large touch keys for amounts and staff login.',
          child: Wrap(
            spacing: 32,
            runSpacing: 24,
            children: [
              SizedBox(
                width: 280,
                child: PosNumpad(onKey: (k) {}, onBackspace: () {}, extraKey: '00'),
              ),
              PosPinPad(onCompleted: (p) => PosToast.success(context, 'PIN entered: $p')),
            ],
          ),
        ),
      ],
    );
  }
}
