import 'saved_article.dart';

abstract interface class SavedArticlesRepository {
  Future<List<SavedArticle>> readAll();

  Future<void> setSaved(SavedArticle article, {required bool saved});
}
