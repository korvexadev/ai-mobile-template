import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../home_layout.dart';

class HomeSectionHeading extends StatelessWidget {
  const HomeSectionHeading({required this.title, this.onMore, super.key});

  final String? title;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    if (title == null || title!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeLayout.horizontalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (onMore != null)
            CupertinoButton(
              key: const ValueKey('home-section-more'),
              minimumSize: const Size(44, 36),
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              onPressed: onMore,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'More',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.brandRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  const HugeIcon(
                    icon: HugeIconsStrokeRounded.arrowRight01,
                    color: AppTheme.brandRed,
                    size: 17,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
