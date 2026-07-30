import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/core/networking/mikozi_api_client.dart';
import 'package:mikozi_mobile/features/home/data/remote_homepage_repository.dart';
import 'package:mikozi_mobile/features/home/domain/homepage.dart';

void main() {
  test('maps all configurable homepage section types', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        'data': {
          'version': 4,
          'topNavigation': [
            {
              'id': 'category-1',
              'name': 'National',
              'slug': 'national',
              'sections': [
                _section('banner'),
                _section('list'),
                _section('horizontal_list'),
                _section('advert'),
                {
                  ..._section('categories'),
                  'categories': [
                    {'id': 'category-2', 'name': 'Sport', 'slug': 'sport'},
                  ],
                },
              ],
            },
          ],
          'moreNavigation': <Object?>[],
        },
      });
    final result = await RemoteHomepageRepository(MikoziApiClient(dio)).fetch();

    expect(result.version, 4);
    expect(result.topNavigation.single.sections.map((item) => item.type), [
      HomeSectionType.banner,
      HomeSectionType.list,
      HomeSectionType.horizontalList,
      HomeSectionType.advert,
      HomeSectionType.categories,
    ]);
  });

  test('maps publication time used by homepage story metadata', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        'data': {
          'version': 1,
          'topNavigation': [
            {
              'id': 'category-1',
              'name': 'National',
              'slug': 'national',
              'sections': [
                {
                  ..._section('banner'),
                  'articles': [
                    {
                      'id': 'article-1',
                      'slug': 'lead-story',
                      'title': 'Lead story',
                      'summary': 'Summary',
                      'heroImageUrl': null,
                      'publishedAt': '2030-01-01T12:00:00.000Z',
                      'category': {
                        'id': 'category-1',
                        'name': 'National',
                        'slug': 'national',
                      },
                    },
                  ],
                },
              ],
            },
          ],
          'moreNavigation': <Object?>[],
        },
      });

    final result = await RemoteHomepageRepository(MikoziApiClient(dio)).fetch();

    expect(
      result.topNavigation.single.sections.single.articles.single.publishedAt,
      DateTime.utc(2030, 1, 1, 12),
    );
  });
}

Map<String, dynamic> _section(String type) => {
  'id': 'section-$type',
  'title': 'Section',
  'type': type,
  'advertPlacementCode': type == 'advert' ? 'home.inline' : null,
  'articles': <Object?>[],
  'categories': <Object?>[],
};

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);
  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      _encode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  String _encode(Map<String, dynamic> value) {
    return '{"data":${_json(value['data'])}}';
  }

  String _json(Object? value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num || value is bool) return '$value';
    if (value is List) return '[${value.map(_json).join(',')}]';
    final map = value as Map<String, dynamic>;
    return '{${map.entries.map((entry) => '"${entry.key}":${_json(entry.value)}').join(',')}}';
  }

  @override
  void close({bool force = false}) {}
}
