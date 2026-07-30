import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/homepage.dart';

class HomeArticleImage extends StatelessWidget {
  const HomeArticleImage({
    required this.article,
    required this.borderRadius,
    this.fit = BoxFit.cover,
    super.key,
  });

  final HomeArticle article;
  final BorderRadius borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: article.heroImageUrl == null
          ? const _ImageFallback(icon: HugeIconsStrokeRounded.imageNotFound01)
          : Image.network(
              article.heroImageUrl!,
              fit: fit,
              semanticLabel: article.title,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) {
                return const _ImageFallback(
                  icon: HugeIconsStrokeRounded.imageNotFound01,
                );
              },
            ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.icon});

  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.softSurface,
      child: Center(
        child: HugeIcon(icon: icon, color: AppTheme.muted, size: 28),
      ),
    );
  }
}
