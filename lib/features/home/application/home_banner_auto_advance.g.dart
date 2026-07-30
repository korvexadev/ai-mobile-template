// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_banner_auto_advance.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeBannerInterval)
final homeBannerIntervalProvider = HomeBannerIntervalProvider._();

final class HomeBannerIntervalProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  HomeBannerIntervalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBannerIntervalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBannerIntervalHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return homeBannerInterval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$homeBannerIntervalHash() =>
    r'4ae35b1a0cc454bf5b0b92ea2e72c97b901a8d56';

@ProviderFor(homeBannerAutoAdvance)
final homeBannerAutoAdvanceProvider = HomeBannerAutoAdvanceFamily._();

final class HomeBannerAutoAdvanceProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  HomeBannerAutoAdvanceProvider._({
    required HomeBannerAutoAdvanceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'homeBannerAutoAdvanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeBannerAutoAdvanceHash();

  @override
  String toString() {
    return r'homeBannerAutoAdvanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return homeBannerAutoAdvance(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeBannerAutoAdvanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeBannerAutoAdvanceHash() =>
    r'409a6937c1e43d031615dc6707826d8472c357db';

final class HomeBannerAutoAdvanceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  HomeBannerAutoAdvanceFamily._()
    : super(
        retry: null,
        name: r'homeBannerAutoAdvanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HomeBannerAutoAdvanceProvider call(String sectionId) =>
      HomeBannerAutoAdvanceProvider._(argument: sectionId, from: this);

  @override
  String toString() => r'homeBannerAutoAdvanceProvider';
}
