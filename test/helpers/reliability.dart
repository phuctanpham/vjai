import 'dart:io';

import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';
import 'package:garblo/features/wardrobe/domain/wear_event.dart';

/// Runs [body] with every socket and HTTP client refused, like airplane
/// mode, and returns how many connections the code attempted (TASK-009-S01).
Future<int> withoutNetwork(Future<void> Function() body) async {
  var attempts = 0;
  Never refuse() {
    attempts++;
    throw const SocketException('Network disabled by the test');
  }

  await HttpOverrides.runZoned(
    () => IOOverrides.runZoned(
      body,
      socketConnect: (host, port, {sourceAddress, sourcePort = 0, timeout}) =>
          refuse(),
      socketStartConnect: (host, port, {sourceAddress, sourcePort = 0}) =>
          refuse(),
    ),
    createHttpClient: (_) => refuse(),
  );
  return attempts;
}

/// A [WardrobeRepository] whose next [failLoads] reads throw a
/// `StorageFailure`, then delegate to [inner] (TASK-009-S08).
class FlakyWardrobeRepository implements WardrobeRepository {
  final WardrobeRepository inner;
  int failLoads;

  FlakyWardrobeRepository(this.inner, {this.failLoads = 0});

  Future<void> _maybeFail() async {
    if (failLoads <= 0) return;
    failLoads--;
    throw const StorageFailure('Could not load your Archive.');
  }

  @override
  Future<WardrobePage> getItems({ItemGroup? group, String? cursor}) async {
    await _maybeFail();
    return inner.getItems(group: group, cursor: cursor);
  }

  @override
  Future<int> countEligible() async {
    await _maybeFail();
    return inner.countEligible();
  }

  @override
  Future<List<WardrobeItem>> getEligibleItems() async {
    await _maybeFail();
    return inner.getEligibleItems();
  }

  @override
  Future<void> saveItems(List<WardrobeItem> items) => inner.saveItems(items);
}

/// A [WearRepository] whose next [failWrites] wear logs throw a
/// `StorageFailure`, then delegate to [inner] (TASK-009-S08).
class FlakyWearRepository implements WearRepository {
  final WearRepository inner;
  int failWrites;

  FlakyWearRepository(this.inner, {this.failWrites = 0});

  @override
  Future<bool> logWear(WearEvent event) async {
    if (failWrites > 0) {
      failWrites--;
      throw const StorageFailure('Could not log the wear.');
    }
    return inner.logWear(event);
  }

  @override
  Future<Map<String, DateTime>> lastWornByItem() => inner.lastWornByItem();

  @override
  Future<Map<String, int>> wearCountByItem() => inner.wearCountByItem();

  @override
  Future<List<WearEvent>> getEvents() => inner.getEvents();
}
