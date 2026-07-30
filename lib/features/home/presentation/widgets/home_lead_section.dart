import 'package:flutter/material.dart';

import '../../domain/homepage.dart';
import '../home_layout.dart';
import 'home_article_image.dart';
import 'home_story_gradient.dart';

class HomeLeadSection extends StatelessWidget {
  const HomeLeadSection({required this.section, super.key});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    if (section.articles.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasMultipleStories = section.articles.length > 1;
        final cardWidth =
            constraints.maxWidth -
            (HomeLayout.horizontalPadding * 2) -
            (hasMultipleStories ? HomeLayout.trailingCardPeek : 0);
        return SizedBox(
          height: HomeLayout.leadCardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: hasMultipleStories
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: HomeLayout.horizontalPadding,
            ),
            itemCount: section.articles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final article = section.articles[index];
              return SizedBox(
                width: cardWidth,
                child: Semantics(
                  label: article.title,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(HomeLayout.cardRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        HomeArticleImage(
                          article: article,
                          borderRadius: BorderRadius.zero,
                        ),
                        HomeStoryGradient(article: article, large: true),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
