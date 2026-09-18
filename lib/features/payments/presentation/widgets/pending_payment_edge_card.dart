import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../../profile/application/reader_entitlement_provider.dart';
import '../../application/payments_controller.dart';
import '../../domain/payment.dart';

class PendingPaymentEdgeCard extends ConsumerStatefulWidget {
  const PendingPaymentEdgeCard({super.key});

  @override
  ConsumerState<PendingPaymentEdgeCard> createState() {
    return _PendingPaymentEdgeCardState();
  }
}

class _PendingPaymentEdgeCardState
    extends ConsumerState<PendingPaymentEdgeCard> {
  Timer? _feedbackTimer;
  String? _completionMessage;

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      _showFeedback(message);
    });
    if (_completionMessage case final message?) {
      return _PaymentCompletionToast(message: message);
    }
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
            decoration: BoxDecoration(
              color: AppTheme.inkOf(context),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(
                  color: AppTheme.surfaceOf(context),
                  radius: 7,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Payment',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.surfaceOf(context),
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

  void _showFeedback(String message) {
    if (!mounted) return;
    _feedbackTimer?.cancel();
    setState(() => _completionMessage = message);
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _completionMessage = null);
    });
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

class _PaymentCompletionToast extends StatelessWidget {
  const _PaymentCompletionToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: const ValueKey('payment-completion-feedback'),
      left: AppSpacing.md,
      right: AppSpacing.md,
      top: AppSpacing.sm,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          liveRegion: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.inkOf(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.surfaceOf(context),
                ),
              ),
            ),
          ),
        ),
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
