import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/gu_match/domain/occasion.dart';
import 'package:garblo/features/gu_match/domain/session_path.dart';
import 'package:garblo/features/gu_match/domain/styling_context.dart';

void main() {
  group('StylingContext', () {
    test('[TASK-004-S02] no chip and no text is the zero-input path (C1)', () {
      expect(const StylingContext().path, SessionPath.zeroInput);
      expect(
          const StylingContext().withPrompt('   ').path, SessionPath.zeroInput);
    });

    test('[TASK-004-S02] any chip or any text is the prompt-led path (C1)', () {
      expect(const StylingContext().toggle(Occasion.coffee).path,
          SessionPath.promptLed);
      expect(const StylingContext().withPrompt('coffee with friends').path,
          SessionPath.promptLed);
    });

    test('[TASK-004-S02] chips are multi-select and toggle off (C10)', () {
      final both = const StylingContext()
          .toggle(Occasion.coffee)
          .toggle(Occasion.afternoonRain);
      expect(both.occasions, {Occasion.coffee, Occasion.afternoonRain});

      final one = both.toggle(Occasion.coffee);
      expect(one.occasions, {Occasion.afternoonRain});
    });

    test('[TASK-004-S02] all five occasions can be selected, never more', () {
      var context = const StylingContext();
      for (final occasion in Occasion.values) {
        context = context.toggle(occasion);
      }

      expect(context.occasions, hasLength(StylingContext.maxOccasions));
    });

    test('[TASK-004-S02] the prompt stops at 280 characters', () {
      final long = 'a' * 300;

      final context = const StylingContext().withPrompt(long);

      expect(context.prompt, hasLength(StylingContext.maxPromptLength));
      expect(
          const StylingContext().withPrompt('a' * 280).prompt, hasLength(280));
    });

    test('labels', () {
      expect(Occasion.values.map((o) => o.label).toList(),
          ['Work', 'Coffee', 'Afternoon rain', 'Date', 'Weekend outing']);
    });

    test('value equality and hashCode follow occasions and prompt', () {
      final a = const StylingContext()
          .toggle(Occasion.work)
          .toggle(Occasion.date)
          .withPrompt('pitch');
      final b = const StylingContext()
          .toggle(Occasion.date)
          .toggle(Occasion.work)
          .withPrompt('pitch');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == b.withPrompt('other'), isFalse);
    });
  });
}
