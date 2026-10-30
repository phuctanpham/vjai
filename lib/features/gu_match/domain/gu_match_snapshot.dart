import 'package:flutter/foundation.dart';

import 'gu_match_session.dart';
import 'outfit_candidate.dart';

/// The latest Gu Match session with its Fits and their decisions, as
/// persisted, so the deck resumes after a restart (TASK-005-S03).
@immutable
class GuMatchSnapshot {
  final GuMatchSession session;

  /// In deck order, with their current `swipeStatus`.
  final List<OutfitCandidate> candidates;

  const GuMatchSnapshot({required this.session, required this.candidates});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuMatchSnapshot &&
          session == other.session &&
          listEquals(candidates, other.candidates);

  @override
  int get hashCode => Object.hash(session, Object.hashAll(candidates));
}
