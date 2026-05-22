import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Baki components ke normal messages ke liye rehne diya h
import 'package:google_sign_in/google_sign_in.dart';
import 'package:women_safety/child/bottom_page.dart';
import 'package:women_safety/child/register_child.dart';
import '../controller/auth_controller.dart';
import '../db/share_pref.dart';
import '../parent/parent_home_screen.dart';
import '../parent/parent_register_screen.dart';
import '../utils/constants/constants.dart';
import '../utils/validators/validation.dart';
import '../widgets/components/PrimaryButton.dart';
import '../widgets/components/SecondaryButton.dart';
import '../widgets/components/custom_textfield.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, String>{};
  final AuthController _controller = AuthController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  // 🔥 CUSTOM PREMIUM SNACKBAR COMPONENT (Toast Ki Jagah Mast Glowing Layout)
  void _showBeautifulSnackBar(BuildContext context, {required String message, required Color color, required IconData icon}) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Purane active snackbars ko clear karo

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Login Authentication Notice",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Floating layout style
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Curved margins
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Screen floating padding
        duration: const Duration(seconds: 4), // Visible frame layout time
      ),
    );
  }

  // 🔥 HELPER FUNCTION: Firestore Database Sync Engine
  Future<void> _handleUserFirestoreDocument(User user, {String? name, String? email, String? photoUrl, String? phone}) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': name ?? user.displayName ?? 'New User',
        'childEmail': email ?? user.email ?? '',
        'guardianEmail': '',
        'phone': phone ?? user.phoneNumber ?? '',
        'profilePic': photoUrl ?? user.photoURL ?? '',
        'type': 'child',
      });
      print("⚡ FIRESTORE LOG: New user record created successfully!");
    } else {
      print("⚡ FIRESTORE LOG: Existing user record identified.");
    }
  }

  // 🔥 EMAIL/PASSWORD LOGIN (Beautiful SnackBar Integrated)
