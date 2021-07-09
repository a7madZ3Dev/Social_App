import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final _auth = FirebaseAuth.instance;

  /// sign Up to firebase
  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password.trim());
    return userCredential;
  }

  /// log in to firebase
  Future<UserCredential?> logIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim());
    return userCredential;
  }
}
