// Generated-contract boundary for GET /api/v1/reader/homepage.
// Regenerate this layer when openapi/mikozi.v1.json changes.
import 'package:dio/dio.dart';

class MikoziApiClient {
  MikoziApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getReaderHomepage() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reader/homepage',
      options: Options(headers: const {'Cache-Control': 'no-cache'}),
    );
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid homepage response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> getReaderArticle({
    required String slug,
    required String accessToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reader/articles/slug/${Uri.encodeComponent(slug)}',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Cache-Control': 'no-cache',
        },
      ),
    );
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid article response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> getReaderEntitlement({
    required String accessToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/subscriptions/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Cache-Control': 'no-cache',
        },
      ),
    );
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid subscription response.');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getPaymentPlans({
    required String accessToken,
  }) {
    return _getItems('/subscriptions/plans', accessToken);
  }

  Future<List<Map<String, dynamic>>> getMobileMoneyOperators({
    required String accessToken,
  }) {
    return _getItems(
      '/subscriptions/payment-methods/mobile-money/operators',
      accessToken,
    );
  }

  Future<List<Map<String, dynamic>>> getPaymentTransactions({
    required String accessToken,
  }) {
    return _getItems('/subscriptions/transactions', accessToken);
  }

  Future<Map<String, dynamic>?> getPendingPayment({
    required String accessToken,
  }) async {
    final data = await _getData(
      '/subscriptions/transactions/pending',
      accessToken,
    );
    final transaction = data['transaction'];
    return transaction is Map<String, dynamic> ? transaction : null;
  }

  Future<Map<String, dynamic>> initiateMobileMoneyPayment({
    required String accessToken,
    required String planId,
    required String operatorId,
    required String phoneNumber,
    required String idempotencyKey,
  }) {
    return _postData('/subscriptions/payments/mobile-money', accessToken, {
      'planId': planId,
      'operatorId': operatorId,
      'phoneNumber': phoneNumber,
    }, idempotencyKey);
  }

  Future<Map<String, dynamic>> initiateBankTransferPayment({
    required String accessToken,
    required String planId,
    required String idempotencyKey,
  }) {
    return _postData('/subscriptions/payments/bank-transfer', accessToken, {
      'planId': planId,
    }, idempotencyKey);
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String accessToken,
    required String transactionId,
  }) {
    return _postData(
      '/subscriptions/transactions/${Uri.encodeComponent(transactionId)}/verify',
      accessToken,
      const {},
      null,
    );
  }

  Future<List<Map<String, dynamic>>> _getItems(
    String path,
    String accessToken,
  ) async {
    final data = await _getData(path, accessToken);
    final items = data['items'];
    if (items is! List<dynamic>) {
      throw const FormatException('Invalid collection response.');
    }
    return items.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _getData(String path, String accessToken) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Cache-Control': 'no-cache',
        },
      ),
    );
    return _envelopeData(response.data);
  }

  Future<Map<String, dynamic>> _postData(
    String path,
    String accessToken,
    Map<String, dynamic> body,
    String? idempotencyKey,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Idempotency-Key': ?idempotencyKey,
        },
      ),
    );
    return _envelopeData(response.data);
  }

  Map<String, dynamic> _envelopeData(Map<String, dynamic>? envelope) {
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid API response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> getReaderCategoryArticles({
    required String slug,
    int limit = 30,
    int offset = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reader/categories/${Uri.encodeComponent(slug)}/articles',
      queryParameters: {'limit': limit, 'offset': offset},
      options: Options(headers: const {'Cache-Control': 'no-cache'}),
    );
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid category articles response.');
    }
    return data;
  }
}
