import '../../../core/networking/mikozi_api_client.dart';
import '../domain/category_articles.dart';
import '../domain/homepage.dart';

class RemoteCategoryArticlesRepository implements CategoryArticlesRepository {
  RemoteCategoryArticlesRepository(this._api);

  final MikoziApiClient _api;

  @override
  Future<CategoryArticles> fetch({
    required String categorySlug,
    int limit = 30,
    int offset = 0,
  }) async {
    final json = await _api.getReaderCategoryArticles(
      slug: categorySlug,
      limit: limit,
      offset: offset,
    );
    return CategoryArticles(
      category: _category(json['category'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => _article(item as Map<String, dynamic>))
          .toList(growable: false),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }

  HomeArticle _article(Map<String, dynamic> json) {
    return HomeArticle(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      heroImageUrl: json['heroImageUrl'] as String?,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      category: _category(json['category'] as Map<String, dynamic>),
    );
  }

  HomeCategory _category(Map<String, dynamic> json) {
    return HomeCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}
