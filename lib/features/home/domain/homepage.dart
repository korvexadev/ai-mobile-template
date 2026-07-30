enum HomeSectionType { banner, list, advert, horizontalList, categories }

class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;
}

class HomeArticle {
  const HomeArticle({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.heroImageUrl,
    required this.category,
  });

  final String id;
  final String slug;
  final String title;
  final String summary;
  final String? heroImageUrl;
  final HomeCategory category;
}

class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.type,
    required this.advertPlacementCode,
    required this.articles,
    required this.categories,
  });

  final String id;
  final String? title;
  final HomeSectionType type;
  final String? advertPlacementCode;
  final List<HomeArticle> articles;
  final List<HomeCategory> categories;
}

class HomeTab extends HomeCategory {
  const HomeTab({
    required super.id,
    required super.name,
    required super.slug,
    required this.sections,
  });

  final List<HomeSection> sections;
}

class Homepage {
  const Homepage({
    required this.version,
    required this.topNavigation,
    required this.moreNavigation,
  });

  final int version;
  final List<HomeTab> topNavigation;
  final List<HomeTab> moreNavigation;
}

abstract interface class HomepageRepository {
  Future<Homepage> fetch();
}
