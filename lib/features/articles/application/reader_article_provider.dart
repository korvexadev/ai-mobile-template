import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/networking/mikozi_api_client.dart';
import '../../../core/networking/network_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/remote_reader_article_repository.dart';
import '../domain/reader_article.dart';
import '../domain/reader_article_repository.dart';

part 'reader_article_provider.g.dart';

@Riverpod(keepAlive: true)
ReaderArticleRepository readerArticleRepository(Ref ref) {
  return RemoteReaderArticleRepository(
    MikoziApiClient(ref.watch(dioProvider)),
    () async {
      final session = await ref
          .read(authControllerProvider.notifier)
          .validSession();
      return session?.tokens.accessToken;
    },
  );
}

@Riverpod(retry: _noRetry)
Future<ReaderArticle> readerArticle(Ref ref, String slug) {
  return ref.watch(readerArticleRepositoryProvider).readBySlug(slug);
}

Duration? _noRetry(int retryCount, Object error) => null;
