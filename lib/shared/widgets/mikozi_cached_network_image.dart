import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../app/theme/app_theme.dart';
import '../../core/media/reader_image_cache.dart';
import '../../core/media/reader_image_url.dart';

class MikoziCachedNetworkImage extends ConsumerWidget {
  const MikoziCachedNetworkImage({
    required this.url,
    required this.semanticLabel,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
    super.key,
  });

  final String url;
  final String? semanticLabel;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedUrl = ReaderImageUrl.resolve(url);
    if (resolvedUrl.isEmpty) {
      return error ?? const _ReaderImageFallback();
    }
    final image = CachedNetworkImage(
      imageUrl: resolvedUrl,
      cacheKey: resolvedUrl,
      cacheManager: ref.watch(readerImageCacheProvider),
      httpHeaders: ReaderImageUrl.headers,
      fit: fit,
      filterQuality: FilterQuality.medium,
      fadeInDuration: const Duration(milliseconds: 140),
      fadeOutDuration: const Duration(milliseconds: 80),
      placeholder: (context, url) {
        return placeholder ?? const _ReaderImageFallback(showIcon: false);
      },
      errorWidget: (context, url, errorValue) {
        return error ?? const _ReaderImageFallback();
      },
    );
    final label = semanticLabel?.trim();
    if (label == null || label.isEmpty) {
      return image;
    }
    return Semantics(
      image: true,
      label: label,
      child: ExcludeSemantics(child: image),
    );
  }
}

class _ReaderImageFallback extends StatelessWidget {
  const _ReaderImageFallback({this.showIcon = true});

  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.softSurface,
      child: showIcon
          ? const Center(
              child: HugeIcon(
                icon: HugeIconsStrokeRounded.imageNotFound01,
                color: AppTheme.muted,
                size: 28,
              ),
            )
          : null,
    );
  }
}
