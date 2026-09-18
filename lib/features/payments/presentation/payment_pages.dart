import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../app/theme/app_theme.dart';
import '../../../shared/design_system/app_spacing.dart';
import '../../../shared/design_system/primary_action.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/phone_number.dart';
import '../../profile/application/reader_entitlement_provider.dart';
import '../application/payments_controller.dart';
import '../domain/mobile_money_network.dart';
import '../domain/payment.dart';
import 'widgets/payment_plan_carousel.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsControllerProvider);
    final entitlement = ref.watch(readerEntitlementProvider).value;
    return PaymentSettingsPage(
      title: 'Subscription',
      onRefresh: () async {
        await ref.read(paymentsControllerProvider.notifier).refresh();
        ref.invalidate(readerEntitlementProvider);
      },
      child: payments.when(
        loading: () => const _Loading(),
        error: (error, stackTrace) =>
            _Retry(onPressed: () => ref.invalidate(paymentsControllerProvider)),
        data: (state) {
          if (entitlement?.paymentsEnabled == false) {
            return const _FreeReadingState();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entitlement != null) _CurrentPlan(entitlement.planName),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Choose plan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              PaymentPlanCarousel(
                plans: state.plans,
                disabled: state.processing || state.pending != null,
                processingPlanId: state.processingPlanId,
                onSelected: (plan) => showPaymentMethods(context, ref, plan),
              ),
              if (state.pending != null) ...[
                const SizedBox(height: AppSpacing.md),
                _PendingSummary(transaction: state.pending!),
              ],
              if (state.failure != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  state.failure!.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.error),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsControllerProvider);
    return PaymentSettingsPage(
      title: 'Transactions',
      onRefresh: ref.read(paymentsControllerProvider.notifier).refresh,
      child: payments.when(
        loading: () => const _Loading(),
        error: (error, stackTrace) =>
            _Retry(onPressed: () => ref.invalidate(paymentsControllerProvider)),
        data: (state) {
          if (state.transactions.isEmpty) {
            return const _EmptyTransactions();
          }
          return Column(
            children: [
              for (final transaction in state.transactions)
                _TransactionRow(transaction: transaction),
            ],
          );
        },
      ),
    );
  }
}

class PaymentSettingsPage extends StatelessWidget {
  const PaymentSettingsPage({
    required this.title,
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final String title;
  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.paperOf(context),
      child: RefreshIndicator.adaptive(
        color: AppTheme.brandRed,
        backgroundColor: AppTheme.paperOf(context),
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
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
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(44, 44),
                        onPressed: context.pop,
                        child: HugeIcon(
                          icon: HugeIconsStrokeRounded.arrowLeft01,
                          color: AppTheme.inkOf(context),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xxxl,
              ),
              sliver: SliverToBoxAdapter(child: child),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showPaymentMethods(
  BuildContext context,
  WidgetRef ref,
  PaymentPlan plan,
) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) => _PaymentMethodSheet(plan: plan),
  );
}

String _displayPhone(String? phone) {
  if (phone == null || phone.trim().isEmpty) return '';
  try {
    return MalawiPhoneNumber.parse(phone).display;
  } on Object {
    return phone;
  }
}

class _PaymentMethodSheet extends ConsumerStatefulWidget {
  const _PaymentMethodSheet({required this.plan});

  final PaymentPlan plan;

  @override
  ConsumerState<_PaymentMethodSheet> createState() {
    return _PaymentMethodSheetState();
  }
}

class _PaymentMethodSheetState extends ConsumerState<_PaymentMethodSheet> {
  late final String _registeredPhone;
  late final TextEditingController _phoneController;
  bool _useAnotherNumber = false;
  String? _submittingMethod;

  @override
  void initState() {
    super.initState();
    final phone = ref
        .read(authControllerProvider)
        .value
        ?.session
        ?.profile
        .phoneNumber;
    _registeredPhone = phone ?? '';
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _mobileMoney(
    MobileMoneyOperator operator,
    String phoneNumber,
    String progressKey,
  ) async {
    setState(() {
      _submittingMethod = progressKey;
    });
    final transaction = await ref
        .read(paymentsControllerProvider.notifier)
        .initiateMobileMoney(
          plan: widget.plan,
          operator: operator,
          phoneNumber: phoneNumber,
        );
    if (!mounted) return;
    if (transaction != null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _submittingMethod = null);
    }
  }

