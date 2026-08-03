import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mikozi_mobile/features/payments/domain/payment.dart';
import 'package:mikozi_mobile/features/payments/presentation/widgets/payment_plan_carousel.dart';

void main() {
  testWidgets('stretches a single plan without creating a carousel', (
    tester,
  ) async {
    await tester.pumpWidget(_fixture(plans: const [_monthlyPlan]));

    expect(find.byKey(const ValueKey('single-payment-plan')), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('single-payment-plan'))).width,
      360,
    );
  });

  testWidgets('keeps multiple plans in a narrow carousel', (tester) async {
    await tester.pumpWidget(_fixture(plans: const [_monthlyPlan, _annualPlan]));

    expect(find.byKey(const ValueKey('payment-plan-carousel')), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('payment-plan-monthly'))).width,
      lessThan(360),
    );
  });

  testWidgets(
    'shows progress only on the selected plan and disables siblings',
    (tester) async {
      await tester.pumpWidget(
        _fixture(
          plans: const [_monthlyPlan, _annualPlan],
          disabled: true,
          processingPlanId: _monthlyPlan.id,
        ),
      );

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      final monthlyButton = tester.widget<CupertinoButton>(
        find.byKey(const ValueKey('pay-plan-monthly')),
      );
      final annualButton = tester.widget<CupertinoButton>(
        find.byKey(const ValueKey('pay-plan-annual')),
      );
      expect(monthlyButton.onPressed, isNull);
      expect(annualButton.onPressed, isNull);
    },
  );
}

Widget _fixture({
  required List<PaymentPlan> plans,
  bool disabled = false,
  String? processingPlanId,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 360,
          child: PaymentPlanCarousel(
            plans: plans,
            disabled: disabled,
            processingPlanId: processingPlanId,
            onSelected: (_) {},
          ),
        ),
      ),
    ),
  );
}

const _monthlyPlan = PaymentPlan(
  id: 'monthly',
  code: 'monthly',
  name: 'Monthly',
  description: null,
  priceMinor: 500000,
  currency: 'MWK',
  billingPeriod: 'month',
  dailyArticleLimit: 10,
);

const _annualPlan = PaymentPlan(
  id: 'annual',
  code: 'annual',
  name: 'Annual',
  description: null,
  priceMinor: 5000000,
  currency: 'MWK',
  billingPeriod: 'year',
  dailyArticleLimit: null,
);
