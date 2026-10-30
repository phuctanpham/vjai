#!/usr/bin/env python3
"""Generate build/flutter/lib/garblo_tokens.dart from tokens/core/color.json, size.json and layout.json.
Run from the package root:  python3 scripts/gen_dart.py"""
import json, os
P='.'
core=json.load(open('tokens/core/color.json'))['color']
th={}
for t in ('warm','cold','neutral'):
    for m in ('light','dark'):
        th[f'{t}-{m}']={r:v['$value'] for r,v in core[t][m].items()}
acc={m:{r:v['$value'] for r,v in core['accent'][m].items()} for m in ('light','dark')}
alpha={'light':{'hud':0.86,'scrim':0.10,'overlay':0.32},'dark':{'hud':0.88,'scrim':0.24,'overlay':0.48}}
# ---------- Dart ----------
def dc(h,a=1.0): return '0x%02X%s'%(round(a*255),h[1:].upper())
fields=[('surfaceCanvas','canvas'),('surfaceCard','card'),('surfaceWell','well'),('surfaceDivider','divider'),('inkPrimary','ink-primary'),('inkEditorial','ink-editorial'),('inkMuted','ink-muted'),('ruleStructural','rule-structural'),('ruleProduct','rule-product')]
afields=[('accentPrimary','primary'),('accentPrimaryPressed','primary-pressed'),('onPrimary','on-primary'),('accentAgenticBg','agentic-bg'),('accentAgenticText','agentic-text'),('accentSynthesisAi','synthesis-ai'),('accentSocialPulse','social-pulse'),('statusCpwOptimal','cpw-optimal'),('statusCpwDormant','cpw-dormant'),('statusCpwDormantText','cpw-dormant-text')]
extra=['hudGlass','imageScrim','overlayScrim']
allf=[f for f,_ in fields]+extra+[f for f,_ in afields]
L=[]
L.append("// GENERATED from garblo-tokens (gen_tokens.py). Do not edit by hand.\n// Garblo design tokens v0.2 (DS-CR-01) · handbook Ch.4-Ch.7, Ch.18 · Flutter ThemeExtension.\nimport 'dart:ui' show lerpDouble;\nimport 'package:flutter/animation.dart';\nimport 'package:flutter/painting.dart';\nimport 'package:flutter/physics.dart';\nimport 'package:flutter/material.dart' show ThemeExtension;\n")
L.append("enum GarbloTheme { warm, cold, neutral }\n")
L.append("@immutable\nclass GarbloColors extends ThemeExtension<GarbloColors> {\n  const GarbloColors({\n"+''.join(f"    required this.{f},\n" for f in allf)+"  });\n")
L.append(''.join(f"  final Color {f};\n" for f in allf))
for k,p in th.items():
    t,m=k.split('-'); name=f"{t}{m.capitalize()}"
    al=alpha[m]
    vals=[(f,dc(p[r])) for f,r in fields]+[('hudGlass',dc(p['canvas'],al['hud'])),('imageScrim',dc('#000000',al['scrim'])),('overlayScrim',dc('#000000',al['overlay']))]+[(f,dc(acc[m][r])) for f,r in afields]
    L.append(f"\n  static const {name} = GarbloColors(\n"+''.join(f"    {f}: Color({v}),\n" for f,v in vals)+"  );\n")
L.append("\n  static GarbloColors of(GarbloTheme theme, Brightness brightness) {\n    final dark = brightness == Brightness.dark;\n    switch (theme) {\n      case GarbloTheme.warm:\n        return dark ? warmDark : warmLight;\n      case GarbloTheme.cold:\n        return dark ? coldDark : coldLight;\n      case GarbloTheme.neutral:\n        return dark ? neutralDark : neutralLight;\n    }\n  }\n")
L.append("\n  @override\n  GarbloColors copyWith({\n"+''.join(f"    Color? {f},\n" for f in allf)+"  }) {\n    return GarbloColors(\n"+''.join(f"      {f}: {f} ?? this.{f},\n" for f in allf)+"    );\n  }\n")
L.append("\n  @override\n  GarbloColors lerp(ThemeExtension<GarbloColors>? other, double t) {\n    if (other is! GarbloColors) return this;\n    return GarbloColors(\n"+''.join(f"      {f}: Color.lerp({f}, other.{f}, t)!,\n" for f in allf)+"    );\n  }\n}\n")
L.append("\nabstract final class GarbloSpace {\n"+''.join(f"  static const double s{i} = {v}.0;\n" for i,v in enumerate([0,4,8,12,16,24,32,48,64,96]))+"}\n")
L.append("\nabstract final class GarbloRadius {\n  static const double media = 1.0;\n  static const double key = 3.0;\n  static const double control = 8.0;\n  static const double hud = 12.0;\n  static const double pill = 9999.0;\n}\n")
size=json.load(open('tokens/core/size.json'))['size']; lay=json.load(open('tokens/core/layout.json'))['layout']
def camel(k): 
    a=k.split('-'); return a[0]+''.join(x.capitalize() for x in a[1:])
