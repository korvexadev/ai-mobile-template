import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../../../shared/widgets/mikozi_cached_network_image.dart';
import '../../domain/reader_article.dart';

class SimilarArticlesSection extends StatelessWidget {
  const SimilarArticlesSection({
    required this.articles,
    required this.onSelected,
    super.key,
  });

  final List<ReaderSimilarArticle> articles;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Similar stories',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: articles.length,
            separatorBuilder: (context, index) {
              return const SizedBox(width: AppSpacing.sm);
            },
            itemBuilder: (context, index) {
              final article = articles[index];
              return _SimilarArticleCard(
                article: article,
                onPressed: () => onSelected(article.slug),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarArticleCard extends StatelessWidget {
  const _SimilarArticleCard({required this.article, required this.onPressed});

  final ReaderSimilarArticle article;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${article.title}, ${_scoreLabel(article.similarityScore)} similar',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: 252,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: article.heroImageUrl == null
                      ? ColoredBox(color: AppTheme.softSurfaceOf(context))
                      : MikoziCachedNetworkImage(
                          url: article.heroImageUrl!,
                          fit: BoxFit.cover,
                          semanticLabel: article.title,
                          error: ColoredBox(
                            color: AppTheme.softSurfaceOf(context),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      article.category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.mutedOf(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${_scoreLabel(article.similarityScore)} match',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.brandRed,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _scoreLabel(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}
