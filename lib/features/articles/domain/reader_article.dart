enum ReaderArticleSectionType { richText, image, youtube, advert, unsupported }

class ReaderArticleCategory {
  const ReaderArticleCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  final String id;
  final String name;
  final String slug;
}

class ReaderArticleAuthor {
  const ReaderArticleAuthor({required this.id, required this.displayName});

  final String id;
  final String? displayName;
}

class ReaderArticleSection {
  const ReaderArticleSection({
    required this.id,
    required this.position,
    required this.type,
    required this.body,
    required this.mediaUrl,
    required this.caption,
    required this.altText,
    required this.youtubeVideoId,
    required this.advertPlacementCode,
  });

  final String id;
  final int position;
  final ReaderArticleSectionType type;
  final String? body;
  final String? mediaUrl;
  final String? caption;
  final String? altText;
  final String? youtubeVideoId;
  final String? advertPlacementCode;
}

class ReaderArticle {
  const ReaderArticle({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.category,
    required this.heroImageUrl,
    required this.publishedAt,
    required this.author,
    required this.sections,
    required this.similarArticles,
  });

  final String id;
  final String slug;
  final String title;
  final String summary;
  final ReaderArticleCategory category;
  final String? heroImageUrl;
  final DateTime? publishedAt;
  final ReaderArticleAuthor author;
  final List<ReaderArticleSection> sections;
  final List<ReaderSimilarArticle> similarArticles;
}

class ReaderSimilarArticle {
  const ReaderSimilarArticle({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.heroImageUrl,
    required this.publishedAt,
    required this.category,
    required this.similarityScore,
  });

  final String id;
  final String slug;
  final String title;
  final String summary;
  final String? heroImageUrl;
  final DateTime? publishedAt;
  final ReaderArticleCategory category;
  final double similarityScore;
}
