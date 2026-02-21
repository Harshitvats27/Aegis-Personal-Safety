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
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return ProfilePage();
          } else {
            Fluttertoast.showToast(msg: 'please login first');
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

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameC = TextEditingController();
  TextEditingController guardianEmailC = TextEditingController();
  TextEditingController childEmailC = TextEditingController();
  TextEditingController phoneC = TextEditingController();

  final key = GlobalKey<FormState>();
  String? id;
  String? profilePic;
  String? downloadUrl;
  bool isSaving = false;
  getDate() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        nameC.text = value.docs.first['name'];
        childEmailC.text = value.docs.first['childEmail'];
        guardianEmailC.text = value.docs.first['guardianEmail'];
        phoneC.text = value.docs.first['phone'];
        id = value.docs.first.id;
        profilePic = value.docs.first['profilePic'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isSaving == true
          ? Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.pink,
          ))
          : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Form(
                  key: key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "UPDATE YOUR PROFILE",
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          final XFile? pickImage = await ImagePicker()
                              .pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 50);
                          if (pickImage != null) {
                            setState(() {
                              profilePic = pickImage.path;
                            });
                          }
                        },
                        child: Container(
                          child: profilePic == null
                              ? CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            radius: 80,
                            child: Center(
                                child: Image.asset(
                                  'assets/add_pic.png',
                                  height: 80,
                                  width: 80,
                                )),
                          )
                              : profilePic!.contains('http')
                              ? CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            radius: 80,
                            backgroundImage:
                            NetworkImage(profilePic!),
                          )
                              : CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              radius: 80,
                              backgroundImage:
                              FileImage(File(profilePic!))),
                        ),
                      ),
                      CustomTextField(
                        controller: nameC,
                        keyboardtype: TextInputType.text,
                        hintText: nameC.text,
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'please enter your updated name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: childEmailC,
                        keyboardtype: TextInputType.emailAddress,
                        hintText: "child email",
                        readOnly: true,
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'please enter your updated name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: guardianEmailC,
                        hintText: "parent email",
                        keyboardtype: TextInputType.phone,
                        readOnly: true,
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'please enter your updated name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: phoneC,
                        hintText: "Phone number",
                        readOnly: true,
                        validate: (v) {
                          if (v!.isEmpty) {
                            return 'please enter your updated name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 25),
                      PrimaryButton(
                          title: "UPDATE",
                          onPressed: () async {
                            if (key.currentState!.validate()) {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              profilePic == null
                                  ? Fluttertoast.showToast(
                                  msg: 'please select profile picture')
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
    final ref =
    FirebaseStorage.instance.ref('profile').child(fileName);

    await ref.putFile(File(filePath));

    return await ref.getDownloadURL();
  }
  Future<void> update() async {
    setState(() {
      isSaving = true;
    });

    try {
      String? imageUrl = profilePic;

      // 👉 Agar nayi image select ki hai (local file)
      if (profilePic != null && !profilePic!.startsWith("http")) {
        imageUrl = await uploadImage(profilePic!);
      }

      Map<String, dynamic> data = {
        'name': nameC.text,
        'profilePic': imageUrl, // old ya new dono handle
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