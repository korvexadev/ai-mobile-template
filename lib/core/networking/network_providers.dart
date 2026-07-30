import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

const defaultApiUrl = 'http://localhost:9289/api/v1';
const apiBaseUrl = String.fromEnvironment(
  'MIKOZI_API_URL',
  defaultValue: defaultApiUrl,
);

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );
}
