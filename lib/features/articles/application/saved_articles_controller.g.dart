// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_articles_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedArticlesRepository)
final savedArticlesRepositoryProvider = SavedArticlesRepositoryProvider._();

final class SavedArticlesRepositoryProvider
    extends
        $FunctionalProvider<
          SavedArticlesRepository,
          SavedArticlesRepository,
          SavedArticlesRepository
        >
    with $Provider<SavedArticlesRepository> {
  SavedArticlesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedArticlesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedArticlesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedArticlesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedArticlesRepository create(Ref ref) {
    return savedArticlesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedArticlesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedArticlesRepository>(value),
    );
  }
}

String _$savedArticlesRepositoryHash() =>
    r'1213e1ac5bf1eb4c6cafd43af65f7a248546a8a1';

@ProviderFor(SavedArticlesController)
final savedArticlesControllerProvider = SavedArticlesControllerProvider._();

final class SavedArticlesControllerProvider
    extends
        $AsyncNotifierProvider<SavedArticlesController, List<SavedArticle>> {
  SavedArticlesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedArticlesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedArticlesControllerHash();

  @$internal
  @override
  SavedArticlesController create() => SavedArticlesController();
}

String _$savedArticlesControllerHash() =>
    r'e4ea1890aa4df70143d5981748a304ffa2097943';

abstract class _$SavedArticlesController
    extends $AsyncNotifier<List<SavedArticle>> {
  FutureOr<List<SavedArticle>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SavedArticle>>, List<SavedArticle>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SavedArticle>>, List<SavedArticle>>,
              AsyncValue<List<SavedArticle>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(savedReaderArticles)
final savedReaderArticlesProvider = SavedReaderArticlesProvider._();

final class SavedReaderArticlesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedArticle>>,
          List<SavedArticle>,
          FutureOr<List<SavedArticle>>
        >
    with
        $FutureModifier<List<SavedArticle>>,
        $FutureProvider<List<SavedArticle>> {
  SavedReaderArticlesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedReaderArticlesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedReaderArticlesHash();

  @$internal
  @override
  $FutureProviderElement<List<SavedArticle>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SavedArticle>> create(Ref ref) {
    return savedReaderArticles(ref);
  }
}

String _$savedReaderArticlesHash() =>
    r'38be5459d0fa2be2f7d614f4503aec7bbda27be2';
