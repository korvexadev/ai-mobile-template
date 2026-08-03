import 'reader_article.dart';

abstract interface class ReaderArticleRepository {
  Future<ReaderArticle> readBySlug(String slug);
}

class ReaderArticleFailure implements Exception {
  const ReaderArticleFailure({
    required this.code,
    required this.message,
    this.preview,
  });

  final String code;
  final String message;
  final ReaderArticlePreview? preview;

  @override
  String toString() => message;
}

class ReaderArticlePreview {
  const ReaderArticlePreview({
    required this.slug,
    required this.title,
    required this.summary,
    required this.heroImageUrl,
    required this.categoryName,
  });

  final String slug;
  final String title;
  final String summary;
  final String? heroImageUrl;
  final String categoryName;
}
