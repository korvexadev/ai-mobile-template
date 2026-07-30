import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../application/category_articles_provider.dart';
import '../domain/category_articles.dart';
import '../domain/homepage.dart';
import 'home_layout.dart';
import 'widgets/home_article_image.dart';
import 'widgets/home_article_meta.dart';

class CategoryArticlesPage extends ConsumerWidget {
  const CategoryArticlesPage({required this.categorySlug, super.key});

  final String categorySlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(categoryArticlesControllerProvider(categorySlug));
    return ColoredBox(
      color: AppTheme.paper,
      child: Stack(
        children: [
          Positioned.fill(
            child: feed.when(
              loading: _CategoryLoading.new,
              error: (error, stackTrace) => _CategoryError(
                onRetry: () {
                  ref.invalidate(
                    categoryArticlesControllerProvider(categorySlug),
                  );
                },
              ),
              data: (value) => _CategoryFeed(
                feed: value,
                onRefresh: () async {
                  await ref
                      .read(
                        categoryArticlesControllerProvider(
                          categorySlug,
                        ).notifier,
                      )
                      .refresh();
                },
                onLoadMore: () {
                  ref
                      .read(
                        categoryArticlesControllerProvider(
                          categorySlug,
                        ).notifier,
                      )
                      .loadMore();
                },
                onArticleSelected: (slug) {
                  context.push('/articles/${Uri.encodeComponent(slug)}');
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: _BackAction(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFeed extends StatelessWidget {
  const _CategoryFeed({
    required this.feed,
    required this.onRefresh,
    required this.onArticleSelected,
    required this.onLoadMore,
  });

  final CategoryArticlesState feed;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onArticleSelected;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    return RefreshIndicator.adaptive(
      color: AppTheme.brandRed,
      backgroundColor: AppTheme.paper,
      edgeOffset: safeTop + 42,
      displacement: safeTop + 62,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: safeTop + 80)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: HomeLayout.horizontalPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                feed.category.name,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          if (feed.items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No articles yet.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: HomeLayout.horizontalPadding,
              ),
              sliver: SliverList.separated(
                itemCount: feed.items.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: AppSpacing.sm);
                },
                itemBuilder: (context, index) {
                  final article = feed.items[index];
                  return _CategoryArticleCard(
                    article: article,
                    onPressed: () => onArticleSelected(article.slug),
                  );
                },
              ),
            ),
          if (feed.items.isNotEmpty && feed.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  HomeLayout.horizontalPadding,
                  AppSpacing.lg,
                  HomeLayout.horizontalPadding,
                  0,
                ),
                child: Center(
                  child: feed.isLoadingMore
                      ? const CircularProgressIndicator.adaptive()
                      : CupertinoButton(
                          onPressed: onLoadMore,
                          child: Text(
                            feed.loadMoreFailed ? 'Try again' : 'Load more',
                          ),
                        ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

class _CategoryArticleCard extends StatelessWidget {
  const _CategoryArticleCard({required this.article, required this.onPressed});

  final HomeArticle article;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: article.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          height: 118,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 148,
                child: HomeArticleImage(
                  article: article,
                  borderRadius: BorderRadius.circular(HomeLayout.imageRadius),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeArticleMeta(article: article),
                    const SizedBox(height: AppSpacing.xs),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackAction extends StatelessWidget {
  const _BackAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.94),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CupertinoButton(
        minimumSize: const Size.square(44),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: const HugeIcon(
          icon: HugeIconsStrokeRounded.arrowLeft01,
          color: AppTheme.ink,
          size: 21,
        ),
      ),
    );
  }
}

class _CategoryLoading extends StatelessWidget {
  const _CategoryLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }
}

class _CategoryError extends StatelessWidget {
  const _CategoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(onPressed: onRetry, child: const Text('Try again')),
    );
  }
}
