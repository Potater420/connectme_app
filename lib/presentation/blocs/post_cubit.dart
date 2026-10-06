import 'dart:async';

import 'package:connect_me_community_app/core/errors/failures.dart';
import 'package:connect_me_community_app/domain/entities/post.dart';
import 'package:connect_me_community_app/domain/usecases/create_post.dart';
import 'package:connect_me_community_app/domain/usecases/get_posts.dart';
import 'package:connect_me_community_app/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// The four states the feed can be in. The screen draws a different UI for each.
sealed class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  PostLoaded(this.posts);
}

class PostError extends PostState {
  final String message;
  PostError(this.message);
}

class PostCubit extends Cubit<PostState> {
  final GetPosts _getPosts;
  final CreatePost _createPost;
  final AuthService _authService;

  StreamSubscription<List<Post>>? _postsSubscription;

  PostCubit(this._getPosts, this._createPost, this._authService)
    : super(PostInitial());

  static const String _genericErrorMessage =
      'Something went wrong. Please try again.';

  /// GET path: listen to the live Firestore stream and emit every update.
  void loadPosts() {
    emit(PostLoading());
    _postsSubscription?.cancel();
    _postsSubscription = _getPosts().listen(
      (posts) => emit(PostLoaded(posts)),
      onError: (Object error) => emit(
        PostError(error is Failure ? error.message : _genericErrorMessage),
      ),
    );
  }

  /// CREATE path: returns null on success, or an error message to show.
  /// We don't emit an error state here, so a failed post doesn't wipe the feed.
  Future<String?> addPost(String content) async {
    final currentUser = _authService.currentUser;
    final displayName = currentUser?.displayName?.trim() ?? '';
    final authorName = displayName.isNotEmpty
        ? displayName
        : (currentUser?.email ?? 'Anonymous');

    try {
      await _createPost(
        Post(
          id: '', // Firestore generates the real id
          authorName: authorName,
          content: content,
          timestamp: DateTime.now(),
        ),
      );
      return null;
    } on Failure catch (failure) {
      return failure.message;
    } catch (_) {
      return _genericErrorMessage;
    }
  }

  // Stop listening to Firestore when the cubit is destroyed.
  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}
