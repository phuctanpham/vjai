# garblo-tokens v0.2

Design tokens for the Garblo UI/UX Design System Handbook (Ch.4–Ch.7, Ch.18).

## Layout
- `tokens/core/*.json` — primitives in W3C DTCG format (`$value`, `$type`): colour ladders for 3 themes × 2 modes, accents (incl. the forest-green primary), space, radius, size, layout (grid, breakpoints, spans, safe-area reference), typography, motion, shadow, z-index.
- `tokens/themes/{warm|cold|neutral}-{light|dark}.json` — semantic tokens (`surface.*`, `ink.*`, `rule.*`, `accent.*`, `status.*`) referencing the core ladders.
- `build/flutter/lib/garblo_tokens.dart` — ready-to-use Flutter library: `GarbloColors` (ThemeExtension, 6 palettes, 22 colours incl. `accentPrimary`, `accentPrimaryPressed`, `onPrimary`), `GarbloSpace`, `GarbloRadius`, `GarbloSize`, `GarbloLayout` + `GarbloGrid`, `GarbloType` (11 styles incl. `monoFigure`, `labelButton`, `labelNav`), `GarbloMotion`, `GarbloShadow`.
- `scripts/gen_dart.py` — regenerates the Dart file from `tokens/core/color.json`, `size.json` and `layout.json` (`python3 scripts/gen_dart.py`).
- `style-dictionary.config.mjs` — optional Style Dictionary v5 build (built-in `flutter` transform group + `flutter/class.dart` format). Not run in this package: npm was unreachable while it was prepared.
- `pubspec.fonts.yaml` — font asset block.

## Use in Flutter
```dart
MaterialApp(
  theme: ThemeData(extensions: [GarbloColors.of(GarbloTheme.warm, Brightness.light)]),
  darkTheme: ThemeData(extensions: [GarbloColors.of(GarbloTheme.warm, Brightness.dark)]),
);
final c = Theme.of(context).extension<GarbloColors>()!;
```

## Rules
- Components read semantic tokens only; never hex values.
- Change a value in `tokens/`, regenerate, bump the version (Ch.19).
- App code never contains a hex value or a raw size: read `GarbloColors`, `GarbloSize`, `GarbloLayout`. The bottom nav uses `GarbloType.labelNav()` inside `MediaQuery.withNoTextScaling`, with the large label on long-press (D51).

## Changelog
- **v0.2 · 2026-10-30** · DS-CR-01: forest-green primary (D39), `GarbloLayout`/`GarbloGrid`, new `GarbloSize` values (nav 56 → 64; `navHeight` and `touchMin` kept as deprecated aliases), `monoFigure`, `labelButton`, `labelNav`, `GarbloMotion.gestureSettle`.
- **v0.1 · 2026-10-28** · First release (handbook MT-18).
