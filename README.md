# POS Suite Theme System (Flutter)

Shared design system for every POS app in the suite: **5 themes × light/dark**, responsive
layout primitives, and a full component library. A showcase app lets you preview everything live.

> **Full API reference and usage rules:** [`packages/pos_theme/README.md`](packages/pos_theme/README.md)
> (start there if you're a developer or an AI agent building a POS app on this package).

```
packages/pos_theme/   reusable package (add as a path/git dependency to each POS app)
apps/showcase/        gallery app with live theme switcher + sample screens
```

## Themes

| Theme | Personality | Fonts | Shape |
|---|---|---|---|
| Corporate Blue | Clean enterprise, navy sidebar | Inter | 8px, soft shadows |
| Midnight Pro | Dark-first, cyan/violet, high contrast (bars, KDS) | Manrope | 10px, borders, no shadows |
| Emerald Fresh | Friendly, rounded, mint surfaces | Nunito | 16px, pill buttons |
| Warm Terracotta | Earthy hospitality, espresso sidebar | DM Sans + Fraunces | 12px, warm-tinted shadows |
| Monochrome Minimal | Editorial black/white, red accent | IBM Plex Sans + Space Grotesk | 2px, 1px rules, flat |

All 10 variants are contrast-checked in tests (body text ≥ 7:1, muted text and status pills ≥ 4.5:1).

## Install from GitHub

The package lives in a sub-folder of this repo, so the git dependency needs `path:`.
Pin `ref:` to a tag so every POS app gets the same, reproducible version.

```yaml
dependencies:
  pos_theme:
    git:
      url: https://github.com/SibghatullahDurrani/pos_theme.git
      path: packages/pos_theme
      ref: v1.0.0
```

Private repo? Use the SSH URL (`git@github.com:SibghatullahDurrani/pos_theme.git`) so pub
uses your SSH key; on CI, add a deploy key or a token-authenticated HTTPS URL.

### Releasing a new version

1. Make changes in `packages/pos_theme`, bump `version:` in its `pubspec.yaml`, note it in `CHANGELOG.md`.
2. `git commit`, then `git tag v1.1.0 && git push --follow-tags`.
3. In each app, change `ref:` to the new tag and run `flutter pub upgrade pos_theme`.

During local development you can temporarily point an app at a checkout instead:
`pos_theme: { path: ../pos_theme_flutter/packages/pos_theme }` (or use `dependency_overrides`).

## Use it in a POS app

```dart
final themes = PosThemeController(spec: PosThemes.emeraldFresh, mode: ThemeMode.system);

PosThemeScope(
  controller: themes,
  child: ListenableBuilder(
    listenable: themes,
    builder: (_, _) => MaterialApp(
      theme: themes.light, darkTheme: themes.dark, themeMode: themes.mode, home: ...),
  ),
);

// Anywhere:
context.pos.success.container   // semantic tones, sidebar colours, chart palette
context.shape.lg                // radii + shadows of the active theme
context.window.isCompact        // compact / medium / expanded / large
```

## What's included

- **Tokens**: `PosColors`, `PosShape` (ThemeExtensions), `PosSpace`, `PosMotion`, plus full M3 component
  theming (buttons, inputs, dropdowns, menus, dialogs, sheets, snackbars, tooltips, tabs, chips, switches,
  checkboxes, radios, sliders, progress, data table, date/time pickers, navigation rail/bar, drawer…).
- **Responsive**: breakpoints (<600 / 600–1023 / 1024–1439 / ≥1440), `PosResponsive`, `PosGrid`,
  `PosAdaptiveScaffold` (bottom bar + drawer → rail → full collapsible side menu),
  `showPosAdaptiveDialog` (bottom sheet on phones, dialog elsewhere, optional full-screen forms).
- **Components**: `PosButton` (6 variants × 4 sizes), icon/split buttons, text/search/barcode fields,
  `PosDropdown`, searchable + multi `PosSelect`, date field, quantity stepper, numpad, PIN pad,
  `PosDataTable` (sort, select, row actions, pagination, loading/empty; becomes cards on phones),
  side menu, top bar, breadcrumbs, steps, category tabs, pagination, dialogs/confirm/sheets,
  stacked toasts, alerts, status pills, badges, avatars, skeletons, empty/error/loading states,
  KPI cards and dependency-free line/bar/donut charts.
- **POS-specific**: product tile, cart line, cart summary, payment method selector, cash tender,
  receipt preview, customer tile, floor-plan table tile, kitchen ticket (KDS), modifier picker, shift card.

## Showcase

```bash
cd apps/showcase
flutter run -d chrome        # or linux / windows / macos / android / ios
```

Sample screens: Dashboard, Checkout (full payment flow), Floor plan + split bill, Kitchen display,
Inventory (filters + edit form), Customers (master–detail), Settings, PIN lock screen.

## Tests

```bash
cd packages/pos_theme && flutter test   # theme build + WCAG contrast for all 10 variants
cd apps/showcase && flutter test        # every page at 360/820/1280/1920 px, every theme × mode
```

## Notes

- Fonts load via `google_fonts` at runtime. For fully offline terminals, bundle the font files as
  assets (google_fonts picks them up automatically) or set `PosFonts.useGoogleFonts = false`.
- `posMoney` is a lightweight formatter; swap in `intl`'s `NumberFormat.currency` for real locales.
