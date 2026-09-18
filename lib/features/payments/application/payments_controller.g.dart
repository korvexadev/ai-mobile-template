// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentRepository)
final paymentRepositoryProvider = PaymentRepositoryProvider._();

final class PaymentRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentRepository,
          PaymentRepository,
          PaymentRepository
        >
    with $Provider<PaymentRepository> {
  PaymentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentRepository create(Ref ref) {
    return paymentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentRepository>(value),
    );
  }
}

String _$paymentRepositoryHash() => r'13252a8ff4155597ef0ca9a156a95f4ef2999772';

@ProviderFor(PaymentsController)
final paymentsControllerProvider = PaymentsControllerProvider._();

final class PaymentsControllerProvider
    extends $AsyncNotifierProvider<PaymentsController, PaymentsState> {
  PaymentsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentsControllerHash();

  @$internal
  @override
  PaymentsController create() => PaymentsController();
}

String _$paymentsControllerHash() =>
    r'3f42ae6635edbb87a8e133f814192b5c8b4b35f9';

abstract class _$PaymentsController extends $AsyncNotifier<PaymentsState> {
  FutureOr<PaymentsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PaymentsState>, PaymentsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaymentsState>, PaymentsState>,
              AsyncValue<PaymentsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
