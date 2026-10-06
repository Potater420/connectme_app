import 'package:connect_me_community_app/domain/entities/post.dart';
import 'package:connect_me_community_app/domain/repositories/post_repository.dart';

class GetPosts {
  final PostRepository _repository;
  GetPosts(this._repository);

  Stream<List<Post>> call() => _repository.getPosts();
}