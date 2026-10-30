import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/navigation/pillar.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/batch_status.dart';
import 'studio_state.dart';
import 'studio_view_model.dart';
import 'widgets/add_photos_panel.dart';
import 'widgets/analysis_scope_sheet.dart';
import 'widgets/review_panel.dart';

/// Add pillar host: 1a/2a tray, 3a scope sheet, analysis progress, 4a review.
/// After a completed save it switches to the Archive pillar.
///
/// Copy follows spec T7 › G3/G4 (1a, 2a, 3a, 4a). Test contract:
/// thumbnails have the tooltip "Remove photo"; the 3a panel has the key
/// `ValueKey('analysis-scope-sheet')`; a failed save shows
/// "Couldn't index your Pieces." with "Try again" (derived from G4).
class StudioView extends ConsumerWidget {
  const StudioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studioViewModelProvider);
    final vm = ref.read(studioViewModelProvider.notifier);

    ref.listen<StudioState>(studioViewModelProvider, (previous, next) {
      final justCompleted = next.batchStatus == BatchStatus.completed &&
          previous?.batchStatus != BatchStatus.completed;
      if (!justCompleted) return;
      // Land on the Archive with the new Pieces, and get Add ready for the
      // next batch (AC-03.8).
      ref.read(pillarProvider.notifier).select(Pillar.wardrobe);
      Future.microtask(vm.startNewBatch);
    });

    final Widget body = switch (state.batchStatus) {
      BatchStatus.draft || BatchStatus.sanitizing => Stack(
          children: [
            AddPhotosPanel(
              state: state,
              onPick: vm.pickPhotos,
              onRemove: vm.removePhoto,
              onConsentChanged: vm.setConsent,
              onAnalyze: vm.analyze,
            ),
            if (state.isScopeSheetOpen) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: vm.reselectPhotos,
                  child: const ColoredBox(color: Color(0x52000000)),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnalysisScopeSheet(
                  key: const ValueKey('analysis-scope-sheet'),
                  state: state,
                  onToggle: vm.toggleTask,
                  onReselect: vm.reselectPhotos,
                  onConfirm: vm.confirmScope,
                ),
              ),
            ],
          ],
        ),
      BatchStatus.queuedForAi || BatchStatus.aiProcessing => LoadingView(
          message: state.tray.count == 1
              ? 'Reading 1 photo…'
              : 'Reading ${state.tray.count} photos…',
        ),
      BatchStatus.failed => _AnalysisFailed(
          message: state.errorMessage ?? StudioViewModel.analysisFailedMessage,
          onRetry: vm.retryAnalysis,
          onReselect: vm.reselectPhotos,
        ),
      BatchStatus.awaitingReview ||
      BatchStatus.completed =>
        state.review == null
            ? const LoadingView()
            : ReviewPanel(
                state: state,
                today: ref.read(clockProvider).now(),
                onExpand: vm.expandItem,
                onTypeChanged: (i, code) => vm.editItem(i, typeCode: code),
                onTextChanged: (i, field, value) => switch (field) {
                  ReviewTextField.color => vm.editItem(i, color: value),
                  ReviewTextField.material => vm.editItem(i, material: value),
                  ReviewTextField.style => vm.editItem(i, styleTag: value),
                },
                onLastWornChanged: vm.setLastWorn,
                onSave: vm.save,
                onStartOver: vm.startNewBatch,
              ),
      BatchStatus.deletedByUser => const SizedBox.shrink(),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!Breakpoints.isDesktop(constraints.maxWidth)) return body;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: body,
          ),
        );
      },
    );
  }
}

class _AnalysisFailed extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onReselect;

  const _AnalysisFailed({
    required this.message,
    required this.onRetry,
    required this.onReselect,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Try again', onPressed: onRetry),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onReselect,
              child: const Text('Reselect photos'),
            ),
          ],
        ),
      ),
    );
  }
}
