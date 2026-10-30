import 'package:flutter/foundation.dart';

import 'occasion.dart';
import 'session_path.dart';

/// The context the user gives on the styling studio (1b): what the day
/// holds, so Garblo can draft Fits from the user's own Pieces.
@immutable
class StylingContext {
  static const int maxPromptLength = 280;
  static const int maxOccasions = 5;

  final Set<Occasion> occasions;
  final String prompt;

  const StylingContext({this.occasions = const {}, this.prompt = ''});

  /// [SessionPath.promptLed] with any chip or non-blank text, else zero-input.
  SessionPath get path => occasions.isNotEmpty || prompt.trim().isNotEmpty
      ? SessionPath.promptLed
      : SessionPath.zeroInput;

  /// Selects or unselects [occasion].
  StylingContext toggle(Occasion occasion) {
    if (occasions.contains(occasion)) {
      return StylingContext(
        occasions: {...occasions}..remove(occasion),
        prompt: prompt,
      );
    }
    if (occasions.length >= maxOccasions) return this;
    return StylingContext(occasions: {...occasions, occasion}, prompt: prompt);
  }

  /// Sets the prompt, cut to [maxPromptLength] characters.
  StylingContext withPrompt(String prompt) => StylingContext(
        occasions: occasions,
        prompt: prompt.length > maxPromptLength
            ? prompt.substring(0, maxPromptLength)
            : prompt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StylingContext &&
          setEquals(occasions, other.occasions) &&
          prompt == other.prompt;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(occasions), prompt);
}
