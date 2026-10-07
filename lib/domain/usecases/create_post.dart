import 'package:connectme_app/domain/entities/post.dart';
import 'package:connectme_app/domain/repositories/post_repository.dart';

class CreatePost {
  final PostRepository _repository;
  CreatePost(this._repository);

  Future<void> call(Post post) => _repository.createPost(post);
}
