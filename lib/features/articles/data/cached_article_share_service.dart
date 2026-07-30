import 'dart:io';
import 'dart:ui';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/media/reader_image_url.dart';
import '../domain/article_share_service.dart';

typedef NativeShare = Future<ShareResult> Function(ShareParams params);

abstract interface class CachedImageLookup {
  Future<File?> read(String url);
}

class CacheManagerImageLookup implements CachedImageLookup {
  const CacheManagerImageLookup(this._cacheManager);

  final BaseCacheManager _cacheManager;

  @override
  Future<File?> read(String url) async {
    return (await _cacheManager.getFileFromCache(url))?.file;
  }
}

class CachedArticleShareService implements ArticleShareService {
  const CachedArticleShareService({
    required this.imageLookup,
    this.nativeShare,
  });

  final CachedImageLookup imageLookup;
  final NativeShare? nativeShare;

  @override
  Future<void> share(ArticleShareRequest request) async {
    final cachedImage = await _readCachedImage(request.imageUrl);
    final files = cachedImage == null
        ? null
        : [XFile(cachedImage.path, mimeType: cachedImage.mimeType)];
    final summary = request.summary.trim();
    final copy = summary.isEmpty
        ? request.title.trim()
        : '${request.title.trim()}\n\n$summary';
    final share = nativeShare ?? SharePlus.instance.share;
    await share(
      ShareParams(
        title: request.title,
        subject: request.title,
        text: copy,
        files: files,
        sharePositionOrigin: Rect.fromLTWH(
          request.anchor.left,
          request.anchor.top,
          request.anchor.width,
          request.anchor.height,
        ),
      ),
    );
  }

  Future<_CachedImage?> _readCachedImage(String? imageUrl) async {
    final url = ReaderImageUrl.resolve(imageUrl ?? '');
    if (url.isEmpty) {
      return null;
    }
    final file = await imageLookup.read(url);
    if (file == null || !await file.exists()) {
      return null;
    }
    return _CachedImage(path: file.path, mimeType: await _imageMimeType(file));
  }
}

class _CachedImage {
  const _CachedImage({required this.path, required this.mimeType});

  final String path;
  final String mimeType;
}

Future<String> _imageMimeType(File file) async {
  final handle = await file.open();
  try {
    final bytes = await handle.read(12);
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
        String.fromCharCodes(bytes.skip(8).take(4)) == 'WEBP') {
      return 'image/webp';
    }
    return 'image/*';
  } finally {
    await handle.close();
  }
}
