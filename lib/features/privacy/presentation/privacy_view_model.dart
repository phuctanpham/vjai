import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/erasure_counts.dart';
import '../data/privacy_repository.dart';
import 'privacy_state.dart';

final privacyViewModelProvider =
    StateNotifierProvider.autoDispose<PrivacyViewModel, PrivacyState>((ref) {
  return PrivacyViewModel(
    repository: ref.watch(privacyRepositoryProvider),
    onDataDeleted: ref.watch(dataResetProvider),
  )..load();
});

/// ViewModel for Privacy & data. Every deletion needs a confirmation step on
/// the page and a second tap (AC-09.2).
class PrivacyViewModel extends StateNotifier<PrivacyState> {
  final PrivacyRepository _repository;
  final void Function() _onDataDeleted;

  PrivacyViewModel({
    required PrivacyRepository repository,
    required void Function() onDataDeleted,
  })  : _repository = repository,
        _onDataDeleted = onDataDeleted,
        super(PrivacyState.initial());

  /// Loads the counts shown in the confirmation steps.
  Future<void> load() async {
    state = state.copyWith(status: PrivacyStatus.loading, clearError: true);
    try {
      final counts = await _repository.counts();
      if (!mounted) return;
      state = state.copyWith(status: PrivacyStatus.loaded, counts: counts);
    } on Failure catch (failure) {
      if (!mounted) return;
      state = state.copyWith(
          status: PrivacyStatus.error, errorMessage: failure.message);
    }
  }

  void askWithdraw() => _ask(PrivacyStep.confirmWithdraw);

  void askDeleteAll() => _ask(PrivacyStep.confirmDeleteAll);

  void cancel() {
    if (!state.isConfirming) return;
    state = state.copyWith(step: PrivacyStep.overview);
  }

  /// The second, explicit tap. Ignored outside a confirmation step or while
  /// working. After delete all, calls `onDataDeleted` (TASK-008-S05).
  Future<void> confirm() async {
    final step = state.step;
    if (!state.isConfirming) return;
    state = state.copyWith(step: PrivacyStep.working, clearError: true);
    try {
      if (step == PrivacyStep.confirmWithdraw) {
        await _repository.withdrawBodyConsent();
        final counts = await _repository.counts();
        if (!mounted) return;
        state = state.copyWith(step: PrivacyStep.withdrawn, counts: counts);
      } else {
        await _repository.deleteAll();
        if (mounted) {
          state = state.copyWith(
              step: PrivacyStep.deleted, counts: ErasureCounts.none);
        }
        // The data is gone either way: restart on the fresh store.
        _onDataDeleted();
      }
    } on Failure catch (failure) {
      if (!mounted) return;
      state = state.copyWith(
          step: PrivacyStep.overview, errorMessage: failure.message);
    }
  }

  void _ask(PrivacyStep step) {
    if (state.step == PrivacyStep.working) return;
    state = state.copyWith(step: step, clearError: true);
  }
}
