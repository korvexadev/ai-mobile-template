import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader_image_cache.g.dart';

const _readerImageCacheKey = 'mikozi-reader-images-v1';

@Riverpod(keepAlive: true)
BaseCacheManager readerImageCache(Ref ref) {
  final manager = CacheManager(
    Config(
      _readerImageCacheKey,
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 240,
    ),
  );
  return manager;
}
