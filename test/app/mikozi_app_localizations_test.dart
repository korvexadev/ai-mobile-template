import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/adaptive/mikozi_page_boundary.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
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

  testWidgets('page boundary retains the dark palette under MaterialApp', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: const MikoziPageBoundary(child: Text('Dark reader')),
      ),
    );

    final context = tester.element(find.text('Dark reader'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Theme.of(context).scaffoldBackgroundColor, AppTheme.darkPaper);
  });

  testWidgets('page boundary retains the dark palette under CupertinoApp', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(
        theme: CupertinoThemeData(brightness: Brightness.dark),
        localizationsDelegates: mikoziLocalizationsDelegates,
        home: MikoziPageBoundary(child: Text('Dark Cupertino reader')),
      ),
    );

    final context = tester.element(find.text('Dark Cupertino reader'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