  void _showPhoneEntry(String phoneNumber) {
    setState(() {
      _phoneController.text = phoneNumber;
      _phoneController.selection = TextSelection.collapsed(
        offset: _phoneController.text.length,
      );
      _useAnotherNumber = true;
    });
  }

  void _toggleAlternatePhone() {
    if (_useAnotherNumber) {
      setState(() {
        _useAnotherNumber = false;
        _phoneController.clear();
      });
      return;
    }
    _showPhoneEntry('');
  }

  Future<void> _bank() async {
    setState(() => _submittingMethod = 'bank_transfer');
    final transaction = await ref
        .read(paymentsControllerProvider.notifier)
        .initiateBankTransfer(widget.plan);
    if (!mounted) return;
    if (transaction == null) {
      setState(() => _submittingMethod = null);
      return;
    }
    Navigator.of(context).pop();
    final account = transaction.bankAccount;
    if (account != null) {
      await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (context) => _BankDetails(
          account: account,
          amountMinor: transaction.amountMinor,
          currency: transaction.currency,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsControllerProvider).value;
    final busy = _submittingMethod != null;
    final operators = state?.operators ?? const <MobileMoneyOperator>[];
    final registeredNetwork = MobileMoneyNetwork.fromPhone(_registeredPhone);
    final registeredOperator = mobileMoneyOperatorForPhone(
      operators,
      _registeredPhone,
    );
    final alternateNetwork = MobileMoneyNetwork.fromPhone(
      _phoneController.text,
    );
    final alternateOperator = mobileMoneyOperatorForPhone(
      operators,
      _phoneController.text,
    );
    final phoneFailure = switch (state?.failure?.code) {
      'INVALID_PHONE_NUMBER' ||
      'MOBILE_MONEY_NETWORK_MISMATCH' => state?.failure,
      _ => null,
    };
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.plan.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Payment details',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedOf(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PaymentAmount(plan: widget.plan),
            const SizedBox(height: AppSpacing.md),
            if (registeredOperator != null && registeredNetwork != null)
              _MethodButton(
                key: const ValueKey('registered-mobile-money'),
                icon: HugeIconsStrokeRounded.smartPhone01,
                label: registeredNetwork.label,
                subtitle: _displayPhone(_registeredPhone),
                busy: false,
                onPressed: busy
                    ? null
                    : () => _showPhoneEntry(_registeredPhone),
              ),
            _MethodButton(
              icon: HugeIconsStrokeRounded.bank,
              label: 'Bank transfer',
              busy: _submittingMethod == 'bank_transfer',
              onPressed: busy ? null : _bank,
            ),
            Align(
              alignment: Alignment.center,
              child: CupertinoButton(
                key: const ValueKey('use-another-number'),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                onPressed: busy ? null : _toggleAlternatePhone,
                child: Text(
                  _useAnotherNumber ? 'Cancel' : 'Use another number',
                ),
              ),
            ),
            if (_useAnotherNumber) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Phone number',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              AdaptiveTextField(
                key: const ValueKey('payment-phone-field'),
                controller: _phoneController,
                enabled: !busy,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [LengthLimitingTextInputFormatter(24)],
                placeholder: '0991 234 567',
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: InputDecoration(
                  hintText: '0991 234 567',
                  errorText: phoneFailure?.message,
                ),
                onChanged: (_) {
                  if (phoneFailure != null) {
                    ref
                        .read(paymentsControllerProvider.notifier)
                        .clearFailure();
                  }
                  setState(() {});
                },
                onSubmitted: (_) {
                  if (!busy && alternateOperator != null) {
                    _mobileMoney(
                      alternateOperator,
                      _phoneController.text,
                      'mobile_money',
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryAction(
                key: const ValueKey('alternate-mobile-money-pay-now'),
                label: alternateNetwork == null
                    ? 'Pay now'
                    : 'Pay with ${alternateNetwork.label}',
                loading: _submittingMethod == 'mobile_money',
                loadingLabel: 'Starting payment',
                enabled: !busy && alternateOperator != null,
                onPressed: alternateOperator == null || busy
                    ? null
                    : () => _mobileMoney(
                        alternateOperator,
                        _phoneController.text,
                        'mobile_money',
                      ),
              ),
            ],
            if (state?.failure != null && phoneFailure == null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  state!.failure!.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentAmount extends StatelessWidget {
  const _PaymentAmount({required this.plan});

  final PaymentPlan plan;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('payment-sheet-amount'),
      decoration: BoxDecoration(
        color: AppTheme.softSurfaceOf(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Amount',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedOf(context),
                ),
              ),
            ),
            Text(
              _money(plan.currency, plan.priceMinor),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.icon,
    required this.label,
    required this.busy,
    required this.onPressed,
    this.subtitle,
    super.key,
  });

  final List<List<dynamic>> icon;
  final String label;
  final String? subtitle;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.fromHeight(58),
        onPressed: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.surfaceOf(context),
            border: Border.all(color: AppTheme.borderOf(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  HugeIcon(
                    icon: icon,
                    color: AppTheme.inkOf(context),
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.mutedOf(context)),
                          ),
                      ],
                    ),
                  ),
                  if (busy)
                    CupertinoActivityIndicator()
                  else
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.arrowRight01,
                      color: AppTheme.mutedOf(context),
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BankDetails extends StatelessWidget {
  const _BankDetails({
    required this.account,
    required this.amountMinor,
    required this.currency,
  });

  final BankPaymentAccount account;
  final int amountMinor;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank transfer',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          _CopyDetail(
            label: 'Amount to transfer',
            value: _money(currency, amountMinor),
          ),
          _CopyDetail(label: 'Bank', value: account.bankName),
          _CopyDetail(label: 'Account name', value: account.accountName),
          _CopyDetail(label: 'Account number', value: account.accountNumber),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Expires ${_dateTime(account.expiresAt)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.mutedOf(context)),
          ),
        ],
      ),
    );
  }
}

