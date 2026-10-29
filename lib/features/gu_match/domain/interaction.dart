import 'package:flutter/foundation.dart';

/// Actions on the 3b rail (spec `card_action`).
enum CardAction {
  dismissPass,
  likeSave,
  customizeEdit,
  triggerVton,
}

/// One logged action on a candidate, with viewing time.
@immutable
class Interaction {
  final String candidateId;
  final CardAction action;
  final int dwellMs;

  /// Set for [CardAction.customizeEdit]: the swapped-out and swapped-in items.
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
  bool operator ==(Object other) => throw UnimplementedError('TASK-004-S05');

  @override
  int get hashCode => throw UnimplementedError('TASK-004-S05');
}
