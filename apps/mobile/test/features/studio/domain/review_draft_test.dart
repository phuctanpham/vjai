import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/studio/domain/extracted_item.dart';
import 'package:garblo/features/studio/domain/review_draft.dart';

ExtractedItem _item(String id) => ExtractedItem(
      draftId: id,
      assetId: 'asset_$id',
      slotIndex: 1,
      itemIndex: 1,
      name: 'Item $id',
      confidence: 0.9,
      ai: const ItemAttributes(
        typeCode: 'SHIRT',
        color: 'Violet',
        material: 'Cotton',
        styleTag: 'Street',
      ),
      value: const ItemAttributes(
        typeCode: 'SHIRT',
        color: 'Violet',
        material: 'Cotton',
        styleTag: 'Street',
      ),
    );

void main() {
  group('ReviewDraft', () {
    test('[TASK-003-S11] every photo read with items is a success', () {
      final draft = ReviewDraft(
        photoCount: 3,
        failedPhotoCount: 0,
        items: [_item('1'), _item('2'), _item('3')],
      );

      expect(draft.outcome, AnalysisOutcome.success);
      expect(draft.bannerText, 'FROM 3 PHOTOS · 3 PIECES');
      expect(draft.failureNote, isNull);
    });

    test('[TASK-003-S11] some unreadable photos give a partial result', () {
      final draft = ReviewDraft(
        photoCount: 3,
        failedPhotoCount: 1,
        items: [_item('1'), _item('2')],
      );

      expect(draft.outcome, AnalysisOutcome.partial);
      expect(draft.failureNote, "1 photo couldn't be read");
      expect(
        ReviewDraft(photoCount: 3, failedPhotoCount: 2, items: [_item('1')])
            .failureNote,
        "2 photos couldn't be read",
      );
    });

    test('[TASK-003-S11] no readable photo means all failed', () {
      const draft = ReviewDraft(photoCount: 2, failedPhotoCount: 2, items: []);

      expect(draft.outcome, AnalysisOutcome.allFailed);
    });

    test('[TASK-003-S11] readable photos with no clothes give zero items', () {
      const draft = ReviewDraft(photoCount: 2, failedPhotoCount: 0, items: []);

      expect(draft.outcome, AnalysisOutcome.zeroItems);
    });

    test('[TASK-003-S11] banner uses singular forms (C2)', () {
      final one =
          ReviewDraft(photoCount: 1, failedPhotoCount: 0, items: [_item('1')]);
      final outfit = ReviewDraft(
        photoCount: 1,
        failedPhotoCount: 0,
        items: [_item('1'), _item('2'), _item('3')],
      );

      expect(one.bannerText, 'FROM 1 PHOTO · 1 PIECE');
      expect(outfit.bannerText, 'FROM 1 PHOTO · 3 PIECES');
    });

    test('replaceItem swaps one item and keeps the rest', () {
      final draft = ReviewDraft(
        photoCount: 2,
        failedPhotoCount: 0,
        items: [_item('1'), _item('2')],
      );
      final edited = draft.items[1].edit(color: 'Black');

      final updated = draft.replaceItem(1, edited);

      expect(updated.items[0], draft.items[0]);
      expect(updated.items[1].value.color, 'Black');
      expect(draft.items[1].value.color, 'Violet');
    });
  });
}
