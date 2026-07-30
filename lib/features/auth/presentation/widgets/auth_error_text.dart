import 'package:flutter/material.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
import 'package:mikozi_mobile/shared/design_system/app_spacing.dart';

class AuthErrorText extends StatelessWidget {
  const AuthErrorText({required this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: message == null
          ? const SizedBox(height: AppSpacing.sm)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  message!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.error),
                ),
              ),
            ),
    );
  }
}
