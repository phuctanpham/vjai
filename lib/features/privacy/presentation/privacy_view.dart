import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnimplementedError('TASK-008-S01');
  }
}
