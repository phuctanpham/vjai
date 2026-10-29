import 'package:flutter/foundation.dart';

import 'occasion.dart';
import 'session_path.dart';

/// One styling session; it deals one deck.
@immutable
class GuMatchSession {
  final String sessionId;
  final SessionPath path;
  final Set<Occasion> occasions;
  final String prompt;
  final int eligibleItemCount;

  /// Always true: looks use only the user's own items (I6).
  final bool ownedOnly;
  final int deckSize;

  const GuMatchSession({
    required this.sessionId,
    required this.path,
    required this.occasions,
    required this.prompt,
    required this.eligibleItemCount,
    this.ownedOnly = true,
    this.deckSize = 8,
  });

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-004-S02');

  @override
  int get hashCode => throw UnimplementedError('TASK-004-S02');
}
