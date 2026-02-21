import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../db/share_pref.dart';
import '../models/user_model.dart';

class AuthRepository {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// ===============================
  /// GOOGLE SIGN IN
  /// ===============================
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
    await _auth.signInWithCredential(credential);

    return userCredential.user;
  }

  /// ===============================
  /// EMAIL LOGIN
  /// ===============================
  Future<User?> loginWithEmail(
      String email, String password) async {

    final credential =
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  /// ===============================
  /// REGISTER WITH EMAIL
  /// ===============================
  Future<User?> registerWithEmail(
      String email, String password) async {

    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  /// ===============================
  /// SAVE USER TO FIRESTORE
  /// ===============================
  Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  /// ===============================
  /// GET USER DATA
  /// ===============================
  Future<UserModel?> getUser(String uid) async {
    final doc =
    await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }

  /// ===============================
  /// CHECK IF USER EXISTS
  /// ===============================
  Future<bool> userExists(String uid) async {
    final doc =
    await _firestore.collection('users').doc(uid).get();

    return doc.exists;
  }

  /// ===============================
  /// LOGOUT
  /// ===============================
  Future<void> logout() async {
    await MySharedPrefference.clear();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// ===============================
  /// CURRENT USER
  /// ===============================
  User? get currentUser => _auth.currentUser;
}