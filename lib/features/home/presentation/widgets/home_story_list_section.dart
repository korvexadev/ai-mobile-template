import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../domain/homepage.dart';
import '../home_layout.dart';
import 'home_article_image.dart';
import 'home_article_meta.dart';
import 'home_section_heading.dart';

class HomeStoryListSection extends StatelessWidget {
  const HomeStoryListSection({
    required this.section,
    required this.onArticleSelected,
    required this.onMore,
    super.key,
  });

  final HomeSection section;
  final ValueChanged<String> onArticleSelected;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    if (section.articles.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeading(title: section.title, onMore: onMore),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeLayout.horizontalPadding,
          ),
          child: Column(
            children: [
              for (var index = 0; index < section.articles.length; index++) ...[
                _CompactStoryCard(
                  article: section.articles[index],
                  onPressed: () {
                    onArticleSelected(section.articles[index].slug);
                  },
                ),
                if (index != section.articles.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactStoryCard extends StatelessWidget {
  const _CompactStoryCard({required this.article, required this.onPressed});

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
        child: Container(
          height: HomeLayout.listCardHeight,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppTheme.softSurface,
            borderRadius: BorderRadius.circular(HomeLayout.cardRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 112,
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
                    Row(
                      children: [
                        Expanded(child: HomeArticleMeta(article: article)),
                        const HugeIcon(
                          icon: HugeIconsStrokeRounded.moreVertical,
                          color: AppTheme.muted,
                          size: 18,
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
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.muted,
                          height: 1.3,
                        ),
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
