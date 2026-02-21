import 'dart:math';

import 'package:flutter/material.dart';
import 'package:women_safety/child/bottom_page.dart';
import 'package:women_safety/child/register_child.dart';
import 'package:women_safety/home_screen.dart';
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
  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, String>();
  final AuthController _controller = AuthController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  _login() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      setState(() => isLoading = true);

      final user = await _controller.loginWithEmail(
        _formData['email']!,
        _formData['password']!,
      );

      setState(() => isLoading = false);

      if (user != null) {
        await MySharedPrefference.saveUserType(user.type!);
        if (user.type == "child") {
          goTo(context, BottomPage());
        } else if (user.type == "parent") {
          goTo(context, ParentHomeScreen());
        } else {
          dialogueBox(context, "Invalid user type");
        }
      } else {
        dialogueBox(context, "User not found");
      }

    } catch (e) {
      setState(() => isLoading = false);
      dialogueBox(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? progressIndicator(context)
          : SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery
                  .of(context)
                  .size
                  .height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.all(20),
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
                          color: kColorRed,
                        ),
                      ),

                      Image.asset(
                        'assets/logo.png',
                        height: 100,
                        width: 100,
                      ),

                      SizedBox(height: 20),

                      CustomTextField(
                        hintText: "Enter Email",
                        keyboardtype:
                        TextInputType.emailAddress,
                        onsave: (v) =>
                        _formData['email'] = v!,
                        validate: (v) =>
                            UValidator.validateEmail(v),
                      ),

                      CustomTextField(
                        hintText: "Enter Password",
                        isPassword: isPasswordHidden,
                        onsave: (v) =>
                        _formData['password'] = v!,
                        validate: (v) =>
                            UValidator.validatePassword(v),
                        suffix: IconButton(
                          icon: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordHidden =
                              !isPasswordHidden;
                            });
                          },
                        ),
                      ),

                      SizedBox(height: 20),

                      PrimaryButton(
                        title: "LOGIN",
                        onPressed: () {
                          if (_formKey.currentState!
                              .validate()) {
                            _login();
                          }
                        },
                      ),

                      SizedBox(height: 15),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            "Forgot Password?",
                            style:
                            TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Click here",
                              style: TextStyle(
                                fontSize: 16,
                                color: kColorRed,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      SecondaryButton(
                        title: 'Register as Child',
                        onPressed: () {
                          goTo(context,
                              RegisterChildScreen());
                        },
                      ),

                      SizedBox(height: 10),

                      SecondaryButton(
                        title: 'Register as Parent',
                        onPressed: () {
                          goTo(context,
                              RegisterParentScreen());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
