import 'package:connect_me_community_app/core/errors/failures.dart';
import 'package:connect_me_community_app/data/datasources/firestore_post_datasource.dart';
import 'package:connect_me_community_app/data/datasources/local_post_datasource.dart';
import 'package:connect_me_community_app/data/models/post_model.dart';
import 'package:connect_me_community_app/domain/entities/post.dart';
import 'package:connect_me_community_app/domain/repositories/post_repository.dart';

enum PostSource { remote, local }

class PostRepositoryImpl implements PostRepository {
  final FirestorePostDataSource _remoteDataSource;
  final LocalPostDataSource _localDataSource;

  PostRepositoryImpl(this._remoteDataSource, this._localDataSource);

  /// FACTORY PATTERN: callers ask for a source type and get the matching
  /// data source back, without knowing which concrete class it is.
  PostDataSource _createDataSource(PostSource source) {
    switch (source) {
      case PostSource.remote:
        return _remoteDataSource;
      case PostSource.local:
        return _localDataSource;
    }
  }

  @override
  Stream<List<Post>> getPosts() async* {
    try {
      // Prefer live Firestore data and keep the local cache up to date.
      await for (final posts
          in _createDataSource(PostSource.remote).getPosts()) {
        await _localDataSource.cachePosts(posts);
        yield posts;
      }
    } catch (_) {
      // Remote failed: fall back to the cache, or report a friendly error.
      final cachedPosts =
          await _createDataSource(PostSource.local).getPosts().first;
      if (cachedPosts.isEmpty) {
        throw const ServerFailure(
          'Could not load posts. Check your connection and try again.',
        );
      }
      yield cachedPosts;
    }
  }

  @override
  Future<void> createPost(Post post) async {
    try {
      await _createDataSource(PostSource.remote)
          .createPost(PostModel.fromEntity(post));
    } catch (_) {
      throw const ServerFailure('Could not publish your post. Try again.');
    }
  }
}