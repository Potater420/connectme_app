import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  // Shared form validators, reused by the login and sign-up screens.
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    final firstLetter = value.trim()[0];
    final isCapital =
        firstLetter == firstLetter.toUpperCase() &&
        firstLetter != firstLetter.toLowerCase();
    return isCapital ? null : 'Name must start with a capital letter';
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an email';
    return value.contains('@') ? null : 'Email must contain @';
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    return value.length < 6 ? 'Password must be at least 6 characters' : null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    return value == password ? null : 'Passwords do not match';
  }

  /// Returns null on success, or a user-friendly error message.
  Future<String?> createAccount({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(fullName);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (_) {
      return 'Something went wrong. Check your connection and try again.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (_) {
      return 'Something went wrong. Check your connection and try again.';
    }
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  // One error mapper for both flows, so there is no duplicated switch.
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'That email address is invalid.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}
