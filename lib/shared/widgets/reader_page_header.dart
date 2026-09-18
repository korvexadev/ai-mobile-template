import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../design_system/app_spacing.dart';

class ReaderPageHeader extends StatelessWidget {
  const ReaderPageHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.contentMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  color: AppTheme.inkOf(context),
                  fontFamily: 'Manrope',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
