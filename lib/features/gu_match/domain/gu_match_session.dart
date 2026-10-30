import 'package:flutter/foundation.dart';

import 'occasion.dart';
import 'session_path.dart';
import 'styling_context.dart';

/// One styling session; it deals one deck of Fits.
@immutable
class GuMatchSession {
  final String sessionId;
  final SessionPath path;
  final Set<Occasion> occasions;
  final String prompt;
  final int eligibleItemCount;

  /// Always true: Fits use only the user's own Pieces (I6).
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

  /// The context this session was started with.
  StylingContext get context =>
      StylingContext(occasions: occasions, prompt: prompt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuMatchSession &&
          sessionId == other.sessionId &&
          path == other.path &&
          setEquals(occasions, other.occasions) &&
          prompt == other.prompt &&
          eligibleItemCount == other.eligibleItemCount &&
          ownedOnly == other.ownedOnly &&
          deckSize == other.deckSize;

  @override
  int get hashCode => Object.hash(
      sessionId,
      path,
      Object.hashAllUnordered(occasions),
      prompt,
      eligibleItemCount,
      ownedOnly,
      deckSize);
}
