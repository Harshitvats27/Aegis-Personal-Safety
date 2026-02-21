import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety/parent/parent_home_screen.dart';
import '../home_screen.dart';
import '../widgets/components/fab_bar_bottom.dart';
import 'bottom_screens/add_contacts.dart';
import 'bottom_screens/contacts_page.dart';

class BottomPage extends StatefulWidget {
  BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
   AddContactsPage(),
    // CheckUserStatusBeforeChat(),
    // ReviewPage(),
    // // CheckUserStatusBeforeChatOnProfile(),
    // SettingsPage()
    // // ReviewPage(),,
    ParentHomeScreen(),
    ParentHomeScreen(),
    ParentHomeScreen(),
  ];
  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: DefaultTabController(
          initialIndex: currentIndex,
          length: pages.length,
          child: Scaffold(
              body: pages[currentIndex],
              bottomNavigationBar: FABBottomAppBar(
                onTabSelected: onTapped,
                items: [
                  FABBottomAppBarItem(iconData: Icons.home, text: "home"),
                  FABBottomAppBarItem(
                      iconData: Icons.contacts, text: "contacts"),
                  FABBottomAppBarItem(iconData: Icons.chat, text: "chat"),
                  FABBottomAppBarItem(
                      iconData: Icons.rate_review, text: "Ratings"),
                  FABBottomAppBarItem(
                      iconData: Icons.settings, text: "Settings"),
                ],
              )),
        ));
  }
}