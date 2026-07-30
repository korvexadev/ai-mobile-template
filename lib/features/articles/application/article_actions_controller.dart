import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/media/reader_image_cache.dart';
import '../data/cached_article_share_service.dart';
import '../domain/article_share_service.dart';
import '../domain/reader_article.dart';
import 'saved_articles_controller.dart';

part 'article_actions_controller.g.dart';

class ArticleActionsState {
  const ArticleActionsState({
    required this.isSaved,
    this.isSaving = false,
    this.isSharing = false,
  });

  final bool isSaved;
  final bool isSaving;
  final bool isSharing;

  ArticleActionsState copyWith({
    bool? isSaved,
    bool? isSaving,
    bool? isSharing,
  }) {
    return ArticleActionsState(
      isSaved: isSaved ?? this.isSaved,
      isSaving: isSaving ?? this.isSaving,
      isSharing: isSharing ?? this.isSharing,
    );
  }
}

@Riverpod(keepAlive: true)
ArticleShareService articleShareService(Ref ref) {
  return CachedArticleShareService(
    imageLookup: CacheManagerImageLookup(ref.watch(readerImageCacheProvider)),
  );
}

@riverpod
class ArticleActionsController extends _$ArticleActionsController {
  @override
  Future<ArticleActionsState> build(String slug) async {
    try {
      final saved = await ref.watch(savedArticlesControllerProvider.future);
      return ArticleActionsState(
        isSaved: saved.any((article) => article.slug == slug),
      );
    } on Object {
      return const ArticleActionsState(isSaved: false);
    }
  }

  Future<bool> toggleSaved(ReaderArticle article) async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return false;
    }
    final nextSaved = !current.isSaved;
    state = AsyncData(current.copyWith(isSaving: true));
    try {
      final saved = await ref
          .read(savedArticlesControllerProvider.notifier)
          .setSaved(article, saved: nextSaved);
      if (!saved) {
        state = AsyncData(current.copyWith(isSaving: false));
        return false;
      }
      state = AsyncData(current.copyWith(isSaved: nextSaved, isSaving: false));
      return true;
    } on Object {
      state = AsyncData(current.copyWith(isSaving: false));
      return false;
    }
  }

  Future<bool> share(ReaderArticle article, ArticleShareAnchor anchor) async {
    final current = state.value;
    if (current == null || current.isSharing) {
      return false;
    }
    state = AsyncData(current.copyWith(isSharing: true));
    try {
      await ref
          .read(articleShareServiceProvider)
          .share(
            ArticleShareRequest(
              title: article.title,
              summary: article.summary,
              imageUrl: article.heroImageUrl,
              anchor: anchor,
            ),
          );
      state = AsyncData(current.copyWith(isSharing: false));
      return true;
    } on Object {
      state = AsyncData(current.copyWith(isSharing: false));
      return false;
    }
  }
}
