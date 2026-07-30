import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/core/constants/api_constants.dart';
import 'package:mikozi_mobile/core/media/reader_image_url.dart';

void main() {
  test('keeps absolute image URLs unchanged', () {
    expect(
      ReaderImageUrl.resolve('https://images.example/story.jpg'),
      'https://images.example/story.jpg',
    );
  });

  test(
    'resolves backend-relative media URLs against the configured origin',
    () {
      expect(
        ReaderImageUrl.resolve('/media/articles/story.jpg'),
        '${ApiConstants.origin}/media/articles/story.jpg',
      );
    },
  );
}
