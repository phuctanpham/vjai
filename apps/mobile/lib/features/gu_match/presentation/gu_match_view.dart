import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/navigation/pillar.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import 'gu_match_state.dart';
import 'gu_match_view_model.dart';
import 'widgets/context_analysis_panel.dart';
import 'widgets/outfit_deck_panel.dart';
import 'widgets/styling_studio_panel.dart';

/// Gu Match pillar host: 1b styling studio, 2b context analysis, 3b deck.
/// Gu Match drafts Fits (outfits) from the user's own Pieces; "match %" is
/// how well a Fit suits the day.
///
/// Copy follows spec T7 › G3 (1b, 2b, 3b) and G4: never "Like", no "I", no
/// emoji. Test contract: rail buttons have the tooltips "Pass",
/// "Add to Rotation", "Adjust", "Try on"; the try-on sheet reads
/// "Try-on is coming soon"; the wear prompt reads "Wearing this today?" with
/// "Wear today" and "Save for later"; the end of deck reads
/// "You added {n} Fits to Rotation" ("1 Fit") with "Change context" and
/// "Go to Archive" (derived from G4).
class GuMatchView extends ConsumerStatefulWidget {
  const GuMatchView({super.key});

  @override
  ConsumerState<GuMatchView> createState() => _GuMatchViewState();
}

class _GuMatchViewState extends ConsumerState<GuMatchView> {
  @override
  void initState() {
    super.initState();
    // The ViewModel outlives the page, so refresh the ready count each time
    // the pillar is shown: it must equal the Archive total (I9).
    Future.microtask(() {
      if (!mounted) return;
      final state = ref.read(guMatchViewModelProvider);
      if (state.phase == GuMatchPhase.studio && !state.isBusy) {
        ref.read(guMatchViewModelProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guMatchViewModelProvider);
    final vm = ref.read(guMatchViewModelProvider.notifier);
    void goTo(Pillar pillar) =>
        ref.read(pillarProvider.notifier).select(pillar);

    final Widget body = switch (state.phase) {
      GuMatchPhase.studio => switch (state.status) {
          GuMatchStatus.initial ||
          GuMatchStatus.loading when state.readyCount == 0 =>
            const LoadingView(),
          GuMatchStatus.error => ErrorView(
              message: state.errorMessage ?? 'Could not read your Archive.',
              onRetry: vm.retry,
            ),
          _ => StylingStudioPanel(
              state: state,
              onToggleOccasion: vm.toggleOccasion,
              onPromptChanged: vm.setPrompt,
              onStart: vm.startSwiping,
              onIndexPieces: () => goTo(Pillar.add),
            ),
        },
      GuMatchPhase.analyzingContext => ContextAnalysisPanel(state: state),
      GuMatchPhase.deck => OutfitDeckPanel(
          state: state,
          onPass: vm.pass,
          onAddToRotation: vm.like,
          onAdjust: vm.openAdjust,
          onTryOn: vm.tryOn,
          onChangeContext: vm.changeContext,
          onWearToday: vm.confirmWearing,
          onSaveForLater: vm.saveForLater,
          onDismissTryOn: vm.dismissTryOn,
          onChooseSlot: vm.chooseSwapSlot,
          onSwap: vm.swap,
          onCloseAdjust: vm.closeAdjust,
        ),
      GuMatchPhase.endOfDeck => _DeckSummary(
          title: state.likedCount == 1
              ? 'You added 1 Fit to Rotation'
              : 'You added ${state.likedCount} Fits to Rotation',
          hint: state.deckHint,
          onChangeContext: vm.changeContext,
          secondaryLabel: 'Go to Archive',
          onSecondary: () => goTo(Pillar.wardrobe),
        ),
      GuMatchPhase.noFits => _DeckSummary(
          title: 'No Fits to draft yet',
          hint: state.deckHint,
          onChangeContext: vm.changeContext,
          secondaryLabel: 'Index Pieces',
          onSecondary: () => goTo(Pillar.add),
        ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!Breakpoints.isDesktop(constraints.maxWidth)) return body;
        // T7 › G1: deck media and content stay at most 560 wide.
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

class _DeckSummary extends StatelessWidget {
  final String title;
  final String? hint;
  final VoidCallback onChangeContext;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const _DeckSummary({
    required this.title,
    required this.hint,
    required this.onChangeContext,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (hint != null) ...[
              const SizedBox(height: 8),
              Text(
                hint!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(label: 'Change context', onPressed: onChangeContext),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
