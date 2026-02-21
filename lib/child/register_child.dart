import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';
import '../utils/constants/constants.dart';
import '../utils/validators/validation.dart';
import '../widgets/components/PrimaryButton.dart';
import '../widgets/components/custom_textfield.dart';
import 'child_login_screen.dart';

class RegisterChildScreen extends StatefulWidget {
  @override
  State<RegisterChildScreen> createState() =>
      _RegisterChildScreenState();
}

class _RegisterChildScreenState
    extends State<RegisterChildScreen> {

  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, String>();
  final AuthController _controller = AuthController();

  bool isLoading = false;
  bool isPasswordHidden = true;
  bool isRetypeHidden = true;

  _register() async {
    _formKey.currentState!.save();

    if (_formData['password'] != _formData['repassword']) {
      dialogueBox(context, "Passwords do not match");
      return;
    }

    try {
      setState(() => isLoading = true);

      final user = await _controller.registerChild(
        name: _formData['name']!,
        phone: _formData['phone']!,
        childEmail: _formData['email']!,
        guardianEmail: _formData['guardianEmail']!,
        password: _formData['password']!,
      );

      setState(() => isLoading = false);

      if (user != null) {
        goTo(context, ChildLoginScreen());
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
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              Text("REGISTER CHILD",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kColorRed)),
              Image.asset(
                'assets/logo.png',
                height: 100,
                width: 100,
              ),

              SizedBox(height: 20),

              CustomTextField(
                hintText: "Enter Name",
                onsave: (v) => _formData['name'] = v!,
                validate: (v) => UValidator.validateEmptyText("Name", v),
              ),

              CustomTextField(
                hintText: "Enter Phone",
                keyboardtype: TextInputType.phone,
                onsave: (v) => _formData['phone'] = v!,
                validate: (v) => UValidator.validatePhoneNumber(v),
              ),

              CustomTextField(
                hintText: "Enter Email",
                keyboardtype: TextInputType.emailAddress,
                onsave: (v) => _formData['email'] = v!,
                validate: (v) => UValidator.validateEmail(v),
              ),

              CustomTextField(
                hintText: "Enter Guardian Email",
                keyboardtype: TextInputType.emailAddress,
                onsave: (v) => _formData['guardianEmail'] = v!,
                validate: (v) => UValidator.validateEmail(v),
              ),

              CustomTextField(
                hintText: "Enter Password",
                isPassword: isPasswordHidden,
                onsave: (v) => _formData['password'] = v!,
                validate: (v) => UValidator.validatePassword(v),
                suffix: IconButton(
                  icon: Icon(isPasswordHidden
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                ),
              ),

              CustomTextField(
                hintText: "Retype Password",
                isPassword: isRetypeHidden,
                onsave: (v) => _formData['repassword'] = v!,
                validate: (v) => UValidator.validatePassword(v),
                suffix: IconButton(
                  icon: Icon(isRetypeHidden
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      isRetypeHidden = !isRetypeHidden;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),

              PrimaryButton(
                title: "REGISTER",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
              ),

              TextButton(
                onPressed: () {
                  goTo(context, ChildLoginScreen());
                },
                child: Text("Already have account? Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}