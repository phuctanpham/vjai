import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/pillar.dart';
import '../../features/gu_match/presentation/gu_match_view.dart';
import '../../features/studio/presentation/studio_view.dart';
import '../../features/wardrobe/presentation/wardrobe_view.dart';
import 'coming_soon_view.dart';

/// Builds the page shown for each pillar. Override it in tests to keep
/// shell tests independent of feature screens.
final pillarPagesProvider = Provider<Map<Pillar, WidgetBuilder>>((ref) {
  return {
    Pillar.add: (_) => const StudioView(),
    Pillar.wardrobe: (_) => const WardrobeView(),
    Pillar.guMatch: (_) => const GuMatchView(),
    Pillar.impact: (_) =>
        const ComingSoonView(message: 'Your impact report is coming soon'),
    Pillar.community: (_) => const ComingSoonView(message: 'Coming soon'),
  };
});
