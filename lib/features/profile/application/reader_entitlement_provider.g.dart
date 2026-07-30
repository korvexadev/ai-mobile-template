// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_entitlement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readerEntitlementRepository)
final readerEntitlementRepositoryProvider =
    ReaderEntitlementRepositoryProvider._();

final class ReaderEntitlementRepositoryProvider
    extends
        $FunctionalProvider<
          ReaderEntitlementRepository,
          ReaderEntitlementRepository,
          ReaderEntitlementRepository
        >
    with $Provider<ReaderEntitlementRepository> {
  ReaderEntitlementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerEntitlementRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerEntitlementRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReaderEntitlementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReaderEntitlementRepository create(Ref ref) {
    return readerEntitlementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReaderEntitlementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReaderEntitlementRepository>(value),
    );
  }
}

String _$readerEntitlementRepositoryHash() =>
    r'c867ad7af06d611fe74746bdc14d0ac870e1266f';

@ProviderFor(readerEntitlement)
final readerEntitlementProvider = ReaderEntitlementProvider._();

final class ReaderEntitlementProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReaderEntitlement>,
          ReaderEntitlement,
          FutureOr<ReaderEntitlement>
        >
    with
        $FutureModifier<ReaderEntitlement>,
        $FutureProvider<ReaderEntitlement> {
  ReaderEntitlementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerEntitlementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerEntitlementHash();

  @$internal
  @override
  $FutureProviderElement<ReaderEntitlement> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReaderEntitlement> create(Ref ref) {
    return readerEntitlement(ref);
  }
}

String _$readerEntitlementHash() => r'3137735923732f228325d6d399fbe18af507e0b3';
