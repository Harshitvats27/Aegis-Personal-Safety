import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:women_safety/child/child_login_screen.dart';
import '../../utils/constants/constants.dart';
import '../../widgets/components/PrimaryButton.dart';
import '../../widgets/components/custom_textfield.dart';
import '../bottom_page.dart';

class CheckUserStatusBeforeChatOnProfile extends StatelessWidget {
  const CheckUserStatusBeforeChatOnProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasData) {
            return const ProfilePage();
          } else {
            return ChildLoginScreen();
          }
        }
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  TextEditingController nameC = TextEditingController();
  TextEditingController guardianEmailC = TextEditingController();
  TextEditingController childEmailC = TextEditingController();
  TextEditingController phoneC = TextEditingController();

  final key = GlobalKey<FormState>();
  String? id;
  String? profilePic;
  String? downloadUrl;
  bool isSaving = false;

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  getDate() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          nameC.text = value.docs.first['name'] ?? '';
          childEmailC.text = value.docs.first['childEmail'] ?? '';
          guardianEmailC.text = value.docs.first['guardianEmail'] ?? '';
          phoneC.text = value.docs.first['phone'] ?? '';
          id = value.docs.first.id;
          profilePic = value.docs.first['profilePic'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDate();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 3.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameC.dispose();
    guardianEmailC.dispose();
    childEmailC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Dynamic Theme Setup
    final dynamicTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Hardcoded white/grey bg removed to match your main.dart background colors
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: dynamicTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: dynamicTextColor),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                try {
                  await FirebaseAuth.instance.signOut();
                  Fluttertoast.showToast(msg: "Logged out successfully");

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => ChildLoginScreen()),
                          (route) => false,
                    );
                  }
                } catch (e) {
                  Fluttertoast.showToast(msg: "Error signing out: $e");
                }
              }
            },
            icon: Icon(Icons.more_vert, size: 28, color: dynamicTextColor),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: isSaving == true
          ? const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.pink,
          ))
          : SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Center(
              child: Form(
                  key: key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.2),
                                  blurRadius: _pulseAnimation.value,
                                  spreadRadius: _pulseAnimation.value / 2,
                                )
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final XFile? pickImage = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery, imageQuality: 50);
                                if (pickImage != null) {
                                  setState(() {
                                    profilePic = pickImage.path;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF2A1B22) : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: profilePic == null
                                    ? const CircleAvatar(
                                  backgroundColor: Colors.pinkAccent,
                                  radius: 75,
                                  child: Center(
                                    child: Icon(Icons.person, size: 70, color: Colors.white),
                                  ),
                                )
                                    : profilePic!.contains('http')
                                    ? CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  radius: 75,
                                  backgroundImage: NetworkImage(profilePic!),
                                )
                                    : CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  radius: 75,
                                  backgroundImage: FileImage(File(profilePic!)),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Colors.pink,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                    ]),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Profile Information",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : Colors.black54
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: nameC,
                        keyboardtype: TextInputType.text,
                        hintText: "Enter your name",
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'please enter your updated name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: childEmailC,
                        keyboardtype: TextInputType.emailAddress,
                        hintText: "child email",
                        readOnly: true,
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'field cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: guardianEmailC,
                        hintText: "parent email",
                        keyboardtype: TextInputType.emailAddress,
                        readOnly: true,
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'field cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: phoneC,
                        hintText: "Phone number",
                        readOnly: true,
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'field cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 35),
                      PrimaryButton(
                          title: "UPDATE PROFILE",
                          onPressed: () async {
                            if (key.currentState!.validate()) {
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
                              profilePic == null
                                  ? Fluttertoast.showToast(msg: 'please select profile picture')
                                  : update();
                            }
                          })
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> uploadImage(String filePath) async {
    final fileName = Uuid().v4();
    final ref = FirebaseStorage.instance.ref('profile').child(fileName);
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  Future<void> update() async {
    setState(() {
      isSaving = true;
    });

    try {
      String? imageUrl = profilePic;

      if (profilePic != null && !profilePic!.startsWith("http")) {
        imageUrl = await uploadImage(profilePic!);
      }

      Map<String, dynamic> data = {
        'name': nameC.text,
        'profilePic': imageUrl,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(data);

      Fluttertoast.showToast(msg: "Profile Updated");
      goTo(context, BottomPage());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() {
      isSaving = false;
    });
  }
}