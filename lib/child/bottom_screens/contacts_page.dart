import 'dart:io'; // Platform identify karne ke liye
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../db/db_services.dart';
import '../../models/contactsm.dart';
import '../../utils/constants/constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> allPhoneContacts = [];
  List<Contact> contactsFiltered = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  // 🔥 Fetch Contacts
  Future<void> fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> fetchedList = await FlutterContacts.getContacts(
        withProperties: true,
      );

      setState(() {
        allPhoneContacts = fetchedList;
        contactsFiltered = fetchedList;
      });

      searchController.addListener(() {
        filterContact();
      });
    } else {
      Fluttertoast.showToast(msg: "Permission denied by user");
    }
  }

  // 🔥 Filter Logic
  void filterContact() {
    String query = searchController.text.toLowerCase();

    List<Contact> filtered = allPhoneContacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phone = contact.phones.isNotEmpty
          ? contact.phones.first.number.replaceAll(RegExp(r'\s+'), "")
          : "";

      return name.contains(query) || phone.contains(query);
    }).toList();

    setState(() {
      contactsFiltered = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dynamicTextColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      // 🔥 FIX 1: Yeh line piche ka poora page main.dart ke background color se match kar degi!
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: allPhoneContacts.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : SafeArea(
              child: Column(
                children: [
                  // 🔥 PREMIUM SEARCH BAR (Matches theme completely)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(color: dynamicTextColor),
                      decoration: InputDecoration(
                        labelText: "Search Contact",
                        labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                        prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
                        filled: true,
                        // Theme ke card color ka subtle tint uthayega background ke liye
                        fillColor: Theme.of(context).cardTheme.color?.withOpacity(0.6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),

                  // 🔥 CONTACTS LISTVIEW
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: contactsFiltered.length,
                      itemBuilder: (context, index) {
                        Contact contact = contactsFiltered[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            // Tile ke peeche ka background card theme se match karega (Light me white, Dark me dark purple-grey)
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: Text(
                              contact.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: dynamicTextColor, // Dynamic Color Working
                              ),
                            ),
                            leading: contact.photo != null
                                ? CircleAvatar(
                                    backgroundColor: Colors.pinkAccent,
                                    backgroundImage: MemoryImage(contact.photo!),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.pink.shade100,
                                    child: Text(
                                      contact.displayName.isNotEmpty
                                          ? contact.displayName[0].toUpperCase()
                                          : "?",
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.pink.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            onTap: () {
                              if (contact.phones.isNotEmpty) {
                                final phoneNum = contact.phones.first.number;
                                final name = contact.displayName;

                                _addContact(TContact(phoneNum, name));
                              } else {
                                Fluttertoast.showToast(
                                  msg: "No phone number found for this contact",
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _addContact(TContact newContact) async {
    int result = await _databaseHelper.insertContact(newContact);
    if (result != 0) {
      Fluttertoast.showToast(msg: "Contact added successfully");
    } else {
      Fluttertoast.showToast(msg: "Failed to add contact");
    }
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }
}