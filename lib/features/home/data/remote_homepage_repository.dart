import '../../../core/networking/mikozi_api_client.dart';
import '../domain/homepage.dart';

class RemoteHomepageRepository implements HomepageRepository {
  RemoteHomepageRepository(this._api);

  final MikoziApiClient _api;

  @override
  Future<Homepage> fetch() async {
    final json = await _api.getReaderHomepage();
    return Homepage(
      version: json['version'] as int,
      topNavigation: _tabs(json['topNavigation']),
      moreNavigation: _tabs(json['moreNavigation']),
    );
  }

  List<HomeTab> _tabs(Object? value) {
    return (value as List<dynamic>? ?? const [])
        .map((item) => _tab(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  HomeTab _tab(Map<String, dynamic> json) {
    return HomeTab(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      sections: (json['sections'] as List<dynamic>? ?? const [])
          .map((item) => _section(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  HomeSection _section(Map<String, dynamic> json) {
    return HomeSection(
      id: json['id'] as String,
      title: json['title'] as String?,
      type: switch (json['type']) {
        'banner' => HomeSectionType.banner,
        'advert' => HomeSectionType.advert,
        'horizontal_list' => HomeSectionType.horizontalList,
        'categories' => HomeSectionType.categories,
        _ => HomeSectionType.list,
      },
      itemLimit: json['itemLimit'] as int? ?? 1,
      advertPlacementCode: json['advertPlacementCode'] as String?,
      articles: (json['articles'] as List<dynamic>? ?? const [])
          .map((item) => _article(item as Map<String, dynamic>))
          .toList(growable: false),
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .map((item) => _category(item as Map<String, dynamic>))
          .toList(growable: false),
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
