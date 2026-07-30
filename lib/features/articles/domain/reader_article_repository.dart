import 'reader_article.dart';

abstract interface class ReaderArticleRepository {
  Future<ReaderArticle> readBySlug(String slug);
}

class ReaderArticleFailure implements Exception {
  const ReaderArticleFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => message;
}
