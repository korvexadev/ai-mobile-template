import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/persistence/preferences_provider.dart';
import '../data/preferences_saved_articles_repository.dart';
import '../domain/reader_article.dart';
import '../domain/saved_article.dart';
import '../domain/saved_articles_repository.dart';

part 'saved_articles_controller.g.dart';

@Riverpod(keepAlive: true)
SavedArticlesRepository savedArticlesRepository(Ref ref) {
  return PreferencesSavedArticlesRepository(
    ref.watch(sharedPreferencesProvider),
  );
}

@Riverpod(keepAlive: true)
class SavedArticlesController extends _$SavedArticlesController {
  @override
  Future<List<SavedArticle>> build() {
    return ref.watch(savedArticlesRepositoryProvider).readAll();
  }

  Future<bool> setSaved(ReaderArticle article, {required bool saved}) async {
    final current = state.value;
    if (current == null) {
      return false;
    }
    final isCurrentlySaved = current.any((item) => item.slug == article.slug);
    if (isCurrentlySaved == saved) {
      return true;
    }
    final savedArticle = SavedArticle.fromReaderArticle(article);
    try {
      await ref
          .read(savedArticlesRepositoryProvider)
          .setSaved(savedArticle, saved: saved);
      final updated = current.toList()
        ..removeWhere((item) => item.slug == article.slug);
      if (saved) {
        updated.insert(0, savedArticle);
      }
      state = AsyncData(List.unmodifiable(updated));
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> refreshSnapshot(ReaderArticle article) async {
    final current =
        state.value ??
        await ref.read(savedArticlesRepositoryProvider).readAll();
    final index = current.indexWhere((item) => item.slug == article.slug);
    if (index < 0) {
      return;
    }
    final existing = current[index];
    final refreshed = SavedArticle.fromReaderArticle(
      article,
      savedAt: existing.savedAt,
    );
    if (existing.hasSameContent(refreshed)) {
      return;
    }
    await ref
        .read(savedArticlesRepositoryProvider)
        .setSaved(refreshed, saved: true);
    final updated = current.toList()..[index] = refreshed;
    updated.sort((left, right) => right.savedAt.compareTo(left.savedAt));
    state = AsyncData(List.unmodifiable(updated));
  }
}

@riverpod
Future<List<SavedArticle>> savedReaderArticles(Ref ref) {
  return ref.watch(savedArticlesControllerProvider.future);
}
