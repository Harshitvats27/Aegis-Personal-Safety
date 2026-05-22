import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
 // 🔥 Path sahi kiya (Check if it matches your project structure)
import '../home_screen.dart';
import 'bottom_screens/add_contacts.dart';
import 'bottom_screens/profile_page.dart'; // 🔥 Yeh file ek baar project directory me re-check kar lena laadle

class BottomPage extends StatefulWidget {
  const BottomPage({super.key});

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _navBarKey = GlobalKey();

  // Pages list matching items length (Strictly checked to be 3)
  final List<Widget> pages = [
    const HomeScreen(),
    const AddContactsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop(); // Direct safe system kill handler
      },
      child: Scaffold(
        // 🔥 FIX 1: Hardcoded Colors.grey[50] hataya taaki background light pink ya dark berry automatic ho jaye!
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),

        // 🔥 HIGHLY PREMIUM CURVED FLUID ANIMATED NAV BAR
        bottomNavigationBar: CurvedNavigationBar(
          key: _navBarKey,
          index: currentIndex,
          height: 60.0,
          items: const <Widget>[
            Icon(Icons.home_rounded, size: 28, color: Colors.white),
            Icon(Icons.contacts_rounded, size: 28, color: Colors.white),
            Icon(Icons.person_rounded, size: 28, color: Colors.white),
          ],
          color: Colors.pink,
          buttonBackgroundColor: Colors.pinkAccent,
          // 🔥 FIX 2: Dark mode me curved bar ke peeche ajeeb white patch na dikhe, isliye transparent ya scaffold color kiya
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}