import 'package:connect_me_community_app/domain/entities/post.dart';
import 'package:connect_me_community_app/domain/repositories/post_repository.dart';

class CreatePost {
  final PostRepository _repository;
  CreatePost(this._repository);

  Future<void> call(Post post) => _repository.createPost(post);
}