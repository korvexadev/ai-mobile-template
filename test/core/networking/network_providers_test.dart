import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/core/constants/api_constants.dart';
import 'package:mikozi_mobile/core/networking/network_providers.dart';

void main() {
  test('every shared REST client uses the constants base URL', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      ApiConstants.baseUrl,
      'https://breach-vegas-cinema-endorsed.trycloudflare.com/api/v1',
    );
    expect(container.read(dioProvider).options.baseUrl, ApiConstants.baseUrl);
  });
}
