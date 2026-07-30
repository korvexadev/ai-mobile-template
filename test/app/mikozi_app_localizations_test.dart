import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/adaptive/mikozi_page_boundary.dart';
import 'package:mikozi_mobile/main.dart';

void main() {
  testWidgets('shared page contracts are available under CupertinoApp', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(
        localizationsDelegates: mikoziLocalizationsDelegates,
        supportedLocales: [Locale('en', 'US')],
        home: MikoziPageBoundary(
          child: TextField(
            decoration: InputDecoration(hintText: 'Shared field'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(Material), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared page boundary remains valid under MaterialApp', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MikoziPageBoundary(
          child: TextField(
            decoration: InputDecoration(hintText: 'Shared field'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
