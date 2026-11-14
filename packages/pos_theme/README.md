# pos_theme

The shared design system for the POS suite: **5 themes × light/dark**, design tokens, responsive
layout primitives and a component library (generic + retail + restaurant).

Everything is exported from one import:

```dart
import 'package:pos_theme/pos_theme.dart';
```

Requires Flutter ≥ 3.41 (Dart ≥ 3.11). Only extra dependency: `google_fonts`.

---

## Contents

1. [Install](#1-install)
2. [App setup](#2-app-setup)
3. [Rules for using this package](#3-rules-for-using-this-package-read-this-first)
4. [Themes](#4-themes)
5. [Tokens](#5-tokens)
6. [Responsive layout](#6-responsive-layout)
7. [Components](#7-components) (buttons, inputs, data table, navigation, overlays, feedback, charts)
8. [POS components](#8-pos-components) (retail and restaurant)
9. [Utilities](#9-utilities)
10. [Custom themes](#10-creating-a-custom-theme)
11. [Testing](#11-testing)
12. [Recipes](#12-recipes)

---

## 1. Install

The package lives in the `packages/pos_theme` sub-folder of the repo, so the git dependency needs `path:`.

```yaml
dependencies:
  pos_theme:
    git:
      url: git@github.com:<account>/pos_theme_flutter.git
      path: packages/pos_theme
      ref: v1.0.0          # always pin a tag
```

For local development against a checkout:

```yaml
dependency_overrides:
  pos_theme:
    path: ../pos_theme_flutter/packages/pos_theme
```

---

## 2. App setup

### Fixed theme (simplest)

```dart
MaterialApp(
  theme: PosThemes.corporateBlue.lightTheme,
  darkTheme: PosThemes.corporateBlue.darkTheme,
  themeMode: ThemeMode.system,
  home: const HomePage(),
);
```

### Switchable theme (recommended)

`PosThemeController` holds the active theme + mode and caches the built `ThemeData`.
It is a plain `ChangeNotifier`, so it works with any state-management library.

```dart
final themes = PosThemeController(spec: PosThemes.corporateBlue, mode: ThemeMode.system);

runApp(PosThemeScope(
  controller: themes,
  child: ListenableBuilder(
    listenable: themes,
    builder: (context, _) => MaterialApp(
      theme: themes.light,
      darkTheme: themes.dark,
      themeMode: themes.mode,
      home: const HomePage(),
    ),
  ),
));

// Anywhere below:
final c = PosThemeScope.of(context);
c.spec = PosThemes.midnightPro;     // change theme
c.mode = ThemeMode.dark;            // change mode
c.toggleMode();                     // light → dark → system
```

Persist the choice yourself: store `c.spec.id` and `c.mode.name`, then restore with
`PosThemes.byId(savedId)` and `ThemeMode.values.byName(savedMode)`.

---

## 3. Rules for using this package (read this first)

These rules keep every POS app consistent and theme-switchable.

1. **Never hard-code colours, radii or shadows.** Read them from the theme:
   `context.colors` (ColorScheme), `context.pos` (POS colours), `context.shape` (radii/shadows),
   `context.text` (TextTheme). Hard-coded values break when the theme changes.
2. **Use `Pos*` widgets before raw Material ones** when one exists (`PosButton` not `ElevatedButton`,
   `PosTextField` not a bare `TextField`, `PosDialog` + `showPosAdaptiveDialog` not `AlertDialog`).
   Plain Material widgets (Switch, Checkbox, TabBar, Chip, Slider, DataTable, ListTile, …) are fully
   themed too, so use them directly when there's no `Pos*` equivalent.
3. **Show statuses with semantic tones, never ad-hoc colours.** Use `PosToneKind` /
   `PosStatusPill.order(...)` / `PosStatusPill.table(...)`.
4. **Branch layouts on `PosWindow`**, not raw pixel checks: `context.window.isCompact`,
   `PosResponsive`, `PosGrid`. Use the breakpoints below.
5. **Open dialogs with `showPosAdaptiveDialog`**. It becomes a bottom sheet on phones automatically.
6. **Format money with `posMoney()`** and show numbers with `posTabular(style)` so digits line up.
7. **Touch targets ≥ 44–48 px.** The default component sizes already meet this; don't shrink them.
8. In widget tests set `PosFonts.useGoogleFonts = false` (see [Testing](#11-testing)).

### Layout constraints (common mistakes)

| Widget | Needs |
|---|---|
| `PosDataTable` | Does **not** scroll vertically itself (it is a shrink-wrapped Column). Put it in a `ListView` / `SingleChildScrollView`. |
| `PosCategoryTabs` | Bounded **width** (horizontal ListView, fixed height 44). |
| `PosSideMenu` | Bounded **height** (e.g. inside a `Row` in a `Scaffold`). |
| `PosModifierPicker` | Bounded height: use it inside `showPosSheet` or a `SizedBox(height: …)`. |
| `PosNumpad`, `PosCashTender`, `PosPaymentMethodSelector` | Bounded width (they use `LayoutBuilder`). |
| `PosCartLine` | A unique `key` (it is `Dismissible` when `onRemove` is set). |
| `PosToast` | A `MaterialApp`/`Overlay` above the calling context. |
| `PosTableTile` | Has a fixed `AspectRatio`. Give it a width (grid cell) and let height follow. |

### Name clash note
`PosThemeContext` adds `context.theme / colors / text / pos / shape`. If your app already defines
extensions with those names, hide it: `import 'package:pos_theme/pos_theme.dart' hide PosThemeContext;`
and use `Theme.of(context).extension<PosColors>()!` instead.

---

## 4. Themes

| Constant | id | Feel | Fonts (display / body) | Shape |
|---|---|---|---|---|
| `PosThemes.corporateBlue` | `corporate_blue` | Clean enterprise, navy sidebar | Inter / Inter | 8px, soft shadows |
| `PosThemes.midnightPro` | `midnight_pro` | Dark-first, cyan + violet, high contrast | Manrope / Manrope | 10px, borders, no shadows |
| `PosThemes.emeraldFresh` | `emerald_fresh` | Friendly, mint surfaces | Nunito / Nunito | 16px, pill buttons |
| `PosThemes.warmTerracotta` | `warm_terracotta` | Earthy hospitality | Fraunces / DM Sans | 12px, warm-tinted shadows |
| `PosThemes.monochromeMinimal` | `monochrome_minimal` | Editorial black & white | Space Grotesk / IBM Plex Sans | 2px, 1px rules, flat |

- `PosThemes.all` is a `List<PosThemeSpec>` of all 5 themes. `PosThemes.byId(id)` returns the
  matching theme, or Corporate Blue if the id is unknown.
- `spec.lightTheme`, `spec.darkTheme`, or `buildPosTheme(spec, Brightness.dark)` give a `ThemeData`.
  Building one is not free, so prefer `PosThemeController` (it caches) or build once and store it.
- `PosThemeSpec` fields: `id`, `name`, `tagline`, `light`/`dark` (`PosPalette`), `bodyFont`,
  `displayFont`, `shape` (`PosShapeSpec`), `filledInputs`, `buttonLetterSpacing`, `headingWeight`,
  `compactDensity`. `spec.palette(brightness)` returns the raw palette.

All 10 variants are tested for WCAG contrast: body text ≥ 7:1, muted text ≥ 4.5:1, button labels
≥ 4.5:1, status pills ≥ 4.5:1.

---

## 5. Tokens

### Context accessors

```dart
context.theme    // ThemeData
context.colors   // ColorScheme
context.text     // TextTheme
context.pos      // PosColors (ThemeExtension)
context.shape    // PosShape  (ThemeExtension)
context.window   // PosWindow (responsive size class)
```

### `PosColors` (`context.pos`)

| Field | Use |
|---|---|
| `success`, `warning`, `info`, `danger`, `neutral`, `brand` | `PosTone`s (see below) |
| `canvas` | Page background behind cards (also `Scaffold` background) |
| `surfaceMuted` | Table headers, input fills, hover rows, secondary panels |
| `border`, `borderStrong` | Hairlines / input & control outlines |
| `textMuted` | Secondary text (AA-compliant on surface) |
| `sidebarBg`, `sidebarFg`, `sidebarMuted`, `sidebarActiveBg`, `sidebarActiveFg`, `sidebarBorder` | Navigation chrome |
| `chart` | `List<Color>`: ordered chart series colours (6) |

### `PosTone`
`color` (strong fill), `onColor` (text on it), `container` (soft background), `onContainer` (text on
the soft background).

```dart
final t = context.pos.warning;
Container(color: t.container, child: Text('Low stock', style: TextStyle(color: t.onContainer)));
```

`PosToneKind { brand, success, warning, info, danger, neutral }`, with `kind.of(context)` → `PosTone`.

### `PosShape` (`context.shape`)
Doubles: `radiusXs`, `radiusSm`, `radiusMd`, `radiusLg`, `radiusXl`, `buttonRadius` (999 = pill),
`borderWidth`. Ready-made `BorderRadius` getters: `xs`, `sm`, `md`, `lg`, `xl`, `button`.
Shadows: `shadowsSm`, `shadowsMd`, `shadowsLg` (`List<BoxShadow>`; empty for flat themes).
`cardBordered` (bool): whether cards draw an outline.

```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surface,
    borderRadius: context.shape.lg,
    border: context.shape.cardBordered ? Border.all(color: context.pos.border) : null,
    boxShadow: context.shape.shadowsSm,
  ),
);
```

### Static tokens
- `PosSpace`: `xxs 2, xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48, touchTarget 48, touchTargetLarge 56`.
- `PosMotion`: `fast 120ms, medium 220ms, slow 360ms`, curves `standard`, `emphasized`.

### Typography
Use `context.text.*` (the standard M3 TextTheme roles). Display/headline styles use the theme's
display font; titles, body and labels use the body font. For prices use `posTabular(context.text.titleMedium!)`.

---

## 6. Responsive layout

### Breakpoints: `PosWindow`

| Value | Width | Typical device | gutter | grid columns |
|---|---|---|---|---|
| `compact` | < 600 | phones, handhelds | 16 | 4 |
| `medium` | 600–1023 | tablets, 10" POS | 20 | 8 |
| `expanded` | 1024–1439 | laptops, 15" terminals | 24 | 12 |
| `large` | ≥ 1440 | desktops | 32 | 12 |

```dart
final w = context.window;                 // or PosWindow.of(context) / PosWindow.fromWidth(px)
w.isCompact; w.atLeastMedium; w.atLeastExpanded; w.gutter; w.columns;

final cols = posValue(context, compact: 2, medium: 3, expanded: 4, large: 6);
```

`PosResponsive` picks a builder using its **own** constraints, so it also works inside panes:

```dart
PosResponsive(
  compact: (_) => const PhoneLayout(),
  medium: (_) => const TabletLayout(),     // optional; falls back to the next smaller class
  expanded: (_) => const DesktopLayout(),
);
```

### `PosGrid`: span-based responsive grid

```dart
PosGrid(children: [
  PosGridItem(compact: 2, medium: 4, expanded: 3, child: kpi1), // half on phone, quarter on desktop
  PosGridItem(compact: 4, medium: 8, expanded: 8, child: chart),
  PosGridItem(medium: 8, expanded: 4, child: sidePanel),
]);
```
Spans are out of 4 / 8 / 12 / 12 columns. Unset values default to full width.

### `PosAdaptiveScaffold`: the app shell
- compact: top bar with a hamburger, drawer, and bottom `NavigationBar` (with an automatic "More" item)
- medium: collapsed icon rail
- expanded/large: full side menu that the user can collapse

```dart
const groups = [
  PosNavGroup(items: [
    PosNavItem(id: 'sell', label: 'Sell', icon: Icons.point_of_sale_outlined),
  ]),
  PosNavGroup(title: 'Catalog', items: [
    PosNavItem(id: 'orders', label: 'Orders', icon: Icons.receipt_long_outlined, badge: 12),
    PosNavItem(id: 'catalog', label: 'Catalog', icon: Icons.category_outlined, children: [
      PosNavItem(id: 'products', label: 'Products', icon: Icons.circle),
      PosNavItem(id: 'modifiers', label: 'Modifiers', icon: Icons.circle),
    ]),
  ]),
];

PosAdaptiveScaffold(
  groups: groups,
  selectedId: selected,
  onSelect: (id) => setState(() => selected = id),
  bottomNavIds: const ['sell', 'orders'],            // ≤ 4 leaf ids for the phone bottom bar
  header: (context, collapsed) => MyLogo(collapsed: collapsed),
  footer: (context, collapsed) => MyUserCard(collapsed: collapsed),
  topBarBuilder: (context, window, openMenu) => PosTopBar(
    title: 'Orders',
    onMenu: openMenu,                                  // non-null only on compact
    search: const PosSearchField(),                    // shown inline on expanded+
    actions: [PosIconButton(icon: Icons.notifications_none, badge: '3', onPressed: () {})],
  ),
  body: pages[selected]!,
);
```

- `PosNavItem(id, label, icon, {selectedIcon, badge, children})`
- `PosNavGroup({title, items})`
- `PosSideMenu(groups, selectedId, onSelect, {collapsed, onToggleCollapsed, header, footer, width = 268, collapsedWidth = 80})`
  can be used on its own.
- `PosTopBar(title, {subtitle (Widget), onMenu, search, actions, leading})`

---

## 7. Components

### Buttons

```dart
PosButton(label: 'Charge \$24.60', icon: Icons.payments, size: PosButtonSize.xl, expand: true, onPressed: pay);
PosButton.secondary(label: 'Hold', onPressed: hold);
PosButton.outline(label: 'Cancel', onPressed: close);
PosButton.ghost(label: 'Skip', onPressed: skip);
PosButton.danger(label: 'Void', icon: Icons.block, onPressed: voidOrder);
PosButton(label: 'Complete', variant: PosButtonVariant.success, onPressed: done);
PosButton(label: 'Saving…', loading: true, onPressed: save);
const PosButton(label: 'Disabled', onPressed: null);
```
`PosButton(label, onPressed, {variant, size, icon, trailingIcon, loading, expand, tooltip})`
- `PosButtonVariant { primary, secondary, outline, ghost, danger, success }`
- `PosButtonSize { sm 36, md 44, lg 52, xl 64 }` (heights in px; use XL for the main register action)

`PosIconButton(icon, onPressed, {tooltip, badge (String), style, size = 44})`.
`PosIconButtonStyle { plain, tonal, filled, outlined }`.

`PosSplitButton(label, onPressed, items: [PopupMenuItem(value: callback, child: …)], {icon})`: the
menu value is a `VoidCallback`, which runs when the item is picked.

### Inputs

```dart
PosTextField(label: 'Price', prefixText: '\$ ', hint: '0.00', keyboardType: TextInputType.number, required: true);
PosTextField(label: 'Email', error: 'Invalid email');          // error replaces helper
PosTextField(label: 'PIN', obscure: true);                       // adds show/hide toggle
PosTextField(hint: 'Search', prefixIcon: Icons.search, clearable: true, onChanged: f);
PosSearchField(hint: 'Search products', onChanged: f, shortcutHint: 'Ctrl K');
PosBarcodeField(label: 'Barcode', onSubmitted: addBySku, onScan: openCamera);
PosDateField(label: 'Date', value: date, onChanged: (d) => setState(() => date = d));
PosQuantityStepper(value: qty, min: 1, onChanged: (v) => setState(() => qty = v), compact: true);
```
`PosTextField({label, hint, helper, error, controller, initialValue, onChanged, onSubmitted, prefixIcon, prefixText, suffix, keyboardType, obscure, enabled, readOnly, required, clearable, maxLines, inputFormatters, textInputAction, autofocus, onTap})`.
Labels are drawn **above** the field. `PosFieldLabel(label, {required, trailing})` gives the same
label for custom controls.

### Dropdowns & selects

```dart
// Single select (Material 3 DropdownMenu; set searchable: true to type-filter)
PosDropdown<String>(
  label: 'Store',
  value: storeId,
  onChanged: (v) => setState(() => storeId = v),
  options: const [
    PosOption('dt', 'Downtown', icon: Icons.location_city),
    PosOption('ap', 'Airport'),
    PosOption('x', 'Closed', enabled: false),
  ],
);

// Searchable select with an overlay list; single or multiple (chips)
PosSelect<String>(
  label: 'Tags',
  multiple: true,
  selected: tags,                         // Set<T>
  onChanged: (s) => setState(() => tags = s),
  options: const [PosOption('vegan', 'Vegan', subtitle: 'No animal products'), PosOption('gf', 'Gluten free')],
);
```
- `PosOption<T>(value, label, {icon, subtitle, enabled})`
- `PosDropdown<T>(options, value, onChanged, {label, hint, prefixIcon, enabled, error, searchable, required})`
- `PosSelect<T>(options, selected, onChanged, {label, hint, multiple, searchHint, prefixIcon})`

### Numpad & PIN

```dart
PosNumpad(onKey: (k) => entry += k, onBackspace: back, onClear: clear, extraKey: '00', keyHeight: 64);
PosPinPad(length: 4, error: wrongPin ? 'Incorrect PIN' : null, onCompleted: (pin) => login(pin));
```
`showDecimal: false` turns the bottom-left key into `C` (clear). Setting a new `error` on `PosPinPad`
resets the entered digits.

### Data table

Responsive: a full table when the width is at least `minTableWidth`, a horizontally scrolling table
on tablets, and one card per row under 600 px. It supports sorting, row selection, row actions,
pagination, and loading and empty states.

```dart
PosDataTable<Order>(
  rows: orders,
  rowId: (o) => o.id,                               // stable id for selection
  columns: [
    PosColumn(label: 'Order', primary: true, width: 100, sortBy: (o) => o.id, cell: (c, o) => Text('#${o.id}')),
    PosColumn(label: 'Customer', flex: 3, sortBy: (o) => o.customer, cell: (c, o) => Text(o.customer)),
    PosColumn(label: 'Status', flex: 2, cell: (c, o) => PosStatusPill.order(o.status, dense: true)),
    PosColumn(label: 'Payment', flex: 2, showInCard: false, cell: (c, o) => Text(o.payment)),
    PosColumn(label: 'Total', width: 100, numeric: true, sortBy: (o) => o.total, cell: (c, o) => Text(posMoney(o.total))),
  ],
  selectable: true,
  selected: selectedIds,                            // Set<Object>
  onSelectionChanged: (s) => setState(() => selectedIds = s),
  onRowTap: openOrder,
  actions: [
    PosRowAction(label: 'Refund', icon: Icons.undo, onTap: refund),
    PosRowAction(label: 'Void', icon: Icons.block, destructive: true, onTap: voidOrder),
  ],
  pageSize: 10,                                     // null = no pagination
  loading: isLoading,
  emptyTitle: 'No orders yet',
);
```
- `PosColumn<T>(label, cell, {flex = 1, width, numeric, sortBy, showInCard = true, primary})`.
  `primary` marks the column used as the card title on phones; `sortBy` returns a `Comparable`.
- `PosDataTable<T>(columns, rows, rowId, {selectable, selected, onSelectionChanged, onRowTap, actions, pageSize, loading, emptyTitle, emptyMessage, minTableWidth = 760, dense, striped})`
- The table is shrink-wrapped, so **put it in a scroll view**.
- `PosPagination(page (0-based), pageCount, onChanged, {summary})` can be used on its own.
- The plain Material `DataTable` is also themed.

### Navigation

```dart
PosBreadcrumbs(items: ['Home', 'Inventory', 'Products'], onTap: (i) {});
PosSteps(steps: ['Cart', 'Customer', 'Payment', 'Receipt'], current: 1);   // vertical on phones
PosCategoryTabs(items: ['All', 'Coffee', 'Food'], counts: [40, 12, 18], selected: i, onSelected: (i) {});
```
Material `TabBar`, `NavigationRail`, `NavigationBar` and `SegmentedButton` are themed as well.

### Dialogs, sheets & toasts

```dart
// Adaptive: centred dialog on medium+, bottom sheet on phones
await showPosAdaptiveDialog<void>(context, builder: (ctx) => PosDialog(
  title: 'Add product',
  icon: Icons.add_box_outlined,
  content: const Column(children: [PosTextField(label: 'Name')]),
  actions: [
    PosButton.outline(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
    PosButton(label: 'Save', onPressed: () => Navigator.pop(ctx)),
  ],
));
// Long forms: fullscreenOnCompact: true (full-screen page on phones)

final ok = await showPosConfirm(context,
    title: 'Void order #1048?', message: 'This cannot be undone.', confirmLabel: 'Void', destructive: true);

await showPosSheet<void>(context, title: 'Order actions', builder: (ctx) => const MyActionList());

PosToast.success(context, 'Payment approved', title: 'Done');
PosToast.error(context, 'Card reader offline');
PosToast.warning(context, '3 left in stock');
PosToast.info(context, 'New online order');
PosToast.show(context, message: 'Item removed', actionLabel: 'Undo', onAction: undo, tone: PosToneKind.neutral);
PosToast.clear();
```
- `PosDialog(title, {message, content, actions, icon, tone (PosToneKind), maxWidth = 480, showClose = true})`.
  Actions are right-aligned on larger screens and stacked full width on phones (put the primary
  action **last**).
- `showPosAdaptiveDialog<T>(context, {builder, fullscreenOnCompact, barrierDismissible})`. Inside it,
  use `PosDialog` as the root and close with `Navigator.pop(ctx, result)`.
- `showPosConfirm(context, {title, message, confirmLabel, cancelLabel, destructive, icon})` → `Future<bool>`.
- `showPosSheet<T>(context, {builder, title, actions})`
- Toasts stack top-right on medium+ and at the bottom on phones. They dismiss themselves after 4 s
  and can be swiped away.

### Feedback & status

```dart
PosAlert(tone: PosToneKind.warning, title: 'Low stock', message: '4 items need reordering', action: btn, onClose: f);
PosStatusPill(label: 'Paid', tone: PosToneKind.success, dot: true);       // style: soft | solid | outline
PosStatusPill.order(PosOrderStatus.preparing);
PosStatusPill.table(PosTableStatus.reserved, dense: true);
PosCountBadge(count: 3);
PosAvatar(name: 'Ava Thompson', size: 40, online: true);                  // initials fallback
PosEmptyState(title: 'Cart is empty', message: 'Scan a product', icon: Icons.shopping_cart_outlined, action: btn, compact: true);
PosErrorState(title: 'Could not load', message: 'Check connection', onRetry: reload);
PosSkeleton(width: 160, height: 14);   PosSkeleton(height: 40, circle: true);
PosLoadingOverlay(loading: busy, message: 'Processing…', child: content);
```
Enums:
- `PosOrderStatus { draft, pending, preparing, ready, served, paid, refunded, voided }`, each with `.label` and `.tone`.
- `PosTableStatus { free, occupied, reserved, billing, cleaning }`, each with `.label` and `.tone`.
- `PosPillStyle { soft, solid, outline }`.

### Cards & layout helpers

```dart
PosCard(title: 'Revenue', subtitle: 'This week', trailing: menuButton, child: chart);
PosCard(onTap: open, selected: isSelected, padding: EdgeInsets.zero, child: …);
PosSectionHeader(title: 'Inventory', subtitle: '64 products', action: PosButton(label: 'Add', onPressed: add));
```
`PosCard({child, title, subtitle, trailing, padding = 16, onTap, selected, color, elevated})`. It
follows each theme's border and shadow style automatically. `PosSectionHeader` stacks its action
under the title below 600 px.

### Charts & KPIs (no chart library needed)

```dart
PosStatCard(label: 'Net sales', value: '\$4,180', delta: 0.124, icon: Icons.payments_outlined, spark: [3, 5, 4, 7]);
PosLineChart(series: [thisWeek, lastWeek], labels: ['Mon', …], legend: ['This week', 'Last week'], height: 240);
PosBarChart(values: hourly, labels: hours, highlightIndex: 4, height: 200);
PosDonutChart(values: [46, 31, 15], labels: ['Card', 'Cash', 'Wallet'], centerValue: '\$4,180', centerLabel: 'Total');
PosSparkline(values: [1, 3, 2, 5]);
```
`delta` is a fraction (0.124 means +12.4%). Colours come from `context.pos.chart`. `PosStatCard`
hides its caption and sparkline when it is narrower than 230 px.

---

## 8. POS components

### Retail / checkout

```dart
PosProductTile(name: 'Flat White', price: 4.2, category: 'Coffee', stock: 3, icon: Icons.coffee,
    tag: 'Popular', quantityInCart: 2, onTap: add);
// Out-of-stock (stock <= 0) is dimmed and can't be tapped; stock <= lowStockThreshold (5) shows a "Low" badge.

PosCartLine(key: ValueKey(line.id), name: 'Flat White', quantity: 2, unitPrice: 4.7,
    modifiers: ['Large', 'Oat'], note: 'Extra hot', discount: 0.5,
    onQuantityChanged: (q) => …, onRemove: () => …);   // swipe left to remove

PosCartSummary(subtotal: 32.1, discount: 3.2, tax: 2.45, taxLabel: 'Tax (8.5%)', onDiscountTap: openDiscount);
// .total = subtotal - discount + serviceCharge + tax

PosPaymentMethodSelector(selected: method, onChanged: (id) => …);          // methods: PosPaymentMethod.defaults
PosCashTender(amountDue: 23.47, onConfirm: (tendered) => …);                // quick-cash buttons, numpad, change due
PosReceipt(storeName: 'Nova Café', orderNo: '#1048', cashier: 'Jordan',
    lines: [PosReceiptLine('Flat White', 2, 9.4)], subtotal: 9.4, tax: 0.8, total: 10.2, paidWith: 'Visa •4242');
PosCustomerTile(name: 'Ava Thompson', phone: '+1…', points: 1240, tier: 'Gold', onTap: attach);
```
`PosPaymentMethod(id, label, icon, {subtitle})` comes with built-ins: `cash`, `card`, `wallet`,
`split`, `giftCard`, `account`, and `defaults` (all six).

### Restaurant

```dart
PosTableTile(name: 'T4', seats: 6, status: PosTableStatus.occupied, guests: 5,
    elapsed: const Duration(minutes: 42), amount: 186.2, round: false, selected: sel, onTap: open);

PosKitchenTicket(
  orderNo: '1048', table: 'T4', channel: 'Dine-in', elapsed: const Duration(minutes: 9),
  items: [PosTicketItem(2, 'Flat White', modifiers: ['Oat']), PosTicketItem(1, 'Toast', note: 'No butter')],
  onItemToggle: (i) => setState(() => items[i].done = !items[i].done),   // PosTicketItem.done is mutable
  onBump: bump,
);  // header turns green → amber at warnAfter (8 min) → red at lateAfter (15 min)

showPosSheet<void>(context, builder: (ctx) => PosModifierPicker(
  itemName: 'Cappuccino',
  basePrice: 4.0,
  groups: const [
    PosModifierGroup(id: 'size', title: 'Size', required: true, options: [
      PosModifierOption('s', 'Small'), PosModifierOption('l', 'Large', price: 0.9),
    ]),
    PosModifierGroup(id: 'extras', title: 'Extras', multiple: true, max: 3, options: [
      PosModifierOption('shot', 'Extra shot', price: 0.8),
    ]),
  ],
  onAdd: (r) { Navigator.pop(ctx); addToCart(r.quantity, r.selected, r.note, r.total); },
));

PosShiftCard(cashier: 'Jordan', openedAt: '08:02', openingFloat: 200, cashSales: 842.6, cardSales: 2310.4,
    onCloseShift: closeShift, onCashMovement: cashInOut);
```
- In `PosModifierPicker`, a required single-choice group selects its first option by default, and
  the Add button stays disabled until every required group has a choice.
- `PosModifierResult` has `quantity`, `selected` (`Map<groupId, Set<optionId>>`), `note` and `total`
  (unit price × quantity).

---

## 9. Utilities

| Function | Purpose |
|---|---|
| `posMoney(num, {symbol = '\$', decimals = 2})` | `1234.5` → `$1,234.50`. Simple; use `intl` for real locales. |
| `posTabular(TextStyle)` | Turns on tabular (fixed-width) digits for prices and quantities |
| `posInitials(String)` | `'Ava Thompson'` → `'AT'` |
| `posHashColor(String, List<Color>)` | Picks the same palette colour for the same string (placeholders) |
| `posContrast(Color, Color)` | WCAG contrast ratio |
| `posOnColor(Color)` | Returns white or near-black, whichever reads better on the colour |
| `posShift(Color, double)` | Lighten (+) or darken (−) a colour in HSL |

---

## 10. Creating a custom theme

Build a `PosThemeSpec`; every component adapts to it. Copy one of the files in `lib/src/themes/`
as a starting point.

```dart
const myBrand = PosThemeSpec(
  id: 'my_brand',
  name: 'My Brand',
  tagline: 'Our colours',
  bodyFont: 'Inter',            // any Google Fonts family name
  displayFont: 'Inter',
  filledInputs: true,           // filled (true) or outlined-on-surface (false) inputs
  shape: PosShapeSpec(radiusXs: 4, radiusSm: 6, radiusMd: 10, radiusLg: 14, radiusXl: 20,
      buttonRadius: 10, shadows: PosShadowStyle.soft, cardBordered: true),
  light: PosPalette(
    brightness: Brightness.light,
    primary: Color(0xFF5B21B6), onPrimary: Colors.white,
    secondary: Color(0xFF1F2937), onSecondary: Colors.white, tertiary: Color(0xFFF59E0B),
    canvas: Color(0xFFF6F5FA), surface: Colors.white, surfaceMuted: Color(0xFFF1EFF7), surfaceHigh: Colors.white,
    onSurface: Color(0xFF111827), textMuted: Color(0xFF5B5F6B),
    border: Color(0xFFE5E3EE), borderStrong: Color(0xFFCBC8D8),
    success: Color(0xFF16A34A), warning: Color(0xFFD97706), info: Color(0xFF0284C7), danger: Color(0xFFDC2626),
    sidebarBg: Color(0xFF1E1B4B), sidebarFg: Colors.white, sidebarMuted: Color(0xFFA5A3C9),
    sidebarActiveBg: Color(0xFF5B21B6), sidebarActiveFg: Colors.white, sidebarBorder: Color(0xFF2E2A6B),
    chart: [Color(0xFF5B21B6), Color(0xFF16A34A), Color(0xFFF59E0B), Color(0xFF0284C7), Color(0xFFDC2626), Color(0xFF14B8A6)],
  ),
  dark: PosPalette(/* same fields with dark values */),
);

themeController.spec = myBrand;
```
The status-tone containers, the `ColorScheme` and all component themes are derived from the palette.
Check contrast with `posContrast` (see `test/pos_theme_test.dart` for the checks the built-in themes pass).

---

## 11. Testing

`google_fonts` tries to download fonts, which fails in widget tests. Turn it off once per test file:

```dart
setUpAll(() => PosFonts.useGoogleFonts = false);
```

Pump at specific sizes to test responsive layouts:

```dart
tester.view.physicalSize = const Size(360, 780);
tester.view.devicePixelRatio = 1;
addTearDown(tester.view.reset);
await tester.pumpWidget(MaterialApp(theme: PosThemes.corporateBlue.lightTheme, home: const MyScreen()));
await tester.pump(const Duration(milliseconds: 400));   // not pumpAndSettle: skeletons animate forever
expect(tester.takeException(), isNull);                  // catches RenderFlex overflows
```

For offline production builds, bundle the font files as assets (google_fonts finds them
automatically) or set `PosFonts.useGoogleFonts = false` to use the platform font.

---

## 12. Recipes

**Two-pane register (cart beside products on wide screens, bottom sheet on phones)**

```dart
LayoutBuilder(builder: (context, c) {
  if (c.maxWidth >= 900) {
    return Row(children: [
      const Expanded(child: ProductGrid()),
      Container(
        width: 400,
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: BorderDirectional(start: BorderSide(color: context.pos.border)),
        ),
        child: const CartPanel(),
      ),
    ]);
  }
  return Column(children: [
    const Expanded(child: ProductGrid()),
    Padding(
      padding: const EdgeInsets.all(16),
      child: PosButton(label: 'View cart · ${posMoney(total)}', size: PosButtonSize.lg, expand: true,
          onPressed: () => showPosSheet<void>(context, builder: (_) => const CartPanel())),
    ),
  ]);
});
```

**Responsive product grid**

```dart
LayoutBuilder(builder: (context, c) => GridView.builder(
  padding: EdgeInsets.all(context.window.gutter),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: (c.maxWidth / 170).floor().clamp(2, 7),
    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
  ),
  itemCount: products.length,
  itemBuilder: (_, i) => PosProductTile(name: products[i].name, price: products[i].price, onTap: () {}),
));
```

**Standard scrolling page**

```dart
ListView(
  padding: EdgeInsets.all(context.window.gutter),
  children: [
    PosSectionHeader(title: 'Orders', action: PosButton(label: 'New', icon: Icons.add, onPressed: () {})),
    PosDataTable<Order>(/* … */),
  ],
);
```

A runnable example of every component and screen is in `apps/showcase` in the same repository.
