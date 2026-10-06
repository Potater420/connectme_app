import 'package:cloud_firestore/cloud_firestore.dart';

/// SINGLETON PATTERN: the factory constructor always returns the same
/// instance, so the whole app shares one FirestoreService.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
}