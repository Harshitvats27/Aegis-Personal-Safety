import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../db/db_services.dart';
import '../../models/contactsm.dart';
import '../../utils/constants/constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  // 🔥 Fetch Contacts
  Future<void> fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> _contacts =
      await FlutterContacts.getContacts(withProperties: true);

      setState(() {
        contacts = _contacts;
        contactsFiltered = _contacts;
      });

      searchController.addListener(() {
        filterContact();
      });
    } else {
      dialogueBox(context, "Permission denied");
    }
  }

  // 🔥 Filter Logic
  void filterContact() {
    String query = searchController.text.toLowerCase();

    List<Contact> filtered = contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phone = contact.phones.isNotEmpty
          ? contact.phones.first.number
          : "";

      return name.contains(query) || phone.contains(query);
    }).toList();

    setState(() {
      contactsFiltered = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      body: contacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Search Contact",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: contactsFiltered.length,
                itemBuilder: (context, index) {
                  Contact contact = contactsFiltered[index];

                  return ListTile(
                    title: Text(contact.displayName),
                    leading: contact.photo != null
                        ? CircleAvatar(
                      backgroundColor: kColorRed,
                      backgroundImage:
                      MemoryImage(contact.photo!),
                    )
                        : CircleAvatar(
                      backgroundColor: kColorRed,
                      child: Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0]
                            : "?",
                      ),
                    ),
                    onTap: () {
                      if (contact.phones.isNotEmpty) {
                        final phoneNum =
                            contact.phones.first.number;
                        final name = contact.displayName;

                        _addContact(TContact(phoneNum, name));
                      } else {
                        Fluttertoast.showToast(
                            msg:
                            "No phone number found for this contact");
                      }
                    },
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
    Navigator.of(context).pop(true);
  }
}