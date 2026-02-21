import '../models/user_model.dart';
import '../repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {

  final AuthRepository _repository = AuthRepository();

  /// ==========================================
  /// GOOGLE LOGIN
  /// ==========================================
  Future<UserModel?> loginWithGoogle(String type) async {

    User? firebaseUser =
    await _repository.signInWithGoogle();

    if (firebaseUser == null) return null;

    bool exists =
    await _repository.userExists(firebaseUser.uid);

    UserModel userModel;

    if (!exists) {
      userModel = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? "",
        childEmail: firebaseUser.email ?? "",
        guardianEmail: "",
        phone: firebaseUser.phoneNumber ?? "",
        profilePic: firebaseUser.photoURL ?? "",
        type: type,
      );

      await _repository.saveUser(userModel);
    } else {
      userModel =
      (await _repository.getUser(firebaseUser.uid))!;
    }

    return userModel;
  }

  /// ==========================================
  /// EMAIL LOGIN (Child / Parent)
  /// ==========================================
  Future<UserModel?> loginWithEmail(
      String email, String password) async {

    User? firebaseUser =
    await _repository.loginWithEmail(email, password);

    if (firebaseUser == null) return null;

    return await _repository.getUser(firebaseUser.uid);
  }

  /// ==========================================
  /// REGISTER CHILD
  /// ==========================================
  Future<UserModel?> registerChild({
    required String name,
    required String phone,
    required String childEmail,
    required String guardianEmail,
    required String password,
  }) async {

    User? firebaseUser =
    await _repository.registerWithEmail(
        childEmail, password);

    if (firebaseUser == null) return null;

    final userModel = UserModel(
      id: firebaseUser.uid,
      name: name,
      phone: phone,
      childEmail: childEmail,
      guardianEmail: guardianEmail,
      type: "child",
    );

    await _repository.saveUser(userModel);

    return userModel;
  }

  /// ==========================================
  /// REGISTER PARENT
  /// ==========================================
  Future<UserModel?> registerParent({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {

    User? firebaseUser =
    await _repository.registerWithEmail(
        email, password);

    if (firebaseUser == null) return null;

    final userModel = UserModel(
      id: firebaseUser.uid,
      name: name,
      phone: phone,
      guardianEmail: email,
      childEmail: "",
      type: "parent",
    );

    await _repository.saveUser(userModel);

    return userModel;
  }

  /// ==========================================
  /// GET CURRENT USER DATA
  /// ==========================================
  Future<UserModel?> getCurrentUserData() async {
    final user = _repository.currentUser;
    if (user == null) return null;

    return await _repository.getUser(user.uid);
  }

  /// ==========================================
  /// LOGOUT
  /// ==========================================
  Future<void> logout() async {
    await _repository.logout();
  }
}