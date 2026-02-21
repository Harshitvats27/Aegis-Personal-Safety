import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety/child/bottom_page.dart';
import 'package:women_safety/home_screen.dart';
import 'package:women_safety/parent/parent_home_screen.dart';

import 'child/child_login_screen.dart';
import 'db/share_pref.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MySharedPrefference.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    String userType = MySharedPrefference.getUserType();

    Widget startScreen;

    if (userType == "child") {
      startScreen = BottomPage();
    } else if (userType == "parent") {
      startScreen = ParentHomeScreen();
    } else {
      startScreen = ChildLoginScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Women Safety',
      theme: ThemeData(
        textTheme: GoogleFonts.firaSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: startScreen,
    );
  }
}