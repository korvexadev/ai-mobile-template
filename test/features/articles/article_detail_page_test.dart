import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/adaptive/mikozi_page_boundary.dart';
import 'package:mikozi_mobile/features/articles/application/article_actions_controller.dart';
import 'package:mikozi_mobile/features/articles/application/reader_article_provider.dart';
import 'package:mikozi_mobile/features/articles/application/saved_articles_controller.dart';
import 'package:mikozi_mobile/features/articles/domain/article_share_service.dart';
import 'package:mikozi_mobile/features/articles/domain/reader_article.dart';
import 'package:mikozi_mobile/features/articles/domain/reader_article_repository.dart';
import 'package:mikozi_mobile/features/articles/domain/saved_article.dart';
import 'package:mikozi_mobile/features/articles/domain/saved_articles_repository.dart';
import 'package:mikozi_mobile/features/articles/presentation/article_detail_page.dart';
import 'package:mikozi_mobile/features/articles/presentation/widgets/article_floating_header.dart';
import 'package:mikozi_mobile/features/payments/application/payments_controller.dart';
import 'package:mikozi_mobile/features/payments/domain/payment.dart';
import 'package:mikozi_mobile/features/payments/domain/payment_repository.dart';
import 'package:mikozi_mobile/features/profile/application/reader_entitlement_provider.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement.dart';
import 'package:mikozi_mobile/features/profile/domain/reader_entitlement_repository.dart';

