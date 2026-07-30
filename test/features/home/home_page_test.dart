import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/adaptive/mikozi_page_boundary.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
import 'package:mikozi_mobile/features/home/application/home_banner_auto_advance.dart';
import 'package:mikozi_mobile/features/home/application/home_category_selection.dart';
import 'package:mikozi_mobile/features/home/application/homepage_provider.dart';
import 'package:mikozi_mobile/features/home/domain/homepage.dart';
import 'package:mikozi_mobile/features/home/presentation/home_page.dart';
import 'package:mikozi_mobile/features/home/presentation/widgets/home_article_image.dart';
import 'package:mikozi_mobile/features/home/presentation/widgets/home_floating_header.dart';
import 'package:mikozi_mobile/features/home/presentation/widgets/home_story_carousel_section.dart';

void main() {
  testWidgets('renders configured sections beneath the pinned header', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homepageRepositoryProvider.overrideWithValue(
            const _FixtureHomepageRepository(),
          ),
        ],
        child: const MaterialApp(home: MikoziPageBoundary(child: HomePage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lead story from the newsroom'), findsOneWidget);
    expect(find.text('A second lead story'), findsOneWidget);
    expect(find.text('National'), findsWidgets);
    expect(find.byType(HomeFloatingHeader), findsOneWidget);
    expect(find.text('Mikozi'), findsNothing);
    final headerTop = tester.getTopLeft(find.byType(HomeFloatingHeader)).dy;

    final verticalScroll = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.text('Latest updates'),
      240,
      scrollable: verticalScroll,
    );
    await tester.pumpAndSettle();

    expect(find.text('Latest updates'), findsOneWidget);
    expect(find.text('A compact story row'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(HomeFloatingHeader)).dy, headerTop);
    expect(
      tester
          .widget<HomeFloatingHeader>(find.byType(HomeFloatingHeader))
          .surfaceOpacity,
      greaterThan(0),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('pull to refresh reconciles dashboard changes through REST', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    final repository = _RefreshingHomepageRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [homepageRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: MikoziPageBoundary(child: HomePage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Before dashboard update'), findsOneWidget);

    final indicator = tester.widget<RefreshIndicator>(
      find.byKey(const ValueKey('home-adaptive-refresh-control')),
    );
    final refresh = indicator.onRefresh();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('home-adaptive-refresh-control')),
      findsOneWidget,
    );
    expect(find.text('Before dashboard update'), findsOneWidget);
    expect(repository.fetchCount, 2);

    repository.completeRefresh();
    await refresh;
    await tester.pumpAndSettle();

    expect(find.text('After dashboard update'), findsOneWidget);
    expect(find.text('Before dashboard update'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the adaptive pull indicator on iOS', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homepageRepositoryProvider.overrideWithValue(
            const _FixtureHomepageRepository(),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const MikoziPageBoundary(child: HomePage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(HomePage))).platform,
      TargetPlatform.iOS,
    );
    expect(find.text('Lead story from the newsroom'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-adaptive-refresh-control')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('More categories use a bottom-anchored editorial sheet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        homepageRepositoryProvider.overrideWithValue(
          const _FixtureHomepageRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MikoziPageBoundary(child: HomePage())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    final sheet = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('more-categories-sheet')),
    );
    final decoration = sheet.decoration as BoxDecoration;
    expect(decoration.color, AppTheme.white);
    expect(decoration.border, isNull);
    expect(decoration.boxShadow, isNull);
    expect(
      decoration.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(30)),
    );

    final category = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('more-category-sports')),
    );
    expect((category.decoration as BoxDecoration).color, Colors.transparent);
    expect(find.byKey(const ValueKey('close-more-categories')), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);

    await tester.tap(find.text('Sports'));
    await tester.pumpAndSettle();
    expect(container.read(homeCategorySelectionProvider), 'sports');
    expect(find.text('Sports'), findsOneWidget);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SizedBox.shrink()),
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MikoziPageBoundary(child: HomePage())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sports'), findsOneWidget);
    expect(container.read(homeCategorySelectionProvider), 'sports');
    expect(
      tester.getTopLeft(find.text('Sports')).dx,
      lessThan(tester.getTopLeft(find.text('National')).dx),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('multi-story banners auto-advance with an infinite delegate', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homepageRepositoryProvider.overrideWithValue(
            const _FixtureHomepageRepository(),
          ),
          homeBannerIntervalProvider.overrideWithValue(
            const Duration(seconds: 2),
          ),
        ],
        child: const MaterialApp(home: MikoziPageBoundary(child: HomePage())),
      ),
    );
    await tester.pump();
    await tester.pump();

    final carousel = tester.widget<PageView>(
      find.byKey(const ValueKey('banner-carousel-lead')),
    );
    final initialPage = carousel.controller!.page!;
    expect(
      (carousel.childrenDelegate as SliverChildBuilderDelegate)
          .estimatedChildCount,
      isNull,
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(carousel.controller!.page, greaterThan(initialPage));
    expect(tester.takeException(), isNull);
  });

  testWidgets('network story images use the shared cache and CDN headers', (
    tester,
  ) async {
    const imageUrl = 'https://images.example.test/story.jpg';
    const category = HomeCategory(
      id: 'general',
      name: 'General',
      slug: 'general',
    );
    const article = HomeArticle(
      id: 'story',
      slug: 'story',
      title: 'Story',
      summary: 'Summary',
      heroImageUrl: imageUrl,
      publishedAt: null,
      category: category,
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SizedBox(
            width: 200,
            height: 120,
            child: HomeArticleImage(
              article: article,
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ),
    );
    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, imageUrl);
    expect(image.cacheKey, imageUrl);
    expect(image.httpHeaders?['Accept'], contains('image/*'));
  });

  testWidgets('horizontal lists use compact landscape cards and More', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    var morePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MikoziPageBoundary(
          child: HomeStoryCarouselSection(
            section: _horizontalSection(),
            onArticleSelected: (_) {},
            onMore: () => morePressed = true,
          ),
        ),
      ),
    );

    final image = find.byType(HomeArticleImage).first;
    final imageSize = tester.getSize(image);
    expect(imageSize.width, lessThanOrEqualTo(272));
    expect(imageSize.width / imageSize.height, closeTo(16 / 9, 0.02));
    expect(
      tester.getTopLeft(find.text('Horizontal story 1')).dy,
      greaterThan(tester.getBottomLeft(image).dy),
    );

    await tester.tap(find.text('More'));
    expect(morePressed, isTrue);
    expect(tester.takeException(), isNull);
  });
}

