import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../../../shared/widgets/mikozi_cached_network_image.dart';
import '../../../shared/widgets/reader_empty_state.dart';
import '../../../shared/widgets/reader_page_header.dart';
import '../application/saved_articles_controller.dart';
import '../domain/saved_article.dart';

class SavedArticlesPage extends ConsumerWidget {
  const SavedArticlesPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    final _ = await ref.refresh(savedReaderArticlesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(savedReaderArticlesProvider);
    return ColoredBox(
      color: AppTheme.paperOf(context),
      child: RefreshIndicator.adaptive(
        key: const ValueKey('saved-articles-refresh'),
        color: AppTheme.brandRed,
        backgroundColor: AppTheme.paperOf(context),
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(child: ReaderPageHeader(title: 'Saved')),
            ...articles.when(
              loading: () => const [_SavedLoading()],
              error: (error, stackTrace) => [
                _SavedError(
                  onRetry: () {
                    ref.invalidate(savedReaderArticlesProvider);
                  },
                ),
              ],
              data: (value) => value.isEmpty
                  ? const [_SavedEmpty()]
                  : _savedGroups(value)
                        .expand(
                          (group) => [
                            SliverToBoxAdapter(
                              child: _SavedGroupHeading(label: group.label),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              sliver: SliverList.separated(
                                itemCount: group.articles.length,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: AppSpacing.xs);
                                },
                                itemBuilder: (context, index) {
                                  final article = group.articles[index];
                                  return Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: AppSpacing.contentMaxWidth,
                                      ),
                                      child: _SavedArticleCard(
                                        article: article,
                                        onPressed: () {
                                          context.push(
                                            '/articles/'
                                            '${Uri.encodeComponent(article.slug)}',
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: AppSpacing.lg),
                            ),
                          ],
                        )
                        .toList(growable: false),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 128)),
          ],
        ),
      ),
    );
  }
}

class _SavedGroupHeading extends StatelessWidget {
  const _SavedGroupHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            0,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Text(
            label,
            key: ValueKey('saved-group-$label'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.inkOf(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedArticleCard extends StatelessWidget {
  const _SavedArticleCard({required this.article, required this.onPressed});

  final SavedArticle article;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: article.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 124,
                    height: 112,
                    child: MikoziCachedNetworkImage(
                      key: ValueKey('saved-image-${article.slug}'),
                      url: article.heroImageUrl ?? '',
                      semanticLabel: article.title,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                article.categoryName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppTheme.brandRed,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxs,
                              ),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: AppTheme.mutedOf(context),
                                ),
                              ),
                            ),
                            Text(
                              _savedTime(article.savedAt),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppTheme.mutedOf(context)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.22,
                              ),
                        ),
                        if (article.summary.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            article.summary.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.mutedOf(context),
                                  height: 1.3,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedArticleGroup {
  const _SavedArticleGroup({required this.label, required this.articles});

  final String label;
  final List<SavedArticle> articles;
}

List<_SavedArticleGroup> _savedGroups(List<SavedArticle> articles) {
  final groups = <String, List<SavedArticle>>{};
  for (final article in articles) {
    final label = _savedDateLabel(article.savedAt);
    groups.putIfAbsent(label, () => []).add(article);
  }
  return groups.entries
      .map(
        (entry) => _SavedArticleGroup(
          label: entry.key,
          articles: List.unmodifiable(entry.value),
        ),
      )
      .toList(growable: false);
}

String _savedDateLabel(DateTime value) {
  final date = value.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final savedDay = DateTime(date.year, date.month, date.day);
  final difference = today.difference(savedDay).inDays;
  if (difference == 0) {
    return 'Today';
  }
  if (difference == 1) {
    return 'Yesterday';
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
  final year = date.year == now.year ? '' : ', ${date.year}';
  return '${months[date.month - 1]} ${date.day}$year';
}

String _savedTime(DateTime value) {
  final time = value.toLocal();
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

class _SavedLoading extends StatelessWidget {
  const _SavedLoading();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CupertinoActivityIndicator(color: AppTheme.brandRed),
      ),
    );
  }
}

class _SavedEmpty extends StatelessWidget {
  const _SavedEmpty();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: const ReaderEmptyState(
        icon: HugeIconsStrokeRounded.bookmark02,
        title: 'No saved stories yet',
        message: 'Save an article while reading to find it here later.',
      ),
    );
  }
}

class _SavedError extends StatelessWidget {
  const _SavedError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CupertinoButton(
          onPressed: onRetry,
          child: const Text('Try again'),
        ),
      ),
    );
  }
}
