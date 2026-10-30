import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/erasure_counts.dart';
import 'privacy_state.dart';
import 'privacy_view_model.dart';

/// Privacy & data (UC-09; entry Avatar › Privacy & data, T7 › G3 1a).
///
/// Test contract (copy derived from G4, CHG-005):
/// - Title "Privacy & data".
/// - "Withdraw body-photo consent" with "Removes body photos and try-on
///   images. Your Pieces stay."
/// - "Delete all my photos and wardrobe data" with "Removes every photo,
///   Piece, wear log and Gu Match history on this phone."
/// - Delete all confirmation on the page (no dialog): "This deletes
///   {n} photos, {n} Pieces, {n} try-on images" (singular "1 photo",
///   "1 Piece", "1 try-on image") with "Delete everything" and "Cancel".
/// - Withdraw confirmation: "This deletes {n} body photos and {n} try-on
///   images. Your {n} Pieces stay." with "Withdraw consent" and "Cancel";
///   afterwards "Body-photo consent withdrawn".
class PrivacyView extends ConsumerWidget {
  /// Same content width on both layouts; wider screens centre it.
  static const double _maxWidth = 640;

  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(privacyViewModelProvider);
    final vm = ref.read(privacyViewModelProvider.notifier);
    final working = state.step == PrivacyStep.working;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & data')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.step == PrivacyStep.withdrawn)
                const _Notice(text: 'Body-photo consent withdrawn'),
              if (state.errorMessage != null)
                _Notice(text: state.errorMessage!, isError: true),
              _ActionTile(
                title: 'Withdraw body-photo consent',
                subtitle:
                    'Removes body photos and try-on images. Your Pieces stay.',
                onTap: working ? null : vm.askWithdraw,
              ),
              if (state.step == PrivacyStep.confirmWithdraw)
                _Confirmation(
                  message: _withdrawMessage(state.counts),
                  confirmLabel: 'Withdraw consent',
                  onConfirm: vm.confirm,
                  onCancel: vm.cancel,
                ),
              const Divider(height: 32),
              _ActionTile(
                title: 'Delete all my photos and wardrobe data',
                subtitle: 'Removes every photo, Piece, wear log and Gu Match '
                    'history on this phone.',
                destructive: true,
                onTap: working ? null : vm.askDeleteAll,
              ),
              if (state.step == PrivacyStep.confirmDeleteAll)
                _Confirmation(
                  message: _deleteAllMessage(state.counts),
                  confirmLabel: 'Delete everything',
                  destructive: true,
                  onConfirm: vm.confirm,
                  onCancel: vm.cancel,
                ),
              if (working)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _count(int n, String one, String many) =>
      n == 1 ? '1 $one' : '$n $many';

  static String _deleteAllMessage(ErasureCounts c) => 'This deletes '
      '${_count(c.photos, 'photo', 'photos')}, '
      '${_count(c.pieces, 'Piece', 'Pieces')}, '
      '${_count(c.tryOnImages, 'try-on image', 'try-on images')}';

  static String _withdrawMessage(ErasureCounts c) => 'This deletes '
      '${_count(c.bodyPhotos, 'body photo', 'body photos')} and '
      '${_count(c.tryOnImages, 'try-on image', 'try-on images')}. '
      '${c.pieces == 1 ? 'Your 1 Piece stays.' : 'Your ${c.pieces} Pieces stay.'}';
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool destructive;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// The on-page confirmation with the counts (no dialog, AC-09.2).
class _Confirmation extends StatelessWidget {
  final String message;
  final String confirmLabel;
  final bool destructive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _Confirmation({
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton(
                  style: destructive
                      ? FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError)
                      : null,
                  onPressed: onConfirm,
                  child: Text(confirmLabel),
                ),
                OutlinedButton(
                    onPressed: onCancel, child: const Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  final bool isError;

  const _Notice({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(color: isError ? scheme.error : scheme.primary),
      ),
    );
  }
}
