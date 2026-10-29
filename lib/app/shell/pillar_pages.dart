import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/pillar.dart';

/// Builds the page shown for each pillar. Override it in tests to keep
/// shell tests independent of feature screens.
final pillarPagesProvider = Provider<Map<Pillar, WidgetBuilder>>((ref) {
  throw UnimplementedError('TASK-002-S07');
});
