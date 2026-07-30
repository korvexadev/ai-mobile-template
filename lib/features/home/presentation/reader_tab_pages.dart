import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
import 'package:mikozi_mobile/features/auth/application/auth_controller.dart';
import 'package:mikozi_mobile/shared/design_system/app_spacing.dart';
import 'package:mikozi_mobile/shared/design_system/mikozi_brand.dart';

class ReaderHomeTab extends StatelessWidget {
  const ReaderHomeTab({super.key});

  static const _stories = <_DummyStory>[
    _DummyStory(
      category: 'MALAWI',
      title: 'The stories shaping the day, selected for a clearer morning.',
      tone: Color(0xFFF1D7D8),
    ),
    _DummyStory(
      category: 'CULTURE',
      title: 'A new generation is changing how local stories are told.',
      tone: Color(0xFFE2E5D8),
    ),
    _DummyStory(
      category: 'BUSINESS',
      title: 'Small decisions with a much wider effect on everyday life.',
      tone: Color(0xFFE7DDD1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey('reader-home'),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MikoziBrand(logoSize: 38),
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: () {},
                    icon: const HugeIcon(
                      icon: HugeIconsStrokeRounded.notification02,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xxl,
              AppSpacing.page,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Today.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            sliver: SliverList.separated(
              itemCount: _stories.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: AppSpacing.xl);
              },
              itemBuilder: (context, index) {
                return _StoryCard(story: _stories[index], featured: index == 0);
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, required this.featured});

  final _DummyStory story;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: story.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: featured ? 1.45 : 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: story.tone,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'M',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.brandRed.withValues(alpha: 0.72),
                      fontSize: featured ? 88 : 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            story.category,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.brandRed,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            story.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: featured
                ? Theme.of(context).textTheme.headlineMedium
                : Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Text(title, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class ReaderProfileTab extends ConsumerWidget {
  const ReaderProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).value?.session;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Text(
              session?.profile.displayName ?? 'Profile',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              session?.profile.phoneNumber ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _DummyStory {
  const _DummyStory({
    required this.category,
    required this.title,
    required this.tone,
  });

  final String category;
  final String title;
  final Color tone;
}
