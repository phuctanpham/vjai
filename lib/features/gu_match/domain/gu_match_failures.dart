import '../../../core/errors/failures.dart';

/// A session cannot start because the wardrobe has no usable items
/// (spec 409 `NO_ELIGIBLE_ITEMS`).
class NoEligibleItemsFailure extends Failure {
  const NoEligibleItemsFailure([
    super.message = 'Index Pieces into your Archive first.',
    super.cause,
  ]);
}
