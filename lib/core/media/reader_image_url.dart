import '../constants/api_constants.dart';

abstract final class ReaderImageUrl {
  static const headers = <String, String>{
    'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
    'User-Agent': 'Mikozi/1.0 (Flutter)',
  };

  static String resolve(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }
    final uri = Uri.tryParse(trimmed);
    if (uri?.hasScheme == true) {
      return trimmed;
    }
    return Uri.parse(ApiConstants.origin).resolve(trimmed).toString();
  }
}
