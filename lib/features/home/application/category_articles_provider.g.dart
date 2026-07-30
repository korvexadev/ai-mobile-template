// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_articles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryArticlesRepository)
final categoryArticlesRepositoryProvider =
    CategoryArticlesRepositoryProvider._();

final class CategoryArticlesRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryArticlesRepository,
          CategoryArticlesRepository,
          CategoryArticlesRepository
        >
    with $Provider<CategoryArticlesRepository> {
  CategoryArticlesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryArticlesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryArticlesRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryArticlesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryArticlesRepository create(Ref ref) {
    return categoryArticlesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryArticlesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryArticlesRepository>(value),
    );
  }
}

String _$categoryArticlesRepositoryHash() =>
    r'3190f37e2177a757c39636503928f560b31c7e27';

@ProviderFor(CategoryArticlesController)
final categoryArticlesControllerProvider = CategoryArticlesControllerFamily._();

final class CategoryArticlesControllerProvider
    extends
        $AsyncNotifierProvider<
          CategoryArticlesController,
          CategoryArticlesState
        > {
  CategoryArticlesControllerProvider._({
    required CategoryArticlesControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryArticlesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryArticlesControllerHash();

  @override
  String toString() {
    return r'categoryArticlesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryArticlesController create() => CategoryArticlesController();

  @override
  bool operator ==(Object other) {
    return other is CategoryArticlesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryArticlesControllerHash() =>
    r'fbb91c1eb3377da6c3c2ed90e9ae7ad4543bb1db';

final class CategoryArticlesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryArticlesController,
          AsyncValue<CategoryArticlesState>,
          CategoryArticlesState,
          FutureOr<CategoryArticlesState>,
          String
        > {
  CategoryArticlesControllerFamily._()
    : super(
        retry: null,
        name: r'categoryArticlesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryArticlesControllerProvider call(String categorySlug) =>
      CategoryArticlesControllerProvider._(argument: categorySlug, from: this);

  @override
  String toString() => r'categoryArticlesControllerProvider';
}

abstract class _$CategoryArticlesController
    extends $AsyncNotifier<CategoryArticlesState> {
  late final _$args = ref.$arg as String;
  String get categorySlug => _$args;

  FutureOr<CategoryArticlesState> build(String categorySlug);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CategoryArticlesState>, CategoryArticlesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CategoryArticlesState>,
                CategoryArticlesState
              >,
              AsyncValue<CategoryArticlesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
