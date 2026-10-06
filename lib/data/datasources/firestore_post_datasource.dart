import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_me_community_app/data/models/post_model.dart';
import 'package:connect_me_community_app/services/firestore_service.dart';

/// Common contract for every post data source (remote or local).
/// The repository's factory returns this type.
abstract class PostDataSource {
  Stream<List<PostModel>> getPosts();
  Future<void> createPost(PostModel post);
}

class FirestorePostDataSource implements PostDataSource {
  static const String _collectionName = 'posts';

  final FirestoreService _firestoreService;
  FirestorePostDataSource(this._firestoreService);

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestoreService.firestore.collection(_collectionName);

  /// Real-time stream: emits a new list every time the collection changes.
  @override
  Stream<List<PostModel>> getPosts() {
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PostModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  @override
  Future<void> createPost(PostModel post) async {
    // Firestore generates the id, so we don't store our empty one.
    final data = post.toJson()..remove('id');
    await _postsCollection.add(data);
  }
}