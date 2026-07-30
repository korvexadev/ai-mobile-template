import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/articles/domain/reader_article.dart';
import 'package:mikozi_mobile/features/articles/domain/saved_article.dart';

void main() {
  test('uses the first article image when a hero image is absent', () {
    final savedAt = DateTime.utc(2026, 7, 30, 12);
    final saved = SavedArticle.fromReaderArticle(
      ReaderArticle(
        id: 'article-1',
        slug: 'story',
        title: 'Story',
        summary: 'Summary',
        category: const ReaderArticleCategory(
          id: 'general',
          name: 'General',
          slug: 'general',
        ),
        heroImageUrl: null,
        publishedAt: DateTime.utc(2026, 7, 29),
        author: const ReaderArticleAuthor(id: 'desk', displayName: 'Desk'),
        sections: const [
          ReaderArticleSection(
            id: 'body',
            position: 0,
            type: ReaderArticleSectionType.richText,
            body: 'Body',
            mediaUrl: null,
            caption: null,
            altText: null,
            youtubeVideoId: null,
            advertPlacementCode: null,
          ),
          ReaderArticleSection(
            id: 'photo',
            position: 1,
            type: ReaderArticleSectionType.image,
            body: null,
            mediaUrl: '/uploads/story.jpg',
            caption: null,
            altText: 'Story photo',
            youtubeVideoId: null,
            advertPlacementCode: null,
          ),
        ],
        similarArticles: const [],
      ),
      savedAt: savedAt,
    );

    expect(saved.heroImageUrl, '/uploads/story.jpg');
    expect(saved.savedAt, savedAt);
    expect(SavedArticle.fromJson(saved.toJson())?.savedAt, savedAt);
  });
}
