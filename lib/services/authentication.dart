import 'package:firebase_auth/firebase_auth.dart';
import 'package:journal/services/authentication_api.dart';

class AuthenticationService implements AuthenticationApi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  FirebaseAuth getFirebaseAuth() {
    return _firebaseAuth;
  }

  @override
  Future<String?> currentUserUid() async {
    User user = _firebaseAuth.currentUser!;
    return user.uid;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<String?> signInWithEmailAndPassword(
      {String? email, String? password}) async {
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email!, password: password!);
    return userCredential.user?.uid;
  }

  @override
  Future<String?> createUserWithEmailAndPassword(
      {String? email, String? password}) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email!, password: password!);
    return userCredential.user!.uid;
  }

  @override
  Future<void> sendEmailVerification() async {
    User user = _firebaseAuth.currentUser!;
    user.sendEmailVerification();
  }

  @override
  Future<bool?> isEmailVerified() async {
    User user = _firebaseAuth.currentUser!;
    return user.emailVerified;
  }
}
