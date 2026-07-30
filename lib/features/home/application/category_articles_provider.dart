import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/networking/mikozi_api_client.dart';
import '../../../core/networking/network_providers.dart';
import '../data/remote_category_articles_repository.dart';
import '../domain/category_articles.dart';

part 'category_articles_provider.g.dart';

@Riverpod(keepAlive: true)
CategoryArticlesRepository categoryArticlesRepository(Ref ref) {
  return RemoteCategoryArticlesRepository(
    MikoziApiClient(ref.watch(dioProvider)),
  );
}

@riverpod
class CategoryArticlesController extends _$CategoryArticlesController {
  static const _pageSize = 20;

  @override
  Future<CategoryArticlesState> build(String categorySlug) async {
    final page = await ref
        .watch(categoryArticlesRepositoryProvider)
        .fetch(categorySlug: categorySlug, limit: _pageSize);
    return CategoryArticlesState.fromPage(page);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final page = await ref
          .read(categoryArticlesRepositoryProvider)
          .fetch(categorySlug: categorySlug, limit: _pageSize);
      return CategoryArticlesState.fromPage(page);
    });
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }
    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );
    try {
      final page = await ref
          .read(categoryArticlesRepositoryProvider)
          .fetch(
            categorySlug: categorySlug,
            limit: _pageSize,
            offset: current.items.length,
          );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          isLoadingMore: false,
          loadMoreFailed: false,
        ),
      );
    } on Object {
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }
}
