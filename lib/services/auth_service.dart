import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
      );
    }
    return null;
  }

  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser != null) {
        return User(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName,
        );
      }
      return null;
    });
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return User(
        id: credential.user!.uid,
        email: credential.user!.email!,
        displayName: credential.user!.displayName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  Future<User> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return User(
        id: credential.user!.uid,
        email: credential.user!.email!,
        displayName: credential.user!.displayName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }}