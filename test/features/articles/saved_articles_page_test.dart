import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/articles/application/reader_article_provider.dart';
import 'package:mikozi_mobile/features/articles/application/saved_articles_controller.dart';
import 'package:mikozi_mobile/features/articles/domain/reader_article.dart';
import 'package:mikozi_mobile/features/articles/domain/reader_article_repository.dart';
import 'package:mikozi_mobile/features/articles/domain/saved_article.dart';
import 'package:mikozi_mobile/features/articles/domain/saved_articles_repository.dart';
import 'package:mikozi_mobile/features/articles/presentation/saved_articles_page.dart';

void main() {
  testWidgets('renders locally saved slugs as current article cards', (
    tester,
  ) async {
    final readerRepository = _ReaderRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedArticlesRepositoryProvider.overrideWithValue(_SavedRepository()),
          readerArticleRepositoryProvider.overrideWithValue(readerRepository),
        ],
        child: const MaterialApp(home: SavedArticlesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Saved story'), findsOneWidget);
    expect(find.text('GENERAL'), findsOneWidget);
    expect(find.byKey(const ValueKey('saved-group-Today')), findsOneWidget);
    expect(find.byKey(const ValueKey('saved-group-Yesterday')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('saved-image-saved-story')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('saved-articles-refresh')),
      findsOneWidget,
    );
    expect(readerRepository.readCount, 0);
    expect(tester.takeException(), isNull);
  });
}

class _SavedRepository implements SavedArticlesRepository {
  @override
  Future<List<SavedArticle>> readAll() async {
    final now = DateTime.now();
    return [
      SavedArticle(
        slug: 'saved-story',
        title: 'Saved story',
        summary: 'Summary',
        categoryName: 'General',
        categorySlug: 'general',
        heroImageUrl: 'https://images.example.test/saved-story.jpg',
        publishedAt: null,
        savedAt: now,
      ),
      SavedArticle(
        slug: 'older-story',
        title: 'Older story',
        summary: 'Earlier summary',
        categoryName: 'Business',
        categorySlug: 'business',
        heroImageUrl: 'https://images.example.test/older-story.jpg',
        publishedAt: null,
        savedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<void> setSaved(SavedArticle article, {required bool saved}) async {}
}

class _ReaderRepository implements ReaderArticleRepository {
  int readCount = 0;

  @override
  Future<ReaderArticle> readBySlug(String slug) async {
    readCount += 1;
    return ReaderArticle(
      id: 'article-1',
      slug: slug,
      title: 'Saved story',
      summary: 'Summary',
      category: const ReaderArticleCategory(
        id: 'general',
        name: 'General',
        slug: 'general',
      ),
      heroImageUrl: null,
      publishedAt: null,
      author: const ReaderArticleAuthor(id: 'desk', displayName: 'Desk'),
      sections: const [],
      similarArticles: const [],
    );
  }
}
