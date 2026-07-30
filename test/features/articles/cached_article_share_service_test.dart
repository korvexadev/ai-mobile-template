import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/articles/data/cached_article_share_service.dart';
import 'package:mikozi_mobile/features/articles/domain/article_share_service.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  test(
    'shares copy with an existing cached image without another fetch',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'mikozi-share-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final image = File('${directory.path}/cached-image');
      await image.writeAsBytes(const [0xFF, 0xD8, 0xFF, 0xD9]);
      final lookup = _CachedImageLookup(image);
      ShareParams? captured;
      final service = CachedArticleShareService(
        imageLookup: lookup,
        nativeShare: (params) async {
          captured = params;
          return ShareResult.unavailable;
        },
      );

      await service.share(_request(imageUrl: 'https://images.test/story.jpg'));

      expect(lookup.readCount, 1);
      expect(captured?.text, 'Story title\n\nStory summary');
      expect(captured?.files, hasLength(1));
      expect(captured?.files?.single.path, image.path);
      expect(captured?.files?.single.mimeType, 'image/jpeg');
      expect(captured?.sharePositionOrigin?.width, 44);
    },
  );

  test('shares copy only when the image is not already cached', () async {
    final lookup = _CachedImageLookup(null);
    ShareParams? captured;
    final service = CachedArticleShareService(
      imageLookup: lookup,
      nativeShare: (params) async {
        captured = params;
        return ShareResult.unavailable;
      },
    );

    await service.share(_request(imageUrl: 'https://images.test/story.jpg'));

    expect(lookup.readCount, 1);
    expect(captured?.files, isNull);
    expect(captured?.text, 'Story title\n\nStory summary');
  });
}

ArticleShareRequest _request({required String imageUrl}) {
  return ArticleShareRequest(
    title: 'Story title',
    summary: 'Story summary',
    imageUrl: imageUrl,
    anchor: const ArticleShareAnchor(left: 8, top: 48, width: 44, height: 44),
  );
}

class _CachedImageLookup implements CachedImageLookup {
  _CachedImageLookup(this.file);

  final File? file;
  int readCount = 0;

  @override
  Future<File?> read(String url) async {
    readCount += 1;
    return file;
  }
}
