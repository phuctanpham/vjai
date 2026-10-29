import 'package:flutter/foundation.dart';

import 'occasion.dart';
import 'session_path.dart';

/// The context the user gives on the styling studio (1b).
@immutable
class StylingContext {
  static const int maxPromptLength = 280;
  static const int maxOccasions = 5;

  final Set<Occasion> occasions;
  final String prompt;

  const StylingContext({this.occasions = const {}, this.prompt = ''});

  /// [SessionPath.promptLed] with any chip or non-blank text, else zero-input.
  SessionPath get path => throw UnimplementedError('TASK-004-S02');

  /// Selects or unselects [occasion].
  StylingContext toggle(Occasion occasion) =>
      throw UnimplementedError('TASK-004-S02');

  /// Sets the prompt, cut to [maxPromptLength] characters.
  StylingContext withPrompt(String prompt) =>
      throw UnimplementedError('TASK-004-S02');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-004-S02');

  @override
  int get hashCode => throw UnimplementedError('TASK-004-S02');
}
