import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../domain/payment.dart';

class PaymentPlanCarousel extends StatefulWidget {
  const PaymentPlanCarousel({
    required this.plans,
    required this.onSelected,
    this.disabled = false,
    this.processingPlanId,
    super.key,
  });

  final List<PaymentPlan> plans;
  final ValueChanged<PaymentPlan> onSelected;
  final bool disabled;
  final String? processingPlanId;

  @override
  State<PaymentPlanCarousel> createState() => _PaymentPlanCarouselState();
}

class _PaymentPlanCarouselState extends State<PaymentPlanCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plans.isEmpty) {
      return const SizedBox(height: 90);
    }
    if (widget.plans.length == 1) {
      final plan = widget.plans.single;
      return SizedBox(
        key: const ValueKey('single-payment-plan'),
        height: 232,
        width: double.infinity,
        child: _PlanCard(
          plan: plan,
          busy: widget.processingPlanId == plan.id,
          disabled: widget.disabled,
          onPressed: widget.disabled ? null : () => widget.onSelected(plan),
        ),
      );
    }
    return SizedBox(
      key: const ValueKey('payment-plan-carousel'),
      height: 232,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: widget.plans.length,
        itemBuilder: (context, index) {
          final plan = widget.plans[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == widget.plans.length - 1 ? 0 : AppSpacing.sm,
            ),
            child: _PlanCard(
              plan: plan,
              busy: widget.processingPlanId == plan.id,
              disabled: widget.disabled,
              onPressed: widget.disabled ? null : () => widget.onSelected(plan),
            ),
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.busy,
    required this.disabled,
    required this.onPressed,
  });

  final PaymentPlan plan;
  final bool busy;
  final bool disabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final allowance = plan.isUnlimited
        ? 'Unlimited reading'
        : '${plan.dailyArticleLimit} stories daily';
    return AnimatedOpacity(
      key: ValueKey('payment-plan-${plan.id}'),
      duration: const Duration(milliseconds: 140),
      opacity: disabled && !busy ? 0.52 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.inkOf(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.surfaceOf(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                allowance,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.surfaceOf(context).withValues(alpha: 0.72),
                ),
              ),
              const Spacer(),
              Text(
                _price(plan),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.surfaceOf(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              CupertinoButton(
                key: ValueKey('pay-plan-${plan.id}'),
                padding: EdgeInsets.zero,
                minimumSize: const Size.fromHeight(46),
                onPressed: onPressed,
                child: Container(
                  alignment: Alignment.center,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.brandRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: busy
                      ? const CupertinoActivityIndicator(color: AppTheme.white)
                      : Text(
                          'Pay now',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppTheme.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _price(PaymentPlan plan) {
  final major = plan.priceMinor / 100;
  final value = major == major.roundToDouble()
      ? major.toStringAsFixed(0)
      : major.toStringAsFixed(2);
  return '${plan.currency} $value / ${plan.billingPeriod}';
}
