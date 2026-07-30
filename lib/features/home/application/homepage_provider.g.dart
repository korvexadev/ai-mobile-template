// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homepage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homepageRepository)
final homepageRepositoryProvider = HomepageRepositoryProvider._();

final class HomepageRepositoryProvider
    extends
        $FunctionalProvider<
          HomepageRepository,
          HomepageRepository,
          HomepageRepository
        >
    with $Provider<HomepageRepository> {
  HomepageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homepageRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homepageRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomepageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomepageRepository create(Ref ref) {
    return homepageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomepageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomepageRepository>(value),
    );
  }
}

String _$homepageRepositoryHash() =>
    r'b782f59b070596cab3ecbef1c9e29be9bbd40fd7';

@ProviderFor(homepage)
final homepageProvider = HomepageProvider._();

final class HomepageProvider
    extends
        $FunctionalProvider<AsyncValue<Homepage>, Homepage, FutureOr<Homepage>>
    with $FutureModifier<Homepage>, $FutureProvider<Homepage> {
  HomepageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homepageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homepageHash();

  @$internal
  @override
  $FutureProviderElement<Homepage> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Homepage> create(Ref ref) {
    return homepage(ref);
  }
}

String _$homepageHash() => r'24274323d649a07e8141273e2bca0832d929dddf';
