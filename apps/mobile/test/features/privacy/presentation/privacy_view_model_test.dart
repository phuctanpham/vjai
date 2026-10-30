import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/privacy/presentation/privacy_state.dart';
import 'package:garblo/features/privacy/presentation/privacy_view_model.dart';

import '../../../helpers/privacy_fakes.dart';

void main() {
  late FakePrivacyRepository repo;
  late int resets;

  PrivacyViewModel vm() => PrivacyViewModel(
        repository: repo,
        onDataDeleted: () => resets++,
      );

  setUp(() {
    repo = FakePrivacyRepository();
    resets = 0;
  });

  test('[TASK-008-S02] starts on the overview and loads the counts', () async {
    final model = vm();
    expect(model.state.step, PrivacyStep.overview);
    expect(model.state.status, PrivacyStatus.initial);

    await model.load();

    expect(model.state.status, PrivacyStatus.loaded);
    expect(model.state.counts, sampleCounts);
  });

  test('[TASK-008-S02] a counts failure is an error state', () async {
    repo = FakePrivacyRepository(failCounts: true);
    final model = vm();

    await model.load();

    expect(model.state.status, PrivacyStatus.error);
    expect(model.state.errorMessage, isNotNull);
  });

  test('[TASK-008-S02] choosing delete all only asks for confirmation',
      () async {
    final model = vm();
    await model.load();

    model.askDeleteAll();

    expect(model.state.step, PrivacyStep.confirmDeleteAll);
    expect(repo.deleteCalls, 0);
    expect(resets, 0);
  });

  test('[TASK-008-S02] cancel returns to the overview without deleting',
      () async {
    final model = vm();
    await model.load();
    model.askDeleteAll();

    model.cancel();

    expect(model.state.step, PrivacyStep.overview);
    expect(repo.deleteCalls, 0);
  });

  test('[TASK-008-S02] confirm outside a confirmation step does nothing',
      () async {
    final model = vm();
    await model.load();

    await model.confirm();

    expect(repo.deleteCalls, 0);
    expect(repo.withdrawCalls, 0);
    expect(model.state.step, PrivacyStep.overview);
  });

  test('[TASK-008-S05] the second tap deletes all and restarts the app fresh',
      () async {
    final model = vm();
    await model.load();
    model.askDeleteAll();

    await model.confirm();

    expect(repo.deleteCalls, 1);
    expect(model.state.step, PrivacyStep.deleted);
    expect(resets, 1);
  });

  test('[TASK-008-S02] a double tap deletes once', () async {
    repo = FakePrivacyRepository(hold: Completer<void>());
    final model = vm();
    await model.load();
    model.askDeleteAll();

    final first = model.confirm();
    expect(model.state.step, PrivacyStep.working);
    final second = model.confirm();
    repo.hold!.complete();
    await Future.wait([first, second]);

    expect(repo.deleteCalls, 1);
    expect(resets, 1);
  });

  test('[TASK-008-S05] a failed delete shows an error and does not restart',
      () async {
    repo = FakePrivacyRepository(failDelete: true);
    final model = vm();
    await model.load();
    model.askDeleteAll();

    await model.confirm();

    expect(model.state.errorMessage, isNotNull);
    expect(model.state.step, PrivacyStep.overview);
    expect(resets, 0);
  });

  test('[TASK-008-S02] withdrawing needs the second tap and keeps the app',
      () async {
    final model = vm();
    await model.load();

    model.askWithdraw();
    expect(model.state.step, PrivacyStep.confirmWithdraw);
    expect(repo.withdrawCalls, 0);

    await model.confirm();

    expect(repo.withdrawCalls, 1);
    expect(model.state.step, PrivacyStep.withdrawn);
    expect(model.state.counts.bodyPhotos, 0);
    expect(resets, 0);
  });
}
