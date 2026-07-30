import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/saved_article.dart';
import '../domain/saved_articles_repository.dart';

class PreferencesSavedArticlesRepository implements SavedArticlesRepository {
  const PreferencesSavedArticlesRepository(this._preferences);

  static const _savedArticlesKey = 'reader.saved-articles.v3';
  static const _legacySavedArticlesKey = 'reader.saved-articles.v2';
  static const _legacySavedSlugsKey = 'reader.saved-article-slugs.v1';
  static const _maximumSavedArticles = 500;

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<SavedArticle>> readAll() async {
    final encoded = await _preferences.getStringList(_savedArticlesKey);
    if (encoded != null) {
      return _latestFirst(encoded.map(_decode).nonNulls);
    }
    final legacyArticles = await _preferences.getStringList(
      _legacySavedArticlesKey,
    );
    if (legacyArticles != null) {
      final migratedAt = DateTime.now().toUtc();
      final migrated = legacyArticles.indexed
          .map(
            (entry) => _decode(
              entry.$2,
              fallbackSavedAt: migratedAt.subtract(
                Duration(milliseconds: entry.$1),
              ),
            ),
          )
          .nonNulls
          .toList(growable: false);
      await _write(migrated);
      await _preferences.remove(_legacySavedArticlesKey);
      return _latestFirst(migrated);
    }
    final legacy = await _preferences.getStringList(_legacySavedSlugsKey);
    final migratedAt = DateTime.now().toUtc();
    final migrated = (legacy ?? const <String>[]).indexed
        .map(
          (entry) => SavedArticle(
            slug: entry.$2,
            title: _titleFromSlug(entry.$2),
            summary: '',
            categoryName: 'News',
            categorySlug: '',
            heroImageUrl: null,
            publishedAt: null,
            savedAt: migratedAt.subtract(Duration(milliseconds: entry.$1)),
          ),
        )
        .toList(growable: false);
    if (legacy != null) {
      await _write(migrated);
      await _preferences.remove(_legacySavedSlugsKey);
    }
    return List.unmodifiable(migrated);
  }

  @override
  Future<void> setSaved(SavedArticle article, {required bool saved}) async {
    final articles = await readAll();
    final updated = articles.toList()
      ..removeWhere((item) => item.slug == article.slug);
    if (saved) {
      updated.insert(0, article);
    }
    await _write(_latestFirst(updated));
    await _preferences.remove(_legacySavedSlugsKey);
    await _preferences.remove(_legacySavedArticlesKey);
  }

  SavedArticle? _decode(String source, {DateTime? fallbackSavedAt}) {
    try {
      final json = jsonDecode(source);
      if (json is! Map<String, Object?>) {
        return null;
      }
      if (fallbackSavedAt != null && json['savedAt'] == null) {
        json['savedAt'] = fallbackSavedAt.toIso8601String();
      }
      return SavedArticle.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  List<SavedArticle> _latestFirst(Iterable<SavedArticle> articles) {
    final sorted = articles.toList()
      ..sort((left, right) => right.savedAt.compareTo(left.savedAt));
    return List.unmodifiable(sorted);
  }

  Future<void> _write(Iterable<SavedArticle> articles) {
    return _preferences.setStringList(
      _savedArticlesKey,
      articles
          .take(_maximumSavedArticles)
          .map((item) => jsonEncode(item.toJson()))
          .toList(),
    );
  }

  String _titleFromSlug(String slug) {
    return slug
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
