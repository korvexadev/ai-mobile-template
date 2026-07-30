import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_spacing.dart';
import '../../domain/homepage.dart';
import 'home_article_meta.dart';

/// Readable editorial copy drawn directly over story artwork.
class HomeStoryGradient extends StatelessWidget {
  const HomeStoryGradient({
    required this.article,
    this.large = false,
    super.key,
  });

  final HomeArticle article;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.18),
              Colors.black.withValues(alpha: 0.9),
            ],
            stops: const [0, 0.34, 1],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeArticleMeta(article: article, onDark: true),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (large
                              ? Theme.of(context).textTheme.headlineSmall
                              : Theme.of(context).textTheme.titleLarge)
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: large ? 1.12 : 1.15,
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