sz=[]
for k,v in size.items():
    if k=='icon':
        for kk,vv in v.items(): sz.append((camel('icon-'+kk),vv['$value'],vv.get('$description')))
    else: sz.append((camel(k),v['$value'],v.get('$description')))
L.append("\n/// Component sizes (D48, DS-12).\nabstract final class GarbloSize {\n"+''.join(f"  static const double {n} = {float(v)};{(' // '+d) if d else ''}\n" for n,v,d in sz)
 +"  @Deprecated('Use target') static const double touchMin = target;\n  @Deprecated('Use nav (64, was 56)') static const double navHeight = nav;\n}\n")
g=lay['grid']
L.append("\n/// One grid class: columns, side margin and gutter.\n@immutable\nclass GarbloGrid {\n  const GarbloGrid(this.columns, this.margin, this.gutter);\n  final int columns;\n  final double margin;\n  final double gutter;\n}\n")
L.append("\n/// Grid, breakpoints, phone spans and safe-area reference (DS-11, DS-14).\n/// Read real insets from MediaQuery.paddingOf(context); the frame values are mock-up references.\nabstract final class GarbloLayout {\n"
 +f"  static const double breakpointMedium = {float(lay['breakpoint']['medium']['$value'])};\n  static const double breakpointExpanded = {float(lay['breakpoint']['expanded']['$value'])}; // workbench, post-pilot (D44)\n"
 +''.join(f"  static const GarbloGrid {k} = GarbloGrid({v['columns']['$value']}, {float(v['margin']['$value'])}, {float(v['gutter']['$value'])});\n" for k,v in g.items())
 +''.join(f"  static const double span{k.capitalize()} = {float(v['$value'])};\n" for k,v in lay['span'].items())
 +f"  static const double frameWidth = {float(lay['frame']['width']['$value'])};\n  static const double frameHeight = {float(lay['frame']['height']['$value'])};\n  static const double insetTopRef = {float(lay['frame']['inset-top']['$value'])};\n  static const double insetBottomRef = {float(lay['frame']['inset-bottom']['$value'])};\n  static const double offsetFloating = {float(lay['offset-floating']['$value'])};\n"
 +"\n  static GarbloGrid gridFor(double width) => width < breakpointMedium ? compact : (width < breakpointExpanded ? medium : expanded);\n}\n")
