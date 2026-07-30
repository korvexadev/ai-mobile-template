// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(articleShareService)
final articleShareServiceProvider = ArticleShareServiceProvider._();

final class ArticleShareServiceProvider
    extends
        $FunctionalProvider<
          ArticleShareService,
          ArticleShareService,
          ArticleShareService
        >
    with $Provider<ArticleShareService> {
  ArticleShareServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'articleShareServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$articleShareServiceHash();

  @$internal
  @override
  $ProviderElement<ArticleShareService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ArticleShareService create(Ref ref) {
    return articleShareService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArticleShareService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArticleShareService>(value),
    );
  }
}

String _$articleShareServiceHash() =>
    r'22087a58fa892507a0402b60876c22afb1f3dec4';

@ProviderFor(ArticleActionsController)
final articleActionsControllerProvider = ArticleActionsControllerFamily._();

final class ArticleActionsControllerProvider
    extends
        $AsyncNotifierProvider<ArticleActionsController, ArticleActionsState> {
  ArticleActionsControllerProvider._({
    required ArticleActionsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'articleActionsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$articleActionsControllerHash();

  @override
  String toString() {
    return r'articleActionsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ArticleActionsController create() => ArticleActionsController();

  @override
  bool operator ==(Object other) {
    return other is ArticleActionsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$articleActionsControllerHash() =>
    r'b44783dd3255d63447816ec269bd860326f7b270';

final class ArticleActionsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ArticleActionsController,
          AsyncValue<ArticleActionsState>,
          ArticleActionsState,
          FutureOr<ArticleActionsState>,
          String
        > {
  ArticleActionsControllerFamily._()
    : super(
        retry: null,
        name: r'articleActionsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ArticleActionsControllerProvider call(String slug) =>
      ArticleActionsControllerProvider._(argument: slug, from: this);

  @override
  String toString() => r'articleActionsControllerProvider';
}

abstract class _$ArticleActionsController
    extends $AsyncNotifier<ArticleActionsState> {
  late final _$args = ref.$arg as String;
  String get slug => _$args;

  FutureOr<ArticleActionsState> build(String slug);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ArticleActionsState>, ArticleActionsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ArticleActionsState>, ArticleActionsState>,
              AsyncValue<ArticleActionsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
