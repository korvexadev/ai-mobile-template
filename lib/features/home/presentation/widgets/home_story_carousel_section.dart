import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_spacing.dart';
import '../../domain/homepage.dart';
import '../home_layout.dart';
import 'home_article_image.dart';
import 'home_section_heading.dart';
import 'home_story_gradient.dart';

class HomeStoryCarouselSection extends StatelessWidget {
  const HomeStoryCarouselSection({required this.section, super.key});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    if (section.articles.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeading(title: section.title),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final hasMultipleStories = section.articles.length > 1;
            final cardWidth =
                constraints.maxWidth -
                (HomeLayout.horizontalPadding * 2) -
                (hasMultipleStories ? HomeLayout.trailingCardPeek : 0);
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
  const _CarouselStoryCard({required this.article, required this.width});

  final HomeArticle article;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HomeLayout.cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            HomeArticleImage(article: article, borderRadius: BorderRadius.zero),
            HomeStoryGradient(article: article),
          ],
        ),
      ),
    );
  }
}