L.append("""
/// Type styles. letterSpacing is converted from em to logical px.
/// Flutter has no text-transform: uppercase system strings in code, never user text (Ch.5).
abstract final class GarbloType {
  static const String display = 'Newsreader';
  static const String sans = 'Inter';
  static const String mono = 'JetBrains Mono';

  static TextStyle _s(String family, FontWeight w, double size, double height, double trackingEm,
          {List<FontFeature> features = const []}) =>
      TextStyle(fontFamily: family, fontWeight: w, fontSize: size, height: height,
          letterSpacing: trackingEm * size, fontFeatures: features);

  static TextStyle displayHero({bool desktop = false}) => _s(display, FontWeight.w400, desktop ? 100 : 52, 1.10, -0.0375);
  static TextStyle displayLookbook({bool desktop = false}) => _s(display, FontWeight.w400, desktop ? 48 : 32, 1.15, -0.025);
  static TextStyle headingSection({bool desktop = false}) => _s(sans, FontWeight.w500, desktop ? 24 : 20, 1.25, -0.015);
  static TextStyle chromeNav({bool desktop = false}) => _s(sans, FontWeight.w400, desktop ? 13 : 12, 1.00, 0.08);
  static TextStyle bodyEditorial({bool desktop = false}) => _s(sans, FontWeight.w400, desktop ? 16 : 15, 1.50, 0);
  static TextStyle productCell({bool desktop = false}) => _s(sans, FontWeight.w500, desktop ? 14 : 13, 1.35, 0.01);
  static TextStyle monoTelemetry({bool desktop = false}) => _s(mono, FontWeight.w500, desktop ? 13 : 12, 1.30, -0.01,
      features: const [FontFeature.tabularFigures(), FontFeature('zero')]);
  static TextStyle monoBadge({bool desktop = false}) => _s(mono, FontWeight.w400, 11, 1.30, 0.04);
  /// Big KPI numbers (DS-08). Digits and units only.
  static TextStyle monoFigure({bool desktop = false}) => _s(mono, FontWeight.w500, desktop ? 32 : 28, 1.10, -0.02,
      features: const [FontFeature.tabularFigures(), FontFeature('zero')]);
  /// 48 pt buttons and the FAB (D40, DS-09). System labels only.
  static TextStyle labelButton({bool desktop = false}) => _s(sans, FontWeight.w500, 15, 1.20, 0);
  /// Bottom-nav labels, uppercase (D51). Wrap the nav in MediaQuery.withNoTextScaling and
  /// show the large label on long-press (Large Content Viewer / tooltip) above 100% text size.
  static TextStyle labelNav() => _s(sans, FontWeight.w500, 10, 1.00, 0.04);
}

abstract final class GarbloMotion {
  static const SpringDescription gesture = SpringDescription(mass: 1, stiffness: 1472.7, damping: 61.4);
  static const SpringDescription keyboard = SpringDescription(mass: 1, stiffness: 1752.7, damping: 83.7);
  static const SpringDescription nodePickup = SpringDescription(mass: 0.8, stiffness: 300, damping: 22);
  static const SpringDescription sheet = SpringDescription(mass: 1, stiffness: 300, damping: 28);
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150); // every reduced-motion fade
  static const Duration base = Duration(milliseconds: 220); // keyboard spring settles here
  static const Duration gestureSettle = Duration(milliseconds: 300); // gesture spring settles here
  static const Duration pulse = Duration(milliseconds: 1200); // static when motion is reduced
  static const Duration toast = Duration(seconds: 6);
  static const Curve easeOut = Cubic(0.2, 0, 0, 1);
  static const Curve easeInOut = Cubic(0.4, 0, 0.2, 1);
  static const Curve easeExit = Cubic(0.4, 0, 1, 1);
  static const double commitRatio = 0.35;
  static const double commitVelocity = 500; // px/s
  static const double tiltMaxDegrees = 12;
  static const int slowPassMs = 3500;
}

abstract final class GarbloShadow {
  static const List<Shadow> cutoutRestingLight = [
    Shadow(offset: Offset(0, 2), blurRadius: 3, color: Color(0x2E000000)),
    Shadow(offset: Offset(0, 8), blurRadius: 16, color: Color(0x14000000)),
  ];
  static const List<Shadow> cutoutRestingDark = [
    Shadow(offset: Offset(0, 2), blurRadius: 3, color: Color(0xA6000000)),
    Shadow(offset: Offset(0, 8), blurRadius: 16, color: Color(0x73000000)),
  ];
  static const List<Shadow> cutoutLifted = [
    Shadow(offset: Offset(0, 12), blurRadius: 24, color: Color(0x38000000)),
  ];
  static const List<BoxShadow> sheet = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x1F000000)),
  ];
}
""")
code='\n'.join(L).replace("import 'dart:ui' show lerpDouble;\n","")
code=code.replace("import 'package:flutter/material.dart' show ThemeExtension;","import 'package:flutter/material.dart' show ThemeExtension, Brightness;\nimport 'package:flutter/foundation.dart' show immutable;")
os.makedirs(f'{P}/build/flutter/lib',exist_ok=True)
open(f'{P}/build/flutter/lib/garblo_tokens.dart','w').write(code)
print(len(code.splitlines()),'dart lines')