// 🔥 EMAIL/PASSWORD LOGIN (With Fully Custom SnackBar Messages)
  _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      if (mounted) setState(() => isLoading = true);

      final user = await _controller.loginWithEmail(
        _formData['email']!,
        _formData['password']!,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (user != null) {
        await MySharedPrefference.saveUserType(user.type!);
        if (user.type == "child") {
          goTo(context, const BottomPage());
        } else if (user.type == "parent") {
          goTo(context, ParentHomeScreen());
        } else {
          _showBeautifulSnackBar(
            context,
            message: "Configured identity layout type mismatch!",
            color: Colors.orange,
            icon: Icons.warning_amber_rounded,
          );
        }
      } else {
        // SnackBar if controller implicitly returns null
        _showBeautifulSnackBar(
          context,
          message: "Incorrect Email or Password! Please verify and re-try.",
          color: const Color(0xFFD32F2F),
          icon: Icons.lock_outline_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);

        // Raw error message ko string me convert karke lowercase kar lete hain check ke liye
        String rawError = e.toString().toLowerCase();
        String customDisplayMessage = "Invalid Email or Password! Please try again."; // 🔥 Aapka Custom Default Message

        // 🔍 Firebase Auth exception filter checks
        if (rawError.contains("credential") ||
            rawError.contains("malformed") ||
            rawError.contains("expired") ||
            rawError.contains("wrong-password") ||
            rawError.contains("user-not-found")) {

          // Agar credentials invalid ka error h, toh jo message aap chahte ho vo override kar do:
          customDisplayMessage = "Incorrect email/password or your session has expired. Please try again!";
        } else if (rawError.contains("network-request-failed") || rawError.contains("network")) {
          customDisplayMessage = "Network error! Please check your internet connection.";
        } else if (rawError.contains("too-many-requests")) {
          customDisplayMessage = "Too many failed attempts! Access temporarily blocked. Try again later.";
        }

        // 🔥 FINALLY DISPLAY CUSTOM BEAUTIFUL SNACKBAR
        _showBeautifulSnackBar(
          context,
          message: customDisplayMessage,
          color: const Color(0xFFD32F2F), // Premium dark red compliance tint
          icon: Icons.lock_reset_rounded,
        );
      }
    }
  }

  // 🔥 GOOGLE SIGN-IN WITH SAFECONTEXT ROUTING
  void _loginWithGoogle() async {
    final NavigatorState navigator = Navigator.of(context);
    try {
      if (mounted) setState(() => isLoading = true);

      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _handleUserFirestoreDocument(
          userCredential.user!,
          name: googleUser.displayName,
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );

        await MySharedPrefference.saveUserType("child");
        if (!mounted) return;
        setState(() => isLoading = false);

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BottomPage()),
              (route) => false,
        );
      }

    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Google Sign-In Failed: $e");
    }
  }

  // 🔥 PHONE LOGIN TRIGGER DIALOG
  void _loginWithPhone() async {
    final TextEditingController phoneController = TextEditingController();
    final dialogKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: const Text("Phone Login", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: dialogKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter your number with country code (e.g., +919518437050)"),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: phoneController,
                  hintText: "Phone Number with +91",
                  keyboardtype: TextInputType.phone,
                  validate: (v) => v!.isEmpty ? "Enter your phone number" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kColorRed),
              onPressed: () {
                if (dialogKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _verifyPhoneNumber(phoneController.text.trim());
                }
              },
              child: const Text("Send OTP", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _verifyPhoneNumber(String phoneNumber) async {
    if (mounted) setState(() => isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          await _handleUserFirestoreDocument(userCredential.user!, phone: phoneNumber);
          await MySharedPrefference.saveUserType("child");
          if (mounted) {
            setState(() => isLoading = false);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const BottomPage()),
                  (route) => false,
            );
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) setState(() => isLoading = false);
        Fluttertoast.showToast(msg: "Verification Failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) setState(() => isLoading = false);
        _showOTPDialog(verificationId, phoneNumber);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _showOTPDialog(String verificationId, String phoneNumber) {
    final TextEditingController otpController = TextEditingController();
    final NavigatorState navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: const Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.bold)),
          content: CustomTextField(
            controller: otpController,
            hintText: "6-Digit OTP",
            keyboardtype: TextInputType.number,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (otpController.text.trim().length == 6) {
                  Navigator.pop(dialogContext);

                  if (mounted) setState(() => isLoading = true);

                  try {
                    PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: otpController.text.trim(),
                    );

                    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

                    if (userCredential.user != null) {
                      await _handleUserFirestoreDocument(userCredential.user!, phone: phoneNumber);
                      await MySharedPrefference.saveUserType("child");

                      if (!mounted) return;
                      setState(() => isLoading = false);

                      print("🚀 LOG: Context Guard Active! Routing to BottomPage safely...");

                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const BottomPage()),
                            (route) => false,
                      );
                    }
                  } catch (e) {
                    if (mounted) setState(() => isLoading = false);
                    Fluttertoast.showToast(msg: "Invalid OTP! Error: $e");
                  }
                } else {
                  Fluttertoast.showToast(msg: "Please enter valid 6-digit OTP");
                }
              },
              child: const Text("Verify & Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 🔥 DYNAMIC METHOD DETECTOR PASSWORD RECOVERY SYSTEM
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    final dialogKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            "Reset Password",
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
          ),
          content: Form(
            key: dialogKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter your registered email to receive a password reset link.",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: resetEmailController,
                  hintText: "Enter your Email",
                  keyboardtype: TextInputType.emailAddress,
                  validate: (v) => UValidator.validateEmail(v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kColorRed),
              onPressed: () async {
                if (dialogKey.currentState!.validate()) {
                  String emailInput = resetEmailController.text.trim();

                  try {
                    // 🔍 Step 1: Firestore mein check karo ki email exist karta hai ya nahi
                    var userCheck = await FirebaseFirestore.instance
                        .collection('users')
                        .where('childEmail', isEqualTo: emailInput)
                        .get();

                    if (userCheck.docs.isEmpty) {
                      Navigator.pop(dialogContext);
                      _showBeautifulSnackBar(
                          context,
                          message: "This email is not registered in our database!",
                          color: Colors.redAccent,
                          icon: Icons.no_accounts_rounded
                      );
                      return;
                    }

                    // 🔍 Step 2: Firebase se direct link bhejo. Agar user password wala nahi hoga,
                    // toh Firebase khud catch block mein error phekega jo hum handle kar lenge.
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailInput);

                    Navigator.pop(dialogContext);
                    _showBeautifulSnackBar(
                        context,
                        message: "Password reset link shared successfully. Check your mail inbox!",
                        color: Colors.green,
                        icon: Icons.mark_email_read_rounded
                    );

                  } catch (e) {
                    Navigator.pop(dialogContext);

                    String errorStr = e.toString().toLowerCase();
                    String errorMessage = "Failed to send reset link. Please verify your account type.";

                    // Agar user Google/Phone wala hai toh Firebase yeh error de sakta h
                    if (errorStr.contains("no-user") || errorStr.contains("user-not-found")) {
                      errorMessage = "Account not found or password method not supported for this email.";
                    } else if (errorStr.contains("invalid-email")) {
                      errorMessage = "The email address is badly formatted.";
                    }

                    _showBeautifulSnackBar(
                        context,
                        message: errorMessage,
                        color: Colors.orange,
                        icon: Icons.error_outline_rounded
                    );
                  }
                }
              },
              child: const Text("Send link", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isLoading
          ? progressIndicator(context)
          : SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "CHILD LOGIN",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.pinkAccent : kColorRed,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      hintText: "Enter Email",
                      keyboardtype: TextInputType.emailAddress,
                      onsave: (v) => _formData['email'] = v!,
                      validate: (v) => UValidator.validateEmail(v),
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      hintText: "Enter Password",
                      isPassword: isPasswordHidden,
                      onsave: (v) => _formData['password'] = v!,
                      validate: (v) => UValidator.validatePassword(v),
                      suffix: IconButton(
                        icon: Icon(
                          isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _showForgotPasswordDialog,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.pinkAccent : kColorRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    PrimaryButton(
                      title: "LOGIN",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text("Or Login With", style: TextStyle(color: isDark ? Colors.white60 : Colors.black45)),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.white24 : Colors.black12)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _loginWithGoogle,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              shape: BoxShape.circle,
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Image.asset(
                              'assets/google.png',
                              height: 30,
                              width: 30,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.g_mobiledata, size: 30, color: isDark ? Colors.white : Colors.blue);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        GestureDetector(
                          onTap: _loginWithPhone,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              shape: BoxShape.circle,
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: const Icon(
                              Icons.phone_android_rounded,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    SecondaryButton(
                      title: 'Register as Child',
                      onPressed: () {
                        goTo(context, RegisterChildScreen());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}