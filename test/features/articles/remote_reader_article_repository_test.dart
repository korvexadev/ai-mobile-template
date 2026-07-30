import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/core/networking/mikozi_api_client.dart';
import 'package:mikozi_mobile/features/articles/data/remote_reader_article_repository.dart';
import 'package:mikozi_mobile/features/articles/domain/reader_article.dart';

void main() {
  test(
    'fetches by slug with auth and preserves backend section order',
    () async {
      final adapter = _ArticleAdapter(_articleEnvelope);
      final dio = Dio(BaseOptions(baseUrl: 'https://reader.test/api/v1'))
        ..httpClientAdapter = adapter;
      final repository = RemoteReaderArticleRepository(
        MikoziApiClient(dio),
        () async => 'reader-token',
      );

      final article = await repository.readBySlug('configured-story');

      expect(adapter.options?.path, '/reader/articles/slug/configured-story');
      expect(adapter.options?.headers['Authorization'], 'Bearer reader-token');
      expect(adapter.options?.headers['Cache-Control'], 'no-cache');
      expect(article.slug, 'configured-story');
      expect(article.category.name, 'National');
      expect(article.author.displayName, 'Mikozi Desk');
      expect(article.sections.map((section) => section.type), [
        ReaderArticleSectionType.richText,
        ReaderArticleSectionType.image,
        ReaderArticleSectionType.youtube,
        ReaderArticleSectionType.advert,
      ]);
      expect(article.sections.map((section) => section.position), [0, 1, 2, 3]);
      expect(article.similarArticles.single.slug, 'related-story');
      expect(article.similarArticles.single.similarityScore, 0.72);
    },
  );

  test('requires a reader session before the request', () async {
    final adapter = _ArticleAdapter(_articleEnvelope);
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = RemoteReaderArticleRepository(
      MikoziApiClient(dio),
      () async => null,
    );

    await expectLater(
      repository.readBySlug('configured-story'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          'Sign in to read this article.',
        ),
      ),
    );
    expect(adapter.options, isNull);
  });
}

const _articleEnvelope = {
  'data': {
    'id': 'article-1',
    'slug': 'configured-story',
    'title': 'Configured story',
    'summary': 'A concise article summary.',
    'category': {'id': 'national', 'name': 'National', 'slug': 'national'},
    'heroImageUrl': 'https://images.test/hero.jpg',
    'publishedAt': '2030-01-01T12:00:00.000Z',
    'author': {'id': 'author-1', 'displayName': 'Mikozi Desk'},
    'sections': [
      {
        'id': 'rich',
        'position': 0,
        'type': 'rich_text',
        'body': 'Opening body.',
        'mediaUrl': null,
        'caption': null,
        'altText': null,
        'youtubeVideoId': null,
        'advertPlacementCode': null,
      },
      {
        'id': 'image',
        'position': 1,
        'type': 'image',
        'body': null,
        'mediaUrl': 'https://images.test/inline.jpg',
        'caption': 'Inline caption',
        'altText': 'A newsroom photograph',
        'youtubeVideoId': null,
        'advertPlacementCode': null,
      },
      {
        'id': 'video',
        'position': 2,
        'type': 'youtube',
        'body': null,
        'mediaUrl': null,
        'caption': 'Video report',
        'altText': null,
        'youtubeVideoId': 'dQw4w9WgXcQ',
        'advertPlacementCode': null,
      },
      {
        'id': 'advert',
        'position': 3,
        'type': 'advert',
        'body': null,
        'mediaUrl': null,
        'caption': null,
        'altText': null,
        'youtubeVideoId': null,
        'advertPlacementCode': 'article.inline',
      },
    ],
    'similarArticles': [
      {
        'id': 'article-2',
        'slug': 'related-story',
        'title': 'Related story',
        'summary': 'Related summary',
        'heroImageUrl': null,
        'publishedAt': '2030-01-01T11:00:00.000Z',
        'category': {'id': 'national', 'name': 'National', 'slug': 'national'},
        'similarityScore': 0.72,
      },
    ],
  },
};

class _ArticleAdapter implements HttpClientAdapter {
  _ArticleAdapter(this.body);

  final Map<String, dynamic> body;
  RequestOptions? options;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
