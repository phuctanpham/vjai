import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/privacy_repository.dart';
import 'privacy_state.dart';

final privacyViewModelProvider =
    StateNotifierProvider.autoDispose<PrivacyViewModel, PrivacyState>((ref) {
  throw UnimplementedError('TASK-008-S02');
});

/// ViewModel for Privacy & data. Every deletion needs a confirmation step on
/// the page and a second tap (AC-09.2).
class PrivacyViewModel extends StateNotifier<PrivacyState> {
  PrivacyViewModel({
    required PrivacyRepository repository,
    required void Function() onDataDeleted,
  }) : super(PrivacyState.initial());

  /// Loads the counts shown in the confirmation steps.
  Future<void> load() => throw UnimplementedError('TASK-008-S02');

  void askWithdraw() => throw UnimplementedError('TASK-008-S02');

  void askDeleteAll() => throw UnimplementedError('TASK-008-S02');

  void cancel() => throw UnimplementedError('TASK-008-S02');

  /// The second, explicit tap. Ignored outside a confirmation step or while
  /// working. After delete all, calls `onDataDeleted` (TASK-008-S05).
  Future<void> confirm() => throw UnimplementedError('TASK-008-S02');
}
