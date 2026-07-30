// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_category_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeCategorySelection)
final homeCategorySelectionProvider = HomeCategorySelectionProvider._();

final class HomeCategorySelectionProvider
    extends $NotifierProvider<HomeCategorySelection, String?> {
  HomeCategorySelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeCategorySelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeCategorySelectionHash();

  @$internal
  @override
  HomeCategorySelection create() => HomeCategorySelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$homeCategorySelectionHash() =>
    r'3a8f3f990521e52820eb9dae1257f0bd47fe0eec';

abstract class _$HomeCategorySelection extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
