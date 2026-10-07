import 'package:cloud_firestore/cloud_firestore.dart';

/// SINGLETON PATTERN: the factory constructor always returns the same
/// instance, so the whole app shares one FirestoreService.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  /// Returns the user's profile photo (base64 text), or null if none is saved.
  Future<String?> getUserPhoto(String uid) async {
    final document = await firestore
        .collection(_usersCollection)
        .doc(uid)
        .get();
    return document.data()?['photoBase64'] as String?;
  }

  /// Saves the profile photo without overwriting other fields in the document.
  Future<void> saveUserPhoto(String uid, String photoBase64) {
    return firestore.collection(_usersCollection).doc(uid).set({
      'photoBase64': photoBase64,
    }, SetOptions(merge: true));
  }
}
