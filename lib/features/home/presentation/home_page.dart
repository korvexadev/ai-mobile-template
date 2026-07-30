import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mikozi_mobile/features/home/application/homepage_provider.dart';
import 'package:mikozi_mobile/features/home/domain/homepage.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _selectedTabId;

  @override
  Widget build(BuildContext context) {
    final homepage = ref.watch(homepageProvider);
    return AdaptiveScaffold(
      appBar: const AdaptiveAppBar(title: 'Mikozi', useNativeToolbar: true),
      body: SafeArea(
        top: false,
        child: homepage.when(
          loading: () => const _HomepageSkeleton(),
          error: (error, stackTrace) =>
              _HomepageError(onRetry: () => ref.invalidate(homepageProvider)),
          data: _buildHomepage,
        ),
      ),
    );
  }

  Widget _buildHomepage(Homepage homepage) {
    final allTabs = [...homepage.topNavigation, ...homepage.moreNavigation];
    if (allTabs.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.refresh(homepageProvider.future),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(hasScrollBody: false, child: _EmptyHomepage()),
          ],
        ),
      );
    }
    final selected = allTabs.firstWhere(
      (tab) => tab.id == _selectedTabId,
      orElse: () => allTabs.first,
    );
    return RefreshIndicator(
      onRefresh: () => ref.refresh(homepageProvider.future),
      child: CustomScrollView(
        key: PageStorageKey(selected.id),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _CategoryRail(
              topTabs: homepage.topNavigation,
              moreTabs: homepage.moreNavigation,
              selectedId: selected.id,
              onSelected: (id) => setState(() => _selectedTabId = id),
            ),
          ),
          if (selected.sections.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyCategory(),
            )
          else
            ...selected.sections.map(_buildSection),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
        ],
      ),
    );
  }

  Widget _buildSection(HomeSection section) {
    return SliverToBoxAdapter(
      key: ValueKey(section.id),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: switch (section.type) {
          HomeSectionType.banner => _BannerSection(section: section),
          HomeSectionType.horizontalList => _HorizontalSection(
            section: section,
          ),
          HomeSectionType.advert => _AdvertSection(section: section),
          HomeSectionType.categories => _CategoriesSection(
            section: section,
            onSelected: (id) => setState(() => _selectedTabId = id),
          ),
          HomeSectionType.list => _ListSection(section: section),
        },
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.topTabs,
    required this.moreTabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<HomeTab> topTabs;
  final List<HomeTab> moreTabs;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'News categories',
      child: SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          children: [
            ...topTabs.map(
              (tab) => _CategoryButton(
                tab: tab,
                selected: tab.id == selectedId,
                onPressed: () => onSelected(tab.id),
              ),
            ),
            if (moreTabs.isNotEmpty)
              PopupMenuButton<String>(
                tooltip: 'More categories',
                onSelected: onSelected,
                itemBuilder: (context) => moreTabs
                    .map(
                      (tab) =>
                          PopupMenuItem(value: tab.id, child: Text(tab.name)),
                    )
                    .toList(growable: false),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Row(
                    children: [
                      Text('More'),
                      SizedBox(width: 4),
                      Icon(Icons.expand_more, size: 18),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.tab,
    required this.selected,
    required this.onPressed,
  });

  final HomeTab tab;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: selected ? colors.primary : colors.onSurfaceVariant,
          textStyle: TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        child: Text(tab.name),
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  const _BannerSection({required this.section});
  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    final article = section.articles.firstOrNull;
    if (article == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Semantics(
        button: true,
        label: article.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArticleImage(article: article, aspectRatio: 16 / 10),
            const SizedBox(height: 14),
            Text(
              article.category.name.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              article.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({required this.section});
  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    if (section.articles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(section.title),
        const SizedBox(height: 12),
        SizedBox(
          height: 245,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: section.articles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final article = section.articles[index];
              return SizedBox(
                width: 235,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ArticleImage(article: article, aspectRatio: 16 / 10),
                    const SizedBox(height: 10),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ListSection extends StatelessWidget {
  const _ListSection({required this.section});
  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    if (section.articles.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(section.title),
          ...section.articles.map(
            (article) => Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.22,
                              ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          article.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 112,
                    child: _ArticleImage(article: article, aspectRatio: 4 / 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvertSection extends StatelessWidget {
  const _AdvertSection({required this.section});
  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Advertisement',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(minHeight: 96),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'ADVERTISEMENT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.section, required this.onSelected});
  final HomeSection section;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (section.categories.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(section.title),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: section.categories
                .map(
                  (category) => ActionChip(
                    label: Text(category.name),
                    onPressed: () => onSelected(category.id),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (title == null || title!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Text(title!, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.article, required this.aspectRatio});
  final HomeArticle article;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: article.heroImageUrl == null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_outlined),
              )
            : Image.network(
                article.heroImageUrl!,
                fit: BoxFit.cover,
                semanticLabel: article.title,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}

class _HomepageSkeleton extends StatelessWidget {
  const _HomepageSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(height: 38, decoration: _skeleton(color)),
        const SizedBox(height: 22),
        AspectRatio(
          aspectRatio: 16 / 10,
          child: DecoratedBox(decoration: _skeleton(color)),
        ),
        const SizedBox(height: 16),
        Container(height: 28, width: 280, decoration: _skeleton(color)),
        const SizedBox(height: 10),
        Container(height: 70, decoration: _skeleton(color)),
      ],
    );
  }

  BoxDecoration _skeleton(Color color) =>
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(12));
}

class _HomepageError extends StatelessWidget {
  const _HomepageError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 14),
            Text(
              'The homepage could not be loaded.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Check your connection and try again.'),
            const SizedBox(height: 20),
            AdaptiveButton(onPressed: onRetry, label: 'Try again'),
          ],
        ),
      ),
    );
  }
}

class _EmptyHomepage extends StatelessWidget {
  const _EmptyHomepage();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No news categories are available yet.'));
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No stories are available in this category.'));
}
