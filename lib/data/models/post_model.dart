import 'package:connectme_app/domain/entities/post.dart';

/// A Post that knows how to convert itself to and from JSON.
/// The timestamp is stored as milliseconds, so the same JSON works for
/// both Firestore and the local cache.
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorName,
    required super.content,
    required super.timestamp,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'Unknown',
      content: json['content'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      authorName: post.authorName,
      content: post.content,
      timestamp: post.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'content': content,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}
