import 'package:connect_me_community_app/domain/entities/post.dart';

/// The domain layer only knows this contract, not Firestore or local storage.
abstract class PostRepository {
  Stream<List<Post>> getPosts(); //returns a stream of (List of posts) meaning it changes when the (list of posts) is changed
  Future<void> createPost(Post post); //doesn't return anything but it accepts value of type Post(entitiy) to create a post
}