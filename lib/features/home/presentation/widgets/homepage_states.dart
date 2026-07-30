import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';

import '../home_layout.dart';

class HomepageSkeleton extends StatelessWidget {
  const HomepageSkeleton({required this.topInset, super.key});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        HomeLayout.horizontalPadding,
        topInset + AppSpacing.md,
        HomeLayout.horizontalPadding,
        120,
      ),
      children: [
        SizedBox(
          height: HomeLayout.leadCardHeight,
          child: DecoratedBox(
            decoration: _skeleton(radius: HomeLayout.cardRadius),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 42,
          child: Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: _skeleton(radius: HomeLayout.controlRadius),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: DecoratedBox(
                  decoration: _skeleton(radius: HomeLayout.controlRadius),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: DecoratedBox(
                  decoration: _skeleton(radius: HomeLayout.controlRadius),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var index = 0; index < 3; index++) ...[
          SizedBox(
            height: HomeLayout.listCardHeight,
            child: DecoratedBox(
              decoration: _skeleton(radius: HomeLayout.cardRadius),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  BoxDecoration _skeleton({required double radius}) {
    return BoxDecoration(
      color: AppTheme.softSurface,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

class HomepageError extends StatelessWidget {
  const HomepageError({
    required this.topInset,
    required this.onRetry,
    super.key,
  });

  final double topInset;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          HomeLayout.horizontalPadding,
          topInset,
          HomeLayout.horizontalPadding,
          HomeLayout.horizontalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(
              icon: HugeIconsStrokeRounded.cloudOff,
              color: AppTheme.muted,
              size: 38,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unable to load stories',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.lg),
            CupertinoButton(
              color: AppTheme.brandRed,
              borderRadius: BorderRadius.circular(HomeLayout.controlRadius),
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyHomepage extends StatelessWidget {
  const EmptyHomepage({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HomeLayout.horizontalPadding),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.muted),
        ),
      ),
    );
  }
}
