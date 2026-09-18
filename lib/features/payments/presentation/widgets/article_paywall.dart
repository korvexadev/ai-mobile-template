import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../../../shared/widgets/mikozi_cached_network_image.dart';
import '../../../articles/domain/reader_article_repository.dart';
import '../../../profile/application/reader_entitlement_provider.dart';
import '../../application/payments_controller.dart';
import '../payment_pages.dart';
import 'payment_plan_carousel.dart';

class ArticlePaywall extends ConsumerWidget {
  const ArticlePaywall({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ReaderArticleFailure failure;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsControllerProvider);
    final entitlement = ref.watch(readerEntitlementProvider).value;
    if (entitlement?.paymentsEnabled == false) {
      return Center(
        child: CupertinoButton(
          onPressed: onRetry,
          child: const Text('Continue reading'),
        ),
      );
    }
    return Stack(
      children: [
        Positioned.fill(child: _Preview(preview: failure.preview)),
        Positioned.fill(
          top: MediaQuery.sizeOf(context).height * 0.28,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.paperOf(context).withValues(alpha: 0),
                  AppTheme.paperOf(context).withValues(alpha: 0.95),
                  AppTheme.paperOf(context),
                  AppTheme.paperOf(context),
                ],
                stops: [0, 0.2, 0.38, 1],
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.xs,
          right: AppSpacing.xs,
          bottom: AppSpacing.md,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep reading',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Choose plan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedOf(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                payments.when(
                  loading: () => const SizedBox(
                    height: 232,
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                  error: (error, stackTrace) => SizedBox(
                    height: 90,
                    child: Center(
                      child: CupertinoButton(
                        onPressed: () =>
                            ref.invalidate(paymentsControllerProvider),
                        child: const Text('Try again'),
                      ),
                    ),
                  ),
                  data: (state) => PaymentPlanCarousel(
                    plans: state.plans,
                    disabled: state.pending != null || state.processing,
                    processingPlanId: state.processingPlanId,
                    onSelected: (plan) =>
                        showPaymentMethods(context, ref, plan),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.preview});

  final ReaderArticlePreview? preview;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xs, 72, AppSpacing.xs, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (preview != null) ...[
              Text(
                preview!.categoryName.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.brandRed,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                preview!.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              if (preview!.heroImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: MikoziCachedNetworkImage(
                      url: preview!.heroImageUrl!,
                      semanticLabel: preview!.title,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