void main() {
  testWidgets('renders the article contract in server-provided order', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);

    final saved = _SavedArticlesRepository();
    final share = _ArticleShareService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readerArticleRepositoryProvider.overrideWithValue(
            const _FixtureArticleRepository(),
          ),
          savedArticlesRepositoryProvider.overrideWithValue(saved),
          articleShareServiceProvider.overrideWithValue(share),
        ],
        child: const MaterialApp(
          home: MikoziPageBoundary(
            child: ArticleDetailPage(slug: 'configured-story'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NATIONAL'), findsOneWidget);
    expect(find.text('Configured story'), findsOneWidget);
    expect(find.text('A concise article summary.'), findsOneWidget);
    expect(find.text('By Mikozi Desk  ·  January 1, 2030'), findsOneWidget);
    expect(find.text('Opening body.'), findsOneWidget);
    expect(find.text('ADVERTISEMENT'), findsOneWidget);
    expect(find.text('Similar stories'), findsOneWidget);
    expect(find.text('Another related story'), findsOneWidget);
    expect(find.text('75% match'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('article-adaptive-refresh-control')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('article-save-action')), findsOneWidget);
    expect(find.byKey(const ValueKey('article-share-action')), findsOneWidget);
    final header = find.byType(ArticleFloatingHeader);
    final headerDecorations = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: header, matching: find.byType(DecoratedBox)),
        )
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>();
    expect(headerDecorations.every((item) => item.gradient == null), isTrue);
    expect(
      headerDecorations.every(
        (item) => item.boxShadow == null || item.boxShadow!.isEmpty,
      ),
      isTrue,
    );
    expect(
      tester.getTopLeft(find.text('Opening body.')).dy,
      lessThan(tester.getTopLeft(find.text('ADVERTISEMENT')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows progress and wires local save and native sharing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    final saved = _SavedArticlesRepository();
    final share = _ArticleShareService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          readerArticleRepositoryProvider.overrideWithValue(
            const _FixtureArticleRepository(),
          ),
          savedArticlesRepositoryProvider.overrideWithValue(saved),
          articleShareServiceProvider.overrideWithValue(share),
        ],
        child: const MaterialApp(
          home: MikoziPageBoundary(
            child: ArticleDetailPage(slug: 'configured-story'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    saved.pendingWrite = Completer<void>();
    await tester.tap(find.byKey(const ValueKey('article-save-action')));
    await tester.pump();
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    saved.pendingWrite!.complete();
    await tester.pumpAndSettle();
    expect(saved.articles, contains('configured-story'));
    expect(find.bySemanticsLabel('Remove saved article'), findsOneWidget);

    share.pendingShare = Completer<void>();
    await tester.tap(find.byKey(const ValueKey('article-share-action')));
    await tester.pump();
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    share.pendingShare!.complete();
    await tester.pumpAndSettle();

    expect(share.lastRequest?.title, 'Configured story');
    expect(share.lastRequest?.summary, 'A concise article summary.');
    expect(share.lastRequest?.anchor.width, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'renders the preview and plan carousel when access is exhausted',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(393, 852);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readerArticleRepositoryProvider.overrideWithValue(
              const _LimitedArticleRepository(),
            ),
            paymentRepositoryProvider.overrideWithValue(
              const _PaymentRepository(),
            ),
            readerEntitlementRepositoryProvider.overrideWithValue(
              const _EntitlementRepository(),
            ),
          ],
          child: const MaterialApp(
            home: MikoziPageBoundary(
              child: ArticleDetailPage(slug: 'locked-story'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Locked story'), findsOneWidget);
      expect(find.text('Keep reading'), findsOneWidget);
      expect(find.text('Mikozi Plus'), findsOneWidget);
      expect(find.text('Choose plan'), findsOneWidget);
    },
  );
}

class _LimitedArticleRepository implements ReaderArticleRepository {
  const _LimitedArticleRepository();

  @override
  Future<ReaderArticle> readBySlug(String slug) async {
    throw ReaderArticleFailure(
      code: 'DAILY_ARTICLE_LIMIT_REACHED',
      message: 'Your daily article allowance has been reached.',
      preview: ReaderArticlePreview(
        slug: slug,
        title: 'Locked story',
        summary: 'A preview summary.',
        heroImageUrl: null,
        categoryName: 'National',
      ),
    );
  }
}

class _EntitlementRepository implements ReaderEntitlementRepository {
  const _EntitlementRepository();

  @override
  Future<ReaderEntitlement> fetch() async {
    return ReaderEntitlement(
      planName: 'Free',
      dailyArticleLimit: 3,
      articlesReadToday: 3,
      articlesRemainingToday: 0,
      resetsAt: DateTime.utc(2030, 1, 2),
      endsAt: null,
    );
  }
}

class _PaymentRepository implements PaymentRepository {
  const _PaymentRepository();

  @override
  Future<List<PaymentPlan>> listPlans() async => const [
    PaymentPlan(
      id: 'plus-id',
      code: 'plus',
      name: 'Mikozi Plus',
      description: null,
      priceMinor: 500000,
      currency: 'MWK',
      billingPeriod: 'monthly',
      dailyArticleLimit: null,
    ),
  ];

  @override
  Future<List<MobileMoneyOperator>> listOperators() async => const [];

  @override
  Future<List<PaymentTransaction>> listTransactions() async => const [];

  @override
  Future<PaymentTransaction?> pendingTransaction() async => null;

  @override
  Future<PaymentTransaction> initiateBankTransfer({
    required String planId,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<PaymentTransaction> initiateMobileMoney({
    required String planId,
    required String operatorId,
    required String phoneNumber,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<PaymentTransaction> verify(String transactionId) =>
      throw UnimplementedError();
}

class _FixtureArticleRepository implements ReaderArticleRepository {
  const _FixtureArticleRepository();

  @override
  Future<ReaderArticle> readBySlug(String slug) async {
    return ReaderArticle(
      id: 'article-1',
      slug: slug,
      title: 'Configured story',
      summary: 'A concise article summary.',
      category: const ReaderArticleCategory(
        id: 'national',
        name: 'National',
        slug: 'national',
      ),
      heroImageUrl: null,
      publishedAt: DateTime.utc(2030),
      author: const ReaderArticleAuthor(
        id: 'author-1',
        displayName: 'Mikozi Desk',
      ),
      sections: const [
        ReaderArticleSection(
          id: 'opening',
          position: 0,
          type: ReaderArticleSectionType.richText,
          body: 'Opening body.',
          mediaUrl: null,
          caption: null,
          altText: null,
          youtubeVideoId: null,
          advertPlacementCode: null,
        ),
        ReaderArticleSection(
          id: 'advert',
          position: 1,
          type: ReaderArticleSectionType.advert,
          body: null,
          mediaUrl: null,
          caption: null,
          altText: null,
          youtubeVideoId: null,
          advertPlacementCode: 'article.inline',
        ),
      ],
      similarArticles: const [
        ReaderSimilarArticle(
          id: 'similar-1',
          slug: 'another-story',
          title: 'Another related story',
          summary: 'Related summary',
          heroImageUrl: null,
          publishedAt: null,
          category: ReaderArticleCategory(
            id: 'national',
            name: 'National',
            slug: 'national',
          ),
          similarityScore: 0.75,
        ),
      ],
    );
  }
}

class _SavedArticlesRepository implements SavedArticlesRepository {
  final articles = <String, SavedArticle>{};
  Completer<void>? pendingWrite;

  @override
  Future<List<SavedArticle>> readAll() async => articles.values.toList();

  @override
  Future<void> setSaved(SavedArticle article, {required bool saved}) async {
    await pendingWrite?.future;
    if (saved) {
      articles[article.slug] = article;
    } else {
      articles.remove(article.slug);
    }
  }
}

class _ArticleShareService implements ArticleShareService {
  ArticleShareRequest? lastRequest;
  Completer<void>? pendingShare;

  @override
  Future<void> share(ArticleShareRequest request) async {
    lastRequest = request;
    await pendingShare?.future;
  }
}
