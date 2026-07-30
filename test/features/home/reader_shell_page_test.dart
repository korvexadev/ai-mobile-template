import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/articles/application/saved_articles_controller.dart';
import 'package:mikozi_mobile/features/articles/domain/saved_article.dart';
import 'package:mikozi_mobile/features/articles/domain/saved_articles_repository.dart';
import 'package:mikozi_mobile/features/home/presentation/reader_shell_page.dart';

void main() {
  testWidgets('bottom navigation switches reader destinations in place', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedArticlesRepositoryProvider.overrideWithValue(
            const _EmptySavedRepository(),
          ),
        ],
        child: const MaterialApp(
          home: ReaderShellPage(destination: ReaderDestination.latest),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsWidgets);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.text('Saved stories'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _EmptySavedRepository implements SavedArticlesRepository {
  const _EmptySavedRepository();

  @override
  Future<List<SavedArticle>> readAll() async => const [];

  @override
  Future<void> setSaved(SavedArticle article, {required bool saved}) async {}
}
