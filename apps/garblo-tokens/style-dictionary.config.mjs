// Optional Style Dictionary v5 build (npm i -D style-dictionary).
// Run: node style-dictionary.config.mjs
// Outputs one flat Dart class per theme × mode using the built-in
// `flutter` transform group and `flutter/class.dart` format.
// Note: alpha values in $extensions (HUD glass, scrims) are applied only by
// scripts/gen_dart.py; this flat build emits the opaque base colours.
import StyleDictionary from 'style-dictionary';

const cap = (s) => s[0].toUpperCase() + s.slice(1);
for (const theme of ['warm', 'cold', 'neutral']) {
  for (const mode of ['light', 'dark']) {
    const sd = new StyleDictionary({
      source: ['tokens/core/**/*.json', `tokens/themes/${theme}-${mode}.json`],
      platforms: {
        flutter: {
          transformGroup: 'flutter',
          buildPath: 'build/sd/',
          files: [{
            destination: `garblo_${theme}_${mode}.dart`,
            format: 'flutter/class.dart',
            options: { className: `Garblo${cap(theme)}${cap(mode)}` },
            // keep semantic tokens; raw ladders under `color.*` stay internal
            filter: (token) => token.path[0] !== 'color',
          }],
        },
      },
    });
    await sd.buildAllPlatforms();
  }
}
