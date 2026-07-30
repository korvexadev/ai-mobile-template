import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../application/app_version_provider.dart';
import '../application/reader_entitlement_provider.dart';
import '../domain/reader_entitlement.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPage(
      title: 'Notifications',
      child: _QuietState(
        icon: HugeIconsStrokeRounded.notification02,
        label: 'No notification preferences yet.',
      ),
    );
  }
}

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPage(
      title: 'Transactions',
      child: _QuietState(
        icon: HugeIconsStrokeRounded.invoice02,
        label: 'No transactions yet.',
      ),
    );
  }
}

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(readerEntitlementProvider);
    return _SettingsPage(
      title: 'Subscription',
      onRefresh: () async {
        final _ = await ref.refresh(readerEntitlementProvider.future);
      },
      child: entitlement.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stackTrace) => _RetryState(
          onPressed: () {
            ref.invalidate(readerEntitlementProvider);
          },
        ),
        data: _SubscriptionDetails.new,
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsPage(
      title: 'Privacy policy',
      child: _ReadingCopy(
        sections: [
          (
            'Your account',
            'Mikozi uses your phone number to sign you in and your name to '
                'identify your reader profile.',
          ),
          (
            'Reading',
            'Article reads are recorded to apply your daily subscription '
                'allowance. Reopening the same story on the same UTC day does '
                'not use another story.',
          ),
          (
            'Saved stories',
            'Saved stories are kept on this device. Removing the app or its '
                'local data may remove them.',
          ),
          (
            'Account controls',
            'You can sign out at any time. Account deletion is currently '
                'completed by Mikozi support.',
          ),
        ],
      ),
    );
  }
}

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).value ?? '—';
    return _SettingsPage(
      title: 'About',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/brand/mikozi-logo.png',
              width: 88,
              height: 88,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Mikozi', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Independent stories, made for reading.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Version $version',
              key: const ValueKey('about-app-version'),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.title,
    required this.child,
    this.onRefresh,
  });

  final String title;
  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final content = CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      CupertinoButton(
                        key: const ValueKey('settings-back'),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(44, 44),
                        onPressed: () => context.pop(),
                        child: const HugeIcon(
                          icon: HugeIconsStrokeRounded.arrowLeft01,
                          color: AppTheme.ink,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.contentMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                child: child,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
    return ColoredBox(
      color: AppTheme.paper,
      child: onRefresh == null
          ? content
          : RefreshIndicator.adaptive(
              color: AppTheme.brandRed,
              backgroundColor: AppTheme.paper,
              onRefresh: onRefresh!,
              child: content,
            ),
    );
  }
}

class _SubscriptionDetails extends StatelessWidget {
  const _SubscriptionDetails(this.entitlement);

  final ReaderEntitlement entitlement;

  @override
  Widget build(BuildContext context) {
    final remaining = entitlement.isUnlimited
        ? 'Unlimited'
        : entitlement.articlesRemainingToday.toString();
    final limit = entitlement.dailyArticleLimit?.toString() ?? 'Unlimited';
    return Align(
      alignment: Alignment.topCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: 'Plan', value: entitlement.planName),
              const Divider(height: AppSpacing.lg),
              _DetailRow(label: 'Daily stories', value: limit),
              const Divider(height: AppSpacing.lg),
              _DetailRow(
                label: 'Read today',
                value: entitlement.articlesReadToday.toString(),
              ),
              const Divider(height: AppSpacing.lg),
              _DetailRow(label: 'Remaining', value: remaining),
              const Divider(height: AppSpacing.lg),
              _DetailRow(
                label: 'Resets',
                value: _shortDateTime(entitlement.resetsAt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ReadingCopy extends StatelessWidget {
  const _ReadingCopy({required this.sections});

  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final section in sections) ...[
            Text(section.$1, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              section.$2,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.55),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _QuietState extends StatelessWidget {
  const _QuietState({required this.icon, required this.label});

  final List<List<dynamic>> icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: AppTheme.muted, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton(
        onPressed: onPressed,
        child: const Text('Try again'),
      ),
    );
  }
}

String _shortDateTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