class _FixtureHomepageRepository implements HomepageRepository {
  const _FixtureHomepageRepository();

  @override
  Future<Homepage> fetch() async {
    const category = HomeCategory(
      id: 'national',
      name: 'National',
      slug: 'national',
    );
    return Homepage(
      version: 3,
      topNavigation: [
        HomeTab(
          id: category.id,
          name: category.name,
          slug: category.slug,
          sections: [
            HomeSection(
              id: 'lead',
              title: null,
              type: HomeSectionType.banner,
              advertPlacementCode: null,
              articles: [
                HomeArticle(
                  id: 'lead-article',
                  slug: 'lead-story',
                  title: 'Lead story from the newsroom',
                  summary: 'The lead summary.',
                  heroImageUrl: null,
                  publishedAt: DateTime(2030),
                  category: category,
                ),
                HomeArticle(
                  id: 'second-lead-article',
                  slug: 'second-lead-story',
                  title: 'A second lead story',
                  summary: 'The second lead summary.',
                  heroImageUrl: null,
                  publishedAt: DateTime(2030),
                  category: category,
                ),
              ],
              categories: const [],
            ),
            HomeSection(
              id: 'latest',
              title: 'Latest updates',
              type: HomeSectionType.list,
              advertPlacementCode: null,
              articles: [
                HomeArticle(
                  id: 'list-article',
                  slug: 'compact-story',
                  title: 'A compact story row',
                  summary: 'A concise summary for the configured list.',
                  heroImageUrl: null,
                  publishedAt: null,
                  category: category,
                ),
              ],
              categories: const [],
            ),
          ],
        ),
      ],
      moreNavigation: const [
        HomeTab(id: 'sports', name: 'Sports', slug: 'sports', sections: []),
      ],
    );
  }
}

class _RefreshingHomepageRepository implements HomepageRepository {
  final Completer<Homepage> _refreshCompleter = Completer<Homepage>();
  int fetchCount = 0;

  @override
  Future<Homepage> fetch() {
    fetchCount += 1;
    if (fetchCount == 1) {
      return Future.value(_homepageWithTitle('Before dashboard update'));
    }
    return _refreshCompleter.future;
  }

  void completeRefresh() {
    _refreshCompleter.complete(_homepageWithTitle('After dashboard update'));
  }
}

Homepage _homepageWithTitle(String title) {
  const category = HomeCategory(
    id: 'national',
    name: 'National',
    slug: 'national',
  );
  return Homepage(
    version: title.hashCode,
    topNavigation: [
      HomeTab(
        id: category.id,
        name: category.name,
        slug: category.slug,
        sections: [
          HomeSection(
            id: 'lead',
            title: null,
            type: HomeSectionType.banner,
            advertPlacementCode: null,
            articles: [
              HomeArticle(
                id: 'lead-article',
                slug: 'lead-story',
                title: title,
                summary: 'The lead summary.',
                heroImageUrl: null,
                publishedAt: null,
                category: category,
              ),
            ],
            categories: const [],
          ),
        ],
      ),
    ],
    moreNavigation: const [],
  );
}

HomeSection _horizontalSection() {
  const category = HomeCategory(
    id: 'national',
    name: 'National',
    slug: 'national',
  );
  return HomeSection(
    id: 'horizontal',
    title: 'Recommended',
    type: HomeSectionType.horizontalList,
    itemLimit: 6,
    advertPlacementCode: null,
    articles: [
      for (var index = 1; index <= 6; index++)
        HomeArticle(
          id: 'horizontal-$index',
          slug: 'horizontal-story-$index',
          title: 'Horizontal story $index',
          summary: 'Summary',
          heroImageUrl: null,
          publishedAt: null,
          category: category,
        ),
    ],
    categories: const [],
  );
}
