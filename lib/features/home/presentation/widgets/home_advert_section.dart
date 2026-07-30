import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/homepage.dart';

import '../home_layout.dart';

class HomeAdvertSection extends StatelessWidget {
  const HomeAdvertSection({required this.section, super.key});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Advertisement',
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: HomeLayout.horizontalPadding,
        ),
        constraints: const BoxConstraints(minHeight: 92),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(HomeLayout.cardRadius),
        ),
        child: Text(
          'ADVERTISEMENT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.muted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
