import 'package:flutter/foundation.dart';

/// Actions on the 3b rail (spec `card_action`). `likeSave` is the
/// "Add to Rotation" button: the user keeps a Fit, not a person.
enum CardAction {
  dismissPass,
  likeSave,
  customizeEdit,
  triggerVton,
}

/// One logged action on a Fit, with viewing time.
@immutable
class Interaction {
  final String candidateId;
  final CardAction action;
  final int dwellMs;

  /// Set for [CardAction.customizeEdit]: the swapped-out and swapped-in Pieces.
  final String? fromItemId;
  final String? toItemId;

  const Interaction({
    required this.candidateId,
    required this.action,
    required this.dwellMs,
    this.fromItemId,
    this.toItemId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Interaction &&
          candidateId == other.candidateId &&
          action == other.action &&
          dwellMs == other.dwellMs &&
          fromItemId == other.fromItemId &&
          toItemId == other.toItemId;

  @override
  int get hashCode =>
      Object.hash(candidateId, action, dwellMs, fromItemId, toItemId);
}
