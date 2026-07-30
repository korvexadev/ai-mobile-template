import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../../../shared/widgets/reader_page_header.dart';

class ReaderPlaceholderTab extends StatelessWidget {
  const ReaderPlaceholderTab({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.paper,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: ReaderPageHeader(title: title)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  128,
                ),
                child: Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
