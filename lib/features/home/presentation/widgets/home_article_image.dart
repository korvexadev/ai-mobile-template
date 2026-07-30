import 'package:flutter/material.dart';
import '../../../../shared/widgets/mikozi_cached_network_image.dart';
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
          ? const _ImageFallback()
          : MikoziCachedNetworkImage(
              url: article.heroImageUrl!,
              fit: fit,
              semanticLabel: article.title,
            ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const MikoziCachedNetworkImage(url: '', semanticLabel: null);
  }
}
