import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/core/networking/mikozi_api_client.dart';
import 'package:mikozi_mobile/features/profile/data/remote_reader_entitlement_repository.dart';

void main() {
  test('maps the authenticated reader entitlement contract', () async {
    final adapter = _EntitlementAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://reader.test/api/v1'))
      ..httpClientAdapter = adapter;
    final repository = RemoteReaderEntitlementRepository(
      MikoziApiClient(dio),
      () async => 'reader-token',
    );

    final entitlement = await repository.fetch();

    expect(adapter.options?.path, '/subscriptions/me');
    expect(adapter.options?.headers['Authorization'], 'Bearer reader-token');
    expect(entitlement.planName, 'Reader Plus');
    expect(entitlement.dailyArticleLimit, 10);
    expect(entitlement.articlesReadToday, 4);
    expect(entitlement.articlesRemainingToday, 6);
    expect(entitlement.isUnlimited, isFalse);
    expect(entitlement.resetsAt, DateTime.utc(2030, 1, 2));
  });
}

class _EntitlementAdapter implements HttpClientAdapter {
  RequestOptions? options;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    return ResponseBody.fromString(
      jsonEncode({
        'data': {
          'plan': {'name': 'Reader Plus', 'dailyArticleLimit': 10},
          'articlesReadToday': 4,
          'articlesRemainingToday': 6,
          'resetsAt': '2030-01-02T00:00:00.000Z',
          'endsAt': null,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
