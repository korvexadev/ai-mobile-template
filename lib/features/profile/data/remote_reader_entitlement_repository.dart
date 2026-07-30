import 'package:dio/dio.dart';

import '../../../core/networking/mikozi_api_client.dart';
import '../domain/reader_entitlement.dart';
import '../domain/reader_entitlement_repository.dart';

class RemoteReaderEntitlementRepository implements ReaderEntitlementRepository {
  RemoteReaderEntitlementRepository(this._api, this._accessToken);

  final MikoziApiClient _api;
  final Future<String?> Function() _accessToken;

  @override
  Future<ReaderEntitlement> fetch() async {
    final token = await _accessToken();
    if (token == null) {
      throw const ReaderEntitlementFailure('Sign in to view your plan.');
    }
    try {
      return _map(await _api.getReaderEntitlement(accessToken: token));
    } on DioException {
      throw const ReaderEntitlementFailure(
        'Your subscription could not be loaded.',
      );
    } on FormatException {
      throw const ReaderEntitlementFailure(
        'Mikozi returned an unexpected subscription.',
      );
    } on TypeError {
      throw const ReaderEntitlementFailure(
        'Mikozi returned an unexpected subscription.',
      );
    }
  }

  ReaderEntitlement _map(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>;
    return ReaderEntitlement(
      planName: plan['name'] as String,
      dailyArticleLimit: plan['dailyArticleLimit'] as int?,
      articlesReadToday: json['articlesReadToday'] as int,
      articlesRemainingToday: json['articlesRemainingToday'] as int?,
      resetsAt: DateTime.parse(json['resetsAt'] as String),
      endsAt: _date(json['endsAt']),
    );
  }

  DateTime? _date(Object? value) {
    return value is String ? DateTime.tryParse(value) : null;
  }
}
