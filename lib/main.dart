import 'package:firebase_auth/firebase_auth.dart'; // 🔥 Import kiya auth streaming ke liye
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shake/shake.dart';
import 'package:women_safety/child/bottom_page.dart';
import 'package:women_safety/parent/parent_home_screen.dart';
import 'package:women_safety/services/SOSService.dart';

import 'child/child_login_screen.dart';
import 'db/share_pref.dart';
import 'firebase_options.dart';

late ShakeDetector _globalShakeDetector;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _globalShakeDetector = ShakeDetector.autoStart(
    onPhoneShake: () async {
      print("Global Shake Detected");
      SOSService.triggerSOS();
    },
    shakeThresholdGravity: 5,
    shakeSlopTimeMS: 500,
    shakeCountResetTime: 3000,
    minimumShakeCount: 2,
  );

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aegis',

      // 1️⃣ LIGHT MODE THEME
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        textTheme: GoogleFonts.firaSansTextTheme(
          ThemeData.light().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),

      // 2️⃣ DARK MODE THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1A1216),
        textTheme: GoogleFonts.firaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2A1B22),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),

      themeMode: ThemeMode.system,

      // 🔥 AUTO-LOGIN BACKEND STREAM BUFFER PIPELINE
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Firebase jab tak secure channel boot up kar raha h
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.pink)),
            );
          }

          // 2. Agar user authenticated h (Firebase session active h)
          if (snapshot.hasData && snapshot.data != null) {
            String userType = MySharedPrefference.getUserType();

            if (userType == "child") {
              return const BottomPage();
            } else if (userType == "parent") {
              return ParentHomeScreen();
            } else {
              return const ChildLoginScreen();
            }
          }

          // 3. Agar token nahi mila ya logout kar diya tha, toh direct Login Screen
          return const ChildLoginScreen();
        },
      ),
    );
  }
}