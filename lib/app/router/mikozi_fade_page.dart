import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The app-wide transition used by every routed Mikozi page.
class MikoziFadePage<T> extends CustomTransitionPage<T> {
  const MikoziFadePage({required super.key, required super.child})
    : super(
        transitionDuration: const Duration(milliseconds: 160),
        reverseTransitionDuration: const Duration(milliseconds: 120),
        transitionsBuilder: _buildFade,
      );

  static Widget _buildFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    final opacity = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(opacity: opacity, child: child);
  }
}
