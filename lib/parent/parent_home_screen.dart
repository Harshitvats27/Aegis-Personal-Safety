import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat_module/chat_screen.dart';
import '../child/child_login_screen.dart';
import '../controller/parent_controller.dart';
import '../utils/constants/constants.dart';

class ParentHomeScreen extends StatelessWidget {
  ParentHomeScreen({super.key});

  final ParentController _controller = ParentController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Container()),
            ListTile(
              title: TextButton(
                onPressed: () async {
                  try {
                    await _controller.logout();
                    goTo(context, ChildLoginScreen());
                  } catch (e) {
                    dialogueBox(context, e.toString());
                  }
                },
                child: Text("SIGN OUT"),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text("SELECT CHILD"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.getChildren(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: progressIndicator(context));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No children found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final d = snapshot.data!.docs[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Color.fromARGB(255, 250, 163, 192),
                  child: ListTile(
                    onTap: () {
                      goTo(
                          context,
                          ChatScreen(
                              currentUserId:
                              FirebaseAuth.instance.currentUser!.uid,
                              friendId: d.id,
                              friendName: d['name']));
                      // Navigator.push(context, MaterialPa)
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(d['name'] ?? "No Name"),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}