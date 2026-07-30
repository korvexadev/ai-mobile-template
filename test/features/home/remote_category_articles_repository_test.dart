import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/core/networking/mikozi_api_client.dart';
import 'package:mikozi_mobile/features/home/data/remote_category_articles_repository.dart';

void main() {
  test('maps the backend-owned category article page', () async {
    final adapter = _CategoryAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://reader.test/api/v1'))
      ..httpClientAdapter = adapter;
    final repository = RemoteCategoryArticlesRepository(MikoziApiClient(dio));

    final result = await repository.fetch(categorySlug: 'national', limit: 30);

    expect(adapter.options?.path, '/reader/categories/national/articles');
    expect(adapter.options?.queryParameters, {'limit': 30, 'offset': 0});
    expect(result.category.name, 'National');
    expect(result.items.single.slug, 'published-story');
    expect(result.total, 7);
  });
}

class _CategoryAdapter implements HttpClientAdapter {
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
          'category': {
            'id': 'national',
            'name': 'National',
            'slug': 'national',
          },
          'items': [
            {
              'id': 'article-1',
              'slug': 'published-story',
              'title': 'Published story',
              'summary': 'Summary',
              'heroImageUrl': null,
              'publishedAt': '2030-01-01T12:00:00.000Z',
              'category': {
                'id': 'national',
                'name': 'National',
                'slug': 'national',
              },
            },
          ],
          'total': 7,
          'limit': 30,
          'offset': 0,
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
