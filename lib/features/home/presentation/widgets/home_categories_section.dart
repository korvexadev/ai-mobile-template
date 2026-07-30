import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../domain/homepage.dart';
import '../home_layout.dart';
import 'home_section_heading.dart';

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({
    required this.section,
    required this.onSelected,
    super.key,
  });

  final HomeSection section;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (section.categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeading(title: section.title),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeLayout.horizontalPadding,
          ),
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: section.categories
                .map((category) {
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    color: AppTheme.softSurface,
                    borderRadius: BorderRadius.circular(
                      HomeLayout.controlRadius,
                    ),
                    pressedOpacity: 0.65,
                    onPressed: () => onSelected(category.id),
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}
