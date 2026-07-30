import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
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
  String? _selectedTabId;
  bool _isRefreshing = false;

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
    return ColoredBox(
      color: AppTheme.paper,
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
                selectedTabId: _selectedTabId,
                topInset: topInset,
                onSelected: (id) => setState(() => _selectedTabId = id),
                onRefresh: _refreshHomepage,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: HomeFloatingHeader(onSearch: () {}, onNotifications: () {}),
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
    required this.onSelected,
    required this.onRefresh,
  });

  final Homepage homepage;
  final String? selectedTabId;
  final double topInset;
  final ValueChanged<String> onSelected;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final allTabs = [...homepage.topNavigation, ...homepage.moreNavigation];
    if (allTabs.isEmpty) {
      return _AdaptiveRefreshScrollView(
        onRefresh: onRefresh,
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
      scrollKey: PageStorageKey(selected.id),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topInset + AppSpacing.md)),
        if (lead != null)
          _sectionSliver(lead, topPadding: 0)
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
          for (final section in remainingSections) _sectionSliver(section),
        const SliverToBoxAdapter(child: SizedBox(height: 128)),
      ],
    );
  }

  SliverToBoxAdapter _sectionSliver(
    HomeSection section, {
    double topPadding = AppSpacing.lg,
  }) {
    return SliverToBoxAdapter(
      key: ValueKey(section.id),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: HomeSectionRenderer(
          section: section,
          onCategorySelected: onSelected,
        ),
      ),
    );
  }
}

class _AdaptiveRefreshScrollView extends StatelessWidget {
  const _AdaptiveRefreshScrollView({
    required this.onRefresh,
    required this.slivers,
    this.scrollKey,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final Key? scrollKey;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return KeyedSubtree(
        key: const ValueKey('home-cupertino-refresh-control'),
        child: CustomScrollView(
          key: scrollKey,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: onRefresh),
            ...slivers,
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: const ValueKey('home-material-refresh-control'),
      color: AppTheme.brandRed,
      backgroundColor: AppTheme.paper,
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: scrollKey,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: slivers,
      ),
    );
  }
}
