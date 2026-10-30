import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/storage_providers.dart';
import 'package:garblo/features/privacy/data/privacy_repository.dart';
import 'package:garblo/features/privacy/domain/erasure_counts.dart';
import 'package:garblo/features/privacy/presentation/privacy_view.dart';

import '../../../helpers/layout.dart';
import '../../../helpers/privacy_fakes.dart';

const _withdraw = 'Withdraw body-photo consent';
const _deleteAll = 'Delete all my photos and wardrobe data';

void main() {
  late FakePrivacyRepository repo;
  late int resets;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        privacyRepositoryProvider.overrideWithValue(repo),
        dataResetProvider.overrideWithValue(() => resets++),
      ],
      child: const MaterialApp(home: PrivacyView()),
    ));
    await tester.pumpAndSettle();
  }

  setUp(() {
    repo = FakePrivacyRepository();
    resets = 0;
  });

  testBothLayouts('[TASK-008-S01] lists both actions with what they remove',
      (tester) async {
    await pump(tester);

    expect(find.text('Privacy & data'), findsOneWidget);
    expect(find.text(_withdraw), findsOneWidget);
    expect(
        find.text('Removes body photos and try-on images. Your Pieces stay.'),
        findsOneWidget);
    expect(find.text(_deleteAll), findsOneWidget);
    expect(
        find.text(
            'Removes every photo, Piece, wear log and Gu Match history on this phone.'),
        findsOneWidget);
  });

  testBothLayouts(
      '[TASK-008-S02] delete all asks on the page with counts, then deletes',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text(_deleteAll));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('This deletes 12 photos, 9 Pieces, 0 try-on images'),
        findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(repo.deleteCalls, 0);

    await tester.tap(find.text('Delete everything'));
    await tester.pumpAndSettle();

    expect(repo.deleteCalls, 1);
    expect(resets, 1);
  });

  testBothLayouts('[TASK-008-S02] cancel deletes nothing', (tester) async {
    await pump(tester);

    await tester.tap(find.text(_deleteAll));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete everything'), findsNothing);
    expect(repo.deleteCalls, 0);
    expect(resets, 0);
  });

  testWidgets('[TASK-008-S02] singular counts read "1 photo, 1 Piece"',
      (tester) async {
    useMobileLayout(tester);
    repo = FakePrivacyRepository(
        current: const ErasureCounts(
            photos: 1, pieces: 1, bodyPhotos: 1, tryOnImages: 1));
    await pump(tester);

    await tester.tap(find.text(_deleteAll));
    await tester.pumpAndSettle();

    expect(find.text('This deletes 1 photo, 1 Piece, 1 try-on image'),
        findsOneWidget);
  });

  testBothLayouts('[TASK-008-S02] withdrawing asks first, then confirms',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text(_withdraw));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(
        find.text(
            'This deletes 2 body photos and 0 try-on images. Your 9 Pieces stay.'),
        findsOneWidget);
    expect(repo.withdrawCalls, 0);

    await tester.tap(find.text('Withdraw consent'));
    await tester.pumpAndSettle();

    expect(repo.withdrawCalls, 1);
    expect(find.text('Body-photo consent withdrawn'), findsOneWidget);
    expect(resets, 0);
  });
}
