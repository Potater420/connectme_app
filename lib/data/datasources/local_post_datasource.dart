import 'dart:convert';

import 'package:connectme_app/core/errors/failures.dart';
import 'package:connectme_app/data/datasources/firestore_post_datasource.dart';
import 'package:connectme_app/data/models/post_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline cache of the latest posts, stored as a JSON string.
class LocalPostDataSource implements PostDataSource {
  static const String _cacheKey = 'cached_posts';

  final SharedPreferences _preferences;
  LocalPostDataSource(this._preferences);

  @override
  Stream<List<PostModel>> getPosts() => Stream.value(_readCache());

  @override
  Future<void> createPost(PostModel post) async =>
      cachePosts([post, ..._readCache()]);

  Future<void> cachePosts(List<PostModel> posts) {
    final encoded = jsonEncode(posts.map((post) => post.toJson()).toList());
    return _preferences.setString(_cacheKey, encoded);
  }

  List<PostModel> _readCache() {
    final raw = _preferences.getString(_cacheKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted cache: report a friendly error instead of crashing.
      throw const CacheFailure();
    }
  }
}
