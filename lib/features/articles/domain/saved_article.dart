import 'reader_article.dart';

class SavedArticle {
  const SavedArticle({
    required this.slug,
    required this.title,
    required this.summary,
    required this.categoryName,
    required this.categorySlug,
    required this.heroImageUrl,
    required this.publishedAt,
    required this.savedAt,
  });

  factory SavedArticle.fromReaderArticle(
    ReaderArticle article, {
    DateTime? savedAt,
  }) {
    return SavedArticle(
      slug: article.slug,
      title: article.title,
      summary: article.summary,
      categoryName: article.category.name,
      categorySlug: article.category.slug,
      heroImageUrl:
          article.heroImageUrl ??
          article.sections
              .where(
                (section) =>
                    section.type == ReaderArticleSectionType.image &&
                    section.mediaUrl?.trim().isNotEmpty == true,
              )
              .firstOrNull
              ?.mediaUrl,
      publishedAt: article.publishedAt,
      savedAt: savedAt ?? DateTime.now().toUtc(),
    );
  }

  final String slug;
  final String title;
  final String summary;
  final String categoryName;
  final String categorySlug;
  final String? heroImageUrl;
  final DateTime? publishedAt;
  final DateTime savedAt;

  Map<String, Object?> toJson() {
    return {
      'slug': slug,
      'title': title,
      'summary': summary,
      'categoryName': categoryName,
      'categorySlug': categorySlug,
      'heroImageUrl': heroImageUrl,
      'publishedAt': publishedAt?.toUtc().toIso8601String(),
      'savedAt': savedAt.toUtc().toIso8601String(),
    };
  }

  static SavedArticle? fromJson(Map<String, Object?> json) {
    final slug = json['slug'];
    final title = json['title'];
    if (slug is! String || slug.isEmpty || title is! String || title.isEmpty) {
      return null;
    }
    final publishedAt = DateTime.tryParse(json['publishedAt'] as String? ?? '');
    final savedAt = DateTime.tryParse(json['savedAt'] as String? ?? '');
    return SavedArticle(
      slug: slug,
      title: title,
      summary: json['summary'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? 'News',
      categorySlug: json['categorySlug'] as String? ?? '',
      heroImageUrl: json['heroImageUrl'] as String?,
      publishedAt: publishedAt,
      savedAt: savedAt ?? publishedAt ?? DateTime.now().toUtc(),
    );
  }

  bool hasSameContent(SavedArticle other) {
    return slug == other.slug &&
        title == other.title &&
        summary == other.summary &&
        categoryName == other.categoryName &&
        categorySlug == other.categorySlug &&
        heroImageUrl == other.heroImageUrl &&
        publishedAt == other.publishedAt &&
        savedAt == other.savedAt;
  }
}
