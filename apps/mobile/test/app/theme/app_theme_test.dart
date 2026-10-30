import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/app/theme/app_theme.dart';

/// Spec T7 › G0 token bridge, warm light and warm dark.
void main() {
  test('[TASK-002-S09] light primary is forest green with white text', () {
    final scheme = AppTheme.lightTheme.colorScheme;

    expect(scheme.primary, const Color(0xFF1F5A2E));
    expect(scheme.onPrimary, const Color(0xFFFFFFFF));
  });

  test('[TASK-002-S09] dark primary is light forest green with black text', () {
    final scheme = AppTheme.darkTheme.colorScheme;

    expect(scheme.primary, const Color(0xFF7BC88A));
    expect(scheme.onPrimary, const Color(0xFF000000));
  });
}
