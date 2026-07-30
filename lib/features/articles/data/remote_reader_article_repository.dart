import 'package:dio/dio.dart';

import '../../../core/networking/mikozi_api_client.dart';
import '../domain/reader_article.dart';
import '../domain/reader_article_repository.dart';

class RemoteReaderArticleRepository implements ReaderArticleRepository {
  RemoteReaderArticleRepository(this._api, this._accessToken);

  final MikoziApiClient _api;
  final Future<String?> Function() _accessToken;

  @override
  Future<ReaderArticle> readBySlug(String slug) async {
    final token = await _accessToken();
    if (token == null) {
      throw const ReaderArticleFailure(
        code: 'AUTH_REQUIRED',
        message: 'Sign in to read this article.',
      );
    }

    try {
      return _mapArticle(
        await _api.getReaderArticle(slug: slug, accessToken: token),
      );
    } on DioException catch (error) {
      throw _failure(error);
    } on FormatException {
      throw const ReaderArticleFailure(
        code: 'INVALID_RESPONSE',
        message: 'Mikozi returned an unexpected article.',
      );
    } on TypeError {
      throw const ReaderArticleFailure(
        code: 'INVALID_RESPONSE',
        message: 'Mikozi returned an unexpected article.',
      );
    }
  }

  ReaderArticle _mapArticle(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>;
    final author = json['author'] as Map<String, dynamic>;
    final sections = json['sections'] as List<dynamic>;
    return ReaderArticle(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      category: ReaderArticleCategory(
        id: category['id'] as String,
        name: category['name'] as String,
        slug: category['slug'] as String,
      ),
      heroImageUrl: json['heroImageUrl'] as String?,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      author: ReaderArticleAuthor(
        id: author['id'] as String,
        displayName: author['displayName'] as String?,
      ),
      sections: sections
          .map((value) => _mapSection(value as Map<String, dynamic>))
          .toList(growable: false),
      similarArticles: (json['similarArticles'] as List<dynamic>? ?? const [])
          .map((value) => _mapSimilarArticle(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  ReaderSimilarArticle _mapSimilarArticle(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>;
    return ReaderSimilarArticle(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      heroImageUrl: json['heroImageUrl'] as String?,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      category: ReaderArticleCategory(
        id: category['id'] as String,
        name: category['name'] as String,
        slug: category['slug'] as String,
      ),
      similarityScore: (json['similarityScore'] as num).toDouble(),
    );
  }

  ReaderArticleSection _mapSection(Map<String, dynamic> json) {
    return ReaderArticleSection(
      id: json['id'] as String,
      position: json['position'] as int,
      type: switch (json['type']) {
        'rich_text' => ReaderArticleSectionType.richText,
        'image' => ReaderArticleSectionType.image,
        'youtube' => ReaderArticleSectionType.youtube,
        'advert' => ReaderArticleSectionType.advert,
        _ => ReaderArticleSectionType.unsupported,
      },
      body: json['body'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      caption: json['caption'] as String?,
      altText: json['altText'] as String?,
      youtubeVideoId: json['youtubeVideoId'] as String?,
      advertPlacementCode: json['advertPlacementCode'] as String?,
    );
  }

  ReaderArticleFailure _failure(DioException exception) {
    final responseData = exception.response?.data;
    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        final code = error['code'];
        final message = error['message'];
        if (code is String && message is String) {
          return ReaderArticleFailure(code: code, message: message);
        }
      }
    }
    return const ReaderArticleFailure(
      code: 'NETWORK_UNAVAILABLE',
      message: 'The article could not be loaded. Try again.',
    );
  }
}
