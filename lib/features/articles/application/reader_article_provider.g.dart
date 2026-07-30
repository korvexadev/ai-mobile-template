// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_article_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readerArticleRepository)
final readerArticleRepositoryProvider = ReaderArticleRepositoryProvider._();

final class ReaderArticleRepositoryProvider
    extends
        $FunctionalProvider<
          ReaderArticleRepository,
          ReaderArticleRepository,
          ReaderArticleRepository
        >
    with $Provider<ReaderArticleRepository> {
  ReaderArticleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerArticleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerArticleRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReaderArticleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReaderArticleRepository create(Ref ref) {
    return readerArticleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReaderArticleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReaderArticleRepository>(value),
    );
  }
}

String _$readerArticleRepositoryHash() =>
    r'8687c9f6c08b5bb2c0981da350764debbd6d4157';

@ProviderFor(readerArticle)
final readerArticleProvider = ReaderArticleFamily._();

final class ReaderArticleProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReaderArticle>,
          ReaderArticle,
          FutureOr<ReaderArticle>
        >
    with $FutureModifier<ReaderArticle>, $FutureProvider<ReaderArticle> {
  ReaderArticleProvider._({
    required ReaderArticleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'readerArticleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readerArticleHash();

  @override
  String toString() {
    return r'readerArticleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReaderArticle> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReaderArticle> create(Ref ref) {
    final argument = this.argument as String;
    return readerArticle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderArticleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readerArticleHash() => r'62901ddd88423d7e328b3921dfd255e38d56b5bf';

final class ReaderArticleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReaderArticle>, String> {
  ReaderArticleFamily._()
    : super(
        retry: null,
        name: r'readerArticleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReaderArticleProvider call(String slug) =>
      ReaderArticleProvider._(argument: slug, from: this);

  @override
  String toString() => r'readerArticleProvider';
}
