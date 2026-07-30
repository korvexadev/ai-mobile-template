import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/adaptive/mikozi_page_boundary.dart';
import 'package:mikozi_mobile/features/home/application/homepage_provider.dart';
import 'package:mikozi_mobile/features/home/domain/homepage.dart';
import 'package:mikozi_mobile/features/home/presentation/home_page.dart';
import 'package:mikozi_mobile/features/home/presentation/widgets/home_floating_header.dart';

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
      find.byKey(const ValueKey('home-material-refresh-control')),
    );
    final refresh = indicator.onRefresh();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('home-material-refresh-control')),
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

  testWidgets('uses the Cupertino pull indicator on iOS', (tester) async {
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
      find.byKey(const ValueKey('home-cupertino-refresh-control')),
      findsOneWidget,
    );
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
      moreNavigation: const [],
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
