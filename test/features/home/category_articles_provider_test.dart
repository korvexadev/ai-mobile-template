import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/home/application/category_articles_provider.dart';
import 'package:mikozi_mobile/features/home/domain/category_articles.dart';
import 'package:mikozi_mobile/features/home/domain/homepage.dart';

void main() {
  test(
    'load more exposes progress and appends the authoritative page',
    () async {
      final repository = _PagedCategoryRepository();
      final container = ProviderContainer(
        overrides: [
          categoryArticlesRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final provider = categoryArticlesControllerProvider('national');

      final initial = await container.read(provider.future);
      expect(initial.items.map((article) => article.id), ['article-1']);

      final loading = container.read(provider.notifier).loadMore();
      expect(container.read(provider).value?.isLoadingMore, isTrue);
      expect(repository.offsets, [0, 1]);

      repository.completeSecondPage();
      await loading;

      final completed = container.read(provider).requireValue;
      expect(completed.items.map((article) => article.id), [
        'article-1',
        'article-2',
      ]);
      expect(completed.isLoadingMore, isFalse);
      expect(completed.hasMore, isFalse);
    },
  );

  test('load more failure keeps content and allows recovery', () async {
    final repository = _PagedCategoryRepository(failFirstMore: true);
    final container = ProviderContainer(
      overrides: [
        categoryArticlesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final provider = categoryArticlesControllerProvider('national');
    await container.read(provider.future);

    await container.read(provider.notifier).loadMore();

    final failed = container.read(provider).requireValue;
    expect(failed.items.map((article) => article.id), ['article-1']);
    expect(failed.loadMoreFailed, isTrue);

    final retry = container.read(provider.notifier).loadMore();
    repository.completeSecondPage();
    await retry;

    expect(container.read(provider).requireValue.loadMoreFailed, isFalse);
    expect(container.read(provider).requireValue.items, hasLength(2));
  });
}

class _PagedCategoryRepository implements CategoryArticlesRepository {
  _PagedCategoryRepository({this.failFirstMore = false});

  final Completer<CategoryArticles> _secondPage = Completer<CategoryArticles>();
  final List<int> offsets = [];
  final bool failFirstMore;
  bool _moreFailed = false;

  @override
  Future<CategoryArticles> fetch({
    required String categorySlug,
    int limit = 30,
    int offset = 0,
  }) {
    offsets.add(offset);
    if (offset == 0) {
      return Future.value(_page(offset: 0, articleId: 'article-1'));
    }
    if (failFirstMore && !_moreFailed) {
      _moreFailed = true;
      return Future.error(Exception('Offline'));
    }
    return _secondPage.future;
  }

  void completeSecondPage() {
    _secondPage.complete(_page(offset: 1, articleId: 'article-2'));
  }
}

CategoryArticles _page({required int offset, required String articleId}) {
  const category = HomeCategory(
    id: 'national',
    name: 'National',
    slug: 'national',
  );
  return CategoryArticles(
    category: category,
    items: [
      HomeArticle(
        id: articleId,
        slug: articleId,
        title: articleId,
        summary: 'Summary',
        heroImageUrl: null,
        publishedAt: null,
        category: category,
      ),
    ],
    total: 2,
    limit: 1,
    offset: offset,
  );
}
