import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../../../shared/widgets/mikozi_cached_network_image.dart';
import '../application/article_actions_controller.dart';
import '../application/reader_article_provider.dart';
import '../application/saved_articles_controller.dart';
import '../domain/article_share_service.dart';
import '../domain/reader_article.dart';
import '../domain/reader_article_repository.dart';
import 'widgets/article_floating_header.dart';
import 'widgets/article_section_renderer.dart';
import 'widgets/similar_articles_section.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  const ArticleDetailPage({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  Future<void> _refresh() async {
    final _ = await ref.refresh(readerArticleProvider(widget.slug).future);
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }

  Future<void> _toggleSaved(ReaderArticle article) async {
    final success = await ref
        .read(articleActionsControllerProvider(widget.slug).notifier)
        .toggleSaved(article);
    if (!success && mounted) {
      await _showActionError('The article could not be saved.');
    }
  }

  Future<void> _share(ReaderArticle article, ArticleShareAnchor anchor) async {
    final success = await ref
        .read(articleActionsControllerProvider(widget.slug).notifier)
        .share(article, anchor);
    if (!success && mounted) {
      await _showActionError('The article could not be shared.');
    }
  }

  Future<void> _showActionError(String message) {
    return showAdaptiveDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final article = ref.watch(readerArticleProvider(widget.slug));
    ref.listen(readerArticleProvider(widget.slug), (previous, next) {
      final value = next.value;
      if (value != null) {
        unawaited(
          ref
              .read(savedArticlesControllerProvider.notifier)
              .refreshSnapshot(value),
        );
      }
    });
    final actions = ref.watch(articleActionsControllerProvider(widget.slug));
    final actionState = actions.value;
    final loadedArticle = article.value;
    return ColoredBox(
      color: AppTheme.paper,
      child: Stack(
        children: [
          Positioned.fill(
            child: article.when(
              loading: _ArticleLoading.new,
              error: (error, stackTrace) =>
                  _ArticleError(error: error, onRetry: _refresh),
              data: (value) => _ArticleBody(
                article: value,
                controller: _scrollController,
                onRefresh: _refresh,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ArticleFloatingHeader(
              onBack: _goBack,
              onShare: loadedArticle == null
                  ? null
                  : (anchor) => _share(loadedArticle, anchor),
              onSave: actionState == null || loadedArticle == null
                  ? null
                  : () => _toggleSaved(loadedArticle),
              isSaved: actionState?.isSaved ?? false,
              isSharing: actionState?.isSharing ?? false,
              isSaving: actions.isLoading || (actionState?.isSaving ?? false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleBody extends StatelessWidget {
  const _ArticleBody({
    required this.article,
    required this.controller,
    required this.onRefresh,
  });

  final ReaderArticle article;
  final ScrollController controller;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    return RefreshIndicator.adaptive(
      key: const ValueKey('article-adaptive-refresh-control'),
      color: AppTheme.brandRed,
      backgroundColor: AppTheme.paper,
      edgeOffset: safeTop + 46,
      displacement: safeTop + 66,
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: safeTop + 76)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            sliver: SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.contentMaxWidth,
                ),
                child: _ArticleContent(article: article),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

class _ArticleContent extends StatelessWidget {
  const _ArticleContent({required this.article});

  final ReaderArticle article;

  @override
  Widget build(BuildContext context) {
    final published = _publicationDate(article.publishedAt);
    final author = article.author.displayName?.trim();
    final byline = author != null && author.isNotEmpty ? 'By $author' : null;
    final metadata = <String?>[
      byline,
      published,
    ].whereType<String>().join('  ·  ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.category.name.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.brandRed,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          article.title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 35,
            height: 1.08,
            letterSpacing: -0.9,
          ),
        ),
        if (article.summary.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            article.summary,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.muted,
              fontWeight: FontWeight.w500,
              height: 1.48,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (article.heroImageUrl?.trim().isNotEmpty == true) ...[
          _HeroImage(url: article.heroImageUrl!.trim(), label: article.title),
          const SizedBox(height: AppSpacing.md),
        ],
        if (metadata.isNotEmpty)
          Text(
            metadata,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        for (final section in article.sections) ...[
          ArticleSectionRenderer(key: ValueKey(section.id), section: section),
          const SizedBox(height: AppSpacing.lg),
        ],
        SimilarArticlesSection(
          articles: article.similarArticles,
          onSelected: (slug) {
            context.push('/articles/${Uri.encodeComponent(slug)}');
          },
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: MikoziCachedNetworkImage(url: url, semanticLabel: label),
      ),
    );
  }
}

class _ArticleLoading extends StatelessWidget {
  const _ArticleLoading();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          84,
          AppSpacing.xs,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final width in [double.infinity, double.infinity, 240.0]) ...[
              Container(
                width: width,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.softSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.lg),
            const AspectRatio(
              aspectRatio: 4 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.softSurface,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleError extends StatelessWidget {
  const _ArticleError({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      ReaderArticleFailure(code: 'DAILY_ARTICLE_LIMIT_REACHED') =>
        'Your reading limit has been reached for today.',
      ReaderArticleFailure(:final message) => message,
      _ => 'The article could not be loaded. Try again.',
    };
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}

String? _publicationDate(DateTime? value) {
  if (value == null) {
    return null;
  }
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final local = value.toLocal();
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}
