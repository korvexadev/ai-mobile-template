import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/app/router/mikozi_fade_page.dart';

void main() {
  testWidgets('uses the fast app-wide fade transition', (tester) async {
    final page = MikoziFadePage<void>(
      key: const ValueKey('page'),
      child: const Text('Destination'),
    );
    late Widget transition;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            transition = page.transitionsBuilder(
              context,
              const AlwaysStoppedAnimation(0.5),
              const AlwaysStoppedAnimation(0),
              page.child,
            );
            return transition;
          },
        ),
      ),
    );

    expect(page.transitionDuration, const Duration(milliseconds: 160));
    expect(page.reverseTransitionDuration, const Duration(milliseconds: 120));
    expect(transition, isA<FadeTransition>());
    expect(find.text('Destination'), findsOneWidget);
  });

  testWidgets('honors the system reduced-motion preference', (tester) async {
    final page = MikoziFadePage<void>(
      key: const ValueKey('page'),
      child: const Text('Destination'),
    );
    late Widget transition;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              transition = page.transitionsBuilder(
                context,
                const AlwaysStoppedAnimation(0.5),
                const AlwaysStoppedAnimation(0),
                page.child,
              );
              return transition;
            },
          ),
        ),
      ),
    );

    expect(transition, same(page.child));
    expect(find.text('Destination'), findsOneWidget);
  });
}
