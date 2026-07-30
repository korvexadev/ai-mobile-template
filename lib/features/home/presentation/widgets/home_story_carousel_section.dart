import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_spacing.dart';
import '../../domain/homepage.dart';
import '../home_layout.dart';
import 'home_article_image.dart';
import 'home_article_meta.dart';
import 'home_section_heading.dart';

class HomeStoryCarouselSection extends StatelessWidget {
  const HomeStoryCarouselSection({
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
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth =
                constraints.maxWidth - (HomeLayout.horizontalPadding * 2);
            final cardWidth =
                (availableWidth * HomeLayout.horizontalCardWidthFactor).clamp(
                  216.0,
                  HomeLayout.horizontalCardMaxWidth,
                );
            return SizedBox(
              height: HomeLayout.carouselCardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: HomeLayout.horizontalPadding,
                ),
                itemCount: section.articles.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: AppSpacing.sm);
                },
                itemBuilder: (context, index) {
                  return _CarouselStoryCard(
                    article: section.articles[index],
                    width: cardWidth,
                    onPressed: () {
                      onArticleSelected(section.articles[index].slug);
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CarouselStoryCard extends StatelessWidget {
  const _CarouselStoryCard({
    required this.article,
    required this.width,
    required this.onPressed,
  });

  final HomeArticle article;
  final double width;
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
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: HomeLayout.horizontalImageAspectRatio,
                child: HomeArticleImage(
                  article: article,
                  borderRadius: BorderRadius.circular(HomeLayout.imageRadius),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              HomeArticleMeta(article: article),
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
