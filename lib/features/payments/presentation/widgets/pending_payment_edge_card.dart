import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../../profile/application/reader_entitlement_provider.dart';
import '../../application/payments_controller.dart';
import '../../domain/payment.dart';

class PendingPaymentEdgeCard extends ConsumerWidget {
  const PendingPaymentEdgeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(readerEntitlementProvider).value;
    if (entitlement == null || !entitlement.paymentsEnabled) {
      return const SizedBox.shrink();
    }
    ref.listen(paymentsControllerProvider, (previous, next) {
      final prior = previous?.value?.pending;
      final current = next.value;
      if (prior == null || current == null || current.pending != null) return;
      final completed = current.transactions
          .where((item) => item.id == prior.id)
          .firstOrNull;
      if (completed == null || !context.mounted) return;
      final message = completed.status == PaymentStatus.succeeded
          ? 'Payment confirmed. Your plan is active.'
          : 'Payment ${_statusLabel(completed.status)}.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    });
    final payments = ref.watch(paymentsControllerProvider).value;
    final transaction = payments?.pending;
    if (transaction == null) return const SizedBox.shrink();
    return Positioned(
      left: -36,
      top: MediaQuery.sizeOf(context).height * 0.38,
      child: RotatedBox(
        quarterTurns: 3,
        child: CupertinoButton(
          key: const ValueKey('pending-payment-edge-card'),
          padding: EdgeInsets.zero,
          minimumSize: const Size(104, 34),
          onPressed: () => _showStatus(context, ref, transaction),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppTheme.ink,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(
                  color: AppTheme.white,
                  radius: 7,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Payment',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showStatus(
    BuildContext context,
    WidgetRef ref,
    PaymentTransaction transaction,
  ) async {
    await showAdaptiveDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: const Text('Payment processing'),
        content: Text(
          '${transaction.plan.name} is being verified. You can keep reading '
          'while Mikozi checks the payment.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref
                  .read(paymentsControllerProvider.notifier)
                  .verifyPending();
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: const Text('Check now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(PaymentStatus status) {
  return switch (status) {
    PaymentStatus.pending => 'is processing',
    PaymentStatus.succeeded => 'was confirmed',
    PaymentStatus.failed => 'failed',
    PaymentStatus.refunded => 'was refunded',
  };
}
