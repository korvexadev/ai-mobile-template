import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../application/home_category_selection.dart';
import '../application/homepage_provider.dart';
import '../domain/homepage.dart';
import 'widgets/home_category_rail.dart';
import 'widgets/home_floating_header.dart';
import 'widgets/home_section_renderer.dart';
import 'widgets/homepage_states.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRefreshing = false;
  late final ScrollController _scrollController;
  late final ValueNotifier<double> _headerSurfaceOpacity;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _headerSurfaceOpacity = ValueNotifier<double>(0);
  }

  void _handleScroll() {
    final progress = (_scrollController.offset / 64).clamp(0.0, 1.0);
    _headerSurfaceOpacity.value = progress * 0.96;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _headerSurfaceOpacity.dispose();
    super.dispose();
  }

  Future<void> _refreshHomepage() async {
    if (_isRefreshing) {
      return;
    }

    setState(() => _isRefreshing = true);
    try {
      final _ = await ref.refresh(homepageProvider.future);
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 76;
    final homepage = ref.watch(homepageProvider);
    final selectedTabId = ref.watch(homeCategorySelectionProvider);
    return ColoredBox(
      color: AppTheme.paperOf(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: homepage.when(
              loading: () => HomepageSkeleton(topInset: topInset),
              error: (error, stackTrace) => HomepageError(
                topInset: topInset,
                onRetry: () {
                  _refreshHomepage();
                },
              ),
              data: (value) => _HomepageFeed(
                homepage: value,
                selectedTabId: selectedTabId,
                topInset: topInset,
                scrollController: _scrollController,
                onSelected: (id) {
                  ref.read(homeCategorySelectionProvider.notifier).select(id);
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                },
                onRefresh: _refreshHomepage,
                onArticleSelected: (slug) {
                  context.push('/articles/${Uri.encodeComponent(slug)}');
                },
                onCategoryMore: (slug) {
                  context.push(
                    '/categories/${Uri.encodeComponent(slug)}/articles',
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _headerSurfaceOpacity,
              builder: (context, opacity, child) {
                return HomeFloatingHeader(
                  onSearch: () {},
                  onNotifications: () =>
                      context.push('/settings/notifications'),
                  surfaceOpacity: opacity,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomepageFeed extends StatelessWidget {
  const _HomepageFeed({
    required this.homepage,
    required this.selectedTabId,
    required this.topInset,
    required this.scrollController,
    required this.onSelected,
    required this.onRefresh,
    required this.onArticleSelected,
    required this.onCategoryMore,
  });

  final Homepage homepage;
  final String? selectedTabId;
  final double topInset;
  final ScrollController scrollController;
  final ValueChanged<String> onSelected;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onArticleSelected;
  final ValueChanged<String> onCategoryMore;

  @override
  Widget build(BuildContext context) {
    final allTabs = [...homepage.topNavigation, ...homepage.moreNavigation];
    if (allTabs.isEmpty) {
      return _AdaptiveRefreshScrollView(
        onRefresh: onRefresh,
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(top: topInset),
            sliver: const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyHomepage(
                message: 'No news categories are available yet.',
              ),
            ),
          ),
        ],
      );
    }

    final selected = allTabs.firstWhere(
      (tab) => tab.id == selectedTabId,
      orElse: () => allTabs.first,
    );
    final leadIsFirst =
        selected.sections.firstOrNull?.type == HomeSectionType.banner;
    final lead = leadIsFirst ? selected.sections.first : null;
    final remainingSections = leadIsFirst
        ? selected.sections.skip(1)
        : selected.sections;

    return _AdaptiveRefreshScrollView(
      onRefresh: onRefresh,
      controller: scrollController,
      scrollKey: PageStorageKey(selected.id),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topInset + AppSpacing.md)),
        if (lead != null)
          _sectionSliver(lead, category: selected, topPadding: 0)
        else
          const SliverToBoxAdapter(child: SizedBox.shrink()),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: lead == null ? 0 : AppSpacing.sm),
            child: HomeCategoryRail(
              topTabs: homepage.topNavigation,
              moreTabs: homepage.moreNavigation,
              selectedId: selected.id,
              onSelected: onSelected,
            ),
          ),
        ),
        if (selected.sections.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyHomepage(
              message: 'No stories are available in this category.',
            ),
          )
        else
          for (final section in remainingSections)
            _sectionSliver(section, category: selected),
        const SliverToBoxAdapter(child: SizedBox(height: 128)),
      ],
    );
  }

  SliverToBoxAdapter _sectionSliver(
    HomeSection section, {
    required HomeCategory category,
    double topPadding = AppSpacing.lg,
  }) {
    return SliverToBoxAdapter(
      key: ValueKey(section.id),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: HomeSectionRenderer(
          section: section,
          onCategorySelected: onSelected,
          onArticleSelected: onArticleSelected,
          onMore: () => onCategoryMore(category.slug),
        ),
      ),
    );
  }
}

class _AdaptiveRefreshScrollView extends StatelessWidget {
  const _AdaptiveRefreshScrollView({
    required this.onRefresh,
    required this.controller,
    required this.slivers,
    this.scrollKey,
  });

  final Future<void> Function() onRefresh;
  final ScrollController controller;
  final List<Widget> slivers;
  final Key? scrollKey;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final safeTop = MediaQuery.paddingOf(context).top;
    return RefreshIndicator.adaptive(
      key: const ValueKey('home-adaptive-refresh-control'),
      color: AppTheme.brandRed,
      backgroundColor: AppTheme.paperOf(context),
      edgeOffset: safeTop + 50,
      displacement: safeTop + 70,
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: scrollKey,
        controller: controller,
        physics: isIOS
            ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              )
            : const AlwaysScrollableScrollPhysics(),
        slivers: slivers,
      ),
    );
  }
}
