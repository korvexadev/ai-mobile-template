import 'package:flutter/material.dart';

import '../home_layout.dart';

class HomeSectionHeading extends StatelessWidget {
  const HomeSectionHeading({required this.title, super.key});

  final String? title;

  @override
  Widget build(BuildContext context) {
    if (title == null || title!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeLayout.horizontalPadding,
      ),
      child: Text(
        title!,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
