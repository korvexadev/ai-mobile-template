import 'homepage.dart';

class CategoryArticles {
  const CategoryArticles({
    required this.category,
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  final HomeCategory category;
  final List<HomeArticle> items;
  final int total;
  final int limit;
  final int offset;
}

class CategoryArticlesState {
  const CategoryArticlesState({
    required this.category,
    required this.items,
    required this.total,
    required this.isLoadingMore,
    required this.loadMoreFailed,
  });

  factory CategoryArticlesState.fromPage(CategoryArticles page) {
    return CategoryArticlesState(
      category: page.category,
      items: page.items,
      total: page.total,
      isLoadingMore: false,
      loadMoreFailed: false,
    );
  }

  final HomeCategory category;
  final List<HomeArticle> items;
  final int total;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  bool get hasMore => items.length < total;

  CategoryArticlesState copyWith({
    List<HomeArticle>? items,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return CategoryArticlesState(
      category: category,
      items: items ?? this.items,
      total: total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

abstract interface class CategoryArticlesRepository {
  Future<CategoryArticles> fetch({
    required String categorySlug,
    int limit = 30,
    int offset = 0,
  });
}