String _money(String currency, int amountMinor) {
  final amount = amountMinor / 100;
  final raw = amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2);
  final parts = raw.split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$currency $whole${parts.length == 1 ? '' : '.${parts.last}'}';
}

class _CopyDetail extends StatefulWidget {
  const _CopyDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  State<_CopyDetail> createState() => _CopyDetailState();
}

class _CopyDetailState extends State<_CopyDetail> {
  bool _copied = false;

  Future<void> _copy() async {
    setState(() => _copied = true);
    await Clipboard.setData(ClipboardData(text: widget.value));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.softSurfaceOf(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    SelectableText(
                      widget.value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_copied) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          '${widget.label} copied',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppTheme.brandRed),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              CupertinoButton(
                key: ValueKey('copy-${widget.label}'),
                padding: const EdgeInsets.all(AppSpacing.xs),
                minimumSize: const Size(44, 44),
                onPressed: _copy,
                child: HugeIcon(
                  icon: _copied
                      ? HugeIconsStrokeRounded.checkmarkCircle02
                      : HugeIconsStrokeRounded.copy01,
                  color: AppTheme.brandRed,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentPlan extends StatelessWidget {
  const _CurrentPlan(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Current plan',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(name, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _PendingSummary extends StatelessWidget {
  const _PendingSummary({required this.transaction});

  final PaymentTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            CupertinoActivityIndicator(),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${transaction.plan.name} payment is processing',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final PaymentTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.plan.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      _dateTime(transaction.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.currency} ${(transaction.amountMinor / 100).toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _status(transaction.status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: transaction.status == PaymentStatus.succeeded
                          ? const Color(0xFF237A4A)
                          : transaction.status == PaymentStatus.failed
                          ? AppTheme.error
                          : AppTheme.mutedOf(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onPressed});

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

class _FreeReadingState extends StatelessWidget {
  const _FreeReadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Free reading is open.',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No transactions yet.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

String _status(PaymentStatus status) {
  return switch (status) {
    PaymentStatus.pending => 'Processing',
    PaymentStatus.succeeded => 'Paid',
    PaymentStatus.failed => 'Failed',
    PaymentStatus.refunded => 'Refunded',
  };
}

String _dateTime(DateTime value) {
  final local = value.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} '
      '${local.hour}:$minute';
}
