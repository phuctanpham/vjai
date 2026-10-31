import 'package:flutter_test/flutter_test.dart';

import 'package:garblo/core/networking/api_config.dart';

void main() {
  test('uses the deployed Worker as the default public API', () {
    expect(ApiConfig.baseUrl, 'https://api.phamtanph.uk');
  });
}
